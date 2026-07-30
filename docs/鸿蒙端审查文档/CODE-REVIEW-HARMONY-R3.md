# 鸿音管家（MusicNest）鸿蒙端代码审查报告 — 第三轮

> 审查日期：2026-06-12 | 审查人：AI 代码审查 | 审查轮次：Round 3（最终深度审查）

---

## 〇、前两轮修复确认

经过三轮迭代审查，以下问题已确认修复（👍 表示从代码中确认已修改）：

| 轮次 | 编号 | 问题 | 状态 |
|:----:|:----:|------|:----:|
| R1 | CRITICAL-1 | HttpClient 回调式→Promise式 | ✅ 已修复 |
| R1 | HIGH-2 | InstrumentCard.isAvailable getter | ✅ 已修复 |
| R1 | HIGH-3 | RatingStars 直接使用 this.rating | ✅ 已修复 |
| R1 | HIGH-5 | MaintenanceCreate 重复 StatusBadge_ | ✅ 已修复 |
| R1 | MED-3 | Login 手机号正则 /^1[3-9]\d{9}$/ | ✅ 已修复 |
| R1 | MED-3 | VerifyIdCard 身份证正则 /^\d{17}[\dXx]$/ | ✅ 已修复 |
| R1 | MED-12 | module.json5 权限声明 | ✅ 已修复 |
| R2 | HIGH-2 | OrderCreate 实名认证校验 + AlertDialog | ✅ 已修复 |
| R2 | HIGH-3 | ReturnBooking disabled: false | ✅ 已修复 |
| R2 | HIGH-4 | MaintenanceDetail "确认验收"按钮 | ✅ 已修复 |
| R2 | HIGH-5 | ReviewCreate maintenanceOrderId | ✅ 已修复 |
| R2 | MED-2 | ImagePicker 未使用 import 清理 | ✅ 已修复 |
| R2 | MED-4 | Profile 信用卡片硬编码→占位符 | ⚠️ 仍有残留问题 |
| R2 | LOW-1 | string.json app_name/权限理由 | ✅ 已修复 |

---

## 一、最终问题汇总

经过三轮逐文件审查，剩余问题如下：

| 严重程度 | 数量 | 
|:--------:|:----:|
| 🔴 致命 | 1 |
| 🟠 严重 | 2 |
| 🟡 中等 | 6 |
| 🔵 轻微 | 5 |
| **合计** | **14** |

---

## 二、致命问题

### 🔴 [CRITICAL] MaintenanceCreate 报修页面无法访问 — 核心业务闭环断裂

**状态**: 经过三轮审查始终存在，未被修复

`MaintenanceCreate.ets`（145行代码）已完整实现，但整个 App 中 **没有任何页面能导航到这个页面**。报修流程是 PRD 定义的 7 大核心闭环之一（"选琴→租赁→使用→报修→归还→复购"），缺少入口意味着：

- 用户无法从任何入口提交报修
- 维修工单无法创建
- `MaintenanceDetail` 页面也因此无法被访问（只有 MaintenanceCreate 提交成功后跳转）
- 整个售后报修模块（F-11、F-12）形同虚设

**根因分析**:
- `Profile.ets` 第 98 行："报修记录"菜单 → `onClick: () => {}`（空函数）
- `OrderDetail.ets`：renting 状态下仅有 `续租` 和 `预约归还` 按钮，**缺少"报修"按钮**

**修复方案**（二选一）:
```
方案 A（推荐）: OrderDetail.ets renting 状态增加"报修"按钮：
  Button('报修')
    .onClick(() => router.pushUrl({ 
      url: 'pages/MaintenanceCreate', 
      params: { 
        orderId: this.orderId, 
        instrumentId: this.order!.instrumentId,
        instrumentName: this.order!.instrumentName,
        orderNo: this.order!.orderNo
      } 
    }))

方案 B: Profile 页"报修记录"菜单 → 跳转到维护工单列表页
```

---

## 三、严重问题

### 🟠 [HIGH-1] Login 页验证码倒计时内存泄漏

**文件**: `pages/Login.ets` 第 37 行

```typescript
const timer = setInterval(() => {
  this.countdown--;
  if (this.countdown <= 0) {
    clearInterval(timer);
    this.isSendingCode = false;
  }
}, 1000);
```

