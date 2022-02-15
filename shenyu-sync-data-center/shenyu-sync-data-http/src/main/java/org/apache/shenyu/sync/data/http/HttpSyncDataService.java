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

package org.apache.shenyu.sync.data.http;

import com.google.common.base.Splitter;
import com.google.common.collect.Lists;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.common.concurrent.ShenyuThreadFactory;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.constant.HttpConstants;
import org.apache.shenyu.common.dto.ConfigData;
import org.apache.shenyu.common.enums.ConfigGroupEnum;
import org.apache.shenyu.common.exception.CommonErrorCode;
import org.apache.shenyu.common.exception.ShenyuException;
import org.apache.shenyu.common.utils.FreshBeanHolder;
import org.apache.shenyu.common.utils.GsonUtils;
import org.apache.shenyu.common.utils.ThreadUtils;
import org.apache.shenyu.sync.data.api.AuthDataSubscriber;
import org.apache.shenyu.sync.data.api.MetaDataSubscriber;
import org.apache.shenyu.sync.data.api.PluginDataSubscriber;
import org.apache.shenyu.sync.data.api.SyncDataService;
import org.apache.shenyu.sync.data.http.config.HttpConfig;
import org.apache.shenyu.sync.data.http.refresh.DataRefreshFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.client.OkHttp3ClientHttpRequestFactory;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * HTTP long polling implementation.
 */
public class HttpSyncDataService implements SyncDataService, AutoCloseable {

    /**
     * logger.
     */
    private static final Logger LOG = LoggerFactory.getLogger(HttpSyncDataService.class);

    private static final AtomicBoolean RUNNING = new AtomicBoolean(false);

    /**
     * only use for http long polling.
     */
    private final RestTemplate httpClient;

    private ExecutorService executor;

    private final HttpConfig httpConfig;

    private final List<String> serverList;

    private final DataRefreshFactory factory;

    private final FreshBeanHolder<String, Optional<Object>> accessToken;

    public HttpSyncDataService(final HttpConfig httpConfig, final PluginDataSubscriber pluginDataSubscriber,
                               final List<MetaDataSubscriber> metaDataSubscribers, final List<AuthDataSubscriber> authDataSubscribers) {
        this.httpConfig = httpConfig;
        this.factory = new DataRefreshFactory(pluginDataSubscriber, metaDataSubscribers, authDataSubscribers);
        this.serverList = Lists.newArrayList(Splitter.on(",").split(httpConfig.getUrl()));
        this.httpClient = createRestTemplate(httpConfig);
        this.accessToken = new FreshBeanHolder<>(this::doLogin);
        this.start();
    }

    private RestTemplate createRestTemplate(final HttpConfig httpConfig) {
        OkHttp3ClientHttpRequestFactory factory = new OkHttp3ClientHttpRequestFactory();
        factory.setConnectTimeout(Objects.isNull(httpConfig.getConnectionTimeout()) ? (int) HttpConstants.CLIENT_POLLING_CONNECT_TIMEOUT : httpConfig.getConnectionTimeout());
        factory.setReadTimeout(Objects.isNull(httpConfig.getReadTimeout()) ? (int) HttpConstants.CLIENT_POLLING_READ_TIMEOUT : httpConfig.getReadTimeout());
        factory.setWriteTimeout(Objects.isNull(httpConfig.getWriteTimeout()) ? (int) HttpConstants.CLIENT_POLLING_WRITE_TIMEOUT : httpConfig.getWriteTimeout());
        return new RestTemplate(factory);
    }

    private void start() {
        // It could be initialized multiple times, so you need to control that.
        if (RUNNING.compareAndSet(false, true)) {
            // fetch all group configs.
            this.fetchGroupConfig(ConfigGroupEnum.values());
            int threadSize = serverList.size();
            this.executor = new ThreadPoolExecutor(threadSize, threadSize, 60L, TimeUnit.SECONDS,
                    new LinkedBlockingQueue<>(),
                    ShenyuThreadFactory.create("http-long-polling", true));
            // start long polling, each server creates a thread to listen for changes.
            this.serverList.forEach(server -> this.executor.execute(new HttpLongPollingTask(server)));
        } else {
            LOG.info("shenyu http long polling was started, executor=[{}]", executor);
        }
    }

