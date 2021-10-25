/*
 * Licensed to the Apache Software Foundation (ASF) under one or more contributor license
 * agreements. See the NOTICE file distributed with this work for additional information regarding
 * copyright ownership. The ASF licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a
 * copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 *
 */

package org.apache.shenyu.examples.spring.cloud.dubbo.service.annotation.impl;

import org.apache.dubbo.config.annotation.DubboService;
import org.apache.dubbo.config.annotation.Service;
import org.apache.shenyu.client.dubbo.common.annotation.ShenyuDubboClient;
import org.apache.shenyu.examples.dubbo.api.entity.DubboTest;
import org.apache.shenyu.examples.dubbo.api.entity.ListResp;
import org.apache.shenyu.examples.dubbo.api.service.DubboTestService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.Random;

/**
 * The type Dubbo service.
 */
@DubboService
public class SpringCloudAlibabaDubboTestServiceImpl implements DubboTestService {

    private static final Logger logger = LoggerFactory.getLogger(SpringCloudAlibabaDubboTestServiceImpl.class);

    @Override
    @ShenyuDubboClient(path = "/findById", desc = "Query by Id")
    public DubboTest findById(final String id) {
        DubboTest dubboTest = new DubboTest();
        dubboTest.setId(id);
        dubboTest.setName("hello world shenyu Apache, findById");
        logger.info("==========================================接口被调用===================================");
        return dubboTest;
    }

    @Override
    @ShenyuDubboClient(path = "/findAll", desc = "Get all data")
    public DubboTest findAll() {
        DubboTest dubboTest = new DubboTest();
        dubboTest.setName("hello world shenyu Apache, findAll");
        dubboTest.setId(String.valueOf(new Random().nextInt()));
        return dubboTest;
    }

    @Override
    @ShenyuDubboClient(path = "/insert", desc = "Insert a row of data")
    public DubboTest insert(final DubboTest dubboTest) {
        dubboTest.setName("hello world shenyu Apache Dubbo: " + dubboTest.getName());
        return dubboTest;
    }

    @Override
    @ShenyuDubboClient(path = "/findList", desc = "Find list")
    public ListResp findList() {
        ListResp listResp = new ListResp();
        listResp.setTotal(1);
        listResp.setUsers(Arrays.asList(new DubboTest("1", "test")));
        return listResp;
    }
}
