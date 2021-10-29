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

package org.apache.shenyu.client.springmvc.init;

import org.apache.commons.lang3.StringUtils;
import org.apache.shenyu.client.core.disruptor.ShenyuClientRegisterEventPublisher;
import org.apache.shenyu.client.springmvc.annotation.ShenyuSpringMvcClient;
import org.apache.shenyu.register.client.api.ShenyuClientRegisterRepository;
import org.apache.shenyu.register.common.config.PropertiesConfig;
import org.apache.shenyu.register.common.dto.MetaDataRegisterDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Controller;
import org.springframework.util.ReflectionUtils;
import org.springframework.web.bind.annotation.RequestMapping;

import java.lang.reflect.Method;
import java.util.Objects;
import java.util.Properties;

/**
 * The type Shenyu spring mvc client bean post processor.
 */
public class SpringMvcClientBeanPostProcessor implements BeanPostProcessor {

    private static final Logger LOG = LoggerFactory.getLogger(SpringMvcClientBeanPostProcessor.class);

    private final ShenyuClientRegisterEventPublisher publisher = ShenyuClientRegisterEventPublisher.getInstance();

    private final String contextPath;

    private final String appName;

    private final Boolean isFull;
    
    /**
     * Instantiates a new Spring mvc client bean post processor.
     *
     * @param shenyuClientRegisterRepository the shenyu client register repository
     * @param clientConfig the client config
     */
    public SpringMvcClientBeanPostProcessor(final ShenyuClientRegisterRepository shenyuClientRegisterRepository,
                                            final PropertiesConfig clientConfig) {
        Properties props = clientConfig.getProps();
        int port = Integer.parseInt(props.getProperty("port"));
        if (port <= 0) {
            String errorMsg = "http register param must config the port must > 0";
            LOG.error(errorMsg);
            throw new RuntimeException(errorMsg);
        }
        this.appName = props.getProperty("appName");
        this.contextPath = props.getProperty("contextPath");
        if (StringUtils.isBlank(appName) && StringUtils.isBlank(contextPath)) {
            String errorMsg = "http register param must config the appName or contextPath";
            LOG.error(errorMsg);
            throw new RuntimeException(errorMsg);
        }
        this.isFull = Boolean.parseBoolean(props.getProperty("isFull", "false"));
        publisher.start(shenyuClientRegisterRepository);
    }

    @Override
    public Object postProcessAfterInitialization(@NonNull final Object bean, @NonNull final String beanName) throws BeansException {
        if (isFull) {
            return bean;
        }
        Controller controller = AnnotationUtils.findAnnotation(bean.getClass(), Controller.class);
        RequestMapping requestMapping = AnnotationUtils.findAnnotation(bean.getClass(), RequestMapping.class);
        if (controller != null || requestMapping != null) {
            ShenyuSpringMvcClient clazzAnnotation = AnnotationUtils.findAnnotation(bean.getClass(), ShenyuSpringMvcClient.class);
            String prePath = "";
            if (Objects.isNull(clazzAnnotation)) {
                return bean;
            }
            if (clazzAnnotation.path().indexOf("*") > 1) {
                publisher.publishEvent(buildMetaDataDTO(clazzAnnotation, prePath));
                return bean;
            }
            prePath = clazzAnnotation.path();
            final Method[] methods = ReflectionUtils.getUniqueDeclaredMethods(bean.getClass());
            for (Method method : methods) {
                ShenyuSpringMvcClient shenyuSpringMvcClient = AnnotationUtils.findAnnotation(method, ShenyuSpringMvcClient.class);
                if (Objects.nonNull(shenyuSpringMvcClient)) {
                    publisher.publishEvent(buildMetaDataDTO(shenyuSpringMvcClient, prePath));
                }
            }
        }
        return bean;
    }

    private MetaDataRegisterDTO buildMetaDataDTO(final ShenyuSpringMvcClient shenyuSpringMvcClient, final String prePath) {
        String contextPath = this.contextPath;
        String appName = this.appName;
        String path;
        if (StringUtils.isEmpty(contextPath)) {
            path = prePath + shenyuSpringMvcClient.path();
        } else {
            path = contextPath + prePath + shenyuSpringMvcClient.path();
        }
        String desc = shenyuSpringMvcClient.desc();
        String configRuleName = shenyuSpringMvcClient.ruleName();
        String ruleName = StringUtils.isBlank(configRuleName) ? path : configRuleName;
        return MetaDataRegisterDTO.builder()
                .contextPath(contextPath)
                .appName(appName)
                .path(path)
                .pathDesc(desc)
                .rpcType(shenyuSpringMvcClient.rpcType())
                .enabled(shenyuSpringMvcClient.enabled())
                .ruleName(ruleName)
                .registerMetaData(shenyuSpringMvcClient.registerMetaData())
                .build();
    }
}


