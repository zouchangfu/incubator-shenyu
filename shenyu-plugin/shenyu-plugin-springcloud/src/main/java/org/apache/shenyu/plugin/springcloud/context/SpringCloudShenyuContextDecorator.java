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

package org.apache.shenyu.plugin.springcloud.context;

import org.apache.shenyu.common.dto.MetaData;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.common.enums.RpcTypeEnum;
import org.apache.shenyu.plugin.api.context.ShenyuContext;
import org.apache.shenyu.plugin.api.context.ShenyuContextDecorator;

/**
 * The type SpringCloud shenyu context decorator.
 */
public class SpringCloudShenyuContextDecorator implements ShenyuContextDecorator {
    
    @Override
    public ShenyuContext decorator(final ShenyuContext shenyuContext, final MetaData metaData) {
        String path = shenyuContext.getPath();
        shenyuContext.setMethod(path);
        shenyuContext.setRealUrl(path);
        shenyuContext.setRpcType(RpcTypeEnum.SPRING_CLOUD.getName());
        shenyuContext.setModule(String.format("%s-%s", PluginEnum.DIVIDE.getName(), shenyuContext.getRpcType()));
        return shenyuContext;
    }
    
    @Override
    public String rpcType() {
        return RpcTypeEnum.SPRING_CLOUD.getName();
    }
}