    private void fetchGroupConfig(final ConfigGroupEnum... groups) throws ShenyuException {
        for (int index = 0; index < this.serverList.size(); index++) {
            String server = serverList.get(index);
            try {
                this.doFetchGroupConfig(server, groups);
                break;
            } catch (ShenyuException e) {
                // no available server, throw exception.
                if (index >= serverList.size() - 1) {
                    throw e;
                }
                LOG.warn("fetch config fail, try another one: {}", serverList.get(index + 1));
            }
        }
    }

    private void doFetchGroupConfig(final String server, final ConfigGroupEnum... groups) {
        StringBuilder params = new StringBuilder();
        for (ConfigGroupEnum groupKey : groups) {
            params.append("groupKeys").append("=").append(groupKey.name()).append("&");
        }
        String url = server + Constants.SHENYU_ADMIN_PATH_CONFIGS_FETCH + "?" + StringUtils.removeEnd(params.toString(), "&");
        LOG.info("request configs: [{}]", url);
        String json;
        try {
            Optional<Object> token = accessToken.apply(server);
            if (!token.isPresent()) {
                throw new ShenyuException("get token from server : [" + server + " ] error");
            }
            HttpHeaders headers = new HttpHeaders();
            headers.set(Constants.X_ACCESS_TOKEN, String.valueOf(token.get()));
            HttpEntity<String> httpEntity = new HttpEntity<>(headers);
            json = this.httpClient.exchange(url, HttpMethod.GET, httpEntity, String.class).getBody();
        } catch (RestClientException e) {
            String message = String.format("fetch config fail from server[%s], %s", url, e.getMessage());
            LOG.warn(message);
            throw new ShenyuException(message, e);
        }
        // update local cache
        boolean updated = this.updateCacheWithJson(json);
        if (updated) {
            LOG.info("get latest configs: [{}]", json);
            return;
        }
        // not updated. it is likely that the current config server has not been updated yet. wait a moment.
        LOG.info("The config of the server[{}] has not been updated or is out of date. Wait for 30s to listen for changes again.", server);
        ThreadUtils.sleep(TimeUnit.SECONDS, 30);
    }

    /**
     * update local cache.
     *
     * @param json the response from config server.
     * @return true: the local cache was updated. false: not updated.
     */
    private boolean updateCacheWithJson(final String json) {
        JsonObject jsonObject = GsonUtils.getGson().fromJson(json, JsonObject.class);
        JsonObject data = jsonObject.getAsJsonObject("data");
        // if the config cache will be updated?
        return factory.executor(data);
    }

    private void doLongPolling(final String server) {
        Optional<Object> token = accessToken.apply(server);
        if (!token.isPresent()) {
            throw new ShenyuException("get token from server : [" + server + " ] error");
        }
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>(8);
        for (ConfigGroupEnum group : ConfigGroupEnum.values()) {
            ConfigData<?> cacheConfig = factory.cacheConfigData(group);
            if (cacheConfig != null) {
                String value = String.join(",", cacheConfig.getMd5(), String.valueOf(cacheConfig.getLastModifyTime()));
                params.put(group.name(), Lists.newArrayList(value));
            }
        }
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        headers.set(Constants.X_ACCESS_TOKEN, String.valueOf(token.get()));
        HttpEntity<MultiValueMap<String, String>> httpEntity = new HttpEntity<>(params, headers);
        String listenerUrl = server + Constants.SHENYU_ADMIN_PATH_CONFIGS_LISTENER;
        LOG.debug("request listener configs: [{}]", listenerUrl);

        JsonArray groupJson;
        try {
            String json = this.httpClient.postForEntity(listenerUrl, httpEntity, String.class).getBody();
            LOG.debug("listener result: [{}]", json);
            groupJson = GsonUtils.getGson().fromJson(json, JsonObject.class).getAsJsonArray("data");
        } catch (RestClientException e) {
            String message = String.format("listener configs fail, server:[%s], %s", server, e.getMessage());
            throw new ShenyuException(message, e);
        }

        if (Objects.nonNull(groupJson)) {
            // fetch group configuration async.
            ConfigGroupEnum[] changedGroups = GsonUtils.getGson().fromJson(groupJson, ConfigGroupEnum[].class);
            if (ArrayUtils.isNotEmpty(changedGroups)) {
                LOG.info("Group config changed: {}", Arrays.toString(changedGroups));
                this.doFetchGroupConfig(server, changedGroups);
            }
        }
    }

