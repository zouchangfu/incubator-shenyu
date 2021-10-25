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

package org.apache.shenyu.plugin.uri;

import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.plugin.api.ShenyuPlugin;
import org.apache.shenyu.plugin.api.ShenyuPluginChain;
import org.apache.shenyu.plugin.api.context.ShenyuContext;
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.Objects;

/**
 * The type Uri plugin.
 */
public class URIPlugin implements ShenyuPlugin {
    
    @Override
    public Mono<Void> execute(final ServerWebExchange exchange, final ShenyuPluginChain chain) {
        ShenyuContext shenyuContext = exchange.getAttribute(Constants.CONTEXT);
        assert shenyuContext != null;
        String path = exchange.getAttribute(Constants.HTTP_DOMAIN);
        String rewriteURI = (String) exchange.getAttributes().get(Constants.REWRITE_URI);
        URI uri = exchange.getRequest().getURI();
        if (StringUtils.isNoneBlank(rewriteURI)) {
            path = path + rewriteURI;
        } else {
            String realUrl = shenyuContext.getRealUrl();
            if (StringUtils.isNoneBlank(realUrl)) {
                path = path + realUrl;
            }
        }
        URI realURI;
        if (StringUtils.isNotEmpty(uri.getRawQuery()) && uri.getRawQuery().contains("%")) {
            path = path + "?" + uri.getRawQuery();
            realURI = UriComponentsBuilder.fromHttpUrl(path).build(true).toUri();
        } else {
            if (StringUtils.isNotEmpty(uri.getQuery())) {
                path = path + "?" + uri.getQuery();
            }
            assert path != null;
            realURI = UriComponentsBuilder.fromHttpUrl(path).build(false).toUri();
        }
        exchange.getAttributes().put(Constants.HTTP_URI, realURI);
        return chain.execute(exchange);
    }
    
    @Override
    public int getOrder() {
        return PluginEnum.URI.getCode();
    }
    
    @Override
    public String named() {
        return PluginEnum.URI.getName();
    }
    
    @Override
    public boolean skip(final ServerWebExchange exchange) {
        ShenyuContext shenyuContext = exchange.getAttribute(Constants.CONTEXT);
        assert shenyuContext != null;
        String rpcType = shenyuContext.getRpcType();
        if (Objects.equals(rpcType, RpcTypeEnum.HTTP.getName())) {
            return false;
        }
        return !Objects.equals(rpcType, RpcTypeEnum.SPRING_CLOUD.getName());
    }
}
