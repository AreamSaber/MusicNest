# 鸿音管家（HarmonySound）技术规格文档 (SPEC)

> 版本：v1.0 | 日期：2026-06-12 | 配套 PRD：v1.0

---

## 一、系统架构

### 1.1 总体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        前端层 (Frontend)                       │
│  ┌──────────────────────────┐  ┌──────────────────────────┐ │
│  │     鸿蒙 App (entry/)     │  │    Web 管理后台 (web-ui/)   │ │
│  │  ArkTS + ArkUI + Stage   │  │   Vue 3 + Element Plus    │ │
│  │  HarmonyOS NEXT API 12+  │  │   Vite + TypeScript       │ │
│  └────────────┬─────────────┘  └─────────────┬────────────┘ │
│               │                               │              │
│               └───────────────┬───────────────┘              │
├───────────────────────────────┼──────────────────────────────┤
│                          网关层                                │
│                  Nginx (反向代理 + 静态资源)                    │
├───────────────────────────────┼──────────────────────────────┤
│                          后端层 (server/)                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                Spring Boot 3.x Application             │  │
│  │  ┌─────────┐ ┌──────────┐ ┌────────┐ ┌────────────┐  │  │
│  │  │用户模块  │ │租赁订单模块│ │售后工单 │ │ 库存管理   │  │  │
│  │  └─────────┘ └──────────┘ └────────┘ └────────────┘  │  │
│  │  ┌─────────┐ ┌──────────┐ ┌──────────────────────┐   │  │
│  │  │系统管理  │ │数据分析   │ │ 安全层 (JWT + RBAC)  │   │  │
│  │  └─────────┘ └──────────┘ └──────────────────────┘   │  │
│  └───────────────────────────────────────────────────────┘  │
├───────────────────────────────┬──────────────────────────────┤
│                          数据层                                │
│  ┌──────────────────┐  ┌──────────────┐                     │
│  │    MySQL 8.0     │  │   Redis 7.x  │                     │
│  │  (核心业务数据)    │  │ (缓存/Session)│                     │
│  └──────────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 项目目录结构

```
MusicNest/                          # 项目根目录
├── entry/                          # 鸿蒙 App 模块 (已有)
│   ├── src/main/ets/
│   │   ├── entryability/           # Ability 入口
│   │   ├── pages/                  # 页面
│   │   ├── views/                  # 自定义组件
│   │   ├── model/                  # 数据模型
│   │   ├── service/                # API 服务层
│   │   ├── store/                  # 状态管理
│   │   └── utils/                  # 工具类
│   ├── src/main/resources/         # 资源文件
│   └── build-profile.json5
│
├── web-ui/                         # Vue 3 Web 管理后台 (新建)
│   ├── src/
│   │   ├── api/                    # API 请求封装
│   │   ├── assets/                 # 静态资源
│   │   ├── components/             # 公共组件
│   │   ├── composables/            # 组合式函数
│   │   ├── layouts/                # 布局组件
│   │   ├── router/                 # 路由配置
│   │   ├── stores/                 # Pinia 状态管理
│   │   ├── views/                  # 页面视图
│   │   │   ├── dashboard/          # 工作台
│   │   │   ├── order/              # 订单管理
│   │   │   ├── inventory/          # 库存管理
│   │   │   ├── workorder/          # 工单管理
│   │   │   ├── databoard/          # 数据看板（管理员）
│   │   │   └── system/             # 系统管理（管理员）
│   │   ├── utils/                  # 工具函数
│   │   ├── App.vue
│   │   └── main.ts
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
│
├── server/                         # Spring Boot 后端 (新建)
│   ├── src/main/java/com/musicnest/
│   │   ├── MusicNestApplication.java
│   │   ├── config/                 # 配置类
│   │   ├── controller/             # 控制器
│   │   ├── service/                # 业务逻辑层
│   │   │   └── impl/
│   │   ├── mapper/                 # MyBatis-Plus Mapper
│   │   ├── entity/                 # 数据库实体
│   │   ├── dto/                    # 数据传输对象
│   │   ├── vo/                     # 视图对象
│   │   ├── enums/                  # 枚举类
│   │   ├── common/                 # 公共类
│   │   │   ├── Result.java         # 统一响应
│   │   │   ├── PageResult.java     # 分页响应
│   │   │   └── exception/          # 异常处理
│   │   └── security/               # 安全相关
│   │       ├── JwtUtil.java
│   │       ├── LoginInterceptor.java
│   │       └── PermissionAspect.java
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   ├── application-dev.yml
│   │   └── mapper/                 # MyBatis XML (如需)
│   └── pom.xml
│
├── docs/                           # 项目文档 (新建)
│   ├── README.md
│   ├── PRD.md
│   ├── SPEC.md                     # 本文档
│   └── ER-DIAGRAM.md
│
├── build-profile.json5             # 鸿蒙项目构建配置
├── oh-package.json5                # 鸿蒙依赖配置
└── .gitignore
```

---

## 二、技术栈详情

### 2.1 鸿蒙端

| 项 | 选型 | 版本 | 说明 |
|----|------|------|------|
| 开发语言 | ArkTS | — | 鸿蒙官方 TypeScript 超集 |
| UI 框架 | ArkUI | — | 声明式 UI，Stage 模型 |
| SDK | HarmonyOS NEXT | API 12+ (5.0.0+) | 纯血鸿蒙 |
| IDE | DevEco Studio | 5.x | 官方 IDE |
| 网络请求 | @ohos.net.http | — | 鸿蒙原生 HTTP |
| 图片加载 | Image 组件 + 缓存 | — | 原生支持 |
| 状态管理 | @State / AppStorage | — | 鸿蒙原生状态管理 |
| 华为账号登录 | @kit.AccountKit | — | 华为账号服务 |

### 2.2 Web 管理端

| 项 | 选型 | 版本 | 说明 |
|----|------|------|------|
| 框架 | Vue 3 | ≥3.4 | Composition API |
| 语言 | TypeScript | ≥5.0 | 类型安全 |
| 构建工具 | Vite | ≥5.0 | 快速开发构建 |
| UI 组件库 | Element Plus | ≥2.5 | 成熟的管理后台组件 |
| 状态管理 | Pinia | ≥2.1 | Vue 官方推荐 |
| 路由 | Vue Router | ≥4.3 | SPA 路由 |
| HTTP 客户端 | Axios | ≥1.6 | 请求拦截、Token 注入 |
| 图表库 | ECharts | ≥5.5 | 数据看板可视化 |
| CSS 预处理 | SCSS | — | 嵌套样式、变量 |

### 2.3 后端

| 项 | 选型 | 版本 | 说明 |
|----|------|------|------|
| 框架 | Spring Boot | 3.x | Java 后端框架 |
| JDK | JDK | 17+ | LTS 版本 |
| ORM | MyBatis-Plus | ≥3.5 | 增强 MyBatis |
| 数据库 | MySQL | 8.0 | 核心业务数据 |
| 缓存 | Redis | 7.x | 验证码、Token、热点数据 |
| 认证 | JWT (jjwt) | ≥0.12 | 无状态鉴权 |
| 加密 | BCrypt | — | Spring Security 内置 |
| API 文档 | Knife4j (Swagger) | ≥4.0 | 在线接口文档 |
| 参数校验 | Jakarta Validation | — | @Valid 注解校验 |
| JSON | Jackson | — | Spring Boot 默认 |
| 工具类 | Hutool | ≥5.8 | 通用工具 |
| 对象映射 | MapStruct | ≥1.5 | DTO 转换 |

