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

package org.apache.shenyu.plugin.ratelimiter.algorithm;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

/**
 * test for RateLimiterAlgorithmFactory.
 */
@ExtendWith(MockitoExtension.class)
public final class RateLimiterAlgorithmFactoryTest {

    @Test
    public void newInstanceTest() {
        RateLimiterAlgorithm<?> leakyBucketLimiterAlgorithm = RateLimiterAlgorithmFactory.newInstance("leakyBucket");
        assertThat(leakyBucketLimiterAlgorithm.getClass().getName(), is("org.apache.shenyu.plugin.ratelimiter.algorithm.LeakyBucketRateLimiterAlgorithm"));

        RateLimiterAlgorithm<?> concurrentRateLimiterAlgorithm = RateLimiterAlgorithmFactory.newInstance("concurrent");
        assertThat(concurrentRateLimiterAlgorithm.getClass().getName(), is("org.apache.shenyu.plugin.ratelimiter.algorithm.ConcurrentRateLimiterAlgorithm"));

        RateLimiterAlgorithm<?> tokenBucketRateLimiterAlgorithm = RateLimiterAlgorithmFactory.newInstance("tokenBucket");
        assertThat(tokenBucketRateLimiterAlgorithm.getClass().getName(), is("org.apache.shenyu.plugin.ratelimiter.algorithm.TokenBucketRateLimiterAlgorithm"));

        RateLimiterAlgorithm<?> slidingWindowRateLimiterAlgorithm = RateLimiterAlgorithmFactory.newInstance("slidingWindow");
        assertThat(slidingWindowRateLimiterAlgorithm.getClass().getName(), is("org.apache.shenyu.plugin.ratelimiter.algorithm.SlidingWindowRateLimiterAlgorithm"));
    }
}
