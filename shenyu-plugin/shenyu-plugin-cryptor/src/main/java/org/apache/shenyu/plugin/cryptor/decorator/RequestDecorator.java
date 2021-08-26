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

package org.apache.shenyu.plugin.cryptor.decorator;

import org.apache.shenyu.plugin.base.support.CachedBodyOutputMessage;
import org.apache.shenyu.plugin.cryptor.utils.HttpUtil;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequestDecorator;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Flux;
import reactor.util.annotation.NonNull;

/**
 * Build and modify the request class.
 */
public class RequestDecorator extends ServerHttpRequestDecorator {

    private final CachedBodyOutputMessage cachedBodyOutputMessage;

    private final ServerWebExchange exchange;

    public RequestDecorator(final ServerWebExchange exchange,
                            final CachedBodyOutputMessage cachedBodyOutputMessage) {
        super(exchange.getRequest());
        this.cachedBodyOutputMessage = cachedBodyOutputMessage;
        this.exchange = exchange;
    }

    @Override
    @NonNull
    public Flux<DataBuffer> getBody() {
        return cachedBodyOutputMessage.getBody();
    }

    @Override
    @NonNull
    public HttpHeaders getHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.putAll(exchange.getRequest().getHeaders());
        headers.remove(HttpHeaders.CONTENT_LENGTH);
        return HttpUtil.modifiedContentLength(headers);
    }
}
