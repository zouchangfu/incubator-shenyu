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

package org.apache.shenyu.web.loader;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.common.concurrent.ShenyuThreadFactory;
import org.apache.shenyu.common.config.ShenyuConfig;
import org.apache.shenyu.common.config.ShenyuConfig.ExtPlugin;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.dto.PluginData;
import org.apache.shenyu.common.dto.PluginPathData;
import org.apache.shenyu.common.exception.CommonErrorCode;
import org.apache.shenyu.common.exception.ShenyuException;
import org.apache.shenyu.common.utils.GsonUtils;
import org.apache.shenyu.plugin.api.ShenyuPlugin;
import org.apache.shenyu.plugin.base.cache.CommonPluginDataSubscriber;
import org.apache.shenyu.plugin.base.handler.PluginDataHandler;
import org.apache.shenyu.web.handler.ShenyuWebHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.OkHttp3ClientHttpRequestFactory;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * The type Shenyu loader service.
 */
public class ShenyuLoaderService {

    private static final Logger LOG = LoggerFactory.getLogger(ShenyuWebHandler.class);

    private final ShenyuWebHandler webHandler;

    private final CommonPluginDataSubscriber subscriber;

    private final ShenyuConfig shenyuConfig;

    private ScheduledThreadPoolExecutor executor;

    private final RestTemplate httpClient;

    private Object accessToken;

    /**
     * Instantiates a new Shenyu loader service.
     *
     * @param webHandler   the web handler
     * @param subscriber   the subscriber
     * @param shenyuConfig the shenyu config
     */
    public ShenyuLoaderService(final ShenyuWebHandler webHandler, final CommonPluginDataSubscriber subscriber, final ShenyuConfig shenyuConfig) {
        this.subscriber = subscriber;
        this.webHandler = webHandler;
        this.shenyuConfig = shenyuConfig;
        this.httpClient = createRestTemplate();
        ExtPlugin config = shenyuConfig.getExtPlugin();
        if (config.getEnabled()) {
            executor = new ScheduledThreadPoolExecutor(config.getThreads(), ShenyuThreadFactory.create("plugin-ext-loader", true));
            executor.scheduleAtFixedRate(this::loaderExtPlugins, config.getScheduleDelay(), config.getScheduleTime(), TimeUnit.SECONDS);
        }
    }

    private RestTemplate createRestTemplate() {
        OkHttp3ClientHttpRequestFactory factory = new OkHttp3ClientHttpRequestFactory();
        return new RestTemplate(factory);
    }

    private void doLogin(String server) {
        String param = Constants.LOGIN_NAME + "=" + shenyuConfig.getExtPlugin().getUsername() + "&" + Constants.PASS_WORD + "=" + shenyuConfig.getExtPlugin().getPassword();
        String url = String.join("?", server + Constants.LOGIN_PATH, param);
        String result = this.httpClient.getForObject(url, String.class);
        Map<String, Object> resultMap = GsonUtils.getInstance().convertToMap(result);
        if (!String.valueOf(CommonErrorCode.SUCCESSFUL).equals(String.valueOf(resultMap.get(Constants.ADMIN_RESULT_CODE)))) {
            return;
        }
        String tokenJson = GsonUtils.getInstance().toJson(resultMap.get(Constants.ADMIN_RESULT_DATA));
        LOG.info("login success: {} ", tokenJson);
        Map<String, Object> tokenMap = GsonUtils.getInstance().convertToMap(tokenJson);
        this.accessToken = tokenMap.get(Constants.ADMIN_RESULT_TOKEN);
    }

    private void loaderExtPlugins() {
        try {
            List<ShenyuLoaderResult> results = ShenyuPluginLoader.getInstance().loadExtendPlugins(shenyuConfig.getExtPlugin().getPath());
            if (CollectionUtils.isEmpty(results)) {
                return;
            }
            List<ShenyuPlugin> shenyuExtendPlugins = results.stream().map(ShenyuLoaderResult::getShenyuPlugin).filter(Objects::nonNull).collect(Collectors.toList());
            webHandler.putExtPlugins(shenyuExtendPlugins);
            List<PluginDataHandler> handlers = results.stream().map(ShenyuLoaderResult::getPluginDataHandler).filter(Objects::nonNull).collect(Collectors.toList());
            subscriber.putExtendPluginDataHandler(handlers);
        } catch (Exception e) {
            LOG.error("shenyu ext plugins load has error ", e);
        }
    }

    public void executeLoaderRemoteExtPlugin(PluginData pluginData) {
        executor.execute(() -> this.loaderRemoteExtPlugin(pluginData));
    }

    private void loaderRemoteExtPlugin(PluginData pluginData) {
        if (StringUtils.isNoneBlank(pluginData.getPath())) {

            PluginPathData pluginPathData = GsonUtils.getInstance().fromJson(pluginData.getPath(), PluginPathData.class);

            if (Objects.isNull(accessToken)) {
                this.doLogin(pluginPathData.getServer());
            }

            InputStream remoteExtPluginStream = fetchRemoteExtPluginStream(pluginData.getId(), pluginPathData.getServer());

            storeExtPluginToLocal(pluginPathData.getFilename(), remoteExtPluginStream);

        }

    }

    private void storeExtPluginToLocal(String filename, InputStream remoteExtPluginStream) {
        if (Objects.nonNull(remoteExtPluginStream)) {
            String path = shenyuConfig.getExtPlugin().getPath();
            File file = new File(path + File.separator + filename);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                try (FileOutputStream fileOut = new FileOutputStream(file);) {
                    byte[] buffer = new byte[10240];
                    int ch;
                    while ((ch = remoteExtPluginStream.read(buffer)) != -1) {
                        fileOut.write(buffer, 0, ch);
                    }
                } catch (IOException e) {
                    String message = String.format("store plugin fail to local [%s], %s", path, e.getMessage());
                    LOG.warn(message);
                    throw new ShenyuException(message, e);
                }
            }
        }
    }

    private InputStream fetchRemoteExtPluginStream(String pluginId, String server) {
        String url = server + Constants.DOWNLOAD_PATH + "/" + pluginId;
        InputStream inputStream = null;
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set(Constants.X_ACCESS_TOKEN, String.valueOf(this.accessToken));
            HttpEntity<String> httpEntity = new HttpEntity<>(headers);
            ResponseEntity<Resource> exchange = this.httpClient.exchange(url, HttpMethod.GET, httpEntity, Resource.class);
            Resource body = exchange.getBody();
            if (Objects.nonNull(body)) {
                try {
                    inputStream = body.getInputStream();
                } catch (IOException e) {
                    String message = String.format("fetch inputStream fail from server[%s], %s", url, e.getMessage());
                    LOG.warn(message);
                    throw new ShenyuException(message, e);
                }
            }
        } catch (RestClientException e) {
            String message = String.format("fetch config fail from server[%s], %s", url, e.getMessage());
            LOG.warn(message);
            throw new ShenyuException(message, e);
        }
        return inputStream;
    }

}
