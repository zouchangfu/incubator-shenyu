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

package org.apache.shenyu.register.server.consul;

import com.ecwid.consul.v1.kv.model.GetValue;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.common.utils.GsonUtils;
import org.apache.shenyu.register.common.dto.MetaDataRegisterDTO;
import org.apache.shenyu.register.common.dto.URIRegisterDTO;
import org.apache.shenyu.register.common.enums.EventType;
import org.apache.shenyu.register.server.api.ShenyuServerRegisterPublisher;
import org.junit.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.event.HeartbeatEvent;
import org.springframework.cloud.consul.discovery.ConsulDiscoveryClient;
import org.springframework.context.annotation.Bean;

import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;

public class ConsulServerRegisterRepositoryTest {

    private ShenyuServerRegisterPublisher mockPublish() {
        ShenyuServerRegisterPublisher publisher = Mockito.mock(ShenyuServerRegisterPublisher.class);
        Mockito.doNothing().when(publisher).publish(any());
        return publisher;
    }

    @Bean
    private ConsulDiscoveryClient mockConsulClient() {
        ServiceInstance serviceInstance = Mockito.mock(ServiceInstance.class);
        Map<String, String> map = new HashMap<>();
        URIRegisterDTO mockServer = URIRegisterDTO.builder().appName("mockServer").contextPath("/mockServer").eventType(EventType.REGISTER).build();
        map.put("uri", GsonUtils.getInstance().toJson(mockServer));
        Mockito.when(serviceInstance.getMetadata()).thenReturn(map);
        ConsulDiscoveryClient client = Mockito.mock(ConsulDiscoveryClient.class);
        Mockito.when(client.getAllInstances()).thenReturn(Collections.singletonList(serviceInstance));
        return client;
    }

    @Bean
    private ConsulServerRegisterRepository mockConsulServerRegisterRepository() throws Exception {
        ConsulServerRegisterRepository consulServerRegisterRepository = new ConsulServerRegisterRepository();
        Class<? extends ConsulServerRegisterRepository> clazz = consulServerRegisterRepository.getClass();

        String fieldClientString = "discoveryClient";
        Field fieldClient = clazz.getDeclaredField(fieldClientString);
        fieldClient.setAccessible(true);
        fieldClient.set(consulServerRegisterRepository, mockConsulClient());

        String fieldPublisherString = "publisher";
        Field fieldPublisher = clazz.getDeclaredField(fieldPublisherString);
        fieldPublisher.setAccessible(true);
        fieldPublisher.set(consulServerRegisterRepository, mockPublish());
        return consulServerRegisterRepository;
    }

    @Test
    public void testConsulServerRegisterRepository() {
        new ApplicationContextRunner().withUserConfiguration(ConsulServerRegisterRepositoryTest.class)
                .run(context -> {
                    context.publishEvent(new HeartbeatEvent(this, 1L));
                    MetaDataRegisterDTO mockServer = MetaDataRegisterDTO.builder().appName("mockServer").contextPath("/mock")
                            .host("127.0.0.1").rpcType(RpcTypeEnum.DUBBO.getName()).build();
                    Map<String, GetValue> mateData = new HashMap<>();
                    GetValue getValue = new GetValue();
                    getValue.setValue(Base64.getEncoder().encodeToString(GsonUtils.getInstance().toJson(mockServer).getBytes(StandardCharsets.UTF_8)));
                    getValue.setCreateIndex(1L);
                    mateData.put("/mock", getValue);
                    ConsulConfigChangedEvent consulConfigChangedEvent = new ConsulConfigChangedEvent(this, 1L, mateData);
                    context.publishEvent(consulConfigChangedEvent);
                });

    }
}
