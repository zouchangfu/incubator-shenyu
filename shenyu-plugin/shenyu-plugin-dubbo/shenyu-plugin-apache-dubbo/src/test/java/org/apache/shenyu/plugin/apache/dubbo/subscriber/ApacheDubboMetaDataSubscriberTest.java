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

package org.apache.shenyu.plugin.apache.dubbo.subscriber;

import org.apache.shenyu.common.dto.MetaData;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;

/**
 * The Test Case For ApacheDubboMetaDataSubscriber.
 */
@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
public final class ApacheDubboMetaDataSubscriberTest {

    private ApacheDubboMetaDataSubscriber apacheDubboMetaDataSubscriber;

    private MetaData metaData;

    @BeforeEach
    public void setUp() {
        apacheDubboMetaDataSubscriber = new ApacheDubboMetaDataSubscriber();
        metaData = new MetaData();
        metaData.setId("1332017966661636096");
        metaData.setAppName("dubbo");
        metaData.setPath("/dubbo/findAll");
        metaData.setServiceName("org.apache.shenyu.test.dubbo.api.service.DubboTestService");
        metaData.setMethodName("findAll");
        metaData.setRpcType(RpcTypeEnum.DUBBO.getName());
        metaData.setRpcExt("{\"group\":\"Group\",\"version\":\"2.7.5\",\"loadbalance\":\"Balance\",\"url\":\"http://192.168.55.113/dubbo\"}");
        metaData.setParameterTypes("parameterTypes");
    }

    @Test
    public void testOnSubscribe() {
        apacheDubboMetaDataSubscriber.onSubscribe(metaData);
        MetaData metaData = MetaData.builder()
                .id("1332017966661636096")
                .appName("dubbo")
                .path("/dubbo/findAll")
                .serviceName("org.apache.shenyu.test.dubbo.api.service.DubboTestService")
                .methodName("findById")
                .rpcType(RpcTypeEnum.DUBBO.getName())
                .rpcExt("{\"group\":\"Group\",\"version\":\"2.7.5\",\"loadbalance\":\"Balance\",\"url\":\"http://192.168.55.113/dubbo\"}")
                .parameterTypes("parameterTypes").build();
        ApacheDubboMetaDataSubscriber apacheDubboMetaDataSubscriberMock = mock(ApacheDubboMetaDataSubscriber.class);
        doNothing().when(apacheDubboMetaDataSubscriberMock).onSubscribe(metaData);
        apacheDubboMetaDataSubscriberMock.onSubscribe(metaData);
        apacheDubboMetaDataSubscriber.unSubscribe(metaData);
    }
}
