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

package org.apache.shenyu.common.dto.convert.plugin;

import com.google.common.collect.ImmutableSet;
import org.junit.jupiter.api.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.core.Is.is;

/**
 * Test case for TarsRegisterConfigTest.
 */
public class TarsRegisterConfigTest {
    
    @Test
    public void testGetterSetter() {
        TarsRegisterConfig config = new TarsRegisterConfig();
        config.setCorethreads(10);
        config.setThreads(10);
        config.setQueues(2);
        config.setThreadpool("threadPool");
        
        assertThat(config.getCorethreads(), is(10));
        assertThat(config.getThreads(), is(10));
        assertThat(config.getQueues(), is(2));
        assertThat(config.getThreadpool(), is("threadPool"));
    }
    
    @Test
    public void testEqualsAndHashCode() {
        TarsRegisterConfig config1 = new TarsRegisterConfig();
        TarsRegisterConfig config2 = new TarsRegisterConfig();
        
        assertThat(ImmutableSet.of(config1, config2), hasSize(1));
    }
    
}
