# 鸿音管家（MusicNest）— 三端全量审查报告

> 审查日期：2026-06-12 | 审查版本：Master Final  
> 审查范围：鸿蒙端 (entry/) + Web端 (web-ui/) + 后端 (server/)  
> 文档依据：PRD v1.0 / SPEC v1.0 / DEV-PLAN-HARMONY v1.0 / DEV-PLAN-WEB-SERVER v1.0

---

## 〇、项目全貌

| 端 | 目录 | 文件数 | 技术栈 | 完成度 |
|----|------|:------:|--------|:------:|
| 鸿蒙端 | `entry/` | 42 | ArkTS + ArkUI + API 12 | 🟢 90% |
| Web端 | `web-ui/` | 27 | Vue 3 + Element Plus + TS | 🟡 65% |
| 后端 | `server/` | 34 | Spring Boot 3 + MyBatis-Plus | 🔴 45% |

---

## 一、鸿蒙端 (entry/) — 已基本就绪

### 1.1 当前状态

鸿蒙端经过三轮审查（R1→R2→R3），已修复 52 个问题。**0 致命，0 严重，剩余 10 个中低优先级问题。**

### 1.2 已解决的问题（摘选）

- HttpClient 从回调式改为 Promise 式 ✅
- InstrumentCard/RatingStars 响应式修复 ✅
- 手机号/身份证号正则校验 ✅
- 下单前实名校验 + AlertDialog ✅
- OrderDetail 新增"报修"按钮 → MaintenanceCreate 可访问 ✅
- MaintenanceDetail 动态"确认验收"按钮 ✅
- ReviewCreate 传递 maintenanceOrderId ✅
- Login 定时器内存泄漏修复 ✅
- module.json5 权限声明 ✅
- CartStore 已实现 ✅
- FeeLine 共享组件已提取 ✅
- 模块权限声明字符串已添加 ✅
- 未使用的 import 已清理 ✅

### 1.3 剩余问题（10个，均为中/低级）

| # | 严重程度 | 问题 | 文件 |
|:--:|:--------:|------|------|
| 1 | 🟡 | OrderList "进行中" Tab 仅映射 renting | OrderList.ets |
| 2 | 🟡 | Profile 信用卡片数据为占位符 "--" | Profile.ets |
| 3 | 🟡 | 三个菜单入口 onClick 为空函数 | Profile.ets |
| 4 | 🟡 | InstrumentDetail specs 展示原始 JSON | InstrumentDetail.ets |
| 5 | 🟡 | hvigor typeCheck 默认关闭 | hvigor-config.json5 |
| 6 | 🟡 | 乐器详情图片轮播仅展示封面图 | InstrumentDetail.ets |
| 7 | 🔵 | mock-config.json5 为空 | mock-config.json5 |
| 8 | 🔵 | oh-package.json5 描述为模板文本 | oh-package.json5 |
| 9 | 🔵 | MainPage 未使用 TopAppBar 导入 | MainPage.ets |
| 10 | 🔵 | hilog DOMAIN 全部 0x0000 | EntryAbility/Index |

### 1.4 PRD 功能对照（鸿蒙端）

| PRD 功能 | 状态 |
|----------|:----:|
| F-01 注册登录 | ⚠️ 手机号 ✅ · 华为登录 TODO |
| F-02 个人资料 | ✅ |
| F-03 实名认证 | ✅ |
| F-04 信用分 | ✅ |
| F-05 乐器浏览搜索 | ✅ |
| F-06 智能推荐 | ✅ (AI推荐标签 + API 对接) |
| F-07 租赁下单 | ✅ (实名校验 + 模拟支付) |
| F-08 订单管理 | ✅ |
| F-09 续租申请 | ✅ |
| F-10 归还预约 | ✅ |
| F-11 售后报修 | ✅ (OrderDetail 已接入入口) |
| F-12 维修跟踪 | ✅ (含确认验收) |
| F-13 评价 | ✅ (租赁+维修双类型) |

---

## 二、Web端 (web-ui/) — 有 1 个阻断性问题

### 2.1 关键发现

#### 🔴 [CRITICAL-WEB] Dashboard.vue 文件不存在 — 应用默认首页无法加载

**文件**: `web-ui/src/router/index.ts` 第 16 行

```typescript
component: () => import('@/views/dashboard/Dashboard.vue')
```

路由引用了 `views/dashboard/Dashboard.vue`，但该文件 **不存在**。而路由配置中将 `/dashboard` 设为 `/` 的默认子路由（`redirect: '/dashboard'`），导致任何 STAFF+ 用户登录后立即遇到模块加载错误。