### 2.4 开发工具与环境

| 项 | 说明 |
|----|------|
| 版本管理 | Git |
| 鸿蒙 IDE | DevEco Studio 5.x |
| Web/后端 IDE | IntelliJ IDEA / VS Code |
| 数据库管理 | Navicat / DBeaver |
| API 测试 | Knife4j 在线文档 / Apifox |
| 项目管理 | 毕设进度表 |

---

## 三、数据库设计

### 3.1 ER 关系概述

```
user ──< rental_order >── instrument
user ──< maintenance_order >── instrument
user ──< review
rental_order ──< payment
rental_order ──< maintenance_order
rental_order ──< review
instrument ──< instrument_image
staff ──< maintenance_order (assignee)
```

### 3.2 完整表结构 (DDL)

#### 3.2.1 user — 用户表（C端）

```sql
CREATE TABLE `user` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `phone`        VARCHAR(20)  NOT NULL COMMENT '手机号',
    `password`     VARCHAR(255)          DEFAULT NULL COMMENT '密码（验证码登录可为空）',
    `nickname`     VARCHAR(50)           DEFAULT NULL COMMENT '昵称',
    `avatar`       VARCHAR(500)          DEFAULT NULL COMMENT '头像URL',
    `real_name`    VARCHAR(20)           DEFAULT NULL COMMENT '真实姓名',
    `id_card`      VARCHAR(18)           DEFAULT NULL COMMENT '身份证号',
    `id_card_front` VARCHAR(500)         DEFAULT NULL COMMENT '身份证正面照URL',
    `id_card_back`  VARCHAR(500)         DEFAULT NULL COMMENT '身份证反面照URL',
    `verify_status` TINYINT     NOT NULL DEFAULT 0 COMMENT '实名认证状态: 0-未认证 1-审核中 2-已通过 3-已驳回',
    `credit_score` INT         NOT NULL DEFAULT 600 COMMENT '信用分 (0-1000)',
    `credit_level` TINYINT     NOT NULL DEFAULT 2 COMMENT '信用等级: 1-优秀 2-良好 3-一般 4-较差',
    `status`       TINYINT     NOT NULL DEFAULT 1 COMMENT '账号状态: 0-禁用 1-正常',
    `huawei_open_id` VARCHAR(100)        DEFAULT NULL COMMENT '华为账号OpenID',
    `last_login_at` DATETIME             DEFAULT NULL COMMENT '最后登录时间',
    `created_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`),
    UNIQUE KEY `uk_huawei_open_id` (`huawei_open_id`),
    KEY `idx_verify_status` (`verify_status`),
    KEY `idx_credit_score` (`credit_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表（C端）';
```

#### 3.2.2 staff — 员工表（B端）

```sql
CREATE TABLE `staff` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '员工ID',
    `username`     VARCHAR(50)  NOT NULL COMMENT '登录账号',
    `password`     VARCHAR(255) NOT NULL COMMENT '密码 (BCrypt)',
    `real_name`    VARCHAR(20)  NOT NULL COMMENT '真实姓名',
    `phone`        VARCHAR(20)           DEFAULT NULL COMMENT '手机号',
    `role`         VARCHAR(20)  NOT NULL DEFAULT 'ROLE_STAFF' COMMENT '角色: ROLE_STAFF / ROLE_ADMIN',
    `status`       TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-正常',
    `last_login_at` DATETIME             DEFAULT NULL COMMENT '最后登录时间',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工表（B端）';
