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

package org.apache.shenyu.admin.service.register;

import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.admin.model.entity.MetaDataDO;
import org.apache.shenyu.admin.model.entity.SelectorDO;
import org.apache.shenyu.admin.service.impl.MetaDataServiceImpl;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.register.common.dto.MetaDataRegisterDTO;
import org.apache.shenyu.register.common.dto.URIRegisterDTO;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import java.util.ArrayList;
import java.util.List;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.BDDMockito.given;

/**
 * Test cases for ShenyuClientRegisterMotanServiceImpl.
 */
@RunWith(MockitoJUnitRunner.Silent.class)
public final class ShenyuClientRegisterMotanServiceImplTest {

    @InjectMocks
    private ShenyuClientRegisterMotanServiceImpl shenyuClientRegisterMotanService;

    @Mock
    private MetaDataServiceImpl metaDataService;

    @Test
    public void rpcType() {
        String rpcType = shenyuClientRegisterMotanService.rpcType();
        Assert.assertEquals(RpcTypeEnum.MOTAN.getName(), rpcType);
    }

    @Test
    public void selectorHandler() {
        MetaDataRegisterDTO metaDataRegisterDTO = MetaDataRegisterDTO.builder().build();
        Assert.assertEquals(StringUtils.EMPTY, shenyuClientRegisterMotanService.selectorHandler(metaDataRegisterDTO));
    }

    @Test
    public void ruleHandler() {
        Assert.assertEquals(StringUtils.EMPTY, shenyuClientRegisterMotanService.ruleHandler());
    }

    @Test
    public void registerMetadata() {
        MetaDataDO metaDataDO = MetaDataDO.builder().build();
        given(metaDataService.findByPath(anyString())).willReturn(metaDataDO);

        MetaDataRegisterDTO metaDataDTO = MetaDataRegisterDTO.builder().build();
        shenyuClientRegisterMotanService.registerMetadata(metaDataDTO);
    }

    @Test
    public void buildHandle() {
        List<URIRegisterDTO> list = new ArrayList<>();
        list.add(URIRegisterDTO.builder().build());
        Assert.assertEquals(StringUtils.EMPTY,
            shenyuClientRegisterMotanService.buildHandle(list, SelectorDO.builder().build()));
    }
}