**目录 `views/dashboard/` 完全不存在。** 现有 `views/` 下只有 `order/`、`inventory/`、`workorder/`、`databoard/`、`system/` 和 `Login.vue`。

**修复**: 创建 `src/views/dashboard/Dashboard.vue`，内容可以是简单的工作台概览页（待处理摘要卡片），或临时重定向到订单列表。

---

### 2.2 页面/路由对照

| SPEC 路由 | 页面文件 | 状态 |
|-----------|----------|:----:|
| `/login` | Login.vue | ✅ |
| `/` → `/dashboard` | Layout.vue + **Dashboard.vue** | ❌ Dashboard.vue 缺失 |
| `/orders` | OrderList.vue | ✅ |
| `/orders/:id` | OrderDetail.vue | ✅ |
| `/inventory` | InstrumentList.vue | ✅ |
| `/inventory/add` | InstrumentForm.vue | ✅ |
| `/inventory/:id/edit` | InstrumentForm.vue | ✅ |
| `/work-orders` | WorkOrderList.vue | ✅ |
| `/work-orders/:id` | WorkOrderDetail.vue | ✅ |
| `/databoard` | DataBoard.vue | ✅ |
| `/system/staff` | StaffList.vue | ✅ |
| `/system/config` | SystemConfig.vue | ✅ |

**完成率**: 12/13 路由可用 = 92%

---

### 2.3 组件/Store 对照

| SPEC 要求 | 实现 | 状态 |
|-----------|------|:----:|
| `Layout.vue` + `Sidebar.vue` + `HeaderBar.vue` | Layout + Sidebar, **HeaderBar 内联在 Layout 中** | ⚠️ 未独立提取 |
| `useAuthStore` | 已实现 | ✅ |
| `useOrderStore` | **未实现** | ❌ |
| `useInstrumentStore` | **未实现** | ❌ |
| `useAppStore` | **未实现** | ❌ |

---

### 2.4 数据流问题

| 问题 | 文件 | 严重程度 |
|------|------|:--------:|
| DataBoard 使用硬编码图表数据而非 API | DataBoard.vue | 🟠 |
| DataBoard 访问 `pending.todayRevenue` 但 PendingSummary 无此字段 | DataBoard.vue | 🟠 |
| OrderDetail 访问 `order.dailyPrice` 但 RentalOrderVO 无此字段 | OrderDetail.vue | 🟡 |
| WorkOrderDetail 访问 `order.completedAt` 但 MaintenanceOrderVO 无此字段 | WorkOrderDetail.vue | 🟡 |
| Dashboard API 4/5 端点定义了但从未被调用 | dashboard.ts | 🟡 |
| Dict API 全部定义了但从未被调用 | admin.ts | 🟡 |
| 品类列表在 InstrumentList/InstrumentForm 中重复硬编码 | 两个文件 | 🔵 |
| Login 页展示硬编码凭据 `admin / admin123` | Login.vue | 🔵 |

---

### 2.5 SPEC API 对接率（Web端）

| API 模块 | 对接状态 |
|----------|:--------:|
| Auth (staff-login / logout) | ✅ |
| Instruments (CRUD + 上传) | ✅ |
| Orders (审核/归还/逾期) | ✅ |
| WorkOrders (派单/维修) | ✅ |
| Dashboard (5 端点) | ⚠️ 仅 getPending 被调用 |
| Admin (staff + dicts + configs) | ⚠️ dict CRUD 从未调用 |

---

## 三、后端 (server/) — 完成度最低，大量接口缺失

### 3.1 整体评估

**SPEC 定义了 56 个 REST API 端点，后端仅实现了 18 个（32%），且其中 5 个看板端点返回硬编码 stub 数据。**

### 3.2 API 实现矩阵

#### 已实现 (18)

| 模块 | 端点 | 备注 |
|------|------|------|
| Auth | `POST /auth/staff-login` | B端登录 ✅ |
| Auth | `GET /auth/logout` | 退出(仅清除标记) |
| Instruments | `GET/POST /instruments` | 列表+新增 ✅ |
| Instruments | `GET/PUT /instruments/{id}` | 详情+更新 ✅ |
| Instruments | `DELETE /instruments/{id}` | 软删(设为scrapped) |
| Instruments | `PUT /instruments/{id}/status` | 状态变更 |
| Files | `POST /files/upload` | 文件上传 ✅ |
| Orders | `GET /orders` + `GET /orders/{id}` | 查询 ✅ |
| Orders | `PUT /orders/{id}/approve|reject|complete-return` | B端操作 ✅ |
| Orders | `GET /orders/overdue` | 逾期列表 |
| WorkOrders | `GET /work-orders` + `GET /work-orders/{id}` | 查询 ✅ |
| WorkOrders | `PUT /work-orders/{id}/assign|start-repair|complete-repair` | B端操作 ✅ |
| Admin | Staff CRUD (5 端点) | 员工管理 ✅ |
| Dashboard | 5 个 GET 端点 | ⚠️ **全部返回空/hardcoded数据** |

