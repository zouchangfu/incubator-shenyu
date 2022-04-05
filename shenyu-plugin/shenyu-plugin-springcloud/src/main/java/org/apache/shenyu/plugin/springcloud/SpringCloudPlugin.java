/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.shenyu.plugin.springcloud;

import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.dto.RuleData;
import org.apache.shenyu.common.dto.SelectorData;
import org.apache.shenyu.common.dto.convert.rule.impl.SpringCloudRuleHandle;
import org.apache.shenyu.common.dto.convert.selector.SpringCloudSelectorHandle;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.plugin.api.ShenyuPluginChain;
import org.apache.shenyu.plugin.api.context.ShenyuContext;
import org.apache.shenyu.plugin.api.result.ShenyuResultEnum;
import org.apache.shenyu.plugin.api.result.ShenyuResultWrap;
import org.apache.shenyu.plugin.api.utils.WebFluxResultUtils;
import org.apache.shenyu.plugin.base.AbstractShenyuPlugin;
import org.apache.shenyu.plugin.base.utils.CacheKeyUtils;
import org.apache.shenyu.plugin.springcloud.handler.SpringCloudPluginDataHandler;
import org.apache.shenyu.plugin.springcloud.loadbalance.LoadBalanceKey;
import org.apache.shenyu.plugin.springcloud.loadbalance.LoadBalanceKeyHolder;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.loadbalancer.LoadBalancerClient;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.Objects;

/**
 * this is springCloud proxy impl.
 */
public class SpringCloudPlugin extends AbstractShenyuPlugin {

    private final LoadBalancerClient loadBalancer;

    /**
     * Instantiates a new Spring cloud plugin.
     *
     * @param loadBalancer the load balancer
     */
    public SpringCloudPlugin(final LoadBalancerClient loadBalancer) {
        this.loadBalancer = loadBalancer;
    }

    @Override
    protected Mono<Void> doExecute(final ServerWebExchange exchange, final ShenyuPluginChain chain, final SelectorData selector,
                                   final RuleData rule) {
        /*
          SpringCloudPlugin 使用负载均衡器根据处理对象的服务id获取服务实例并重建 URI，
          据此 URI 生成真实的 URL，最后设置最终的 url 和超时时间交由插件链下游进行处理。
         */
        if (Objects.isNull(rule)) {
            return Mono.empty();
        }
        final ShenyuContext shenyuContext = exchange.getAttribute(Constants.CONTEXT);
        assert shenyuContext != null;
        // 获取在管理端配置选择器数据
        final SpringCloudSelectorHandle springCloudSelectorHandle = SpringCloudPluginDataHandler.SELECTOR_CACHED.get().obtainHandle(selector.getId());
        // 获取在管理端配置的规则数据
        final SpringCloudRuleHandle ruleHandle = SpringCloudPluginDataHandler.RULE_CACHED.get().obtainHandle(CacheKeyUtils.INST.getKey(rule));
        // 获取serviceId，也就是你springCloud项目配置的 spring.application.name
        String serviceId = springCloudSelectorHandle.getServiceId();
        if (StringUtils.isBlank(serviceId)) {
            Object error = ShenyuResultWrap.error(exchange,
                    ShenyuResultEnum.CANNOT_CONFIG_SPRINGCLOUD_SERVICEID, null);
            return WebFluxResultUtils.result(exchange, error);
        }
        // 获取客户端的来源IP，根据IP做负载均衡
        // 这里负载均衡是借助了 SpringCloud 的 Ribbon 组件来实现的，ShenYu内部不需要自己写实现逻辑
        String ip = Objects.requireNonNull(exchange.getRequest().getRemoteAddress()).getAddress().getHostAddress();
        LoadBalanceKey loadBalanceKey = new LoadBalanceKey(ip, selector.getId(), ruleHandle.getLoadBalance());
        ServiceInstance serviceInstance;
        try {
            LoadBalanceKeyHolder.setLoadBalanceKey(loadBalanceKey);
            // 获取负责均衡实例
            // 注意：在 shenyu-bootstrap的application.yml配置文件中需要把网关注入到Eureka中，并且还需要开启负责均衡
            serviceInstance = loadBalancer.choose(serviceId);
        } finally {
            LoadBalanceKeyHolder.resetLoadBalanceKey();
        }
        if (Objects.isNull(serviceInstance)) {
            Object error = ShenyuResultWrap.error(exchange,
                    ShenyuResultEnum.SPRINGCLOUD_SERVICEID_IS_ERROR, null);
            return WebFluxResultUtils.result(exchange, error);
        }

        // 构建目标服务的URI地址
        URI uri = loadBalancer.reconstructURI(serviceInstance, URI.create(shenyuContext.getRealUrl()));
        // 构建真正的请求地址，最后请求会通过httpclient插件来发起远程调用
        setDomain(uri, exchange);
        //set time out.
        exchange.getAttributes().put(Constants.HTTP_TIME_OUT, ruleHandle.getTimeout());
        /*
           总体思路：
           1、请求匹配到规则
           2、根据服务Id，通过负载均衡组件获取实例
           3、构建真实的请求路径
         */
        return chain.execute(exchange);
    }

    @Override
    public int getOrder() {
        return PluginEnum.SPRING_CLOUD.getCode();
    }

    @Override
    public String named() {
        return PluginEnum.SPRING_CLOUD.getName();
    }

    /**
     * plugin is execute.
     *
     * @param exchange the current server exchange
     * @return default false.
     */
    @Override
    public boolean skip(final ServerWebExchange exchange) {
        return skipExcept(exchange, RpcTypeEnum.SPRING_CLOUD);
    }

    @Override
    protected Mono<Void> handleSelectorIfNull(final String pluginName, final ServerWebExchange exchange, final ShenyuPluginChain chain) {
        return WebFluxResultUtils.noSelectorResult(pluginName, exchange);
    }

    @Override
    protected Mono<Void> handleRuleIfNull(final String pluginName, final ServerWebExchange exchange, final ShenyuPluginChain chain) {
        return WebFluxResultUtils.noRuleResult(pluginName, exchange);
    }

    private void setDomain(final URI uri, final ServerWebExchange exchange) {
        String domain = uri.getScheme() + "://" + uri.getAuthority();
        exchange.getAttributes().put(Constants.HTTP_DOMAIN, domain);
    }
}