**问题**: `timer` 变量是 `sendCode()` 方法内的局部变量，**没有保存在组件实例上**。如果用户在 60 秒倒计时期间执行以下操作：
- 点击登录成功 → `router.replaceUrl` 跳转 → Login 组件被销毁
- 但 `setInterval` 仍在运行，回调中访问已销毁组件的 `this.countdown` → 潜在崩溃

同样，如果用户在倒计时期间离开页面（如按返回键），定时器也无法被清除。

**修复**:
```typescript
private countdownTimer: number | null = null;

sendCode(): void {
  // ...
  this.countdownTimer = setInterval(() => { ... }, 1000);
}

aboutToDisappear(): void {
  if (this.countdownTimer !== null) {
    clearInterval(this.countdownTimer);
    this.countdownTimer = null;
  }
}
```

---

### 🟠 [HIGH-2] ReturnBooking "提交预约"按钮禁用逻辑与日期可选性不一致

**文件**: `pages/ReturnBooking.ets` 第 115 行

```typescript
// 日期: disabled: false (第30行 — 今天可选) ✅
// 按钮: enabled(this.selectedDate > 0 && !this.isLoading) (第115行)
```

`selectedDate` 默认为 `0`，当用户选择"今天"(`index=0`) 后，`this.selectedDate` 被设为 `0`，提交按钮仍处于禁用状态。虽然"今天"在日期选择器中是可点选的，但用户点选后无法提交。

**修复**: `enabled(!this.isLoading)` — 去掉 `this.selectedDate > 0` 条件。

---

## 四、中等问题

### 🟡 [MED-1] Profile 信用卡片右侧数据全部为占位符

**文件**: `pages/Profile.ets` 第 85-86 行

```typescript
Text((this.creditDetail ? '--' : '--').toString())  // 三元表达式无意义，永远显示 "--"
Text('信用良好')  // 硬编码
```

虽然不再硬编码 `3` 和 `2/3`，但这些字段应该从 `creditDetail` 数据中提取真实值。

---

### 🟡 [MED-2] OrderList Tab 状态映射遗漏 pending/returning/overdue

**文件**: `pages/OrderList.ets` 第 43 行（三轮未修复）

```typescript
// "进行中"仅映射到 'renting'，遗漏 pending、returning、overdue
this.activeTab = tab === '进行中' ? 'renting' : ...
```

用户如果有待审核(`pending`)、待归还(`returning`)、逾期(`overdue`)的订单，点击"进行中"Tab 会看不到它们。

---

### 🟡 [MED-3] 多个菜单入口为死胡同

**文件**: `pages/Profile.ets`

| 菜单项 | onClick | 
|--------|:------:|
| 🔧 报修记录 | `() => {}` — 完全没反应 |
| 🔔 消息通知 | `() => {}` — 完全没反应 |
| ⚙️ 设置 | `() => {}` — 完全没反应 |

这些空操作会让用户困惑。虽然通知和设置可以作为 P2 功能延后，但"报修记录"应该至少能跳转到工单列表或报修页面。

---

### 🟡 [MED-4] HttpClient isMockEnabled 缩进错误

**文件**: `utils/HttpClient.ets` 第 29 行

```typescript
  isMockEnabled(): boolean {    // ← 缩进与类方法不对齐
    return this.useMock;
  }
```

---

### 🟡 [MED-5] 乐器详情页 spec 字段为原始 JSON 字符串

**文件**: `pages/InstrumentDetail.ets` 第 201-205 行

```typescript
if (this.specsExpanded && this.instrument!.specs) {
  Text(this.instrument!.specs)  // 直接展示 JSON 字符串
}
```

`InstrumentVO.specs` 是 JSON string，直接 `Text()` 渲染会显示 `{"key":"value",...}` 的原始JSON。应该解析后以 key-value 列表形式展示。

---

### 🟡 [MED-6] hvigor typeCheck 默认关闭

**文件**: `hvigor/hvigor-config.json5`

```json
"typeCheck": false  // 注释状态，默认 false
```

ArkTS 的类型检查被禁用，可能隐藏类型不匹配的编译期错误。建议至少在 CI 或提交前手动启用检查。

---

## 五、轻微问题

### 🔵 [LOW-1] mock-config.json5 为空对象

Mock 模式开关已在 HttpClient 中实现，但 mock 数据配置文件 `entry/src/mock/mock-config.json5` 内容为 `{}`，没有配置任何 mock 数据。

### 🔵 [LOW-2] oh-package.json5 描述为模板文本