#### 缺失 (38)

| 模块 | 缺失端点 |
|------|----------|
| **Auth** | `POST /auth/send-code`, `POST /auth/login`, `POST /auth/huawei-login`, `POST /auth/refresh-token` |
| **User** | `GET /user/profile`, `PUT /user/profile`, `POST /user/verify`, `GET /user/credit`, `GET /user/notifications`, `PUT /user/notifications/{id}/read` |
| **Files** | `GET /files/{filename}` |
| **Instruments** | `GET /instruments/hot`, `GET /instruments/recommend`, `GET /instruments/{id}/reviews` |
| **Orders** | `POST /orders`, `POST /orders/{id}/pay`, `POST /orders/{id}/renew`, `POST /orders/{id}/return-booking`, `POST /orders/{id}/cancel` |
| **WorkOrders** | `POST /work-orders`, `PUT /work-orders/{id}/confirm` |
| **Reviews** | `POST /reviews`, `GET /reviews` |
| **Admin** | `GET /admin/dicts`, `POST /admin/dicts`, `PUT /admin/dicts/{id}`, `GET /admin/configs`, `PUT /admin/configs` |

### 3.3 包结构对照 SPEC

| SPEC 包 | 实际 | 缺失 |
|---------|------|------|
| entity/ | 5 个 (Instrument, RentalOrder, MaintenanceOrder, Staff, User) | Review, Payment, Notification, SysDict, SysConfig, MaintenanceLog |
| mapper/ | 4 个 (Instrument, RentalOrder, MaintenanceOrder, Staff) | User, Payment, Review, Notification, SysDict, SysConfig, MaintenanceLog |
| service/ | 4 个 (Auth, Instrument, Order, WorkOrder) | User, Review, Recommend, Credit, Dashboard(impl) |
| service/impl/ | **目录不存在** | 全部 |
| controller/ | 7 个 (Auth, Instrument, Order, WorkOrder, Admin, Dashboard, File) | User, Review |
| dto/ | **目录不存在** | 全部 |
| vo/ | **目录不存在** | 全部 |
| enums/ | **目录不存在** | 全部 |

### 3.4 代码质量问题

| 严重程度 | 问题 |
|:--------:|------|
| 🔴 | **C端用户认证完全缺失** — 无 UserMapper/UserService/UserController，鸿蒙端无法登录 |
| 🔴 | **订单创建接口缺失** — `POST /orders` 未实现，鸿蒙端无法下单 |
| 🔴 | **工单创建接口缺失** — `POST /work-orders` 未实现，鸿蒙端无法报修 |
| 🔴 | **Dashboard 5 端点全部返回 stub 零值** — 管理员看不到任何数据 |
| 🟠 | AdminController 使用 MD5 做密码哈希，与 data.sql 的 BCrypt 不一致 |
| 🟠 | 无 RBAC 权限控制 — AuthInterceptor 提取角色但无人校验，任意 STAFF 可操作 Admin |
| 🟠 | WorkOrderService GET 请求中执行状态变更（破坏 REST 幂等性） |
| 🟠 | OrderService.completeReturn() 允许跳过 returning 状态直接完成 |
| 🟡 | InstrumentService 无 @Transactional 注解 |
| 🟡 | 无输入验证注解 (@NotBlank, @Size 等) |
| 🟡 | data.sql BCrypt 哈希值可能无效 |
| 🔵 | 分页参数无边界校验 |
| 🔵 | `DELETE /instruments/{id}` 实际是软删除但未用 @TableLogic |

---

## 四、三端联调问题 — 最大风险

### 4.1 核心业务闭环断裂点

PRD 要求的完整闭环：

```
鸿蒙端(用户) → 后端 → Web端(员工/管理员)
      选琴    →  ❌   →  入库登记
      下单    →  ❌   →  审核订单
      支付    →  ❌   →  (模拟)
      报修    →  ❌   →  派单/维修
      评价    →  ❌   →  (查看)
```

**当前状态**: 鸿蒙端的页面 UI 已全部就绪，但后端缺少以下关键接口导致**整个闭环无法走通**：

