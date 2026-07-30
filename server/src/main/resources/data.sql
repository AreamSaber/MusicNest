-- 鸿音管家 种子数据
-- 首次启动时所有密码为空，跳转 SetupPassword 页面统一设置
INSERT INTO staff (username, password, real_name, role) VALUES
('admin', '', '店长', 'ROLE_ADMIN'),
('staff01', '', '店员小李', 'ROLE_STAFF')
ON DUPLICATE KEY UPDATE password=VALUES(password);

-- 模拟用户
INSERT INTO user (phone, nickname, real_name, verify_status, credit_score) VALUES
('13800001111', '音乐爱好者小王', '王小明', 2, 780),
('13800002222', '吉他手小张', '张磊', 2, 620),
('13800003333', '钢琴学生小李', '李华', 1, 600)
ON DUPLICATE KEY UPDATE nickname=VALUES(nickname);

-- 乐器 (5件)
INSERT INTO instrument (name, category, brand, model, condition_level, daily_price, weekly_price, monthly_price, deposit, purchase_price, status, cover_image) VALUES
('雅马哈 U1 立式钢琴', 'piano', 'Yamaha', 'U1', 2, 150.00, 900.00, 3000.00, 5000.00, 45000.00, 'available', ''),
('Yamaha C40 古典吉他', 'guitar', 'Yamaha', 'C40', 1, 30.00, 180.00, 600.00, 800.00, 1200.00, 'available', ''),
('Stradivarius 小提琴 4/4', 'violin', 'Strad', 'SV-100', 3, 50.00, 300.00, 1000.00, 2000.00, 5000.00, 'available', ''),
('Yamaha YFL-222 长笛', 'wind', 'Yamaha', 'YFL-222', 2, 40.00, 240.00, 800.00, 1500.00, 3000.00, 'available', ''),
('敦煌 古筝 694KK', 'folk', '敦煌', '694KK', 1, 60.00, 360.00, 1200.00, 3000.00, 6000.00, 'available', '')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 系统字典: 乐器分类
INSERT INTO sys_dict (dict_type, dict_key, dict_value, sort_order) VALUES
('instrument_category', 'piano', '钢琴', 1),
('instrument_category', 'guitar', '吉他', 2),
('instrument_category', 'violin', '提琴', 3),
('instrument_category', 'wind', '管乐', 4),
('instrument_category', 'folk', '民乐', 5),
('instrument_category', 'percussion', '打击乐', 6)
ON DUPLICATE KEY UPDATE dict_value=VALUES(dict_value);

-- 系统字典: 适用人群
INSERT INTO sys_dict (dict_type, dict_key, dict_value, sort_order) VALUES
('applicable_level', 'beginner', '入门', 1),
('applicable_level', 'intermediate', '进阶', 2),
('applicable_level', 'professional', '专业', 3),
('applicable_level', 'all', '全部适用', 4)
ON DUPLICATE KEY UPDATE dict_value=VALUES(dict_value);

-- 系统参数默认值
INSERT INTO sys_config (config_key, config_value, description) VALUES
('rent_max_months', '12', '最大租赁月数'),
('deposit_default_ratio', '1.0', '默认押金比例'),
('late_fee_rate', '1.5', '滞纳金倍率'),
('depreciation_rate', '0.1', '年折旧率 (10%)'),
('repair_timeout_days', '7', '维修超时天数'),
('checking_auto_days', '3', '待验收自动确认天数')
ON DUPLICATE KEY UPDATE config_value=VALUES(config_value);
