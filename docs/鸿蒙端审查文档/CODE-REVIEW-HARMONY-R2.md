# 鸿音管家（MusicNest）鸿蒙端代码审查报告 — 第二轮

> 审查日期：2026-06-12 | 审查人：AI 代码审查 | 审查轮次：Round 2（深度复查）

---

## 零、一轮修复确认

在第一轮审查中发现的以下问题已经得到修复：

| 一轮编号 | 问题 | 状态 |
|:--------:|------|:----:|
| CRITICAL-1 | HttpClient 回调式 API → Promise 式 | ✅ 已修复 |
| — | HttpClient 新增 Mock 模式开关 | ✅ 新增 |
| HIGH-2 | InstrumentCard.isAvailable 响应式失效 → getter | ✅ 已修复 |
| HIGH-3 | RatingStars.currentRating 不响应 Prop 变化 → 直接用 rating | ✅ 已修复 |
| MED-3 | Login 手机号仅检查长度 → 增加正则 /^1[3-9]\d{9}$/ | ✅ 已修复 |
| MED-3 | VerifyIdCard 身份证仅检查长度 → 增加正则 /^\d{17}[\dXx]$/ | ✅ 已修复 |
| HIGH-4 | Tab 占位视图 → CategoryTab 改为内联渲染 InstrumentCard | ⚠️ 部分修复 |
| HIGH-5 | MaintenanceCreate 重复 StatusBadge_ → 改用导入的 StatusBadge | ✅ 已修复 |

---

## 一、问题统计

| 严重程度 | 数量 | 说明 |
|:--------:|:----:|------|
| 🔴 致命 | 0 | 一轮致命问题已修复 |
| 🟠 严重 | 5 | 新增或未修复的高优先级问题 |
| 🟡 中等 | 10 | 新增发现 |
| 🔵 轻微 | 6 | 新增发现 |
| **合计** | **21** | |

---

## 二、严重问题

### 🟠 [HIGH-1] BottomNavBar 子组件直接修改 @Prop — 状态管理反模式

**文件**: `views/BottomNavBar.ets` 第 35 行

```typescript
@Prop activeTab: number = 0;

// onClick 中:
this.activeTab = index;  // ❌ 子组件修改 @Prop（单向数据流违规）
if (this.onChange) {
  this.onChange(index);
}
```

在 ArkTS 中，`@Prop` 是父→子的单向数据流。子组件修改 `@Prop` 不会回传到父组件的 `@State`。虽然 `onChange` 回调最终会触发父组件更新并重新传入正确的值，但：
- 如果 `onChange` 回调未提供，UI 状态会永久不一致
- 在回调触发前的短暂时间内，子组件展示的是错误状态

**修复**: 移除 `this.activeTab = index;`，仅依赖父组件通过 `onChange` 回调更新后重新渲染。

---

### 🟠 [HIGH-2] 下单前缺少实名认证校验

**文件**: `pages/OrderCreate.ets` 第 47-63 行

PRD §3.1 F-07 明确要求：「实名认证通过方可下单」。当前 `confirmOrder()` 方法仅检查了协议勾选 (`this.agreedPolicy`)，未验证 `userInfo.verifyStatus === 2`。

```typescript
async confirmOrder(): Promise<void> {
  if (!this.agreedPolicy) return;  // 只检查了协议
  // 缺少: if (this.userInfo?.verifyStatus !== 2) return;
  ...
}
```

**影响**: 未实名用户可以直接下单，违反核心业务规则。

**修复**: 在 `confirmOrder()` 开头增加：
```typescript
if (!this.userInfo || this.userInfo.verifyStatus !== 2) {
  // 提示用户先完成实名认证
  return;
}
```

---

### 🟠 [HIGH-3] 归还预约"今天"误设为不可选

**文件**: `pages/ReturnBooking.ets` 第 30 行

```typescript
generateDays(): void {
  for (let i = 0; i < 7; i++) {
    this.days.push({
      disabled: i === 0  // ❌ 今天不可选，但 PRD 只禁止"早于今天"
    });
  }
}
```

PRD §3.1 F-10 规定「预约日期不能早于当前日期」。这意味着今天及之后都是合法日期。当前代码把今天设为 `disabled`，导致最早只能预约明天。

**修复**: `disabled: false`（所有未来7天均可选），或在前端提示"今天预约可能来不及准备"但不禁止选择。

---

### 🟠 [HIGH-4] 维修详情页缺少"确认验收"按钮

**文件**: `pages/MaintenanceDetail.ets` 第 127-138 行

底部操作栏硬编码为"联系技师"和"在线客服"，不随工单状态变化。当工单状态为 `checking`（待验收）时，用户应能看到"确认验收"按钮以完成工单（PRD §3.1 F-12）。

SPEC §6.2 工单状态流：`checking → confirm → completed`。`WorkOrderService.confirmRepair()` 方法已实现，但 UI 中没有触发入口。

**修复**: 根据 `this.order.status` 动态渲染底部按钮：
```typescript
if (this.order!.status === 'checking') {
  Button('确认验收')
    .onClick(() => workOrderService.confirmRepair(this.orderId))
}
```

