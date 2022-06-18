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

package org.apache.shenyu.admin.model.event.metadata;

import org.apache.shenyu.admin.model.entity.MetaDataDO;
import org.apache.shenyu.admin.model.enums.EventTypeEnum;

/**
 * MetadataUpdatedEvent.
 */
public class MetadataUpdatedEvent extends MetaDataChangedEvent {
    
    
    /**
     * Create a new {@code SelectorChangedEvent}.operator is unknown.
     *
     * @param source   Current selector state
     * @param before   before selector state
     * @param operator operator
     */
    public MetadataUpdatedEvent(final MetaDataDO source, final MetaDataDO before, final String operator) {
        super(source, before, EventTypeEnum.META_DATA_UPDATE, operator);
    }
    
    /**
     * the created metadata.
     *
     * @return metadata
     */
    public MetaDataDO getMetaData() {
        return (MetaDataDO) getSource();
    }
    
}
