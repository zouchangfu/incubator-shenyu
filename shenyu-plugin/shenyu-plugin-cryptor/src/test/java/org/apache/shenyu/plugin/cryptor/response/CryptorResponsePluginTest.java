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

package org.apache.shenyu.plugin.cryptor.response;

import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.dto.RuleData;
import org.apache.shenyu.common.dto.SelectorData;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.plugin.api.ShenyuPluginChain;
import org.apache.shenyu.plugin.cryptor.decorator.ResponseDecorator;
import org.apache.shenyu.plugin.cryptor.handler.CryptorResponsePluginDataHandler;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.junit.MockitoJUnitRunner;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.codec.ServerCodecConfigurer;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.net.InetSocketAddress;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.mock;

/**
 * Test case for {@link CryptorResponsePlugin}.
 */
@RunWith(MockitoJUnitRunner.class)
public class CryptorResponsePluginTest {

    private RuleData ruleData;

    private ShenyuPluginChain chain;

    private ServerWebExchange exchange;

    private CryptorResponsePlugin cryptorResponsePlugin;

    private CryptorResponsePluginDataHandler cryptorResponsePluginDataHandler;

    private SelectorData selectorData;

    @Before
    public void setUp() {
        this.ruleData = new RuleData();
        this.ruleData.setSelectorId("test");
        this.ruleData.setName("test-cryptor-response-plugin");
        this.ruleData.setHandle("{\"strategyName\":\"rsa\","
                + "\"key\":\"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALa36JRlLS4WVUqXeS/6AF2xlvUZ+eJg/ejcrlrMafygrHA6HhUnDe"
                + "7knNy8CpNeMKwuF9Pn0g8ZtJDD074DQcsCAwEAAQ\\u003d\\u003d\","
                + "\"fieldNames\":\"data\"}");
        this.cryptorResponsePluginDataHandler = new CryptorResponsePluginDataHandler();
        this.chain = mock(ShenyuPluginChain.class);
        this.selectorData = mock(SelectorData.class);
        this.cryptorResponsePlugin = new CryptorResponsePlugin();
        MockServerHttpRequest request = MockServerHttpRequest
                .post("/test")
                .remoteAddress(new InetSocketAddress(8090))
                .header(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .body("{\"code\":200,\"msg\":\"success\",\"data\":[\"test\"]}");
        this.exchange = spy(MockServerWebExchange.from(request));
    }

    @Test
    public void doExecuteTest() {
        ServerWebExchange.Builder builder = mock(ServerWebExchange.Builder.class);
        when(exchange.mutate()).thenReturn(builder);
        when(builder.response(any(ResponseDecorator.class))).thenReturn(builder);
        when(builder.build()).thenReturn(exchange);
        when(chain.execute(any())).thenReturn(Mono.empty());
        cryptorResponsePluginDataHandler.handlerRule(ruleData);
        ServerWebExchange exchangeNormal = generateServerWebExchange();
        Mono<Void> result = cryptorResponsePlugin.doExecute(exchangeNormal, chain, selectorData, ruleData);
        StepVerifier.create(result).expectSubscription().verifyComplete();
    }

    @Test
    public void namedTest() {
        final String result = cryptorResponsePlugin.named();
        assertEquals(PluginEnum.CRYPTOR_RESPONSE.getName(), result);
    }

    @Test
    public void getOrderTest() {
        final int result = cryptorResponsePlugin.getOrder();
        assertEquals(PluginEnum.CRYPTOR_RESPONSE.getCode(), result);
    }

    private ServerWebExchange generateServerWebExchange() {
        ClientResponse.Builder builder;
        builder = ClientResponse.create(HttpStatus.OK, ServerCodecConfigurer.create().getReaders());
        ClientResponse clientResponse = builder.body(Flux.from(exchange.getRequest().getBody())).build();
        exchange.getAttributes().put(Constants.CLIENT_RESPONSE_ATTR, clientResponse);
        return this.exchange;
    }
}
