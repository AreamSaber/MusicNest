-- 鸿音管家 数据库初始化脚本
-- 基于 SPEC.md §3.2

CREATE TABLE IF NOT EXISTS `user` (
    `id`              BIGINT NOT NULL AUTO_INCREMENT,
    `phone`           VARCHAR(20) NOT NULL,
    `nickname`        VARCHAR(50) DEFAULT NULL,
    `avatar`          VARCHAR(500) DEFAULT NULL,
    `real_name`       VARCHAR(20) DEFAULT NULL,
    `id_card`         VARCHAR(18) DEFAULT NULL,
    `id_card_front`   VARCHAR(500) DEFAULT NULL,
    `id_card_back`    VARCHAR(500) DEFAULT NULL,
    `verify_status`   TINYINT NOT NULL DEFAULT 0,
    `credit_score`    INT NOT NULL DEFAULT 600,
    `credit_level`    TINYINT NOT NULL DEFAULT 2,
    `status`          TINYINT NOT NULL DEFAULT 1,
    `huawei_open_id`  VARCHAR(100) DEFAULT NULL,
    `last_login_at`   DATETIME DEFAULT NULL,
    `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `staff` (
    `id`              BIGINT NOT NULL AUTO_INCREMENT,
    `username`        VARCHAR(50) NOT NULL,
    `password`        VARCHAR(255) NOT NULL,
    `real_name`       VARCHAR(20) NOT NULL,
    `phone`           VARCHAR(20) DEFAULT NULL,
    `role`            VARCHAR(20) NOT NULL DEFAULT 'ROLE_STAFF',
    `status`          TINYINT NOT NULL DEFAULT 1,
    `last_login_at`   DATETIME DEFAULT NULL,
    `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `instrument` (
    `id`                BIGINT NOT NULL AUTO_INCREMENT,
    `name`              VARCHAR(100) NOT NULL,
    `category`          VARCHAR(30) NOT NULL,
    `brand`             VARCHAR(50) NOT NULL,
    `model`             VARCHAR(100) DEFAULT NULL,
    `serial_no`         VARCHAR(50) DEFAULT NULL,
    `condition_level`   TINYINT NOT NULL DEFAULT 3,
    `description`       TEXT DEFAULT NULL,
    `specs`             JSON DEFAULT NULL,
    `daily_price`       DECIMAL(10,2) NOT NULL,
    `weekly_price`      DECIMAL(10,2) DEFAULT NULL,
    `monthly_price`     DECIMAL(10,2) DEFAULT NULL,
    `deposit`           DECIMAL(10,2) NOT NULL,
    `deposit_ratio`     DECIMAL(5,4) NOT NULL DEFAULT 1.0000,
    `purchase_price`    DECIMAL(10,2) DEFAULT NULL,
    `purchase_date`     DATE DEFAULT NULL,
    `current_value`     DECIMAL(10,2) DEFAULT NULL,
    `depreciation_rate` DECIMAL(5,4) DEFAULT 0.1000,
    `status`            VARCHAR(20) NOT NULL DEFAULT 'available',
    `applicable_level`  VARCHAR(20) DEFAULT 'all',
    `cover_image`       VARCHAR(500) DEFAULT NULL,
    `sort_order`        INT DEFAULT 0,
    `created_at`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `instrument_image` (
    `id`            BIGINT NOT NULL AUTO_INCREMENT,
    `instrument_id` BIGINT NOT NULL,
    `image_url`     VARCHAR(500) NOT NULL,
    `is_cover`      TINYINT NOT NULL DEFAULT 0,
    `sort_order`    INT DEFAULT 0,
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_instrument_id` (`instrument_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `rental_order` (
    `id`                  BIGINT NOT NULL AUTO_INCREMENT,
    `order_no`            VARCHAR(32) NOT NULL,
    `user_id`             BIGINT NOT NULL,
    `instrument_id`       BIGINT NOT NULL,
    `start_date`          DATE NOT NULL,
    `end_date`            DATE NOT NULL,
    `actual_return_date`  DATE DEFAULT NULL,
    `rent_days`           INT NOT NULL,
    `daily_price`         DECIMAL(10,2) NOT NULL,
    `deposit_amount`      DECIMAL(10,2) NOT NULL,
    `rent_amount`         DECIMAL(10,2) NOT NULL,
    `late_fee`            DECIMAL(10,2) DEFAULT 0,
    `total_amount`        DECIMAL(10,2) NOT NULL,
    `status`              VARCHAR(20) NOT NULL DEFAULT 'pending',
    `delivery_type`       VARCHAR(20) DEFAULT 'pickup',
    `delivery_address`    VARCHAR(255) DEFAULT NULL,
    `remark`              VARCHAR(500) DEFAULT NULL,
    `cancel_reason`       VARCHAR(255) DEFAULT NULL,
    `parent_order_id`     BIGINT DEFAULT NULL,
    `created_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `payment` (
    `id`              BIGINT NOT NULL AUTO_INCREMENT,
    `order_id`        BIGINT NOT NULL,
    `user_id`         BIGINT NOT NULL,
    `payment_no`      VARCHAR(32) NOT NULL,
    `amount`          DECIMAL(10,2) NOT NULL,
    `type`            VARCHAR(20) NOT NULL,
    `method`          VARCHAR(20) NOT NULL DEFAULT 'mock',
    `status`          VARCHAR(20) NOT NULL DEFAULT 'pending',
    `refund_amount`   DECIMAL(10,2) DEFAULT NULL,
    `refund_reason`   VARCHAR(255) DEFAULT NULL,
    `paid_at`         DATETIME DEFAULT NULL,
    `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_payment_no` (`payment_no`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `maintenance_order` (
    `id`                   BIGINT NOT NULL AUTO_INCREMENT,
    `order_no`             VARCHAR(32) NOT NULL,
    `rental_order_id`      BIGINT DEFAULT NULL,
    `instrument_id`        BIGINT NOT NULL,
    `user_id`              BIGINT NOT NULL,
    `assignee_id`          BIGINT DEFAULT NULL,
    `fault_desc`           TEXT NOT NULL,
    `fault_images`         JSON DEFAULT NULL,
    `urgency`              VARCHAR(10) NOT NULL DEFAULT 'normal',
    `status`               VARCHAR(20) NOT NULL DEFAULT 'pending',
    `diagnosis`            TEXT DEFAULT NULL,
    `repair_content`       TEXT DEFAULT NULL,
    `repair_parts`         VARCHAR(500) DEFAULT NULL,
    `repair_cost`          DECIMAL(10,2) DEFAULT 0,
    `checking_started_at`  DATETIME DEFAULT NULL,
    `completed_at`         DATETIME DEFAULT NULL,
    `created_at`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_no` (`order_no`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `maintenance_log` (
    `id`            BIGINT NOT NULL AUTO_INCREMENT,
    `order_id`      BIGINT NOT NULL,
    `operator_id`   BIGINT NOT NULL,
    `operator_type` VARCHAR(10) NOT NULL,
    `action`        VARCHAR(30) NOT NULL,
    `remark`        VARCHAR(500) DEFAULT NULL,
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `review` (
    `id`                    BIGINT NOT NULL AUTO_INCREMENT,
    `user_id`               BIGINT NOT NULL,
    `rental_order_id`       BIGINT DEFAULT NULL,
    `maintenance_order_id`  BIGINT DEFAULT NULL,
    `instrument_id`         BIGINT DEFAULT NULL,
    `type`                  VARCHAR(10) NOT NULL,
    `rating`                TINYINT NOT NULL,
    `content`               VARCHAR(500) DEFAULT NULL,
    `images`                JSON DEFAULT NULL,
    `created_at`            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `notification` (
    `id`         BIGINT NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT NOT NULL,
    `type`       VARCHAR(30) NOT NULL,
    `title`      VARCHAR(100) NOT NULL,
    `content`    VARCHAR(500) NOT NULL,
    `is_read`    TINYINT NOT NULL DEFAULT 0,
    `related_id` BIGINT DEFAULT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id_read` (`user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `sys_dict` (
    `id`         BIGINT NOT NULL AUTO_INCREMENT,
    `dict_type`  VARCHAR(50) NOT NULL,
    `dict_key`   VARCHAR(50) NOT NULL,
    `dict_value` VARCHAR(100) NOT NULL,
    `sort_order` INT DEFAULT 0,
    `status`     TINYINT NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_type_key` (`dict_type`, `dict_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `sys_config` (
    `id`           BIGINT NOT NULL AUTO_INCREMENT,
    `config_key`   VARCHAR(50) NOT NULL,
    `config_value` VARCHAR(255) NOT NULL,
    `description`  VARCHAR(200) DEFAULT NULL,
    `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