---

### 🟠 [HIGH-5] 评价提交缺少 maintenanceOrderId — 维修评价无法关联

**文件**: `pages/ReviewCreate.ets` 第 34-39 行

```typescript
await reviewService.createReview({
  rentalOrderId: this.type === 'rental' ? this.orderId : undefined,
  type: this.type,
  rating: this.rating,
  content: this.content,
  images: this.images
});
```

当 `type === 'maintenance'` 时，仅传了 `rentalOrderId: undefined`，没有传 `maintenanceOrderId`。后端 SPEC §4.3.7 要求维修评价关联 `maintenanceOrderId`。

**修复**: 增加 `maintenanceOrderId` 参数：
```typescript
maintenanceOrderId: this.type === 'maintenance' ? this.orderId : undefined,
```

---

## 三、中等问题

### 🟡 [MED-1] 乐器详情页图片轮播是假的 — images 数组未使用

**文件**: `pages/InstrumentDetail.ets` 第 94-101 行

```typescript
// 图片轮播点（硬编码3个点，不响应实际图片数量）
Row() {
  Circle().width(8).height(8).fill(Color.White).opacity(1)
  Circle().width(8).height(8).fill(Color.White).opacity(0.5).margin({ left: 6 })
  Circle().width(8).height(8).fill(Color.White).opacity(0.5).margin({ left: 6 })
}
```

`InstrumentVO.images` 数组被完全忽略。轮播指示器硬编码为 3 个点，且无滑动切换功能。设计稿要求多图轮播。

**修复**: 使用 Swiper 组件 + 动态指示器。

---

### 🟡 [MED-2] ImagePicker 存在未使用的 import

**文件**: `views/ImagePicker.ets` 第 1-4 行

```typescript
import { image } from '@kit.ImageKit';      // 未使用
import { fileIo } from '@kit.CoreFileKit';   // 未使用
```

这两个导入增加了包体积和编译时间，且如果 `@kit.ImageKit` 或 `@kit.CoreFileKit` 未在 `oh-package.json5` 中声明依赖，可能导致运行时错误。

---

### 🟡 [MED-3] HttpClient 缩进不一致

**文件**: `utils/HttpClient.ets` 第 29 行

```typescript
isMockEnabled(): boolean {  // 缩进错误，应与 enableMock 对齐
    return this.useMock;
  }
```

格式问题会导致代码审查工具报错。

---

### 🟡 [MED-4] Profile 页信用分卡片的"已租次数"是硬编码

**文件**: `pages/Profile.ets` 第 83-86 行

```typescript
Text('3').fontSize(...)                    // 硬编码
Text('按时归还 2/3').fontSize(...)          // 硬编码
```

这些数据应该从 `creditDetail` 或 `userInfo` 中获取，而非写死。

---

### 🟡 [MED-5] OrderList 状态 Tab 映射不完整

**文件**: `pages/OrderList.ets` 第 43 行

```typescript
this.activeTab = tab === '全部' ? '' : 
  (tab === '进行中' ? 'renting' : 
   tab === '已完成' ? 'completed' : 'cancelled');
```

"进行中" Tab 映射为 `renting`，但遗漏了 `pending`（待审核）、`returning`（待归还）、`overdue`（逾期）等同样属于"进行中"的状态。用户会看到这些订单消失在列表中。

**修复**: 传递多个状态值，如 `status: 'renting,returning,overdue'` 或由后端处理 `status=active` 的语义。

---

### 🟡 [MED-6] 没有网络连接检测

**文件**: `utils/HttpClient.ets`

HttpClient 在发起请求前不检查设备网络状态。HarmonyOS 提供了 `@kit.NetworkKit` 的 connection manager，可以在请求前检查是否联网，给用户更友好的提示。

---

### 🟡 [MED-7] 设计稿色板不完整

**文件**: `resources/base/element/color.json`

DESIGN.md 定义了 40+ 颜色 Token，当前 `color.json` 仅定义了 25 个。缺失的关键颜色包括 `surface-tint`、`primary-fixed`、`primary-fixed-dim`、`inverse-surface`、`inverse-on-surface`、`on-error` 等。代码中多处使用了硬编码颜色字符串（如 `'rgba(0, 83, 56, 0.1)'`），有的可以映射到已有的设计 Token。

---

### 🟡 [MED-8] 自定义字体未注册

**文件**: 项目全局

DESIGN.md 指定字体为 **Hanken Grotesk**，但项目中无 `.ttf`/`.otf` 字体文件，`module.json5` 和 ArkTS 代码中均未注册自定义字体。鸿蒙端将回退到 HarmonyOS Sans 默认字体，与设计稿存在视觉差异。

---

### 🟡 [MED-9] MainPage 导入 TopAppBar 但未使用

**文件**: `pages/MainPage.ets` 第 3 行

```typescript
import { TopAppBar } from '../views/TopAppBar';  // 未在任何 Builder 中使用
```

---

### 🟡 [MED-10] 列表缺少下拉刷新

