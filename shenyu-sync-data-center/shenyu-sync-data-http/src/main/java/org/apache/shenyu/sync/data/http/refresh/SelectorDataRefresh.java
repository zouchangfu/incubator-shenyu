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

package org.apache.shenyu.sync.data.http.refresh;

import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.shenyu.common.dto.ConfigData;
import org.apache.shenyu.common.dto.SelectorData;
import org.apache.shenyu.common.enums.ConfigGroupEnum;
import org.apache.shenyu.sync.data.api.PluginDataSubscriber;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * The type Selector data refresh.
 */
public class SelectorDataRefresh extends AbstractDataRefresh<SelectorData> {

    /**
     * logger.
     */
    private static final Logger LOG = LoggerFactory.getLogger(SelectorDataRefresh.class);

    private final PluginDataSubscriber pluginDataSubscriber;

    public SelectorDataRefresh(final PluginDataSubscriber pluginDataSubscriber) {
        this.pluginDataSubscriber = pluginDataSubscriber;
    }

    @Override
    protected JsonObject convert(final JsonObject data) {
        return data.getAsJsonObject(ConfigGroupEnum.SELECTOR.name());
    }

    @Override
    protected ConfigData<SelectorData> fromJson(final JsonObject data) {
        return GSON.fromJson(data, new TypeToken<ConfigData<SelectorData>>() {
        }.getType());
    }

    @Override
    protected boolean updateCacheIfNeed(final ConfigData<SelectorData> result) {
        return updateCacheIfNeed(result, ConfigGroupEnum.SELECTOR);
    }

    @Override
    public ConfigData<?> cacheConfigData() {
        return GROUP_CACHE.get(ConfigGroupEnum.SELECTOR);
    }

    @Override
    protected void refresh(final List<SelectorData> data) {
        if (CollectionUtils.isEmpty(data)) {
            LOG.info("clear all selector cache, old cache");
            data.forEach(pluginDataSubscriber::unSelectorSubscribe);
            pluginDataSubscriber.refreshSelectorDataAll();
        } else {
            // update cache for UpstreamCacheManager
            pluginDataSubscriber.refreshSelectorDataAll();
            data.forEach(pluginDataSubscriber::onSelectorSubscribe);
        }
    }
}
