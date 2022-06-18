-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

/*Table structure for table `dashboard_user` */
CREATE TABLE IF NOT EXISTS `dashboard_user` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `user_name` varchar(64) NOT NULL COMMENT 'user name',
  `password` varchar(128) DEFAULT NULL COMMENT 'user password',
  `role` int(4) NOT NULL COMMENT 'role',
  `enabled` tinyint(4) NOT NULL COMMENT 'delete or not',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`),
  UNIQUE KEY(`user_name`)
);

/*Table structure for table `plugin` */
CREATE TABLE IF NOT EXISTS `plugin` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `name` varchar(62) NOT NULL COMMENT 'plugin name',
  `config` text COMMENT 'plugin configuration',
  `role` varchar(64) NOT NULL COMMENT 'plug-in role',
  `sort` int(4)  NULL COMMENT 'sort',
  `enabled` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'whether to open (0, not open, 1 open)',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `plugin_handle` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `plugin_id` varchar(128) NOT NULL COMMENT 'plugin id',
  `field` varchar(100) NOT NULL COMMENT 'field',
  `label` varchar(100) DEFAULT NULL COMMENT 'label',
  `data_type` smallint(6) NOT NULL DEFAULT '1' COMMENT 'data type 1 number 2 string',
  `type` smallint(6) NULL COMMENT 'type, 1 means selector, 2 means rule',
  `sort` int(4)  NULL COMMENT 'sort',
  `ext_obj` varchar(1024) DEFAULT NULL COMMENT 'extra configuration (json format data)',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  UNIQUE KEY `plugin_id_field_type` (`plugin_id`,`field`,`type`)
);

/*Table structure for table `selector` */
CREATE TABLE IF NOT EXISTS `selector` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id varchar' primary key,
  `plugin_id` varchar(128) NOT NULL COMMENT 'plugin id',
  `name` varchar(64) NOT NULL COMMENT 'selector name',
  `match_mode` int(2) NOT NULL COMMENT 'matching mode (0 and 1 or)',
  `type` int(4) NOT NULL COMMENT 'type (0, full flow, 1 custom flow)',
  `sort` int(4) NOT NULL COMMENT 'sort',
  `handle` varchar(1024) DEFAULT NULL COMMENT 'processing logic (here for different plug-ins, there will be different fields to identify different processes, all data in JSON format is stored)',
  `enabled` tinyint(4) NOT NULL COMMENT 'whether to open',
  `loged` tinyint(4) NOT NULL COMMENT 'whether to print the log',
  `continued` tinyint(4) NOT NULL COMMENT 'whether to continue execution',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time'
);

/*Table structure for table `selector_condition` */
CREATE TABLE IF NOT EXISTS `selector_condition` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `selector_id` varchar(128) NOT NULL COMMENT 'selector id',
  `param_type` varchar(64) NOT NULL COMMENT 'parameter type (to query uri, etc.)',
  `operator` varchar(64) NOT NULL COMMENT 'matching character (=> <like matching)',
  `param_name` varchar(64) NOT NULL COMMENT 'parameter name',
  `param_value` varchar(64) NOT NULL COMMENT 'parameter value',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`)
);

/*Table structure for table `rule` */
CREATE TABLE IF NOT EXISTS `rule` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id' PRIMARY KEY,
  `selector_id` varchar(128) NOT NULL COMMENT 'selector id',
  `match_mode` int(2) NOT NULL COMMENT 'matching mode (0 and 1 or)',
  `name` varchar(128) NOT NULL COMMENT 'rule name',
  `enabled` tinyint(4) NOT NULL COMMENT 'whether to open',
  `loged` tinyint(4) NOT NULL COMMENT 'whether to log or not',
  `sort` int(4) NOT NULL COMMENT 'sort',
  `handle` varchar(1024) DEFAULT NULL COMMENT 'processing logic (here for different plug-ins, there will be different fields to identify different processes, all data in JSON format is stored)',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time'
);

CREATE TABLE IF NOT EXISTS `rule_condition` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id' PRIMARY KEY,
  `rule_id` varchar(128) NOT NULL COMMENT 'rule id',
  `param_type` varchar(64) NOT NULL COMMENT 'parameter type (post query uri, etc.)',
  `operator` varchar(64) NOT NULL COMMENT 'matching character (=> <like match)',
  `param_name` varchar(64) NOT NULL COMMENT 'parameter name',
  `param_value` varchar(64) NOT NULL COMMENT 'parameter value',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time'
);

