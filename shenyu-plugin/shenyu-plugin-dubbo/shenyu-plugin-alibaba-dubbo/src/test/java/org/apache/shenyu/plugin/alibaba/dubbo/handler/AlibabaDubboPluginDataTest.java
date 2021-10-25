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

package org.apache.shenyu.plugin.alibaba.dubbo.handler;

import org.apache.shenyu.common.dto.convert.plugin.DubboRegisterConfig;
import org.apache.shenyu.common.dto.MetaData;
import org.apache.shenyu.common.dto.PluginData;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.common.utils.Singleton;
import org.junit.Assert;
import org.junit.Before;
import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.MethodSorters;
import org.mockito.junit.MockitoJUnitRunner;

/**
 * AlibabaDubboPluginDataTest.
 */
@RunWith(MockitoJUnitRunner.class)
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public final class AlibabaDubboPluginDataTest {

    private AlibabaDubboPluginDataHandler alibabaDubboPluginDataHandler;

    private final String registryConfig = "{\"protocol\":\"zookeeper\",\"register\":\"127.0.0.1:2181\"}";

    @Before
    public void setUp() {
        alibabaDubboPluginDataHandler = new AlibabaDubboPluginDataHandler();
        MetaData metaData = new MetaData();
        metaData.setId("1332017966661636096");
        metaData.setAppName("dubbo");
        metaData.setPath("/dubbo/findAll");
        metaData.setServiceName("org.apache.shenyu.test.dubbo.api.service.DubboTestService");
        metaData.setMethodName("findAll");
    }

    @Test
    public void testPluginEnable() {
        PluginData pluginData = new PluginData("", "", registryConfig, "1", true);
        alibabaDubboPluginDataHandler.handlerPlugin(pluginData);
        Assert.assertEquals(Singleton.INST.get(DubboRegisterConfig.class).getRegister(), "127.0.0.1:2181");
    }

    @Test
    public void testPluginDisable() {
        PluginData pluginData = new PluginData("", "", registryConfig, "1", false);
        alibabaDubboPluginDataHandler.handlerPlugin(pluginData);
        Assert.assertNull(Singleton.INST.get(DubboRegisterConfig.class));
    }

    @Test
    public void testPluginNamed() {
        Assert.assertEquals(alibabaDubboPluginDataHandler.pluginNamed(), PluginEnum.DUBBO.getName());
    }
}