```

#### 3.2.3 instrument — 乐器表

```sql
CREATE TABLE `instrument` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT COMMENT '乐器ID',
    `name`             VARCHAR(100)  NOT NULL COMMENT '乐器名称',
    `category`         VARCHAR(30)   NOT NULL COMMENT '分类: piano/guitar/violin/wind/folk/percussion',
    `brand`            VARCHAR(50)   NOT NULL COMMENT '品牌',
    `model`            VARCHAR(100)           DEFAULT NULL COMMENT '型号',
    `serial_no`        VARCHAR(50)            DEFAULT NULL COMMENT '序列号/编号',
    `condition_level`  TINYINT       NOT NULL DEFAULT 3 COMMENT '成色: 1-全新 2-95新 3-9成新 4-8成新 5-较旧',
    `description`      TEXT                   DEFAULT NULL COMMENT '描述',
    `specs`            JSON                   DEFAULT NULL COMMENT '规格参数 (JSON)',
    `daily_price`      DECIMAL(10,2) NOT NULL COMMENT '日租金',
    `weekly_price`     DECIMAL(10,2)          DEFAULT NULL COMMENT '周租金',
    `monthly_price`    DECIMAL(10,2)          DEFAULT NULL COMMENT '月租金',
    `deposit`          DECIMAL(10,2) NOT NULL COMMENT '押金',
    `deposit_ratio`    DECIMAL(5,4)  NOT NULL DEFAULT 1.0000 COMMENT '押金比例',
    `purchase_price`   DECIMAL(10,2)          DEFAULT NULL COMMENT '购入价值',
    `purchase_date`    DATE                   DEFAULT NULL COMMENT '购入日期',
    `current_value`    DECIMAL(10,2)          DEFAULT NULL COMMENT '当前估值 (折旧后)',
    `depreciation_rate` DECIMAL(5,4)          DEFAULT 0.1000 COMMENT '年折旧率',
    `status`           VARCHAR(20)   NOT NULL DEFAULT 'available' COMMENT '状态: available/rented/maintenance/scrapped',
    `applicable_level` VARCHAR(20)            DEFAULT 'all' COMMENT '适用人群: beginner/intermediate/professional/all',
    `stock_count`      INT           NOT NULL DEFAULT 1 COMMENT '库存数量（同型号）',
    `rent_count`       INT           NOT NULL DEFAULT 0 COMMENT '已租出数量',
    `sort_order`       INT                    DEFAULT 0 COMMENT '排序权重',
    `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_status` (`status`),
    KEY `idx_brand` (`brand`),
    KEY `idx_daily_price` (`daily_price`),
    KEY `idx_condition` (`condition_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='乐器表';
```

#### 3.2.4 instrument_image — 乐器图片表

```sql
CREATE TABLE `instrument_image` (
    `id`            BIGINT       NOT NULL AUTO_INCREMENT,
    `instrument_id` BIGINT       NOT NULL COMMENT '乐器ID',
    `image_url`     VARCHAR(500) NOT NULL COMMENT '图片URL',
    `is_cover`      TINYINT      NOT NULL DEFAULT 0 COMMENT '是否封面: 0-否 1-是',
    `sort_order`    INT                   DEFAULT 0 COMMENT '排序',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_instrument_id` (`instrument_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='乐器图片表';
```

#### 3.2.5 rental_order — 租赁订单表

```sql
CREATE TABLE `rental_order` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT COMMENT '订单ID',
    `order_no`         VARCHAR(32)   NOT NULL COMMENT '订单号 (系统生成)',
    `user_id`          BIGINT        NOT NULL COMMENT '用户ID',
    `instrument_id`    BIGINT        NOT NULL COMMENT '乐器ID',
    `start_date`       DATE          NOT NULL COMMENT '租赁开始日期',
    `end_date`         DATE          NOT NULL COMMENT '预计归还日期',
    `actual_return_date` DATE                 DEFAULT NULL COMMENT '实际归还日期',
    `rent_days`        INT           NOT NULL COMMENT '租赁天数',
    `daily_price`      DECIMAL(10,2) NOT NULL COMMENT '下单时日租金（快照）',
    `deposit_amount`   DECIMAL(10,2) NOT NULL COMMENT '押金金额',
    `rent_amount`      DECIMAL(10,2) NOT NULL COMMENT '租金金额',
    `late_fee`         DECIMAL(10,2)          DEFAULT 0 COMMENT '滞纳金',
    `total_amount`     DECIMAL(10,2) NOT NULL COMMENT '实付总金额',
    `status`           VARCHAR(20)   NOT NULL DEFAULT 'pending' COMMENT '状态: pending/renting/returning/completed/cancelled/overdue',
    `delivery_type`    VARCHAR(20)            DEFAULT 'pickup' COMMENT '配送方式: pickup-自提 delivery-配送',
    `delivery_address` VARCHAR(255)           DEFAULT NULL COMMENT '配送地址',
    `remark`           VARCHAR(500)           DEFAULT NULL COMMENT '用户备注',
    `cancel_reason`    VARCHAR(255)           DEFAULT NULL COMMENT '取消原因',
    `parent_order_id`  BIGINT                 DEFAULT NULL COMMENT '续租关联原订单ID',
    `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_instrument_id` (`instrument_id`),
    KEY `idx_status` (`status`),
    KEY `idx_start_date` (`start_date`),
    KEY `idx_parent_order_id` (`parent_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租赁订单表';
```

#### 3.2.6 payment — 支付记录表

```sql
CREATE TABLE `payment` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT,
    `order_id`         BIGINT        NOT NULL COMMENT '关联订单ID',
    `user_id`          BIGINT        NOT NULL COMMENT '用户ID',
    `payment_no`       VARCHAR(32)   NOT NULL COMMENT '支付流水号',
    `amount`           DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    `type`             VARCHAR(20)   NOT NULL COMMENT '类型: deposit-押金 rental-租金 late_fee-滞纳金 refund-退款 repair-维修费',
    `method`           VARCHAR(20)   NOT NULL DEFAULT 'mock' COMMENT '支付方式: mock-模拟 alipay-支付宝 wechat-微信',
    `status`           VARCHAR(20)   NOT NULL DEFAULT 'pending' COMMENT '状态: pending/success/failed/refunded',
    `refund_amount`    DECIMAL(10,2)          DEFAULT NULL COMMENT '退款金额',
    `refund_reason`    VARCHAR(255)           DEFAULT NULL COMMENT '退款原因',
    `paid_at`          DATETIME               DEFAULT NULL COMMENT '支付完成时间',
    `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_payment_no` (`payment_no`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_type` (`type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';
```

#### 3.2.7 maintenance_order — 维修工单表

```sql
CREATE TABLE `maintenance_order` (
    `id`               BIGINT        NOT NULL AUTO_INCREMENT COMMENT '工单ID',
    `order_no`         VARCHAR(32)   NOT NULL COMMENT '工单号',
    `rental_order_id`  BIGINT                 DEFAULT NULL COMMENT '关联租赁订单ID',
    `instrument_id`    BIGINT        NOT NULL COMMENT '关联乐器ID',
    `user_id`          BIGINT        NOT NULL COMMENT '报修用户ID',
    `assignee_id`      BIGINT                 DEFAULT NULL COMMENT '指派的员工ID',
    `fault_desc`       TEXT          NOT NULL COMMENT '故障描述',
    `fault_images`     JSON                   DEFAULT NULL COMMENT '故障图片URL数组',
    `urgency`          VARCHAR(10)   NOT NULL DEFAULT 'normal' COMMENT '紧急程度: normal/urgent',
    `status`           VARCHAR(20)   NOT NULL DEFAULT 'pending' COMMENT '状态: pending/assigned/repairing/checking/completed',
    `diagnosis`        TEXT                   DEFAULT NULL COMMENT '故障诊断',
    `repair_content`   TEXT                   DEFAULT NULL COMMENT '维修内容',
    `repair_parts`     VARCHAR(500)           DEFAULT NULL COMMENT '更换配件',
    `repair_cost`      DECIMAL(10,2)          DEFAULT 0 COMMENT '维修费用',
    `checking_started_at` DATETIME           DEFAULT NULL COMMENT '进入待验收的时间（用于超3天自动完成判断）',
    `completed_at`     DATETIME               DEFAULT NULL COMMENT '完成时间',
    `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_rental_order_id` (`rental_order_id`),
    KEY `idx_instrument_id` (`instrument_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_assignee_id` (`assignee_id`),
    KEY `idx_status` (`status`),
    KEY `idx_urgency` (`urgency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修工单表';
```

#### 3.2.8 maintenance_log — 工单流转日志表

```sql
CREATE TABLE `maintenance_log` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `order_id`     BIGINT       NOT NULL COMMENT '工单ID',
    `operator_id`  BIGINT       NOT NULL COMMENT '操作人ID (用户或员工)',
    `operator_type` VARCHAR(10) NOT NULL COMMENT '操作人类型: user/staff',
    `action`       VARCHAR(30)  NOT NULL COMMENT '操作: create/assign/start_repair/complete/confirm',
    `remark`       VARCHAR(500)          DEFAULT NULL COMMENT '备注',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单流转日志表';
```

#### 3.2.9 review — 评价表

```sql
CREATE TABLE `review` (
    `id`            BIGINT        NOT NULL AUTO_INCREMENT,
    `user_id`       BIGINT        NOT NULL COMMENT '评价用户ID',
    `rental_order_id` BIGINT               DEFAULT NULL COMMENT '关联租赁订单ID',
    `maintenance_order_id` BIGINT          DEFAULT NULL COMMENT '关联维修工单ID',
    `instrument_id` BIGINT                 DEFAULT NULL COMMENT '关联乐器ID',
    `type`          VARCHAR(10)   NOT NULL COMMENT '评价类型: rental/maintenance',
    `rating`        TINYINT       NOT NULL COMMENT '评分 (1-5)',
    `content`       VARCHAR(500)           DEFAULT NULL COMMENT '评价内容',
    `images`        JSON                   DEFAULT NULL COMMENT '评价图片',
    `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_rental_order_id` (`rental_order_id`),
    KEY `idx_instrument_id` (`instrument_id`),
    KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评价表';
```

#### 3.2.10 notification — 通知表

```sql
CREATE TABLE `notification` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT       NOT NULL COMMENT '接收用户ID',
    `type`       VARCHAR(30)  NOT NULL COMMENT '通知类型: order/repair/system',
    `title`      VARCHAR(100) NOT NULL COMMENT '通知标题',
    `content`    VARCHAR(500) NOT NULL COMMENT '通知内容',
    `is_read`    TINYINT      NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读 1-已读',
    `related_id` BIGINT                DEFAULT NULL COMMENT '关联业务ID',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id_read` (`user_id`, `is_read`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';
```

#### 3.2.11 sys_dict — 系统字典表

```sql
CREATE TABLE `sys_dict` (
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `dict_type`  VARCHAR(50)  NOT NULL COMMENT '字典类型: instrument_category/brand',
    `dict_key`   VARCHAR(50)  NOT NULL COMMENT '字典键',
    `dict_value` VARCHAR(100) NOT NULL COMMENT '字典值',
    `sort_order` INT                   DEFAULT 0 COMMENT '排序',
    `status`     TINYINT      NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_type_key` (`dict_type`, `dict_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统字典表';
```

#### 3.2.12 sys_config — 系统配置表

```sql
CREATE TABLE `sys_config` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `config_key`  VARCHAR(50)  NOT NULL COMMENT '配置键',
    `config_value` VARCHAR(255) NOT NULL COMMENT '配置值',
    `description` VARCHAR(200)          DEFAULT NULL COMMENT '说明',
    `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';
```

> **JSON 字段 TypeHandler 配置**：`instrument.specs`、`maintenance_order.fault_images`、`review.images` 三个字段为 MySQL JSON 类型，MyBatis-Plus 实体类中需配置：
> ```java
> @TableField(typeHandler = JacksonTypeHandler.class)
> private JSONObject specs;  // 或 private String specs; 手动序列化
> ```
> 或在 `application.yml` 中注册全局 TypeHandler：`mybatis-plus.type-handlers-package: com.musicnest.handler`

---

## 四、API 接口设计

### 4.1 接口规范

| 项 | 规范 |
|----|------|
| 协议 | HTTP/HTTPS |
| 格式 | JSON |
| 编码 | UTF-8 |
| 版本 | URL 路径版本 `/api/v1/` |
| 鉴权 | Header: `Authorization: Bearer <token>` |
| 统一响应 | `{ "code": 200, "message": "success", "data": {...} }` |
| 分页响应 | `{ "code": 200, "data": { "records": [...], "total": 100, "page": 1, "size": 10 } }` |
| 错误响应 | `{ "code": 400, "message": "参数错误", "data": null }` |

### 4.2 状态码约定

| code | 含义 |
|------|------|
| 200 | 成功 |
| 400 | 参数校验失败 |
| 401 | 未登录/Token 过期 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 业务冲突（如重复操作） |
| 500 | 服务器内部错误 |

### 4.3 接口清单

#### 4.3.1 认证模块 `/api/v1/auth`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| POST | `/auth/send-code` | 发送手机验证码 | 否 |
| POST | `/auth/login` | 手机号+验证码登录 | 否 |
| POST | `/auth/huawei-login` | 华为账号一键登录 | 否 |
| POST | `/auth/staff-login` | 员工/管理员账号密码登录 | 否 |
| POST | `/auth/refresh-token` | 刷新 Token | 否 |
| GET | `/auth/logout` | 退出登录 | 是 |

#### 4.3.2 用户模块 `/api/v1/user`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| GET | `/user/profile` | 获取个人信息 | 是 |
| PUT | `/user/profile` | 更新个人信息 | 是 |
| POST | `/user/verify` | 提交实名认证 | 是 |
| GET | `/user/credit` | 获取信用分与明细 | 是 |
| GET | `/user/notifications` | 获取通知列表（分页） | 是 |
| PUT | `/user/notifications/{id}/read` | 标记通知已读 | 是 |

#### 4.3.3 文件上传 `/api/v1/files`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| POST | `/files/upload` | 上传文件（multipart/form-data），type=instrument/idcard/repair/review/avatar | 是 |
| GET | `/files/{filename}` | 查看文件（静态资源映射） | 否 |

> **上传参数**：`file` (必填, ≤5MB, jpg/png/webp), `type` (必填, 用于分类存储目录)  
> **返回**：`{ "url": "/api/v1/files/2026/06/xxx.jpg" }`  
> **存储方案**：本地存储至 `server/static/uploads/{type}/` 目录，通过 Spring Boot `spring.web.resources.static-locations` 映射为静态资源 URL

#### 4.3.4 乐器模块 `/api/v1/instruments`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| GET | `/instruments` | 乐器列表（分页+筛选） | 否 |
| GET | `/instruments/{id}` | 乐器详情 | 否 |
| GET | `/instruments/hot` | 热门乐器 TOP N | 否 |
| GET | `/instruments/recommend` | 智能推荐（需登录） | 是 |
| GET | `/instruments/{id}/reviews` | 乐器评价列表 | 否 |
| POST | `/instruments` | 新增乐器（入库） | STAFF+ |
| PUT | `/instruments/{id}` | 更新乐器信息 | STAFF+ |
| PUT | `/instruments/{id}/status` | 变更乐器状态 | STAFF+ |
| DELETE | `/instruments/{id}` | 删除乐器（软删/标记报废） | ADMIN |

#### 4.3.5 订单模块 `/api/v1/orders`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| POST | `/orders` | 创建租赁订单 | 是(USER) |
| GET | `/orders` | 订单列表（分页+筛选） | 是 |
| GET | `/orders/{id}` | 订单详情 | 是 |
| POST | `/orders/{id}/pay` | 支付订单 | 是(USER) |
| POST | `/orders/{id}/renew` | 续租申请 | 是(USER) |
| POST | `/orders/{id}/return-booking` | 归还预约 | 是(USER) |
| PUT | `/orders/{id}/approve` | 审核通过，直接进入租赁中（员工） | STAFF+ |
| PUT | `/orders/{id}/reject` | 审核驳回，退还押金（员工） | STAFF+ |
| PUT | `/orders/{id}/complete-return` | 确认归还验收，结算退还押金（员工） | STAFF+ |
| PUT | `/orders/{id}/cancel` | 取消订单，释放库存与退还押金 | 是 |
| GET | `/orders/overdue` | 逾期订单列表 | STAFF+ |

#### 4.3.6 工单模块 `/api/v1/work-orders`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| POST | `/work-orders` | 用户提交报修 | 是(USER) |
| GET | `/work-orders` | 工单列表（分页+筛选） | 是 |
| GET | `/work-orders/{id}` | 工单详情（含流转日志） | 是 |
| PUT | `/work-orders/{id}/assign` | 派单（员工） | STAFF+ |
| PUT | `/work-orders/{id}/start-repair` | 开始维修（员工） | STAFF+ |
| PUT | `/work-orders/{id}/complete-repair` | 完成维修（员工） | STAFF+ |
| PUT | `/work-orders/{id}/confirm` | 用户验收确认 | 是(USER) |

#### 4.3.7 评价模块 `/api/v1/reviews`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| POST | `/reviews` | 提交评价 | 是(USER) |
| GET | `/reviews` | 评价列表（分页） | 否 |

#### 4.3.8 数据看板 `/api/v1/dashboard` (ADMIN)

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| GET | `/dashboard/pending` | 待处理摘要（新订单数/待派单数/逾期数） | STAFF+ |
| GET | `/dashboard/revenue` | 营收概览（日/周/月） | ADMIN |
| GET | `/dashboard/rental-stats` | 租赁统计（品类/趋势） | ADMIN |
| GET | `/dashboard/user-stats` | 用户统计 | ADMIN |
| GET | `/dashboard/workorder-stats` | 工单统计 | ADMIN |

#### 4.3.9 系统管理 `/api/v1/admin` (ADMIN)

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|:----:|
| GET | `/admin/staff` | 员工列表 | ADMIN |
| POST | `/admin/staff` | 新增员工 | ADMIN |
| PUT | `/admin/staff/{id}` | 编辑员工 | ADMIN |
| PUT | `/admin/staff/{id}/status` | 启用/禁用员工 | ADMIN |
| PUT | `/admin/staff/{id}/reset-pwd` | 重置密码 | ADMIN |
| GET | `/admin/dicts` | 字典列表 | ADMIN |
| POST | `/admin/dicts` | 新增字典项 | ADMIN |
| PUT | `/admin/dicts/{id}` | 编辑字典项 | ADMIN |
| GET | `/admin/configs` | 系统配置列表 | ADMIN |
| PUT | `/admin/configs` | 更新系统配置 | ADMIN |

---

## 五、安全设计

### 5.1 认证流程

```
[鸿蒙端]
  用户 → 手机号 + 验证码 → POST /auth/login → 返回 JWT → 存入本地 → 后续请求携带 Token

[Web端]
  员工 → 账号 + 密码 → POST /auth/staff-login → 返回 JWT → 存入 localStorage → Axios 拦截器自动携带

[Token 刷新]
  Access Token 过期 (24h/4h) → 使用 Refresh Token → POST /auth/refresh-token → 新 Token
  Refresh Token 存储在 Redis 中，key = "refresh_token:{token}", value = userId, TTL = 7天
```

### 5.2 RBAC 权限模型

```
用户表 (user)               员工表 (staff)
    │                            │
    │                            ├── role: ROLE_STAFF / ROLE_ADMIN
    │                            │
    │                            └── 后端 @PreAuthorize 注解控制
    │
    └── C端用户，所有接口限定只能操作自己的数据
```

- C端：通过 Token 中的 userId 校验"只能操作自己的数据"
- B端：通过角色注解 `@PreAuthorize("hasRole('ADMIN')")` 控制接口访问
- 更细粒度的数据权限在 Service 层实现

### 5.3 安全措施

| 措施 | 实现 |
|------|------|
| 密码加密 | BCryptPasswordEncoder |
| Token 签名 | HMAC-SHA256，密钥外部化配置 |
| CORS | 允许 Web 管理端域名（鸿蒙端为原生应用，不受浏览器 CORS 策略限制，后端不做 CORS 校验） |
| SQL 注入 | MyBatis-Plus 参数化查询，禁止拼接 SQL |
| XSS | 前端统一输出编码，后端 HTML 特殊字符过滤 |
| 敏感数据 | 日志中手机号中间 4 位脱敏，身份证号脱敏 |
| 验证码 | 5 分钟有效，单手机号频率限制 (Redis) |
| 登录保护 | 连续 5 次失败锁定 30 分钟 (Redis) |

---

## 六、关键业务状态机

### 6.1 租赁订单状态流转

```
                    ┌─────────┐
                    │ pending  │  ← 用户下单并支付
                    │ 待处理   │
                    └────┬────┘
                         │
              ┌──────────┼──────────┐
              │ 审核通过  │          │ 驳回/超时未付
              ▼           │          ▼
       ┌──────────┐      │   ┌──────────┐
       │ renting  │      │   │cancelled │
       │ 租赁中   │      │   │ 已取消   │
       └────┬─────┘      │   └──────────┘
            │            │
    ┌───────┼───────┐    │
    │续租   │       │归还预约
    ▼       │       ▼
┌──────┐   │  ┌───────────┐
│renting│   │  │ returning │
│(续租) │   │  │  待归还   │
└──────┘   │  └─────┬─────┘
           │        │ 确认归还 → 退押金
           │        ▼
           │  ┌───────────┐
           │  │ completed │  ← 完成
           │  │  已完成   │
           │  └───────────┘
           │
           │  超时未归还/未续租
           ▼
      ┌──────────┐
      │ overdue  │  ← 逾期（可缴滞纳金后归还）
      │  逾期中  │
      └──────────┘

状态说明（共 6 个状态）：
  pending   → 已下单支付，等待门店审核
  renting   → 审核通过，乐器在用户手中
  returning → 用户已预约归还，等待门店确认验收
  completed → 归还确认完成，押金已退
  cancelled → 审核驳回 或 超时未支付 或 用户主动取消
  overdue   → 超期未归还，滞纳金累计中
```

### 6.2 维修工单状态流转

```
┌──────────┐
│ pending   │  ← 用户提交报修
│ 待派单    │
└────┬─────┘
     │ assign (员工派单)
     ▼
┌──────────┐
│ assigned  │
│ 已派单    │
└────┬─────┘
     │ start (开始维修)
     ▼
┌──────────┐
│repairing │  ← 维修中（超7天自动标记"超期"，查询时动态计算）
│ 维修中   │
└────┬─────┘
     │ complete (维修完成)
     ▼
┌──────────┐
│ checking  │  ← 等待用户验收（超3天未确认则系统自动完成）
│ 待验收   │
└────┬─────┘
     │ confirm (用户确认 / 系统自动)
     ▼
┌──────────┐
│completed │
│ 已完成   │
└──────────┘
```

> **超时处理策略**（查询时动态计算，无需定时任务）：
> - `repairing` 状态：`DATEDIFF(NOW(), created_at) > 7` → 前端展示"超期"标记，列表置顶
> - `checking` 状态：`DATEDIFF(NOW(), checking_started_at) > 3` → 下次接口查询时自动转为 `completed`
> - `checking_started_at` 在 `completeRepair()` 方法中写入：`maintenanceOrder.setCheckingStartedAt(new Date())`

---

## 七、鸿蒙端设计

### 7.1 页面路由表

| 路由路径 | 页面 | 说明 |
|----------|------|------|
| `pages/Index` | 首页（Tab 容器） | 底部导航 |
| `pages/Login` | 登录页 | 验证码登录 / 华为账号登录 |
| `pages/InstrumentList` | 乐器列表 | 分类浏览 + 筛选 |
| `pages/InstrumentDetail` | 乐器详情 | 图文详情 + 价格阶梯 + 评价 |
| `pages/OrderCreate` | 下单页 | 选租期 → 确认信息 → 支付 |
| `pages/OrderList` | 订单列表 | Tab 切换状态 |
| `pages/OrderDetail` | 订单详情 | 状态时间轴 + 续租/归还预约入口 |
| `pages/OrderRenew` | 续租申请 | 选择续租时长 → 确认 → 支付续租费用 |
| `pages/ReturnBooking` | 归还预约 | 选择归还日期 → 确认预约 |
| `pages/MaintenanceCreate` | 报修提交 | 描述 + 拍照 |
| `pages/MaintenanceDetail` | 维修详情 | 进度时间轴 |
| `pages/ReviewCreate` | 提交评价 | 星级评分 + 文字 + 图片上传 |
| `pages/MyReviews` | 我的评价 | 评价列表 |
| `pages/Profile` | 个人中心 | 资料 + 信用分 + 入口 |
| `pages/VerifyIdCard` | 实名认证 | 身份证上传 |
| `pages/MyReviews` | 我的评价 | 评价列表 |

> **设计稿来源**：鸿蒙端拥有来自 "Harmonious Instrument Suite" 设计系统的 14 张高保真设计稿（见 `设计稿/` 目录），设计规范见 [DESIGN.md](./设计稿/.../DESIGN.md)。其中 `Login`、`Profile`、`VerifyIdCard` 三页仅有截图无 HTML 代码，实现时需参考已有设计 Token（色板 `#2e02e9` / `#f9f9ff`、字体 Hanken Grotesk、圆角 24px 卡片、玻璃态底部导航）自行完成。

#### 7.1.1 设计稿关键 UI 细节

以下细节来自设计稿，开发时直接参照：

| 页面 | 设计亮点 | 实现要点 |
|------|----------|------|
| 首页 `Index` (_6) | Banner 轮播（首月半价）+ 4×2 分类宫格 + "猜你喜欢"AI 推荐卡片（左上角 `AI推荐` 标签）+ 热门租赁 2 列网格 | Material Symbols 图标（`piano/guitar/music_note` 等 8 个分类图标） |
| 乐器详情 `InstrumentDetail` (_9) | **三级价格阶梯**：日/周/月三列，月租标记 `BEST VALUE` 角标 + 可展开规格参数 + 评分星级 | 月租列使用 `primary-container` 背景高亮 |
| 下单确认 `OrderCreate` (_10) | 进度条（选择→确认→支付）+ 时长横向滑动选择器（1/6/12月，"推荐"角标）+ 费用明细中含 **信用免押** 绿色行（`-¥5,000.00`） | 信用免押行用 `bg-tertiary-container/10` + `text-tertiary`，搭配 `verified_user` 图标 |
| 乐器列表 `InstrumentList` (_12) | **已租出乐器灰显**：`grayscale-[30%]` + 半透明 + 蒙层 "已租出" 标签 | 第三张卡片展示 Rented 态处理 |
| 订单列表 `OrderList` (_13) | **三态配色**：租赁中=绿色(`text-tertiary-container`)、待支付=红色(`text-error`)、已完成=灰色(`text-outline`) | 状态标签用对应颜色的半透明背景 |
| 续租 `OrderRenew` (_14) | **折扣标签**：3个月95折、6个月9折，选中态高亮，折扣值以角标形式浮动在卡片右上角 | Radio 选中态 `border-primary` + `bg-primary/5` |
| 评价 `ReviewCreate` (_8) | 5 星评分交互动效（`star-active` / `star-inactive` CSS 类切换）+ 文字评价 500 字 + 图片上传 | Material Symbols `star` 图标，`FILL` 属性控制填充 |

### 7.2 状态管理

| 状态 | 存储方式 | 说明 |
|------|----------|------|
| 用户 Token | AppStorage | 全局持久化 |
| 用户信息 | AppStorage | 登录后写入 |
| 当前页面状态 | @State / @Prop | 组件内状态 |
| 列表数据 | @State | 页面级 |

### 7.3 网络层封装

```
utils/HttpClient.ts
  ├── baseUrl: 'http://<server>:8080/api/v1'
  ├── 自动附加 Authorization Header
  ├── 统一错误处理 (401 → 跳转登录)
  └── 请求/响应拦截
```

### 7.4 华为账号一键登录集成

```
1. 引入 @kit.AccountKit
2. 调用华为账号授权 SDK，获取 Authorization Code
3. 将 code 发送至后端 POST /auth/huawei-login
4. 后端通过 code 换取用户信息（OpenID、手机号等）
5. 返回 JWT Token，前端存储并跳转首页
```

---

## 八、Web 管理端设计

### 8.1 路由表

| 路由 | 页面组件 | 权限 | 说明 |
|------|----------|:----:|------|
| `/login` | Login.vue | 公开 | 登录页 |
| `/` | Layout.vue | STAFF+ | 主布局（侧边栏+顶栏） |
| `/dashboard` | Dashboard.vue | STAFF+ | 工作台概览 |
| `/orders` | OrderList.vue | STAFF+ | 订单列表 |
| `/orders/:id` | OrderDetail.vue | STAFF+ | 订单详情 |
| `/inventory` | InstrumentList.vue | STAFF+ | 库存列表 |
| `/inventory/add` | InstrumentForm.vue | STAFF+ | 入库登记 |
| `/inventory/:id/edit` | InstrumentForm.vue | STAFF+ | 编辑乐器 |
| `/work-orders` | WorkOrderList.vue | STAFF+ | 工单列表 |
| `/work-orders/:id` | WorkOrderDetail.vue | STAFF+ | 工单详情 |
| `/databoard` | DataBoard.vue | ADMIN | 数据看板 |
| `/system/staff` | StaffList.vue | ADMIN | 员工管理 |
| `/system/config` | SystemConfig.vue | ADMIN | 系统配置 |

### 8.2 组件树

```
App.vue
├── Login.vue
└── Layout.vue
    ├── Sidebar.vue          # 左侧菜单（根据角色动态渲染）
    ├── HeaderBar.vue        # 顶栏（用户信息/退出）
    └── <router-view>
        ├── Dashboard.vue        # 工作台：待处理摘要（新订单/待派单/逾期）+ 图表（ADMIN）
        ├── OrderList.vue
        ├── OrderDetail.vue
        │   └── OrderTimeline.vue  # 订单时间轴
        ├── InstrumentList.vue
        ├── InstrumentForm.vue
        │   └── ImageUpload.vue    # 图片上传组件
        ├── WorkOrderList.vue
        ├── WorkOrderDetail.vue
        │   └── WorkOrderTimeline.vue
        ├── DataBoard.vue
        │   ├── RevenueChart.vue   # 营收折线图
        │   ├── CategoryPie.vue    # 品类饼图
        │   └── HotRank.vue        # 热门排行柱状图
        ├── StaffList.vue
        └── SystemConfig.vue
```

### 8.3 Pinia Store 设计

| Store | 说明 |
|-------|------|
| `useAuthStore` | Token、员工信息、登录/退出方法 |
| `useOrderStore` | 订单列表缓存、筛选条件 |
| `useInstrumentStore` | 乐器列表缓存 |
| `useAppStore` | 侧边栏折叠状态、面包屑 |

### 8.4 Axios 封装

```typescript
// api/request.ts
const service = axios.create({
  baseURL: '/api/v1',
  timeout: 15000
})

// 请求拦截：附加 Token
service.interceptors.request.use(config => {
  const token = useAuthStore().token
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// 响应拦截：统一错误处理
service.interceptors.response.use(
  res => res.data,
  err => {
    if (err.response.status === 401) {
      // Token 过期 → 跳转登录
      useAuthStore().logout()
      router.push('/login')
    }
    return Promise.reject(err)
  }
)
```

---

## 九、后端模块设计

### 9.1 包结构

```
com.musicnest
├── config/
│   ├── WebMvcConfig.java          # CORS、拦截器注册
│   ├── MyBatisPlusConfig.java     # 分页插件
│   ├── RedisConfig.java           # Redis 序列化
│   ├── Knife4jConfig.java         # API 文档
│   └── ThreadPoolConfig.java      # 线程池
├── controller/
│   ├── AuthController.java
│   ├── UserController.java
│   ├── InstrumentController.java
│   ├── OrderController.java
│   ├── WorkOrderController.java
│   ├── ReviewController.java
│   ├── DashboardController.java
│   └── AdminController.java
├── service/
│   ├── AuthService.java
│   ├── UserService.java
│   ├── InstrumentService.java
│   ├── OrderService.java
│   ├── WorkOrderService.java
│   ├── ReviewService.java
│   ├── RecommendService.java      # 智能推荐（大模型API）
│   ├── CreditService.java         # 信用分计算
│   ├── DashboardService.java
│   └── impl/                      # 实现类
├── mapper/
│   ├── UserMapper.java
│   ├── StaffMapper.java
│   ├── InstrumentMapper.java
│   ├── InstrumentImageMapper.java
│   ├── RentalOrderMapper.java
│   ├── PaymentMapper.java
│   ├── MaintenanceOrderMapper.java
│   ├── MaintenanceLogMapper.java
│   ├── ReviewMapper.java
│   ├── NotificationMapper.java
│   ├── SysDictMapper.java
│   └── SysConfigMapper.java
├── entity/                        # 与数据库表一一对应
├── dto/                           # 请求体对象
│   ├── LoginDTO.java
│   ├── OrderCreateDTO.java
│   ├── PageQueryDTO.java
│   └── ...
├── vo/                            # 响应体对象
│   ├── UserVO.java
│   ├── OrderVO.java
│   ├── InstrumentVO.java
│   └── ...
├── enums/
│   ├── OrderStatus.java
│   ├── MaintenanceStatus.java
│   ├── InstrumentStatus.java
│   └── RoleEnum.java
├── common/
│   ├── Result.java                # 统一响应体
│   ├── PageResult.java            # 分页响应体
│   ├── BusinessException.java     # 业务异常
│   └── GlobalExceptionHandler.java
└── security/
    ├── JwtUtil.java               # JWT 工具类
    ├── AuthInterceptor.java       # 登录拦截器
    └── StaffUserDetails.java      # B端用户凭证
```

### 9.2 关键业务逻辑

#### 9.2.1 下单、支付与库存管理

```java
@Transactional
public OrderVO createOrder(OrderCreateDTO dto) {
    // 1. 校验用户是否已实名
    // 2. 校验用户当前租赁数量 < 3
    // 3. 查询乐器，校验状态为 available
    // 4. 悲观锁锁定乐器行 (SELECT ... FOR UPDATE)
    // 5. 更新乐器 status = 'rented', rent_count + 1
    // 6. 计算租金 = 日租金 × 天数 × 折扣系数
    // 7. 计算押金 = 乐器押金 × 信用折扣
    // 8. 创建 order (status=pending)
    // 9. 创建 payment (status=success, method=mock) ← 模拟支付
    // 10. 发送通知
    // 11. 返回订单信息
}

// --- 取消订单（含库存回滚） ---
@Transactional
public void cancelOrder(Long orderId, String reason) {
    // 1. 查询订单，校验状态为 pending（只有待审核可取消）
    // 2. 更新 order.status = 'cancelled', cancel_reason = reason
    // 3. 更新 instrument.status = 'available', rent_count - 1  ← 库存回滚
    // 4. 创建退款 payment (type=refund, amount=原押金)
    // 5. 发送通知
}

// --- 30 分钟未支付自动取消（Redis 过期事件） ---
// 注：当前为模拟支付模式，createOrder() 中 payment 直接标记为 success，
// 故以下超时取消逻辑在当前模式下不会触发，作为「设计预留」保留。
// 对接真实支付网关后：下单时 payment.status=pending，以下逻辑生效。
// 下单时: redisTemplate.opsForValue().set("order:timeout:" + orderId, orderId, 30, TimeUnit.MINUTES);
// Redis 键过期时通过 Keyspace Notification 触发 cancelOrder()
// 降级方案：@Scheduled 每分钟扫描 pending + 超过30分钟的订单
```

#### 9.2.2 智能推荐（双层架构 + 降级保障）

```java
public List<InstrumentVO> recommend(Long userId) {
    // ====== 第一层：大模型 API（主推荐引擎） ======
    if (aiConfig.isAvailable()) {
        try {
            return callAiRecommend(userId);
        } catch (Exception e) {
            log.warn("AI推荐失败，降级为标签匹配: {}", e.getMessage());
        }
    }

    // ====== 第二层：标签匹配规则引擎（降级方案） ======
    return tagMatchRecommend(userId);
}

// --- 大模型推荐 ---
private List<InstrumentVO> callAiRecommend(Long userId) {
    // 1. 查询用户画像 (偏好标签、租赁历史、浏览历史)
    // 2. 查询当前可租乐器列表
    // 3. 构造 Prompt:
    //    System: "你是乐器推荐专家，根据用户偏好从候选乐器中推荐最合适的..."
    //    User: "用户偏好: {...} 候选列表: [...] 请返回 JSON 数组 [乐器ID, 推荐理由]"
    // 4. 调用大模型 API
    // 5. 解析返回的 JSON，加载乐器信息
    // 6. 缓存结果 (Redis, 2小时)
    // 7. 返回推荐列表
}

// --- 标签匹配降级 ---
private List<InstrumentVO> tagMatchRecommend(Long userId) {
    // 1. 获取用户画像的偏好标签集合（如: {piano, beginner, classical}）
    // 2. 获取所有可租乐器，每件乐器有分类+适用人群标签
    // 3. 计算 Jaccard 相似度: |用户标签 ∩ 乐器标签| / |用户标签 ∪ 乐器标签|
    // 4. 按相似度降序 + 乐器评分加权 → 取 Top 6
    // 5. 返回推荐列表（推荐理由统一标注"基于偏好匹配"）
}
```

> **论文实验设计**：同一组用户画像下，对比大模型推荐 Top 3 与标签匹配推荐 Top 3 的差异，分析语义推荐与规则推荐的互补关系。此对比可单独作为论文第 5 章的一节实验内容。

#### 9.2.3 信用分计算

```java
public int calculateCreditScore(Long userId) {
    // 维度1: 履约率 (权重 40%)
    double completionRate = getCompletionRate(userId); // 按时归还订单 / 总已完成订单
    
    // 维度2: 逾期记录 (权重 25%)
    int overduePenalty = calculateOverduePenalty(userId); // 逾期次数 × 扣分
    
    // 维度3: 评价得分 (权重 15%)
    double avgRating = getAverageRating(userId); // 被评价平均分
    
    // 维度4: 租赁活跃度 (权重 10%)
    int rentCount = getCompletedRentCount(userId);
    
    // 维度5: 账户完整度 (权重 10%)
    int profileScore = getProfileScore(userId); // 实名认证 + 资料完整度
    
    // 加权计算
    int score = (int)(completionRate * 400 
                    + (600 - overduePenalty) * 0.25
                    + avgRating * 30
                    + Math.min(rentCount, 10) * 10
                    + profileScore * 10);
    
    return Math.max(0, Math.min(1000, score));
}

// 注意：credit_level 必须在同一事务中根据 credit_score 同步更新，避免两字段不一致
// credit_level 映射：≥800→1(优秀) 600-799→2(良好) 400-599→3(一般) <400→4(较差)
// 调用方应在 @Transactional 方法内：
//   user.setCreditScore(score);
//   user.setCreditLevel(mapScoreToLevel(score));
//   userMapper.updateById(user);
```

#### 9.2.4 评价提交（应用层外键校验）

```java
public void createReview(ReviewCreateDTO dto) {
    // 应用层校验：补偿数据库层面的双重空外键
    if ("rental".equals(dto.getType()) && dto.getRentalOrderId() == null) {
        throw new BusinessException("租赁评价必须关联租赁订单");
    }
    if ("maintenance".equals(dto.getType()) && dto.getMaintenanceOrderId() == null) {
        throw new BusinessException("维修评价必须关联维修工单");
    }
    // 校验订单归属当前用户
    // 校验订单已完成且未评价
    // 创建评价记录 → 更新订单/工单的 is_reviewed 标记
}
```

---

## 十、开发规范

### 10.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| Java 类 | PascalCase | `OrderController` |
| Java 方法/变量 | camelCase | `findByUserId` |
| 数据库表 | snake_case | `rental_order` |
| 数据库字段 | snake_case | `start_date` |
| RESTful URL | kebab-case | `/api/v1/work-orders` |
| Vue 组件 | PascalCase | `OrderList.vue` |
| ArkTS 文件 | PascalCase | `InstrumentDetail.ets` |
| Git 分支 | kebab-case | `feature/order-module` |

### 10.2 Git 提交规范

```
feat: 新增订单管理模块
fix: 修复库存扣减并发问题
docs: 更新 API 文档
refactor: 重构信用分计算逻辑
test: 添加订单服务单元测试
style: 格式化代码
```

### 10.3 代码质量

- 后端：所有 public 方法必须写 Javadoc 注释
- 后端：关键业务逻辑写单元测试（覆盖率 ≥ 60%）
- 前端：TypeScript 严格模式，禁止 `any`
- 鸿蒙端：遵循 DevEco Studio 代码检查规则
- 所有接口参数使用 `@Valid` 校验

---

## 十一、部署与运行

### 11.1 开发环境启动

```bash
# 后端 (server/)
cd server
mvn spring-boot:run -Dspring-boot.run.profiles=dev
# 访问: http://localhost:8080/doc.html (Knife4j API文档)

# Web 管理端 (web-ui/)
cd web-ui
npm install
npm run dev
# 访问: http://localhost:5173

# 鸿蒙端 (entry/)
# 使用 DevEco Studio 打开项目根目录，运行 entry 模块
```

### 11.2 后端配置

```yaml
# server/src/main/resources/application-dev.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/musicnest?useUnicode=true&characterEncoding=utf8mb4
    username: root
    password: your_password
  data:
    redis:
      host: localhost
      port: 6379
  sql:
    init:
      mode: always          # 启动时自动执行 data.sql
      schema-locations: classpath:schema.sql
      data-locations: classpath:data.sql

jwt:
  secret: your-secret-key-at-least-256-bits
  expire-hours: 24
  staff-expire-hours: 4

# 大模型 API 配置（智能推荐用，可选；为空时自动走标签匹配降级方案）
# 注意：国内校园网可能无法访问 api.openai.com，可改用国内模型或留空走降级
# 答辩前务必测试降级路径：将 api-key 置空 → 启动 → 访问首页推荐位 → 确认展示"基于偏好匹配"标签
ai:
  api-key: ${AI_API_KEY:}       # 留空走降级
  model: gpt-4o-mini
  endpoint: https://api.openai.com/v1/chat/completions
```

### 11.3 种子数据（data.sql）

> 答辩演示需要预置数据，避免现场手动录入。以下 SQL 在应用首次启动时由 `spring.sql.init.mode=always` 自动执行。

```sql
-- 管理员账号 (密码: admin123, BCrypt加密)
INSERT INTO staff (username, password, real_name, role) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '店长', 'ROLE_ADMIN'),
('staff01', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5Eh', '店员小李', 'ROLE_STAFF');

-- 模拟用户
INSERT INTO user (phone, nickname, real_name, verify_status, credit_score) VALUES
('13800001111', '音乐爱好者小王', '王小明', 2, 780),
('13800002222', '吉他手小张', '张磊', 2, 620),
('13800003333', '钢琴学生小李', '李华', 1, 600);

-- 乐器 (5件，覆盖不同分类)
INSERT INTO instrument (name, category, brand, model, condition_level, daily_price, weekly_price, monthly_price, deposit, purchase_price, status) VALUES
('雅马哈 U1 立式钢琴', 'piano', 'Yamaha', 'U1', 2, 150.00, 900.00, 3000.00, 5000.00, 45000.00, 'available'),
('Yamaha C40 古典吉他', 'guitar', 'Yamaha', 'C40', 1, 30.00, 180.00, 600.00, 800.00, 1200.00, 'available'),
('Stradivarius 小提琴 4/4', 'violin', 'Strad', 'SV-100', 3, 50.00, 300.00, 1000.00, 2000.00, 5000.00, 'available'),
('Yamaha YFL-222 长笛', 'wind', 'Yamaha', 'YFL-222', 2, 40.00, 240.00, 800.00, 1500.00, 3000.00, 'available'),
('敦煌 古筝 694KK', 'folk', '敦煌', '694KK', 1, 60.00, 360.00, 1200.00, 3000.00, 6000.00, 'available');

-- 几条已完成订单 (用于信用分演示)
INSERT INTO rental_order (order_no, user_id, instrument_id, start_date, end_date, actual_return_date, rent_days, deposit_amount, rent_amount, status) VALUES
('R20260601001', 1, 2, '2026-06-01', '2026-06-07', '2026-06-07', 7, 800.00, 180.00, 'completed'),
('R20260601002', 2, 3, '2026-06-01', '2026-06-14', '2026-06-14', 14, 2000.00, 600.00, 'completed'),
('R20260605003', 1, 1, '2026-06-05', '2026-06-12', '2026-06-15', 7, 5000.00, 900.00, 'completed');
```

> **注意**：`data.sql` 中的 BCrypt 密码需在真实环境重新生成。建议开发阶段不启用 `spring.sql.init.mode=always`，改为手动执行 SQL 文件。

---

*文档版本：v1.0 | 日期：2026-06-12*