根目录和 entry 的 oh-package.json5 中 `description` 仍为 `"Please describe the basic information."`。

### 🔵 [LOW-3] MainPage 导入 TopAppBar 但未使用

`pages/MainPage.ets` 第 3 行 `import { TopAppBar }` 但 HomeTab/CategoryTab/OrderTab/ProfileTab 均未使用该组件。

### 🔵 [LOW-4] hilog DOMAIN 值全部为 0x0000

`EntryAbility.ets` 和 `Index.ets` 都使用 `DOMAIN = 0x0000`，无法按模块过滤日志。

### 🔵 [LOW-5] 设计稿 DESIGN.md 圆角规范：Mobile Cards 应为 24px

DESIGN.md §Shapes 规定 Mobile Cards 使用 `rounded-xl (24px)`，Standard Cards 使用 `rounded-lg (16px)`。当前代码中 major containers（如 Banner、分类卡片区）使用 `borderRadius(20)` 和 `borderRadius(16)`，与 24px 规范略有偏差。

---

## 六、三轮修复趋势

```
Round 1: 27 problems (1 critical, 6 high, 12 medium, 8 low)
Round 2: 21 problems (0 critical, 5 high, 10 medium, 6 low) — 14 fixed, 8 new
Round 3: 14 problems (1 critical, 2 high,  6 medium, 5 low) — 13 fixed, 6 new
```

代码质量在持续改善。三轮审查共发现 62 个独立问题，已修复约 70%。

---

## 七、当前必须修复清单（答辩前）

| 优先级 | 问题 | 工时 |
|:------:|------|:----:|
| 🔴 | MaintenanceCreate 无法访问 — 增加导航入口 | 1h |
| 🟠 | Login 定时器泄漏 — 添加 aboutToDisappear 清理 | 0.5h |
| 🟠 | ReturnBooking 提交按钮今天不可用 | 0.25h |
| 🟡 | 菜单空操作（报修记录/通知/设置） | 1h |
| 🟡 | InstrumentDetail specs JSON 格式化展示 | 1h |

**预计总工时**: ~4h

---

## 八、路由参数完整校验表

| # | 发送方 | 参数 | 接收方 | 接收参数名 | 匹配 |
|:--:|--------|------|--------|-----------|:----:|
| 1 | Index → MainPage | — | MainPage | — | ✅ |
| 2 | Index → Login | — | Login | — | ✅ |
| 3 | Login → MainPage | — | MainPage | — | ✅ |
| 4 | MainPage → InstrumentList | — | InstrumentList | — | ✅ |
| 5 | MainPage → InstrumentDetail | `{ id }` | InstrumentDetail | `['id']` | ✅ |
| 6 | MainPage → OrderList | — | OrderList | — | ✅ |
| 7 | MainPage → Profile | — | Profile | — | ✅ |
| 8 | InstrumentList → InstrumentDetail | `{ id }` | InstrumentDetail | `['id']` | ✅ |
| 9 | InstrumentDetail → OrderCreate | `{ instrumentId }` | OrderCreate | `['instrumentId']` | ✅ |
| 10 | OrderCreate → OrderDetail | `{ id }` | OrderDetail | `['id']` | ✅ |
| 11 | OrderCreate → VerifyIdCard | — | VerifyIdCard | — | ✅ |
| 12 | OrderList → OrderDetail | `{ id }` | OrderDetail | `['id']` | ✅ |
| 13 | OrderDetail → OrderRenew | `{ orderId }` | OrderRenew | `['orderId']` | ✅ |
| 14 | OrderDetail → ReturnBooking | `{ orderId }` | ReturnBooking | `['orderId']` | ✅ |
| 15 | OrderDetail → ReviewCreate | `{ orderId, type }` | ReviewCreate | `['orderId', 'type']` | ✅ |
| 16 | Profile → VerifyIdCard | — | VerifyIdCard | — | ✅ |
| 17 | Profile → MyReviews | — | MyReviews | — | ✅ |
| 18 | Profile → Login | — | Login | — | ✅ |
| 19 | MaintenanceCreate → MaintenanceDetail | `{ id }` | MaintenanceDetail | `['id']` | ✅ |

> ⚠️ 注意：第 19 行的 MaintenanceCreate 页面本身没有入站导航（CRITICAL 问题），但一旦被导航到，出站参数是正确的。

---

*审查报告版本：v3.0 | 日期：2026-06-12*