| 步骤 | 鸿蒙端 UI | 后端接口 | 能否走通 |
|------|:--------:|:--------:|:--------:|
| 用户登录 | ✅ Login.ets | ❌ /auth/login | ❌ |
| 浏览乐器 | ✅ MainPage+Detail | ✅ /instruments | ✅ |
| 下单 | ✅ OrderCreate.ets | ❌ POST /orders | ❌ |
| 支付 | ✅ (模拟) | ❌ POST /orders/{id}/pay | ❌ |
| 报修 | ✅ MaintenanceCreate | ❌ POST /work-orders | ❌ |
| 维修确认 | ✅ MaintenanceDetail | ❌ PUT /work-orders/{id}/confirm | ❌ |
| 评价 | ✅ ReviewCreate | ❌ POST /reviews | ❌ |
| 员工审核 | N/A | ✅ PUT /orders/{id}/approve | ✅ |
| 看板 | N/A | ⚠️ stub 零值 | ⚠️ |

### 4.2 后端缺失接口的优先级矩阵

| 优先级 | 缺失端点 | 阻塞的前端功能 |
|:------:|----------|---------------|
| P0 | `/auth/send-code`, `/auth/login` | 鸿蒙端用户无法登录 |
| P0 | `POST /orders`, `/orders/{id}/pay` | 鸿蒙端无法下单 |
| P0 | `POST /work-orders`, `/work-orders/{id}/confirm` | 鸿蒙端无法报修+验收 |
| P0 | `POST /reviews`, `GET /reviews` | 鸿蒙端无法评价 |
| P1 | `GET /user/profile`, `PUT /user/profile`, `/user/verify`, `/user/credit` | 鸿蒙端个人中心数据为空 |
| P1 | `/instruments/hot`, `/instruments/recommend`, `/instruments/{id}/reviews` | 鸿蒙端首页热门/推荐/评价不可用 |
| P1 | 5 个 Dashboard 端点实现真实查询 | Web端看板数据全为零 |
| P2 | `/orders/{id}/renew`, `/orders/{id}/return-booking`, `/orders/{id}/cancel` | 续租/归还/取消 |
| P2 | Admin dicts/configs 接口 + 前端调用 | 字典管理和系统配置 |

---

## 五、三端修复优先级总览

### 后端 — 第一优先（答辩必须可用）

| # | 任务 | 预计工时 |
|:--:|------|:--------:|
| 1 | 实现 UserMapper + UserService + Auth 扩展（send-code/login） | 4h |
| 2 | 实现 POST /orders (create) + POST /orders/{id}/pay (mock) | 3h |
| 3 | 实现 POST /work-orders (create) + PUT /work-orders/{id}/confirm | 2h |
| 4 | 实现 Reviews CRUD | 2h |
| 5 | 实现 Dashboard 真实 SQL 查询（替换 stub） | 2h |
| 6 | 将 AdminController 密码改为 BCrypt | 0.5h |
| 7 | 添加 RBAC 权限校验（@PreAuthorize on admin routes） | 1h |
| 8 | 修复 GET 请求中的副作用（WorkOrderService） | 0.5h |

**后端小计**: ~15h

### Web端 — 第一优先

| # | 任务 | 预计工时 |
|:--:|------|:--------:|
| 1 | 创建 Dashboard.vue（工作台概览页） | 2h |
| 2 | DataBoard.vue 改为调用真实 API | 2h |
| 3 | 修复 OrderDetail/WorkOrderDetail 类型不匹配 | 0.5h |
| 4 | 修复 DataBoard PendingSummary 类型不匹配 | 0.5h |
| 5 | 清理 Login.vue 硬编码凭据提示 | 0.25h |

**Web端小计**: ~5.5h

### 鸿蒙端 — 收尾

| # | 任务 | 预计工时 |
|:--:|------|:--------:|
| 1 | 修复剩余 10 个中/低问题 | 3h |

**鸿蒙端小计**: ~3h

---

## 六、总结

| 维度 | 鸿蒙端 | Web端 | 后端 |
|------|:------:|:-----:|:----:|
| 页面/接口完成率 | 100% (16/16) | 92% (12/13) | 32% (18/56) |
| PRD 功能覆盖率 | 95% | 70% | 45% |
| 致命问题数 | 0 | 1 | 4 |
| 严重问题数 | 0 | 3 | 5 |
| 答辩可用性 | 🟢 基本可用 | 🟡 需修复Dashboard | 🔴 不可用 |

**核心结论**: 鸿蒙端 UI 层已基本就绪，Web端有 1 个关键文件缺失，**后端是当前最大短板** — 仅实现了 32% 的 SPEC 接口，C端认证和订单/工单创建等核心接口全部缺失，导致鸿蒙端无法与后端联调走通完整业务流程。后端需要约 15 小时补齐 P0/P1 接口，Web端需要约 5.5 小时修复 Dashboard 和数据对接问题。

---

*审查报告版本：Master Final | 日期：2026-06-12*
