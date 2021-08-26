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

package org.apache.shenyu.examples.plugin.ext;

import org.apache.shenyu.common.dto.PluginData;
import org.apache.shenyu.common.dto.RuleData;
import org.apache.shenyu.common.dto.SelectorData;
import org.apache.shenyu.plugin.base.handler.PluginDataHandler;

public class ExtPluginDataHandler implements PluginDataHandler {
    
    /**
     * Handler plugin.
     *
     * @param pluginData the plugin data
     */
    @Override
    public void handlerPlugin(final PluginData pluginData) {
        System.out.println("hello, im extend plugin dataHandler" );
    }
    
    /**
     * Remove plugin.
     *
     * @param pluginData the plugin data
     */
    @Override
    public void removePlugin(final PluginData pluginData) {
        
    }
    
    /**
     * Handler selector.
     *
     * @param selectorData the selector data
     */
    @Override
    public void handlerSelector(final SelectorData selectorData) {
        
    }
    
    /**
     * Remove selector.
     *
     * @param selectorData the selector data
     */
    @Override
    public void removeSelector(final SelectorData selectorData) {
        
    }
    
    /**
     * Handler rule.
     *
     * @param ruleData the rule data
     */
    @Override
    public void handlerRule(final RuleData ruleData) {
        
    }
    
    /**
     * Remove rule.
     *
     * @param ruleData the rule data
     */
    @Override
    public void removeRule(final RuleData ruleData) {
        
    }
    
    /**
     * Plugin named string.
     *
     * @return the string
     */
    @Override
    public String pluginNamed() {
        return "ext";
    }
}
