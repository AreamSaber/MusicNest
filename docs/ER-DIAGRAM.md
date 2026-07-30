# 鸿音管家 — ER 图与数据库表结构速查

> 生成自 SPEC.md v1.0 第三章

---

## ER 关系图

```
                         ┌──────────────────┐
                         │      user         │
                         │  (C端用户)         │
                         └───┬───┬──────┬────┘
                             │   │      │
               ┌─────────────┘   │      └─────────────┐
               │                 │                    │
               ▼                 ▼                    ▼
     ┌─────────────────┐  ┌──────────────┐  ┌────────────────┐
     │  rental_order   │  │maintenance_   │  │    review       │
     │  (租赁订单)      │  │   order       │  │   (评价)        │
     └───┬─────┬───────┘  │  (维修工单)   │  └────────────────┘
         │     │          └───┬─────┬─────┘
         │     │              │     │
         ▼     │              │     ▼
  ┌──────────┐│              │  ┌─────────────────┐
  │ payment  ││              │  │ maintenance_log │
  │(支付记录) ││              │  │  (工单流转日志)   │
  └──────────┘│              │  └─────────────────┘
              │              │
              ▼              ▼
     ┌────────────────────────────────┐
     │          instrument            │
     │           (乐器)               │
     └──────────────┬─────────────────┘
                    │
                    ▼
          ┌──────────────────┐
          │ instrument_image │
          │   (乐器图片)     │
          └──────────────────┘

                         ┌──────────────────┐
                         │      staff        │
                         │   (B端员工/管理员)  │
                         └──────────────────┘
                                   │ (assignee_id 外键)
                                   ▼
                         ┌──────────────────┐
                         │ maintenance_order│
                         └──────────────────┘
```

## 关系链

| 关系 | 类型 | 说明 |
|------|------|------|
| user → rental_order | 1:N | 一个用户可创建多个订单 |
| user → maintenance_order | 1:N | 一个用户可提交多次报修 |
| user → review | 1:N | 一个用户可写多条评价 |
| instrument → rental_order | 1:N | 一件乐器可被多次租赁 |
| instrument → maintenance_order | 1:N | 一件乐器可被多次报修 |
| instrument → instrument_image | 1:N | 一件乐器对应多张图片 |
| rental_order → payment | 1:N | 一个订单可有多笔支付 |
| rental_order → maintenance_order | 1:N | 一个订单可多次报修 |
| staff → maintenance_order | 1:N | 一个员工处理多个工单 |
| rental_order → rental_order | 1:1 (自引用) | 续租关联原订单 (parent_order_id) |

## 表清单 (12 张)

| # | 表名 | 说明 | 核心索引 |
|---|------|------|----------|
| 1 | `user` | C端用户 | uk_phone, uk_huawei_open_id, idx_credit_score |
| 2 | `staff` | B端员工 | uk_username |
| 3 | `instrument` | 乐器 | idx_category, idx_status, idx_brand, idx_daily_price |
| 4 | `instrument_image` | 乐器图片 | idx_instrument_id |
| 5 | `rental_order` | 租赁订单 | uk_order_no, idx_user_id, idx_status, idx_start_date |
| 6 | `payment` | 支付记录 | uk_payment_no, idx_order_id, idx_user_id |
| 7 | `maintenance_order` | 维修工单 | uk_order_no, idx_user_id, idx_assignee_id, idx_status | checking_started_at 用于超时判断 |
| 8 | `maintenance_log` | 工单日志 | idx_order_id |
| 9 | `review` | 评价 | idx_user_id, idx_instrument_id |
| 10 | `notification` | 通知 | idx_user_id_read (user_id + is_read 联合) |
| 11 | `sys_dict` | 字典 | uk_type_key (dict_type + dict_key 联合) |
| 12 | `sys_config` | 系统配置 | uk_config_key |

## 关键字段约束速查

| 表 | 字段 | 取值范围 |
|----|------|----------|
| instrument | status | `available`, `rented`, `maintenance`, `scrapped` |
| instrument | category | `piano`, `guitar`, `violin`, `wind`, `folk`, `percussion` |
| instrument | condition_level | 1~5 (1=全新, 5=较旧) |
| rental_order | status | `pending`, `renting`, `returning`, `completed`, `cancelled`, `overdue` |
| maintenance_order | status | `pending`, `assigned`, `repairing`, `checking`, `completed` |
| payment | type | `deposit`, `rental`, `late_fee`, `refund`, `repair` |
| payment | status | `pending`, `success`, `failed`, `refunded` |
| user | verify_status | 0=未认证, 1=审核中, 2=已通过, 3=已驳回 |
| staff | role | `ROLE_STAFF`, `ROLE_ADMIN` |

---

*文档版本：v1.0 | 日期：2026-06-12*
