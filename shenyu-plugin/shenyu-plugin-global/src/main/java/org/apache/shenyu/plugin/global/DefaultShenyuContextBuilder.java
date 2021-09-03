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
        // 获取请求的URI
        String path = request.getURI().getPath();
        // 根据请求路径获取元数据信息
        MetaData metaData = MetaDataCache.getInstance().obtain(path);
        String rpcType;
        if (Objects.nonNull(metaData) && metaData.getEnabled()) {
            // 把元数据信息记录到请求的属性当中
            exchange.getAttributes().put(Constants.META_DATA, metaData);
            // 根据源数据判断当前请求的请求类型
            rpcType = metaData.getRpcType();
        } else {
            String rpcTypeParam = request.getHeaders().getFirst("rpc_type");
            // 如果元数据为空，默认为Http类型
            rpcType = StringUtils.isEmpty(rpcTypeParam) ? RpcTypeEnum.HTTP.getName() : rpcTypeParam;
        }
        // 从decoratorMap中获取对于的类型处理
        return decoratorMap.get(rpcType).decorator(buildDefaultContext(request), metaData);
    }

    // 把请求的数据设置到 shenyuContext 上下文中
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
