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

package org.apache.shenyu.plugin.cryptor.strategy;

import org.apache.shenyu.spi.ExtensionLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The type Cryptor strategy factory.
 */
public class CryptorStrategyFactory {
    
    private static final Logger LOG = LoggerFactory.getLogger(CryptorStrategyFactory.class);
    
    /**
     * New instance cryptor strategy.
     *
     * @param strategyName the strategy name
     * @return the cryptor strategy
     */
    public static CryptorStrategy newInstance(final String strategyName) {
        return ExtensionLoader.getExtensionLoader(CryptorStrategy.class).getJoin(strategyName);
    }
    
    /**
     * Encrypt string.
     *
     * @param strategyName the strategy name
     * @param key the key
     * @param encryptData the encrypt data
     * @return the string
     */
    public static String encrypt(final String strategyName, final String key, final String encryptData) {
        try {
            return newInstance(strategyName).encrypt(key, encryptData);
        } catch (Exception e) {
            LOG.error("encrypt data error: ", e);
            return null;
        }
    }
    
    /**
     * Decrypt string.
     *
     * @param strategyName the strategy name
     * @param key the key
     * @param encryptData the encrypt data
     * @return the string
     */
    public static String decrypt(final String strategyName, final String key, final String encryptData) {
        try {
            return newInstance(strategyName).decrypt(key, encryptData);
        } catch (Exception e) {
            LOG.error("decrypt data error: ", e);
            return null;
        }
    }
}
