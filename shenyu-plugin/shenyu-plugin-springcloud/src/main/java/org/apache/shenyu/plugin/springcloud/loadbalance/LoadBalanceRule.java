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

package org.apache.shenyu.plugin.springcloud.loadbalance;

import com.netflix.loadbalancer.Server;
import com.netflix.loadbalancer.ZoneAvoidanceRule;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.shenyu.common.dto.convert.selector.SpringCloudSelectorHandle;
import org.apache.shenyu.loadbalancer.cache.UpstreamCacheManager;
import org.apache.shenyu.loadbalancer.entity.Upstream;
import org.apache.shenyu.loadbalancer.factory.LoadBalancerFactory;
import org.apache.shenyu.plugin.springcloud.handler.SpringCloudPluginDataHandler;

import java.util.ArrayList;
import java.util.List;

/**
 * The spring cloud loadbalancer rule.
 */
public class LoadBalanceRule extends ZoneAvoidanceRule {

    @Override
    public Server choose(final Object key) {
        final LoadBalanceKey loadBalanceKey = LoadBalanceKeyHolder.getLoadBalanceKey();
        final List<Server> available = getPredicate().getEligibleServers(getLoadBalancer().getAllServers(), key);
        if (CollectionUtils.isEmpty(available)) {
            return null;
        }
        final SpringCloudSelectorHandle springCloudSelectorHandle = SpringCloudPluginDataHandler.SELECTOR_CACHED.get().obtainHandle(loadBalanceKey.getSelectorId());
        if (!springCloudSelectorHandle.getGray()) {
            return super.choose(key);
        }
        List<Upstream> divideUpstreams = UpstreamCacheManager.getInstance().findUpstreamListBySelectorId(loadBalanceKey.getSelectorId());
        if (CollectionUtils.isEmpty(divideUpstreams)) {
            return super.choose(key);
        }
        //select server from available to choose
        final List<Upstream> choose = new ArrayList<>(available.size());
        for (Server server : available) {
            divideUpstreams.stream()
                    .filter(Upstream::isStatus)
                    .filter(upstream -> upstream.getUrl().equals(server.getHostPort()))
                    .findFirst().ifPresent(choose::add);
        }
        if (CollectionUtils.isEmpty(choose)) {
            return super.choose(key);
        }
        Upstream upstream = LoadBalancerFactory.selector(choose, loadBalanceKey.getLoadBalance(), loadBalanceKey.getIp());
        return available.stream().filter(server -> server.getHostPort().equals(upstream.getUrl())).findFirst().orElse(null);
    }
}
