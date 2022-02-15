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

package org.apache.shenyu.plugin.sync.data.websocket.handler;

import com.google.gson.Gson;
import org.apache.shenyu.common.dto.ConditionData;
import org.apache.shenyu.common.dto.SelectorData;
import org.apache.shenyu.sync.data.api.PluginDataSubscriber;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.Is.is;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

public final class SelectorDataHandlerTest {

    private final PluginDataSubscriber subscriber;

    private final SelectorDataHandler selectorDataHandler;

    public SelectorDataHandlerTest() {
        subscriber = mock(PluginDataSubscriber.class);
        selectorDataHandler = new SelectorDataHandler(subscriber);
    }

    @Test
    public void testConvert() {
        List<SelectorData> selectorDataList = new LinkedList<>();
        ConditionData conditionData = new ConditionData();
        conditionData.setParamName("conditionName-" + 0);
        List<ConditionData> conditionDataList = Collections.singletonList(conditionData);
        selectorDataList.add(SelectorData.builder().name("name1").enabled(true).conditionList(conditionDataList).build());
        selectorDataList.add(SelectorData.builder().name("name2").build());
        Gson gson = new Gson();
        String json = gson.toJson(selectorDataList);
        List<SelectorData> convertedList = selectorDataHandler.convert(json);
        assertThat(convertedList, is(selectorDataList));
    }

    @Test
    public void testDoRefresh() {
        List<SelectorData> selectorDataList = createFakeSelectorDataObjects(3);
        selectorDataHandler.doRefresh(selectorDataList);
        verify(subscriber).refreshSelectorDataSelf(selectorDataList);
        selectorDataList.forEach(verify(subscriber)::onSelectorSubscribe);
    }

    @Test
    public void testDoUpdate() {
        List<SelectorData> selectorDataList = createFakeSelectorDataObjects(4);
        selectorDataHandler.doUpdate(selectorDataList);
        selectorDataList.forEach(verify(subscriber)::onSelectorSubscribe);
    }

    @Test
    public void testDoDelete() {
        List<SelectorData> selectorDataList = createFakeSelectorDataObjects(3);
        selectorDataHandler.doDelete(selectorDataList);
        selectorDataList.forEach(verify(subscriber)::unSelectorSubscribe);
    }

    private List<SelectorData> createFakeSelectorDataObjects(final int count) {
        List<SelectorData> result = new LinkedList<>();
        for (int i = 1; i <= count; i++) {
            result.add(SelectorData.builder().name("name-" + i).build());
        }
        return result;
    }
}