    @Override
    public void close() {
        RUNNING.set(false);
        if (Objects.nonNull(executor)) {
            executor.shutdownNow();
            // help gc
            executor = null;
        }
    }

    private Optional<Object> doLogin(final String server) {
        Map<String, Object> loginMap = new HashMap<>(2);
        loginMap.put(Constants.LOGIN_NAME, httpConfig.getUsername());
        loginMap.put(Constants.PASS_WORD, httpConfig.getPassword());
        String param = toQuery(loginMap);
        String url = String.join("?", server + Constants.LOGIN_PATH, param);
        String result = this.httpClient.getForObject(url, String.class);
        Map<String, Object> resultMap = GsonUtils.getInstance().convertToMap(result);
        if (!String.valueOf(CommonErrorCode.SUCCESSFUL).equals(String.valueOf(resultMap.get(Constants.ADMIN_RESULT_CODE)))) {
            return Optional.empty();
        }
        String tokenJson = GsonUtils.getInstance().toJson(resultMap.get(Constants.ADMIN_RESULT_DATA));
        LOG.info("login success: {} ", tokenJson);
        Map<String, Object> tokenMap = GsonUtils.getInstance().convertToMap(tokenJson);
        return Optional.ofNullable(tokenMap.get(Constants.ADMIN_RESULT_TOKEN));
    }

    private String toQuery(final Object o) {
        Map<String, Object> map = null;
        if (o instanceof Map) {
            map = (Map) o;
        } else {
            map = GsonUtils.getInstance().convertToMap(GsonUtils.getInstance().toJson(o));
        }
        String[] list = new String[((Map) map).size()];
        int i = 0;

        Map.Entry e;
        for (Iterator var = ((Map) map).entrySet().iterator(); var.hasNext(); list[i++] = (String) e.getKey() + "=" + e.getValue().toString()) {
            e = (Map.Entry) var.next();
        }
        return StringUtils.join(list, '&');
    }

    class HttpLongPollingTask implements Runnable {

        private final String server;

        HttpLongPollingTask(final String server) {
            this.server = server;
        }

        @Override
        public void run() {
            while (RUNNING.get()) {
                int retryTimes = 3;
                for (int time = 1; time <= retryTimes; time++) {
                    try {
                        //refresh the admin token
                        accessToken.doFresh(server);
                        doLongPolling(server);
                    } catch (Exception e) {
                        // print warnning LOG.
                        if (time < retryTimes) {
                            LOG.warn("Long polling failed, tried {} times, {} times left, will be suspended for a while! {}",
                                    time, retryTimes - time, e.getMessage());
                            ThreadUtils.sleep(TimeUnit.SECONDS, 5);
                            continue;
                        }
                        // print error, then suspended for a while.
                        LOG.error("Long polling failed, try again after 5 minutes!", e);
                        ThreadUtils.sleep(TimeUnit.MINUTES, 5);
                    }
                }
            }
            LOG.warn("Stop http long polling.");
        }
    }
}