CREATE TABLE  IF NOT EXISTS `meta_data` (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `app_name` varchar(255) NOT NULL COMMENT 'application name',
  `path` varchar(255) NOT NULL COMMENT 'path, cannot be repeated',
  `path_desc` varchar(255) COMMENT 'path description',
  `rpc_type` varchar(64) NOT NULL COMMENT 'rpc type',
  `service_name` varchar(255) NULL DEFAULT NULL COMMENT 'service name',
  `method_name` varchar(255) NULL DEFAULT NULL COMMENT 'method name',
  `parameter_types` varchar(255) NULL DEFAULT NULL COMMENT 'parameter types are provided with multiple parameter types separated by commas',
  `rpc_ext` varchar(512) NULL DEFAULT NULL COMMENT 'rpc extended information, json format',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  `enabled` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'enabled state',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `app_auth`  (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `app_key` varchar(32) NOT NULL COMMENT 'application identification key',
  `app_secret` varchar(128) NOT NULL COMMENT 'encryption algorithm secret',
  `user_id` varchar(128) NULL DEFAULT NULL COMMENT 'user id',
  `phone` varchar(255) NULL DEFAULT NULL COMMENT 'phone number when the user applies',
  `ext_info` varchar(1024) NULL DEFAULT NULL COMMENT 'extended parameter json',
  `open` tinyint(4) NOT NULL COMMENT 'open auth path or not',
  `enabled` tinyint(4) NOT NULL COMMENT 'delete or not',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `auth_param`  (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `auth_id` varchar(128) NULL DEFAULT NULL COMMENT 'Authentication table id',
  `app_name` varchar(255) NOT NULL COMMENT 'business Module',
  `app_param` varchar(255) NULL DEFAULT NULL COMMENT 'service module parameters (parameters that need to be passed by the gateway) json type',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`)
);

-- ----------------------------
-- Table structure for auth_path
-- ----------------------------
CREATE TABLE IF NOT EXISTS `auth_path`  (
  `id` varchar(128) NOT NULL COMMENT 'primary key id',
  `auth_id` varchar(128) NOT NULL COMMENT 'auth table id',
  `app_name` varchar(255) NOT NULL COMMENT 'module',
  `path` varchar(255) NOT NULL COMMENT 'path',
  `enabled` tinyint(4) NOT NULL COMMENT 'whether pass 1 is',
  `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
  `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `shenyu_dict` (
   `id` varchar(128) NOT NULL COMMENT 'primary key id',
   `type` varchar(100) NOT NULL COMMENT 'type',
   `dict_code` varchar(100) NOT NULL COMMENT 'dictionary encoding',
   `dict_name` varchar(100) NOT NULL COMMENT 'dictionary name',
   `dict_value` varchar(100) DEFAULT NULL COMMENT 'dictionary value',
   `desc` varchar(255) DEFAULT NULL COMMENT 'dictionary description or remarks',
   `sort` int(4) NOT NULL COMMENT 'sort',
   `enabled` tinyint(4) DEFAULT NULL COMMENT 'whether it is enabled',
   `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
   `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    UNIQUE KEY `dict_type_dict_code_dict_name` (`type`,`dict_code`,`dict_name`)
 );

-- ----------------------------
-- Table structure for permission role
-- ----------------------------
CREATE TABLE IF NOT EXISTS `role` (
    `id` varchar(128) NOT NULL COMMENT 'primary key id',
    `role_name` varchar(32) NOT NULL COMMENT 'role name',
    `description` varchar(255) DEFAULT NULL COMMENT 'role describe',
    `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`,`role_name`)
    );
-- ----------------------------
-- Table structure for user_role
-- ----------------------------
CREATE TABLE IF NOT EXISTS `user_role` (
    `id` varchar(128) NOT NULL COMMENT 'primary key id',
    `user_id` varchar(128) NOT NULL COMMENT 'user primary key',
    `role_id` varchar(128) NOT NULL COMMENT 'role primary key',
    `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`)
    );
-- ----------------------------
-- Table structure for permission
-- ----------------------------
CREATE TABLE IF NOT EXISTS `permission` (
    `id` varchar(128) NOT NULL COMMENT 'primary key id',
    `object_id` varchar(128) NOT NULL COMMENT 'user primary key id or role primary key id',
    `resource_id` varchar(128) NOT NULL COMMENT 'resource primary key id',
    `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`)
    );
-- ----------------------------
-- Table structure for resource
-- ----------------------------
CREATE TABLE IF NOT EXISTS `resource` (
    `id` varchar(128) NOT NULL COMMENT 'primary key id',
    `parent_id` varchar(128) NOT NULL COMMENT 'resource parent primary key id',
    `title` varchar(128) NOT NULL COMMENT 'title',
    `name` varchar(32) NOT NULL COMMENT 'route name',
    `url` varchar(32) NOT NULL COMMENT 'route url',
    `component` varchar(32) NOT NULL COMMENT 'component',
    `resource_type` int(4) NOT NULL COMMENT 'resource type eg 0:main menu 1:child menu 2:function button',
    `sort` int(4) NOT NULL COMMENT 'sort',
    `icon` varchar(32) NOT NULL COMMENT 'icon',
    `is_leaf` tinyint(1) NOT NULL COMMENT 'leaf node 0:no 1:yes',
    `is_route` int(4) NOT NULL COMMENT 'route 1:yes 0:no',
    `perms` varchar(64) NOT NULL COMMENT 'button permission description sys:user:add(add)/sys:user:edit(edit)',
    `status` int(4) NOT NULL COMMENT 'status 1:enable 0:disable',
    `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`)
    );
-- ----------------------------
-- Table structure for data_permission
-- ----------------------------
CREATE TABLE IF NOT EXISTS `data_permission` (
    `id` varchar(128) NOT NULL COMMENT 'primary key id',
    `user_id` varchar(128) NOT NULL COMMENT 'user primary key id',
    `data_id` varchar(128) NOT NULL COMMENT 'data(selector,rule) primary key id',
    `data_type` int(1) NOT NULL COMMENT '0 selector type , 1 rule type',
    `date_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'create time',
    `date_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time',
    PRIMARY KEY (`id`)
    );
-- ----------------------------
-- Table structure for operation_record_log
-- ----------------------------
CREATE TABLE IF NOT EXISTS `operation_record_log`
(
    `id`             bigint       NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'id',
    `color`          varchar(20)  NOT NULL COMMENT 'log color',
    `context`        text         NOT NULL COMMENT 'log context',
    `operator`       varchar(200) NOT NULL COMMENT 'operator [user or app]]',
    `operation_time` datetime     NOT NULL DEFAULT now() COMMENT 'operation time',
    `operation_type` varchar(60)  NOT NULL DEFAULT 'update' COMMENT 'operation type：create/update/delete/register...'
);

-- ----------------------------
-- Table structure for alert_template
-- ----------------------------
CREATE TABLE IF NOT EXISTS `alert_template`
(
    `id`            bigint          NOT NULL AUTO_INCREMENT COMMENT 'primary key id',
    `name`          varchar(255)    NOT NULL COMMENT 'alert template name',
    `strategy_name` varchar(255)    NOT NULL COMMENT 'alert template strategy name',
    `content`       varchar(1000)   NOT NULL COMMENT 'alert template content',
    `date_created`  timestamp       NOT NULL DEFAULT now() COMMENT 'create time',
    `date_updated`  timestamp       NOT NULL DEFAULT now() COMMENT 'update time'
);

/**default admin user**/
INSERT IGNORE INTO `dashboard_user` (`id`, `user_name`, `password`, `role`, `enabled`) VALUES ('1','admin','ba3253876aed6bc22d4a6ff53d8406c6ad864195ed144ab5c87621b6c233b548baeae6956df346ec8c17f5ea10f35ee3cbc514797ed7ddd3145464e2a0bab413', '1', '1');

/** insert admin role */
INSERT IGNORE INTO `user_role` (`id`, `user_id`, `role_id`) VALUES ('1351007709096976384', '1', '1346358560427216896');

/** insert permission role for role */
INSERT IGNORE INTO `role` (`id`,`role_name`,`description`) VALUES ('1346358560427216896', 'super', 'Administrator');
INSERT IGNORE INTO `role` (`id`,`role_name`,`description`) VALUES ('1385482862971723776', 'default', 'Standard');

/*shenyu dict*/
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589888', 'degradeRuleGrade', 'DEGRADE_GRADE_RT', 'slow call ratio', '0', 'degrade type-slow call ratio', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589889', 'degradeRuleGrade', 'DEGRADE_GRADE_EXCEPTION_RATIO', 'exception ratio', '1', 'degrade type-abnormal ratio', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589890', 'degradeRuleGrade', 'DEGRADE_GRADE_EXCEPTION_COUNT', 'exception number strategy', '2', 'degrade type-abnormal number strategy', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589891', 'flowRuleGrade', 'FLOW_GRADE_QPS', 'QPS', '1', 'grade type-QPS', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589892', 'flowRuleGrade', 'FLOW_GRADE_THREAD', 'number of concurrent threads', '0', 'degrade type-number of concurrent threads', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589893', 'flowRuleControlBehavior', 'CONTROL_BEHAVIOR_DEFAULT', 'direct rejection by default', '0', 'control behavior-direct rejection by default', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589894', 'flowRuleControlBehavior', 'CONTROL_BEHAVIOR_WARM_UP', 'warm up', '1', 'control behavior-warm up', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589895', 'flowRuleControlBehavior', 'CONTROL_BEHAVIOR_RATE_LIMITER', 'constant speed queuing', '2', 'control behavior-uniform speed queuing', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589896', 'flowRuleControlBehavior', 'CONTROL_BEHAVIOR_WARM_UP_RATE_LIMITER', 'preheating uniformly queued', '3', 'control behavior-preheating uniformly queued', 3, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589897', 'permission', 'REJECT', 'reject', 'reject', 'reject', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589898', 'permission', 'ALLOW', 'allow', 'allow', 'allow', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589899', 'algorithmName', 'ALGORITHM_SLIDINGWINDOW', 'slidingWindow', 'slidingWindow', 'Sliding window algorithm', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589900', 'algorithmName', 'ALGORITHM_LEAKYBUCKET', 'leakyBucket', 'leakyBucket', 'Leaky bucket algorithm', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613191589901', 'algorithmName', 'ALGORITHM_CONCURRENT', 'concurrent', 'concurrent', 'Concurrent algorithm', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784192', 'algorithmName', 'ALGORITHM_TOKENBUCKET', 'tokenBucket', 'tokenBucket', 'Token bucket algorithm', 3, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784193', 'loadBalance', 'LOAD_BALANCE', 'roundRobin', 'roundRobin', 'roundRobin', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784194', 'loadBalance', 'LOAD_BALANCE', 'random', 'random', 'random', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784195', 'loadBalance', 'LOAD_BALANCE', 'hash', 'hash', 'hash', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784196', 'status', 'DIVIDE_STATUS', 'close', 'false', 'close', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784197', 'status', 'DIVIDE_STATUS', 'open', 'true', 'open', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784198', 'multiRuleHandle', 'MULTI_RULE_HANDLE', 'multiple rule', '1', 'multiple rule', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784199', 'multiRuleHandle', 'MULTI_RULE_HANDLE', 'single rule', '0', 'single rule', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784200', 'multiSelectorHandle', 'MULTI_SELECTOR_HANDLE', 'multiple handle', '1', 'multiple handle', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784201', 'multiSelectorHandle', 'MULTI_SELECTOR_HANDLE', 'single handle', '0', 'single handle', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784202', 'matchMode', 'MATCH_MODE', 'and', '0', 'and', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784203', 'matchMode', 'MATCH_MODE', 'or', '1', 'or', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784204', 'operator', 'OPERATOR', 'match', 'match', 'match', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784205', 'operator', 'OPERATOR', '=', '=', '=', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784206', 'operator', 'OPERATOR', 'regex', 'regex', 'regex', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784207', 'operator', 'OPERATOR', 'contains', 'contains', 'contains', 3, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784208', 'operator', 'OPERATOR', 'TimeBefore', 'TimeBefore', 'TimeBefore', 4, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784209', 'operator', 'OPERATOR', 'TimeAfter', 'TimeAfter', 'TimeAfter', 5, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784210', 'operator', 'OPERATOR', 'exclude', 'exclude', 'exclude', 6, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784211', 'operator', 'OPERATOR', 'startsWith', 'startsWith', 'startsWith', 7, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784212', 'operator', 'OPERATOR', 'endsWith', 'endsWith', 'endsWith', 8, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784213', 'paramType', 'PARAM_TYPE', 'post', 'post', 'post', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784214', 'paramType', 'PARAM_TYPE', 'uri', 'uri', 'uri', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784215', 'paramType', 'PARAM_TYPE', 'query', 'query', 'query', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784216', 'paramType', 'PARAM_TYPE', 'host', 'host', 'host', 3, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784217', 'paramType', 'PARAM_TYPE', 'ip', 'ip', 'ip', 4, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784218', 'paramType', 'PARAM_TYPE', 'header', 'header', 'header', 5, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784219', 'paramType', 'PARAM_TYPE', 'cookie', 'cookie', 'cookie', 6, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784220', 'paramType', 'PARAM_TYPE', 'req_method', 'req_method', 'req_method', 7, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784221', 'keyResolverName', 'WHOLE_KEY_RESOLVER', 'whole', 'WHOLE_KEY_RESOLVER', 'Rate limit by all request', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784222', 'keyResolverName', 'REMOTE_ADDRESS_KEY_RESOLVER', 'remoteAddress', 'REMOTE_ADDRESS_KEY_RESOLVER', 'Rate limit by remote address', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784223', 'automaticTransitionFromOpenToHalfOpenEnabled', 'AUTOMATIC_HALF_OPEN', 'open', 'true', '', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784224', 'automaticTransitionFromOpenToHalfOpenEnabled', 'AUTOMATIC_HALF_OPEN', 'close', 'false', '', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784225', 'paramType', 'PARAM_TYPE', 'domain', 'domain', 'domain', 8, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784226', 'strategyName', 'STRATEGY_NAME', 'rsa', 'rsa', 'rsa strategy', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784227', 'way', 'WAY', 'encrypt', 'encrypt', 'encrypt', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784228', 'way', 'WAY', 'decrypt', 'decrypt', 'decrypt', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784229', 'mode', 'MODE', 'cluster', 'cluster', 'cluster', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784230', 'mode', 'MODE', 'sentinel', 'sentinel', 'sentinel', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784231', 'mode', 'MODE', 'standalone', 'standalone', 'standalone', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784232', 'gray', 'GRAY_STATUS', 'close', 'false', 'close', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784233', 'gray', 'GRAY_STATUS', 'open', 'true', 'open', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784234', 'threadpool', 'THREADPOOL', 'shared', 'shared', '', 4, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784235', 'threadpool', 'THREADPOOL', 'fixed', 'fixed', '', 3, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784236', 'threadpool', 'THREADPOOL', 'eager', 'eager', '', 2, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784237', 'threadpool', 'THREADPOOL', 'cached', 'cached', '', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784238', 'threadpool', 'THREADPOOL', 'limited', 'limited', '', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784239', 'retryStrategy', 'RETRY_STRATEGY', 'current', 'current', 'current', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784240', 'retryStrategy', 'RETRY_STRATEGY', 'failover', 'failover', 'failover', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784241', 'table', 'INIT_FLAG', 'status', 'false', 'table(resource,permission) init status', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784242', 'compressAlg', 'COMPRESS_ALG', 'none', 'none', '', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784243', 'compressAlg', 'COMPRESS_ALG', 'LZ4', 'LZ4', '', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784244', 'cacheType', 'CACHE_TYPE_MEMORY', 'memory', 'memory', 'use memory to cache data', 0, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784245', 'cacheType', 'CACHE_TYPE_REDIS', 'redis', 'redis', 'use redis to cache data', 1, 1);
INSERT IGNORE INTO `shenyu_dict` (`id`, `type`,`dict_code`, `dict_name`, `dict_value`, `desc`, `sort`, `enabled`) VALUES ('1529402613195784246', 'threadpool', 'THREADPOOL', 'default', 'default', '', 5, 1);

/*plugin*/
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('1','sign','Authentication',  20, '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`,`config`,`enabled`) VALUES ('2','waf', 'Authentication', 50,'{"model":"black"}','0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('3','rewrite', 'HttpProcess', 90,'0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`,`enabled`) VALUES ('4','rateLimiter','FaultTolerance', 60,'{"master":"mymaster","mode":"standalone","url":"192.168.1.1:6379","password":"abc"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`,`enabled`) VALUES ('5','divide', 'Proxy', 200,'{"multiSelectorHandle":"1","multiRuleHandle":"0"}','1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`,`enabled`) VALUES ('6','dubbo','Proxy', 310,'{"register":"zookeeper://localhost:2181","multiSelectorHandle":"1","threadpool":"cached","corethreads":0,"threads":2147483647,"queues":0}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('8','springCloud','Proxy', 200, '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('9','hystrix', 'FaultTolerance', 130,'0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('10','sentinel', 'FaultTolerance', 140,'0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('11','sofa', 'Proxy', 310, '{"protocol":"zookeeper","register":"127.0.0.1:2181"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('12','resilience4j', 'FaultTolerance', 310,'0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('13', 'tars', 'Proxy', 310,'{"multiSelectorHandle":"1","multiRuleHandle":"0"}','0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('14', 'contextPath', 'HttpProcess', 80,'1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('15', 'grpc', 'Proxy', 310,'{"multiSelectorHandle":"1","multiRuleHandle":"0","threadpool":"cached"}','0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('16', 'redirect', 'HttpProcess', 110,'0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('17', 'motan', 'Proxy', 310,'{"register":"127.0.0.1:2181","corethreads":0,"threads":2147483647,"queues":0,"threadpool":"cached"}','0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('18', 'loggingConsole', 'Logging', 160, '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('19', 'jwt', 'Authentication', 30, '{"secretKey":"key"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('20', 'request', 'HttpProcess', 120, '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('21', 'oauth2', 'Authentication', 40, '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('22', 'paramMapping','HttpProcess', 70,'{"ruleHandlePageType":"custom"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('23', 'modifyResponse', 'HttpProcess', 220, '{"ruleHandlePageType":"custom"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('24', 'cryptorRequest', 'Cryptor', 100, '1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('25', 'cryptorResponse', 'Cryptor', 410, '1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('26', 'websocket', 'Proxy', 200, '{"multiSelectorHandle":"1"}', '1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `enabled`) VALUES ('27', 'generalContext', 'Common', 125, '1');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('28', 'mqtt', 'Proxy', 125, '{"port": 9500,"bossGroupThreadCount": 1,"maxPayloadSize": 65536,"workerGroupThreadCount": 12,"userName": "shenyu","password": "shenyu","isEncryptPassword": false,"encryptMode": "","leakDetectorLevel": "DISABLED"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `role`, `sort`, `config`, `enabled`) VALUES ('29', 'loggingRocketMQ', 'Logging', 170,'{"topic":"shenyu-access-logging", "namesrvAddr": "localhost:9876","producerGroup":"shenyu-plugin-logging-rocketmq"}', '0');
INSERT IGNORE INTO `plugin` (`id`, `name`, `config`, `role`, `sort`, `enabled`) VALUES ('30', 'cache', '{"cacheType":"memory"}', 'Cache', 10, 0);

/*insert plugin_handle data for sentinel*/
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613195784246', '10', 'flowRuleGrade', 'flowRuleGrade', 3, 2, 8, '{"required":"1","defaultValue":"1","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978496', '10', 'flowRuleControlBehavior', 'flowRuleControlBehavior', 3, 2, 5, '{"required":"1","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978497', '10', 'flowRuleEnable', 'flowRuleEnable 1 or 0)', 1, 2, 7, '{"required":"1","defaultValue":"1","rule":"/^[01]$/"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978498', '10', 'flowRuleCount', 'flowRuleCount', 1, 2, 6, '{"required":"1","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978499', '10', 'degradeRuleEnable', 'degradeRuleEnable 1 or 0)', 1, 2, 2, '{"required":"1","defaultValue":"1","rule":"/^[01]$/"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978500', '10', 'degradeRuleGrade', 'degradeRuleGrade', 3, 2, 3, '{"required":"1","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978501', '10', 'degradeRuleCount', 'degradeRuleCount', 1, 2, 1, '{"required":"1","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978502', '10', 'degradeRuleTimeWindow', 'degradeRuleTimeWindow', 1, 2, 4, '{"required":"1","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978503', '10', 'degradeRuleMinRequestAmount', 'degradeRuleMinRequestAmount', 1, 2, 3, '{"required":"1","defaultValue":"5","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978504', '10', 'degradeRuleStatIntervals', 'degradeRuleStatIntervals', 1, 2, 3, '{"required":"1","defaultValue":"1","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978505', '10', 'degradeRuleSlowRatioThreshold', 'degradeRuleSlowRatioThreshold', 1, 2, 3, '{"required":"1","defaultValue":"0.5","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978506', '10', 'fallbackUri', 'fallbackUri', 2, 2, 9, '{"required":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978507', '2', 'permission', 'permission', 3, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978508', '2', 'statusCode', 'statusCode', 2, 2, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978509', '4', 'replenishRate', 'replenishRate', 2, 2, 2, '{"required":"1","defaultValue":"10","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978510', '4', 'burstCapacity', 'burstCapacity', 2, 2, 3, '{"required":"1","defaultValue":"100","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978511', '3', 'regex', 'regex', 2, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978512', '3', 'replace', 'replace', 2, 2, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978513', '16', 'redirectURI', 'redirectURI', 2, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978514', '8', 'path', 'path', 2, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978515', '8', 'timeout', 'timeout ms)', 1, 2, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978516', '8', 'serviceId', 'serviceId', 2, 1, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978517', '12', 'timeoutDurationRate', 'timeoutDurationRate ms)', 1, 2, 1, '{"required":"1","defaultValue":"5000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978518', '12', 'limitRefreshPeriod', 'limitRefreshPeriod ms)', 1, 2, 0, '{"required":"1","defaultValue":"500","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978519', '12', 'limitForPeriod', 'limitForPeriod', 1, 2, 0, '{"required":"1","defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978520', '12', 'circuitEnable', 'circuitEnable', 1, 2, 2, '{"required":"1","defaultValue":"0","rule":"/^[01]$/"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978521', '12', 'timeoutDuration', 'timeoutDuration ms)', 1, 2, 2, '{"required":"1","defaultValue":"30000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978522', '12', 'fallbackUri', 'fallbackUri', 2, 2, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978523', '12', 'slidingWindowSize', 'slidingWindowSize', 1, 2, 2, '{"required":"1","defaultValue":"100","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978524', '12', 'slidingWindowType', 'slidingWindowType', 1, 2, 2, '{"required":"1","defaultValue":"0","rule":"/^[01]$/"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978525', '12', 'minimumNumberOfCalls', 'minimumNumberOfCalls', 1, 2, 2, '{"required":"1","defaultValue":"100","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978526', '12', 'waitIntervalFunctionInOpenState', 'waitIntervalInOpen', 1, 2, 2, '{"required":"1","defaultValue":"60000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978527', '12', 'permittedNumberOfCallsInHalfOpenState', 'bufferSizeInHalfOpen', 1, 2, 2, '{"required":"1","defaultValue":"10","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978528', '12', 'failureRateThreshold', 'failureRateThreshold', 1, 2, 2, '{"required":"1","defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978529', '12', 'automaticTransitionFromOpenToHalfOpenEnabled', 'automaticHalfOpen', 3, 2, 1, '{"required":"1","defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978530', '4', 'mode', 'mode', 3, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978531', '4', 'master', 'master', 2, 3, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978532', '4', 'url', 'url', 2, 3, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978533', '4', 'password', 'password', 2, 3, 4);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978534', '11', 'protocol', 'protocol', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978535', '11', 'register', 'register', 2, 3, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978536', '2', 'model', 'model', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978537', '6', 'register', 'register', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978538', '4', 'algorithmName', 'algorithmName', 3, 2, 1, '{"required":"1","defaultValue":"slidingWindow","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978539', '4', 'keyResolverName', 'keyResolverName', 3, 2, 4, '{"required":"1","defaultValue":"WHOLE_KEY_RESOLVER","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978540', '5', 'upstreamHost', 'host', 2, 1, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978541', '5', 'protocol', 'protocol', 2, 1, 2, '{"required":"0","defaultValue":"","placeholder":"http://","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978542', '5', 'upstreamUrl', 'ip:port', 2, 1, 1, '{"required":"1","placeholder":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978543', '5', 'weight', 'weight', 1, 1, 3, '{"defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978544', '5', 'timestamp', 'startupTime', 1, 1, 3, '{"defaultValue":"0","placeholder":"startup timestamp","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978545', '5', 'warmup', 'warmupTime', 1, 1, 5, '{"defaultValue":"0","placeholder":"warmup time ms)","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978546', '5', 'status', 'status', 3, 1, 6, '{"defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978547', '5', 'loadBalance', 'loadStrategy', 3, 2, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978548', '5', 'retry', 'retryCount', 1, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978549', '5', 'timeout', 'timeout', 1, 2, 2, '{"defaultValue":"3000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978550', '5', 'multiSelectorHandle', 'multiSelectorHandle', 3, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978551', '5', 'multiRuleHandle', 'multiRuleHandle', 3, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978552', '5', 'headerMaxSize', 'headerMaxSize', 1, 2, 3, '{"defaultValue":"10240","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978553', '5', 'requestMaxSize', 'requestMaxSize', 1, 2, 4, '{"defaultValue":"102400","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978554', '5', 'retryStrategy', 'retryStrategy', 3, 2, 0, '{"required":"0","defaultValue":"current","placeholder":"retryStrategy","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978555', '13', 'upstreamHost', 'host', 2, 1, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978556', '13', 'protocol', 'protocol', 2, 1, 2, '{"defaultValue":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978557', '13', 'upstreamUrl', 'ip:port', 2, 1, 1, '{"required":"1","placeholder":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978558', '13', 'weight', 'weight', 1, 1, 3, '{"defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978559', '13', 'timestamp', 'startupTime', 1, 1, 3, '{"defaultValue":"0","placeholder":"startup timestamp","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978560', '13', 'warmup', 'warmupTime', 1, 1, 5, '{"defaultValue":"0","placeholder":"warmup time ms)","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978561', '13', 'status', 'status', 3, 1, 6, '{"defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978562', '13', 'loadBalance', 'loadStrategy', 3, 2, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`)  VALUES ('1529402613199978563', '13', 'retry', 'retryCount', 1, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978564', '13', 'timeout', 'timeout', 1, 2, 2, '{"defaultValue":"3000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978565', '13', 'multiSelectorHandle', 'multiSelectorHandle', 3, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978566', '13', 'multiRuleHandle', 'multiRuleHandle', 3, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978567', '15', 'upstreamUrl', 'ip:port', 2, 1, 1, '{"required":"1","placeholder":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978568', '15', 'weight', 'weight', 1, 1, 3, '{"defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978569', '15', 'status', 'status', 3, 1, 6, '{"defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978570', '15', 'multiSelectorHandle', 'multiSelectorHandle', 3, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978571', '15', 'multiRuleHandle', 'multiRuleHandle', 3, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978572', '15', 'threadpool', 'threadpool', 3, 3, 0, '{"required":"0","defaultValue":"cached","placeholder":"threadpool","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978573', '14', 'contextPath', 'contextPath', 2, 2, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978574', '14', 'addPrefix', 'addPrefix', 2, 2, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613199978575', '20', 'ruleHandlePageType', 'ruleHandlePageType', 3, 3, 0, '{"required":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978576', '19', 'secretKey', 'secretKey', 2, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978577', '24', 'strategyName', 'strategyName', 3, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978578', '24', 'fieldNames', 'fieldNames', 2, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613199978579', '24', 'decryptKey', 'decryptKey', 2, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172800', '24', 'encryptKey', 'encryptKey', 2, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172801', '24', 'way', 'way', 3, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172802', '25', 'strategyName', 'strategyName', 3, 2, 2);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172803', '25', 'decryptKey', 'decryptKey', 2, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172804', '25', 'encryptKey', 'encryptKey', 2, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172805', '25', 'fieldNames', 'fieldNames', 2, 2, 4);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172806', '25', 'way', 'way', 3, 2, 3);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172807', '6', 'gray', 'gray', 3, 1, 9, '{"required":"0","defaultValue":"false","placeholder":"gray","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172808', '6', 'group', 'group', 2, 1, 3, '{"required":"0","placeholder":"group","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172809', '6', 'loadbalance', 'loadbalance', 3, 2, 0, '{"required":"0","placeholder":"loadbalance","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172810', '6', 'multiSelectorHandle', 'multiSelectorHandle', 3, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172811', '6', 'protocol', 'protocol', 2, 1, 2, '{"required":"0","defaultValue":"","placeholder":"http://","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172812', '6', 'status', 'status', 3, 1, 8, '{"defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172813', '6', 'timestamp', 'startupTime', 1, 1, 7, '{"defaultValue":"0","placeholder":"startup timestamp","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172814', '6', 'upstreamHost', 'host', 2, 1, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172815', '6', 'upstreamUrl', 'ip:port', 2, 1, 1, '{"required":"1","placeholder":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172816', '6', 'version', 'version', 2, 1, 4, '{"required":"0","placeholder":"version","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172817', '6', 'warmup', 'warmupTime', 1, 1, 6, '{"defaultValue":"0","placeholder":"warmup time ms)","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172818', '6', 'weight', 'weight', 1, 1, 5, '{"defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172819', '6', 'threadpool', 'threadpool', 3, 3, 0, '{"required":"0","defaultValue":"cached","placeholder":"threadpool","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172820', '6', 'corethreads', 'corethreads', 1, 3, 0, '{"required":"0","defaultValue":"0","placeholder":"corethreads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172821', '6', 'threads', 'threads', 1, 3, 0, '{"required":"0","defaultValue":"2147483647","placeholder":"threads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172822', '6', 'queues', 'queues', 1, 3, 0, '{"required":"0","defaultValue":"0","placeholder":"queues","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172823', '26', 'host', 'host', 2, 1, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172824', '26', 'protocol', 'protocol', 2, 1, 2, '{"required":"0","defaultValue":"","placeholder":"ws://","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172825', '26', 'url', 'ip:port', 2, 1, 1, '{"required":"1","placeholder":"","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172826', '26', 'weight', 'weight', 1, 1, 3, '{"defaultValue":"50","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172827', '26', 'timestamp', 'startupTime', 1, 1, 3, '{"defaultValue":"0","placeholder":"startup timestamp","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172828', '26', 'warmup', 'warmupTime', 1, 1, 5, '{"defaultValue":"0","placeholder":"warmup time ms)","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172829', '26', 'status', 'status', 3, 1, 6, '{"defaultValue":"true","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172830', '26', 'loadBalance', 'loadStrategy', 3, 2, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172831', '26', 'retry', 'retryCount', 1, 2, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172832', '26', 'timeout', 'timeout', 1, 2, 2, '{"defaultValue":"3000","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172833', '26', 'multiSelectorHandle', 'multiSelectorHandle', 3, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172834', '17', 'register', 'register', 2, 3, 0);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172835', '17', 'corethreads', 'corethreads', 1, 3, 0, '{"required":"0","defaultValue":"0","placeholder":"corethreads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172836', '17', 'threads', 'threads', 1, 3, 0, '{"required":"0","defaultValue":"2147483647","placeholder":"threads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172837', '17', 'queues', 'queues', 1, 3, 0, '{"required":"0","defaultValue":"0","placeholder":"queues","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172838', '17', 'threadpool', 'threadpool', 3, 3, 0, '{"required":"0","defaultValue":"cached","placeholder":"threadpool","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172839', '28', 'port', 'port', 1, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172840', '28', 'bossGroupThreadCount', 'bossGroupThreadCount', 1, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172841', '28', 'maxPayloadSize', 'maxPayloadSize', 1, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172842', '28', 'workerGroupThreadCount', 'workerGroupThreadCount', 1, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172843', '28', 'userName', 'userName', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172844', '28', 'password', 'password', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172845', '28', 'isEncryptPassword', 'isEncryptPassword', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172846', '28', 'encryptMode', 'encryptMode', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`) VALUES ('1529402613204172847', '28', 'leakDetectorLevel', 'leakDetectorLevel', 2, 3, 1);
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172848', '29', 'topic', 'topic', 2, 3, 1, '{"required":"1","defaultValue":"shenyu-access-logging"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172849', '29', 'namesrvAddr', 'namesrvAddr', 2, 3, 2, '{"required":"1","defaultValue":"localhost:9876"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172850', '29', 'producerGroup', 'producerGroup', 2, 3, 3, '{"required":"1","defaultValue":"shenyu-plugin-logging-rocketmq"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172851', '29', 'sampleRate', 'sampleRate', 2, 3, 4, '{"required":"0","defaultValue":"1","placeholder":"optional,0,0.01~1"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172852', '29', 'maxResponseBody', 'maxResponseBody', 1, 3, 5, '{"required":"0","defaultValue":524288}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172853', '29', 'maxRequestBody', 'maxRequestBody', 1, 3, 6, '{"required":"0","defaultValue":524288}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172854', '29', 'compressAlg', 'compressAlg', 3, 3, 7, '{"required":"0","defaultValue":"none"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172855', '29', 'topic', 'topic', 2, 1, 1, '{"required":"0","defaultValue":"","placeholder":"optional"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172856', '29', 'sampleRate', 'sampleRate', 2, 1, 2, '{"required":"0","defaultValue":"","placeholder":"optional,0,0.01~1"}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172857', '30', 'cacheType', 'cacheType', 3, 3, 1, '{"required":"1","defaultValue":"memory","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172858', '30', 'database', 'database', 1, 3, 2, '{"required":"0","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172859', '30', 'master', 'master', 2, 3, 3, '{"required":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172860', '30', 'mode', 'mode', 2, 3, 4, '{"required":"0","defaultValue":"standalone","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172861', '30', 'url', 'url', 2, 3, 5, '{"required":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172862', '30', 'password', 'password', 2, 3, 6, '{"required":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172863', '30', 'maxIdle', 'maxIdle', 1, 3, 7, '{"required":"0","defaultValue":"8","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172864', '30', 'minIdle', 'minIdle', 1, 3, 8, '{"required":"0","defaultValue":"0","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172865', '30', 'maxActive', 'maxActive', 1, 3, 9, '{"required":"0","defaultValue":"8","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172866', '30', 'maxWait', 'maxWait', 3, 3, 10, '{"required":"0","defaultValue":"-1","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172867', '30', 'timeoutSeconds', 'timeoutSeconds', 1, 2, 0, '{"required":"0","defaultValue":"60","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172868', '13', 'corethreads', 'corethreads', 1, 3, 3, '{"required":"0","defaultValue":"0","placeholder":"corethreads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172869', '13', 'threads', 'threads', 1, 3, 4, '{"required":"0","defaultValue":"2147483647","placeholder":"threads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172870', '13', 'queues', 'queues', 1, 3, 5, '{"required":"0","defaultValue":"0","placeholder":"queues","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172871', '13', 'threadpool', 'threadpool', 3, 3, 2, '{"required":"0","defaultValue":"default","placeholder":"threadpool","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172872', '11', 'corethreads', 'corethreads', 1, 3, 4, '{"required":"0","defaultValue":"0","placeholder":"corethreads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172873', '11', 'threads', 'threads', 1, 3, 5, '{"required":"0","defaultValue":"2147483647","placeholder":"threads","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172874', '11', 'queues', 'queues', 1, 3, 6, '{"required":"0","defaultValue":"0","placeholder":"queues","rule":""}');
INSERT IGNORE INTO plugin_handle (`id`, `plugin_id`,`field`,`label`,`data_type`,`type`,`sort`,`ext_obj`) VALUES ('1529402613204172875', '11', 'threadpool', 'threadpool', 3, 3, 3, '{"required":"0","defaultValue":"default","placeholder":"threadpool","rule":""}');

/** insert resource for resource */
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346775491550474240','','SHENYU.MENU.PLUGIN.LIST','plug','/plug','PluginList','0','0','dashboard','0','0','','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1357956838021890048','','SHENYU.MENU.CONFIG.MANAGMENT','config','/config','config','0','1','api','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346777449787125760','1357956838021890048','SHENYU.MENU.SYSTEM.MANAGMENT.PLUGIN','plugin','/config/plugin','plugin','1','2','book','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347034027070337024','1346777449787125760','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:plugin:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347039054925148160','1346777449787125760','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','1','','1','0','system:plugin:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347041326749691904','1346777449787125760','SHENYU.BUTTON.SYSTEM.ADD','','','','2','2','','1','0','system:plugin:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347046566244003840','1346777449787125760','SHENYU.BUTTON.SYSTEM.SYNCHRONIZE','','','','2','3','','1','0','system:plugin:modify','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047143350874112','1346777449787125760','SHENYU.BUTTON.SYSTEM.ENABLE','','','','2','4','','1','0','system:plugin:disable','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047203220369408','1346777449787125760','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','5','','1','0','system:plugin:edit','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346777623011880960','1357956838021890048','SHENYU.PLUGIN.PLUGINHANDLE','pluginhandle','/config/pluginhandle','pluginhandle','1','3','down-square','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047555588042752','1346777623011880960','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:pluginHandler:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047640145211392','1346777623011880960','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','1','','1','0','system:pluginHandler:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047695002513408','1346777623011880960','SHENYU.BUTTON.SYSTEM.ADD','','','','2','2','','1','0','system:pluginHandler:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347047747305484288','1346777623011880960','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','3','','1','0','system:pluginHandler:edit','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346777766301888512','1357956838021890048','SHENYU.MENU.SYSTEM.MANAGMENT.AUTHEN','auth','/config/auth','auth','1','4','audit','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048004105940992','1346777766301888512','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:authen:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048101875167232','1346777766301888512','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','1','','1','0','system:authen:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048145877610496','1346777766301888512','SHENYU.BUTTON.SYSTEM.ADD','','','','2','2','','1','0','system:authen:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048240677269504','1346777766301888512','SHENYU.BUTTON.SYSTEM.ENABLE','','','','2','3','','1','0','system:authen:disable','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048316216684544','1346777766301888512','SHENYU.BUTTON.SYSTEM.SYNCHRONIZE','','','','2','4','','1','0','system:authen:modify','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048776029843456','1346777766301888512','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','5','','1','0','system:authen:edit','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350804501819195392','1346777766301888512','SHENYU.BUTTON.SYSTEM.EDITRESOURCEDETAILS','','','','2','6','','1','0','system:authen:editResourceDetails','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346777907096285184','1357956838021890048','SHENYU.MENU.SYSTEM.MANAGMENT.METADATA','metadata','/config/metadata','metadata','1','5','snippets','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347048968414179328','1346777907096285184','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:meta:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049029323862016','1346777907096285184','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','1','','1','0','system:meta:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049092552994816','1346777907096285184','SHENYU.BUTTON.SYSTEM.ADD','','','','2','2','','1','0','system:meta:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049251395481600','1346777907096285184','SHENYU.BUTTON.SYSTEM.ENABLE','','','','2','3','','1','0','system:meta:disable','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049317178945536','1346777907096285184','SHENYU.BUTTON.SYSTEM.SYNCHRONIZE','','','','2','4','','1','0','system:meta:modify','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049370014593024','1346777907096285184','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','5','','1','0','system:meta:edit','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346778036402483200','1357956838021890048','SHENYU.MENU.SYSTEM.MANAGMENT.DICTIONARY','dict','/config/dict','dict','1','6','ordered-list','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049542417264640','1346778036402483200','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:dict:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049598155370496','1346778036402483200','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','1','','1','0','system:dict:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049659023110144','1346778036402483200','SHENYU.BUTTON.SYSTEM.ADD','','','','2','2','','1','0','system:dict:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049731047698432','1346778036402483200','SHENYU.BUTTON.SYSTEM.ENABLE','','','','2','3','','1','0','system:dict:disable','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347049794008395776','1346778036402483200','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','4','','1','0','system:dict:edit','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346776175553376256','','SHENYU.MENU.SYSTEM.MANAGMENT','system','/system','system','0','2','setting','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1346777157943259136','1346776175553376256','SHENYU.MENU.SYSTEM.MANAGMENT.USER','manage','/system/manage','manage','1','1','user','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347032308726902784','1346777157943259136','SHENYU.BUTTON.SYSTEM.ADD','','','','2','0','','1','0','system:manager:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347032395901317120','1346777157943259136','SHENYU.BUTTON.SYSTEM.LIST','','','','2','1','','1','0','system:manager:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347032453707214848','1346777157943259136','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','2','','1','0','system:manager:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1347032509051056128','1346777157943259136','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','3','','1','0','system:manager:edit','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1386680049203195904','1346777157943259136','SHENYU.BUTTON.DATA.PERMISSION.CONFIG', '', '', '', 2, 0, '', 1, 0, 'system:manager:configureDataPermission', 1);

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350106119681622016','1346776175553376256','SHENYU.MENU.SYSTEM.MANAGMENT.ROLE','role','/system/role','role','1','0','usergroup-add','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350107709494804480','1350106119681622016','SHENYU.BUTTON.SYSTEM.ADD','','','','2','0','','1','0','system:role:add','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350107842236137472','1350106119681622016','SHENYU.BUTTON.SYSTEM.LIST','','','','2','1','','1','0','system:role:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350112406754766848','1350106119681622016','SHENYU.BUTTON.SYSTEM.DELETE','','','','2','2','','1','0','system:role:delete','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1350112481253994496','1350106119681622016','SHENYU.BUTTON.SYSTEM.EDIT','','','','2','3','','1','0','system:role:edit','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1355163372527050752','1346776175553376256','SHENYU.MENU.SYSTEM.MANAGMENT.RESOURCE','resource','/system/resource','resource','1','2','menu','0','0','','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1355165158419750912','1355163372527050752','SHENYU.BUTTON.RESOURCE.MENU.ADD','','','','2','1','','1','0','system:resource:addMenu','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1355165353534578688','1355163372527050752','SHENYU.BUTTON.SYSTEM.LIST','','','','2','0','','1','0','system:resource:list','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1355165475785957376','1355163372527050752','SHENYU.BUTTON.RESOURCE.MENU.DELETE','','','','2','2','','1','0','system:resource:deleteMenu','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1355165608565039104','1355163372527050752','SHENYU.BUTTON.RESOURCE.MENU.EDIT','','','','2','3','','1','0','system:resource:editMenu','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1357977745889132544','1355163372527050752','SHENYU.BUTTON.RESOURCE.BUTTON.ADD','','','','2','4','','1','0','system:resource:addButton','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1357977912126177280','1355163372527050752','SHENYU.SYSTEM.EDITOR','','','','2','5','','1','0','system:resource:editButton','1');
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES('1357977971827900416','1355163372527050752','SHENYU.SYSTEM.DELETEDATA','','','','2','6','','1','0','system:resource:deleteButton','1');

INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES ('1534577121923309568', '', 'Document', '', '/document', '', 0, 3, 'file-text', 0, 0, '', 1);
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES ('1534585430311051264', '1534577121923309568', 'API document', '', '/document/apidoc', '', 1, 0, 'api', 0, 0, '', 1);
INSERT IGNORE INTO `resource` (`id`, `parent_id`, `title`, `name`, `url`, `component`, `resource_type`, `sort`, `icon`, `is_leaf`, `is_route`, `perms`, `status`) VALUES ('1534585531108564992', '1534585430311051264', 'send', '', '', '', 2, 0, '', 1, 0, 'document:apirun:send', 1);


/* default permission */
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708572688384', '1346358560427216896', '1346775491550474240');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1357956838021890049', '1346358560427216896', '1357956838021890048');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708597854208', '1346358560427216896', '1346777449787125760');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708702711808', '1346358560427216896', '1347034027070337024');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708706906112', '1346358560427216896', '1347039054925148160');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708711100416', '1346358560427216896', '1347041326749691904');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708715294720', '1346358560427216896', '1347046566244003840');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708719489024', '1346358560427216896', '1347047143350874112');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708723683328', '1346358560427216896', '1347047203220369408');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708606242816', '1346358560427216896', '1346777623011880960');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708727877632', '1346358560427216896', '1347047555588042752');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708732071936', '1346358560427216896', '1347047640145211392');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708732071937', '1346358560427216896', '1347047695002513408');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708736266240', '1346358560427216896', '1347047747305484288');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708610437120', '1346358560427216896', '1346777766301888512');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708740460544', '1346358560427216896', '1347048004105940992');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708744654848', '1346358560427216896', '1347048101875167232');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708744654849', '1346358560427216896', '1347048145877610496');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708748849152', '1346358560427216896', '1347048240677269504');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708753043456', '1346358560427216896', '1347048316216684544');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708757237760', '1346358560427216896', '1347048776029843456');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709088587777', '1346358560427216896', '1350804501819195392');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708614631424', '1346358560427216896', '1346777907096285184');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708757237761', '1346358560427216896', '1347048968414179328');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708761432064', '1346358560427216896', '1347049029323862016');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708765626368', '1346358560427216896', '1347049092552994816');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708769820672', '1346358560427216896', '1347049251395481600');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708774014976', '1346358560427216896', '1347049317178945536');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708774014977', '1346358560427216896', '1347049370014593024');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708623020032', '1346358560427216896', '1346778036402483200');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708778209280', '1346358560427216896', '1347049542417264640');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708782403584', '1346358560427216896', '1347049598155370496');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708786597888', '1346358560427216896', '1347049659023110144');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708790792192', '1346358560427216896', '1347049731047698432');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708794986496', '1346358560427216896', '1347049794008395776');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708585271296', '1346358560427216896', '1346776175553376256');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708593659904', '1346358560427216896', '1346777157943259136');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708685934593', '1346358560427216896', '1347032308726902784');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708690128896', '1346358560427216896', '1347032395901317120');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708694323200', '1346358560427216896', '1347032453707214848');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007708698517504', '1346358560427216896', '1347032509051056128');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1386680049203195905', '1346358560427216896', '1386680049203195904');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709080199168', '1346358560427216896', '1350106119681622016');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709080199169', '1346358560427216896', '1350107709494804480');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709084393472', '1346358560427216896', '1350107842236137472');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709084393473', '1346358560427216896', '1350112406754766848');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1351007709088587776', '1346358560427216896', '1350112481253994496');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1355167519859040256', '1346358560427216896', '1355163372527050752');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1355167519859040257', '1346358560427216896', '1355165158419750912');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1355167519859040258', '1346358560427216896', '1355165353534578688');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1355167519859040259', '1346358560427216896', '1355165475785957376');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1355167519859040260', '1346358560427216896', '1355165608565039104');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1357977745893326848', '1346358560427216896', '1357977745889132544');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1357977912126177281', '1346358560427216896', '1357977912126177280');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1357977971827900417', '1346358560427216896', '1357977971827900416');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1534577122279825408', '1346358560427216896', '1534577121923309568');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1534585430587875328', '1346358560427216896', '1534585430311051264');
INSERT IGNORE INTO `permission` (`id`, `object_id`, `resource_id`) VALUES ('1534585531389583360', '1346358560427216896', '1534585531108564992');
