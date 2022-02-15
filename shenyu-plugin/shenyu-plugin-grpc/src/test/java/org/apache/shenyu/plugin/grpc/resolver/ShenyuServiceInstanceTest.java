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

package org.apache.shenyu.plugin.grpc.resolver;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * The Test Case For {@link ShenyuServiceInstance}.
 */
@ExtendWith(MockitoExtension.class)
public class ShenyuServiceInstanceTest {

    private ShenyuServiceInstance shenyuServiceInstance;

    @BeforeEach
    public void setUp() {
        shenyuServiceInstance = new ShenyuServiceInstance("localhost", 8080);
    }

    @Test
    public void testWeight() {
        assertEquals(0, shenyuServiceInstance.getWeight());
        shenyuServiceInstance.setWeight(1);
        assertEquals(1, shenyuServiceInstance.getWeight());
    }

    @Test
    public void testStatus() {
        shenyuServiceInstance.setStatus(true);
        assertEquals("true", shenyuServiceInstance.getStatus());
    }
}
