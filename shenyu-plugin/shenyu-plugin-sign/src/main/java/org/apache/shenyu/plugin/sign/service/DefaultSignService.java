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

package org.apache.shenyu.plugin.sign.service;

import com.google.common.collect.Maps;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.shenyu.common.constant.Constants;
import org.apache.shenyu.common.dto.AppAuthData;
import org.apache.shenyu.common.dto.AuthParamData;
import org.apache.shenyu.common.dto.AuthPathData;
import org.apache.shenyu.common.dto.PluginData;
import org.apache.shenyu.common.enums.PluginEnum;
import org.apache.shenyu.common.utils.DateUtils;
import org.apache.shenyu.common.utils.PathMatchUtils;
import org.apache.shenyu.common.utils.SignUtils;
import org.apache.shenyu.plugin.api.SignService;
import org.apache.shenyu.plugin.api.context.ShenyuContext;
import org.apache.shenyu.plugin.api.result.ShenyuResultEnum;
import org.apache.shenyu.plugin.base.cache.BaseDataCache;
import org.apache.shenyu.plugin.sign.cache.SignAuthDataCache;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.server.ServerWebExchange;

/**
 * The type Default sign service.
 */
public class DefaultSignService implements SignService {

    private static final Logger LOG = LoggerFactory.getLogger(DefaultSignService.class);

    @Value("${shenyu.sign.delay:5}")
    private int delay;

    @Override
    public Pair<Boolean, String> signVerify(final ServerWebExchange exchange) {
        // 获取插件配置数据
        PluginData signData = BaseDataCache.getInstance().obtainPluginData(PluginEnum.SIGN.getName());

        // 判断插件是否启用
        if (signData != null && signData.getEnabled()) {
            // 获取shenyuContext请求的上下文
            final ShenyuContext shenyuContext = exchange.getAttribute(Constants.CONTEXT);
            assert shenyuContext != null;
            // 认证
            return verify(shenyuContext, exchange);
        }
        return Pair.of(Boolean.TRUE, "");
    }

    private Pair<Boolean, String> verify(final ShenyuContext shenyuContext, final ServerWebExchange exchange) {

        // 当前请求的上下文中的appKey，sign，timestamp，不能为空
        if (StringUtils.isBlank(shenyuContext.getAppKey())
                || StringUtils.isBlank(shenyuContext.getSign())
                || StringUtils.isBlank(shenyuContext.getTimestamp())) {
            LOG.error("sign parameters are incomplete,{}", shenyuContext);
            return Pair.of(Boolean.FALSE, Constants.SIGN_PARAMS_ERROR);
        }

        // 把请求的时间戳转换为LocalDateTime
        final LocalDateTime start = DateUtils.formatLocalDateTimeFromTimestampBySystemTimezone(Long.parseLong(shenyuContext.getTimestamp()));
        final LocalDateTime now = LocalDateTime.now();
        // 两者的时间做比较
        final long between = DateUtils.acquireMinutesBetween(start, now);

        // 如果两者的时间大于默认的5分钟，请求失效
        if (between > delay) {
            return Pair.of(Boolean.FALSE, String.format(ShenyuResultEnum.SIGN_TIME_IS_TIMEOUT.getMsg(), delay));
        }

        // 签名比较
        return sign(shenyuContext, exchange);
    }

    /**
     * verify sign .
     *
     * @param shenyuContext {@linkplain ShenyuContext}
     * @return result : True is pass, False is not pass.
     */
    private Pair<Boolean, String> sign(final ShenyuContext shenyuContext, final ServerWebExchange exchange) {

        // 从缓存中获取生成的密钥
        final AppAuthData appAuthData = SignAuthDataCache.getInstance().obtainAuthData(shenyuContext.getAppKey());

        // 如果为空或者状态为不开启，认证失败
        if (Objects.isNull(appAuthData) || !appAuthData.getEnabled()) {
            LOG.error("sign APP_kEY does not exist or has been disabled,{}", shenyuContext.getAppKey());
            return Pair.of(Boolean.FALSE, Constants.SIGN_APP_KEY_IS_NOT_EXIST);
        }

        // 路由认证开启
        // 啥是路由认证呢？
        // 如果开启了路由认证，匹配到sign插件的地址，必须要在资源路径中
        if (appAuthData.getOpen()) {
            // 获取所有接口列表
            List<AuthPathData> pathDataList = appAuthData.getPathDataList();
            if (CollectionUtils.isEmpty(pathDataList)) {
                LOG.error("You have not configured the sign path:{}", shenyuContext.getAppKey());
                return Pair.of(Boolean.FALSE, Constants.SIGN_PATH_NOT_EXIST);
            }

            // 判断当前的请求是否在路由认证列表中
            boolean match = pathDataList.stream().filter(AuthPathData::getEnabled)
                    .anyMatch(e -> PathMatchUtils.match(e.getPath(), shenyuContext.getPath()));
            // 如果没有匹配到数据，认证失败
            if (!match) {
                LOG.error("You have not configured the sign path:{},{}", shenyuContext.getAppKey(), shenyuContext.getRealUrl());
                return Pair.of(Boolean.FALSE, Constants.SIGN_PATH_NOT_EXIST);
            }
        }

        // 根据密钥和上下文参数生成sign值
        String sigKey = SignUtils.generateSign(appAuthData.getAppSecret(), buildParamsMap(shenyuContext));
        // 对比结果
        boolean result = Objects.equals(sigKey, shenyuContext.getSign());
        if (!result) {
            LOG.error("the SignUtils generated signature value is:{},the accepted value is:{}", sigKey, shenyuContext.getSign());
            return Pair.of(Boolean.FALSE, Constants.SIGN_VALUE_IS_ERROR);
        } else {
            // 认证成功

            // 获取配置的参数列表
            List<AuthParamData> paramDataList = appAuthData.getParamDataList();
            if (CollectionUtils.isEmpty(paramDataList)) {
                return Pair.of(Boolean.TRUE, "");
            }

            // 如果appName等于上下文的contextPath
            // 把参数添加到header中
            paramDataList.stream().filter(p ->
                    ("/" + p.getAppName()).equals(shenyuContext.getContextPath()))
                    .map(AuthParamData::getAppParam)
                    .filter(StringUtils::isNoneBlank).findFirst()
                    .ifPresent(param -> exchange.getRequest().mutate().headers(httpHeaders -> httpHeaders.set(Constants.APP_PARAM, param)).build()
            );
        }
        return Pair.of(Boolean.TRUE, "");
    }

    private Map<String, String> buildParamsMap(final ShenyuContext dto) {
        Map<String, String> map = Maps.newHashMapWithExpectedSize(3);
        map.put(Constants.TIMESTAMP, dto.getTimestamp());
        map.put(Constants.PATH, dto.getPath());
        map.put(Constants.VERSION, "1.0.0");
        return map;
    }
}
