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

package org.apache.shenyu.plugin.global;

import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.dto.MetaData;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.plugin.api.context.ShenyuContext;
import org.apache.shenyu.plugin.api.context.ShenyuContextBuilder;
import org.apache.shenyu.plugin.api.context.ShenyuContextDecorator;
import org.apache.shenyu.plugin.global.cache.MetaDataCache;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.web.server.ServerWebExchange;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

/**
 * The type Default Shenyu context builder.
 */
public class DefaultShenyuContextBuilder implements ShenyuContextBuilder {

    private static final Logger LOG = LoggerFactory.getLogger(GlobalPlugin.class);

    private static final String RPC_TYPE = "rpc_type";

    private static final String UPGRADE = "Upgrade";

    private final Map<String, ShenyuContextDecorator> decoratorMap;

    /**
     * Instantiates a new Default shenyu context builder.
     *
     * @param decoratorMap the decorator map
     */
    public DefaultShenyuContextBuilder(final Map<String, ShenyuContextDecorator> decoratorMap) {
        this.decoratorMap = decoratorMap;
    }

    @Override
    public ShenyuContext build(final ServerWebExchange exchange) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();
        // 根据路径获取元数据
        // 通过路径匹配到的元数据来断定当前请求的类型，如果没有获取到元数据类型的话，默认后续是通过divide插件构建请求地址
        // 这个元数据在可以在管理端中的 元数据管理 中进行配置
        MetaData metaData = MetaDataCache.getInstance().obtain(path);
        HttpHeaders headers = request.getHeaders();
        String upgrade = headers.getFirst(UPGRADE);
        String rpcType;
        if (Objects.nonNull(metaData) && Boolean.TRUE.equals(metaData.getEnabled())) {
            exchange.getAttributes().put(Constants.META_DATA, metaData);
            rpcType = metaData.getRpcType();
        } else if (StringUtils.isNotEmpty(upgrade) && RpcTypeEnum.WEB_SOCKET.getName().equals(upgrade)) {
            // websocket 类型
            rpcType = RpcTypeEnum.WEB_SOCKET.getName();
        } else {
            // 前面条件都不符合的话，而且没有携带rpc_type，说明当前请求是普通的Http注册到网关的
            // 如果没有设置到请求头没有携带rpc_type 类型的话，默认就是 http 类型，后续走divide插件
            String rpcTypeParam = request.getHeaders().getFirst(RPC_TYPE);
            rpcType = StringUtils.isEmpty(rpcTypeParam) ? RpcTypeEnum.HTTP.getName() : rpcTypeParam;
        }

        // 根据rpc类型,构建不同的全局上下文Context
        // 这些rpc类是在哪里被初始化的呢？
        // 在插件的starter中，这些类被注入到了Spring容器中，例如：
        // 在SpringCloudPluginConfiguration 可以看到 SpringCloudShenyuContextDecorator 被注入到Spring容器里面了

        // 这些类是怎么被放到 decoratorMap中的呢？
        // 在 GlobalPluginConfiguration 类中，一下代码构建了rpc类的装饰Map集合
        // “Map<String, ShenyuContextDecorator> decoratorMap = decoratorList.stream().collect(Collectors.toMap(ShenyuContextDecorator::rpcType, e -> e));”

        /*
           总体逻辑：
           1、获取rpc类型，这些rpc类型在元数据中保存
           2、根据不同的rpc类型构建不同的全局上下文context
         */
        return decoratorMap.get(rpcType).decorator(buildDefaultContext(request), metaData);
    }

    private ShenyuContext buildDefaultContext(final ServerHttpRequest request) {
        String appKey = request.getHeaders().getFirst(Constants.APP_KEY);
        String sign = request.getHeaders().getFirst(Constants.SIGN);
        String timestamp = request.getHeaders().getFirst(Constants.TIMESTAMP);
        ShenyuContext shenyuContext = new ShenyuContext();
        String path = request.getURI().getPath();
        shenyuContext.setPath(path);
        shenyuContext.setAppKey(appKey);
        shenyuContext.setSign(sign);
        shenyuContext.setTimestamp(timestamp);
        shenyuContext.setStartDateTime(LocalDateTime.now());
        Optional.ofNullable(request.getMethod()).ifPresent(httpMethod -> shenyuContext.setHttpMethod(httpMethod.name()));
        return shenyuContext;
    }
}