**文件**: `pages/InstrumentList.ets`, `pages/OrderList.ets`

两个列表页都支持 `onReachEnd` 上拉加载更多，但没有实现下拉刷新（Pull-to-Refresh）。PRD §3.1 F-05 明确要求「支持下拉刷新」。

---

## 四、轻微问题

### 🔵 [LOW-1] AppScope 缺少 app_name 定义

`string.json` 缺少 `app_name` 键，`AppScope/app.json5` 引用 `$string:app_name` 会解析为空。

### 🔵 [LOW-2] Login 页返回按钮处理不合理

Login 页有一个返回按钮（第 79-87 行），但 Login 是 Splash 页跳转过来的 `replaceUrl` 目标，此时路由栈中可能没有上一页，点击返回行为不确定。

### 🔵 [LOW-3] background.png 未使用

`resources/base/media/background.png` 存在于项目中但未被任何页面引用。

### 🔵 [LOW-4] hilog DOMAIN 值全为 0x0000

`EntryAbility.ets` 和 `Index.ets` 都使用 `DOMAIN = 0x0000`，无法按模块区分日志来源。建议为不同模块分配不同的 domain 值。

### 🔵 [LOW-5] 部分页面按钮"咨询"/"联系技师"无实际功能

`InstrumentDetail.ets` 的"咨询"按钮和 `MaintenanceDetail.ets` 的"联系技师"/"在线客服"按钮均为空操作，点击无响应。

### 🔵 [LOW-6] 两处定义了 FeeLine 子组件

`OrderDetail.ets`（第 185-198 行）和 `OrderCreate.ets`（第 223-237 行）中存在功能几乎相同的 `FeeLine` 组件，`OrderRenew.ets`（第 112-128 行）还有 `RenewFeeLine`，三个组件应该提取为共享组件。

---

## 五、与 SPEC 接口对比表

| SPEC 接口 | 前端调用 | 状态 |
|-----------|:------:|:----:|
| POST /auth/send-code | AuthService.sendCode | ✅ |
| POST /auth/login | AuthService.login | ✅ |
| POST /auth/huawei-login | AuthService.huaweiLogin (未接入) | ⚠️ |
| POST /auth/refresh-token | 未实现 | ❌ |
| GET /auth/logout | 未调用后端 | ❌ |
| GET /user/profile | UserService.getProfile | ✅ |
| PUT /user/profile | UserService.updateProfile | ✅ |
| POST /user/verify | UserService.submitVerification | ✅ |
| GET /user/credit | UserService.getCreditScore | ✅ |
| POST /files/upload | 未实现（文件上传走后端） | ❌ |
| GET /instruments | InstrumentService.getList | ✅ |
| GET /instruments/{id} | InstrumentService.getDetail | ✅ |
| GET /instruments/hot | InstrumentService.getHot | ✅ |
| GET /instruments/recommend | InstrumentService.getRecommend | ✅ |
| POST /orders | OrderService.createOrder | ✅ |
| GET /orders | OrderService.getList | ✅ |
| GET /orders/{id} | OrderService.getDetail | ✅ |
| POST /orders/{id}/pay | OrderService.payOrder | ✅ |
| POST /orders/{id}/renew | OrderService.renewOrder | ✅ |
| POST /orders/{id}/return-booking | OrderService.returnBooking | ✅ |
| PUT /orders/{id}/cancel | OrderService.cancelOrder | ✅ |
| POST /work-orders | WorkOrderService.createWorkOrder | ✅ |
| GET /work-orders | WorkOrderService.getList | ✅ |
| GET /work-orders/{id} | WorkOrderService.getDetail | ✅ |
| PUT /work-orders/{id}/confirm | WorkOrderService.confirmRepair | ⚠️ API有但UI缺按钮 |
| POST /reviews | ReviewService.createReview | ⚠️ 缺少maintenanceOrderId |
| GET /reviews | ReviewService.getList | ✅ |

---

## 六、修复优先级

### 立即修复（答辩前）

| # | 问题 | 预计工时 |
|---|------|:--------:|
| HIGH-2 | 下单前实名认证校验 | 0.5h |
| HIGH-3 | 归还预约"今天"误禁用 | 0.25h |
| HIGH-4 | 维修详情"确认验收"按钮 | 1h |
| HIGH-5 | 评价缺少 maintenanceOrderId | 0.5h |
| HIGH-1 | BottomNavBar @Prop 修改 | 0.5h |
| MED-2 | ImagePicker 未使用 import 清理 | 0.25h |

### 建议修复

| # | 问题 | 预计工时 |
|---|------|:--------:|
| MED-1 | 详情页真轮播 | 3h |
| MED-5 | OrderList 状态映射补全 | 1h |
| MED-4 | Profile 信用卡片数据动态化 | 1h |
| LOW-5 | 空按钮添加功能/隐藏 | 1h |
| MED-10 | 下拉刷新 | 2h |
| LOW-6 | 提取共享 FeeLine 组件 | 1h |

---

*审查报告版本：v2.0 | 日期：2026-06-12*
