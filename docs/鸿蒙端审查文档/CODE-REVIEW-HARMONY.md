# 鸿音管家（MusicNest）鸿蒙端代码审查报告

> 审查日期：2026-06-12 | 审查人：AI 代码审查 | 项目版本：v1.0

---

## 一、审查总览

### 1.1 审查范围

| 维度 | 说明 |
|------|------|
| 审查对象 | `entry/src/main/ets/` 下所有 34 个 `.ets` 文件（含配置资源） |
| 文档依据 | PRD.md / SPEC.md / DEV-PLAN-HARMONY.md / ER-DIAGRAM.md |
| 审查维度 | 文档一致性、代码质量与架构、鸿蒙平台规范、安全与性能 |

### 1.2 问题统计

| 严重程度 | 数量 | 说明 |
|:--------:|:----:|------|
| 🔴 致命 | 1 | 导致应用完全无法与后端通信 |
| 🟠 严重 | 6 | 功能缺失或严重不符合文档 |
| 🟡 中等 | 12 | 代码质量问题，影响可维护性 |
| 🔵 轻微 | 8 | 风格/规范建议 |
| **合计** | **27** | |

### 1.3 文档一致性总体评估

| 文档 | 匹配度 | 备注 |
|------|:------:|------|
| PRD.md | 85% | P0 功能基本覆盖，华为登录/H5支付未完整实现 |
| SPEC.md | 80% | 架构对齐，HTTP 层实现有重大偏差 |
| DEV-PLAN-HARMONY.md | 90% | 页面数和组件数达标，CartStore 缺失 |
| ER-DIAGRAM.md | 95% | 数据模型定义与 DDL 对齐良好 |
| 设计稿 | 75% | 颜色 Token 对齐，部分交互细节未完全实现 |

---

## 二、致命问题

### 🔴 [CRITICAL-1] HttpClient 异步模式错误 — 整个网络层不工作

**文件**: `utils/HttpClient.ets` (第 22-62 行)

**问题描述**:
`request()` 方法使用了回调式的 `http.request()` API，但所有 Service 层代码使用 `await httpClient.get<T>(...)` 的 async/await 模式调用。方法在 HTTP 请求真正完成之前就立即返回了一个假的 mock 响应 `{code: 0, message: 'request pending', data: null}`，导致所有 API 调用都无法获取实际数据。

```typescript
// 当前代码（错误）:
async request<T>(...): Promise<ApiResponse<T>> {
  httpRequest.request(fullUrl, {...}, async (err, data) => {
    // 回调在请求完成后才执行，但此时方法早已返回
    const response = JSON.parse(data.result as string);
    return response; // 这里 return 的是回调函数，不是外层方法
  });
  // 立即返回假数据，远超实际请求完成
  return { code: 0, message: 'request pending', data: null };
}
```

**影响**:
- 所有页面调用 Service → HttpClient 后拿到的都是 `{code:0, message:'request pending'}` 假数据
- 登录、乐器列表、订单创建等所有功能均无法正常工作
- Index 页 splash 会因为 `token` 在 AppStorage 中不存在而永远跳转 Login 页

**修复建议**:
```typescript
// 正确方式：使用 Promise 式 API（HarmonyOS NEXT API 12+）
async request<T>(method: http.RequestMethod, url: string, params?: object | null): Promise<ApiResponse<T>> {
  const token = AppStorage.get<string>('token') || '';
  const httpRequest = http.createHttp();
  try {
    const data = await httpRequest.request(fullUrl, {
      method: method,
      header: {
        'Content-Type': 'application/json',
        'Authorization': token ? 'Bearer ' + token : ''
      },
      extraData: params ? JSON.stringify(params) : undefined,
      connectTimeout: this.timeout,
      readTimeout: this.timeout
    });
    const response: ApiResponse<T> = JSON.parse(data.result as string);
    if (response.code === 401) {
      AppStorage.setOrCreate('token', '');
      AppStorage.setOrCreate('userInfo', null);
    }
    return response;
  } catch (err) {
    console.error('HTTP Error: ' + JSON.stringify(err));
    return { code: 500, message: 'Network error', data: null };
  } finally {
    httpRequest.destroy();
  }
}
```

---

## 三、严重问题

### 🟠 [HIGH-1] 华为账号一键登录未实现（F-01 部分缺失）

**文件**: `pages/Login.ets` (第 70-73 行)

PRD §3.1 F-01 明确要求支持华为账号一键登录（`@kit.AccountKit`），当前仅显示占位提示 "华为账号登录将在后续版本接入"。这是 P0 级需求。

**影响**: 鸿蒙端特性缺失，不符合 PRD 验收标准。

---

### 🟠 [HIGH-2] InstrumentCard.isAvailable 响应式失效

**文件**: `views/InstrumentCard.ets` (第 17 行)

```typescript
@Prop status: string = 'available';
private isAvailable: boolean = this.status === 'available'; // 声明时求值，后续 Prop 变化不更新
```

`isAvailable` 在类字段初始化时求值（等于 `'available' === 'available'` = `true`），当父组件传入 `status='rented'` 时不会重新计算。

**影响**: 已租出的乐器卡片不会显示灰显和"已租出"蒙层。

**修复**: 改为 getter 或在 build() 中计算：
```typescript
get isAvailable(): boolean { return this.status === 'available'; }
```

---

### 🟠 [HIGH-3] RatingStars.currentRating 无法响应外部 Prop 变化

**文件**: `views/RatingStars.ets` (第 12 行)

```typescript
@Prop rating: number = 0;
@State private currentRating: number = this.rating; // 只在构造时同步一次
```

当父组件改变 `rating` prop 时，`currentRating` (State) 不会自动同步。

**修复**: 使用 `@Watch` 装饰器或直接使用 `this.rating` 替代 `this.currentRating`：
```typescript
// build() 中使用 this.rating 而非 this.currentRating
Text(star <= this.rating ? '★' : '☆')
```

---

### 🟠 [HIGH-4] 底部 Tab 导航架构缺陷 — Tab 嵌入页面未联动

**文件**: `pages/MainPage.ets` (第 296-348 行)

分类 Tab、订单 Tab、我的 Tab 都是占位视图，点击按钮后通过 `router.pushUrl()` 跳转到独立页面。这导致：
1. 从分类/订单/个人中心返回时，底部导航的选中状态丢失
2. Tab 容器失去了"在同一页面内切换"的核心价值
3. 用户无法通过底部 Tab 返回首页 — 需要使用系统返回键多次回退

**修复建议**: 将 Category/Order/Profile 内容直接在 MainPage 内渲染为内联组件，而非跳转独立页面；或使用 Navigation + Tabs 组件的标准模式。

---

### 🟠 [HIGH-5] StatusBadge_ 重复组件 — 代码冗余

**文件**: `pages/MaintenanceCreate.ets` (第 157-166 行)

文件中定义了一个本地 `StatusBadge_` 组件，因为已导入的 `StatusBadge` 与其有命名冲突或使用问题。这是代码异味，说明组件设计不够灵活。

**修复**: 删除本地 `StatusBadge_`，直接使用 `views/StatusBadge` 组件。

---

### 🟠 [HIGH-6] 缺少 CartStore（文档约定未实现）

DEV-PLAN-HARMONY.md §3.4 明确要求实现 `CartStore` 用于 "暂存下单流程中的选中乐器 + 租期参数"，但代码库中不存在该文件。当前下单流程完全依赖 router params 传递参数。

**影响**: 如果下单流程需要跨多个页面传递复杂状态（如从详情→确认→支付），使用 router params 不够健壮。

---

## 四、中等问题

### 🟡 [MED-1] 后端地址硬编码且不可切换

**文件**: `utils/HttpClient.ets` (第 9 行)

```typescript
private baseUrl: string = 'http://10.0.2.2:8080/api/v1'; // 仅适用于模拟器
```

虽然有 `setBaseUrl()` 方法但从未被调用。生产构建无法使用。

**修复**: 从 AppStorage 或构建配置中读取 baseUrl，支持开发/生产环境切换。

---

### 🟡 [MED-2] 缺少 Mock/离线数据模式 — 未满足验收标准

DEV-PLAN-HARMONY.md 验收标准明确要求 "独立于后端可演示（Mock 数据模式）"。当前代码无任何 mock 数据层。对于毕设答辩场景，依赖后端可用是有风险的。

**修复**: 在 Service 层增加 mock 数据 fallback，通过 flag 控制。

---

### 🟡 [MED-3] 输入验证不充分

| 位置 | 问题 |
|------|------|
| `Login.ets:27` | 手机号仅检查 `length !== 11`，未验证格式（如 `1[3-9]\d{9}`） |
| `VerifyIdCard.ets:45` | 身份证仅检查 `length === 18`，未验证校验码 |
| `OrderCreate.ets:48` | 未验证用户是否已实名认证即可下单（PRD 要求实名后方可租赁） |
| `OrderCreate.ets` | 未校验用户当前租赁数量是否 < 3（PRD 要求上限 3 件） |
| 全局 | 所有 TextInput 缺少 `maxLength` 限制（除个别外） |

---

### 🟡 [MED-4] 缺少 Token 刷新机制

SPEC §5.1 描述了 Access Token + Refresh Token 的双 Token 机制，但 HttpClient 中没有实现：
- 401 响应后仅清除 token，不尝试使用 Refresh Token 续期
- 没有 `POST /auth/refresh-token` 的调用代码

---

### 🟡 [MED-5] 测试覆盖率极低

**文件**: `entry/src/test/LocalUnit.test.ets`

仅有一个模板测试 `assertContain('abc', 'b')`，无任何业务逻辑测试。SPEC §10.3 要求后端单元测试覆盖率 ≥60%，对前端虽无硬性要求，但当前覆盖率为 0%。

---

### 🟡 [MED-6] Service 层类型安全性差

多个 Service 方法使用 `object` 类型作为参数和返回值：

```typescript
// InstrumentService.ets
async getList(params: object): Promise<ApiResponse<{ records: InstrumentVO[]; total: number }>>
async getReviews(instrumentId: number, page: number = 1): Promise<ApiResponse<{ records: object[]; total: number }>>
```

应定义明确的 DTO 接口，例如：
```typescript
interface InstrumentQueryParams {
  page: number;
  size: number;
  keyword?: string;
  category?: string;
}
```

---

### 🟡 [MED-7] 深色模式仅覆盖启动背景

**文件**: `resources/dark/element/color.json`

深色模式只定义了 `start_window_background: #000000`，其他 24 个颜色 Token 无深色对应值。SPEC §5.1 设计语言要求遵循 HarmonyOS Design 规范，深色模式是基本要求。

---

### 🟡 [MED-8] 支付流程缺少超时取消机制

PRD §3.1 F-07 要求 "下单后 30 分钟内未支付则自动取消"。当前 OrderCreate 直接调用 `createOrder → payOrder` 连续执行（模拟支付模式），没有超时逻辑。虽然文档说明这是模拟模式，但应至少在前端做 UI 层面的超时提示或预留接口。

---

### 🟡 [MED-9] bundleName 使用示例值

**文件**: `AppScope/app.json5`

```json
"bundleName": "com.example.musicnest"
```

`com.example` 是保留前缀，无法上架应用市场。应改为正式包名如 `com.musicnest.harmonysound`。

---

### 🟡 [MED-10] 日志标签使用不统一

部分文件使用 `hilog` 配合 `DOMAIN` 常量（EntryAbility），部分使用 `console.error/warn`（各页面）。建议统一使用 hilog 并定义一致的日志域。

---

### 🟡 [MED-11] AuthService.logout 未调用后端接口

**文件**: `service/AuthService.ets` (第 49-52 行)

`logout()` 方法仅清除本地 AppStorage，未调用 `GET /auth/logout` 使服务端 Token 失效。

---

### 🟡 [MED-12] ImagePicker 使用 photoAccessHelper 但未处理权限拒绝

**文件**: `views/ImagePicker.ets`

`pickImage()` 使用 `photoAccessHelper.PhotoViewPicker`，但未检查相册/相机权限。在 HarmonyOS 中，访问相册需要 `ohos.permission.READ_IMAGEVIDEO` 权限，拍照需要 `ohos.permission.CAMERA`。当前 `module.json5` 中未声明这些权限。

---

## 五、轻微问题

### 🔵 [LOW-1] 无障碍（屏幕朗读）未实现

PRD §4.4 要求鸿蒙端支持屏幕朗读。当前组件中未添加 `accessibilityText`、`accessibilityGroup` 等无障碍属性。

---

### 🔵 [LOW-2] 关键操作缺少二次确认

PRD §4.4 要求 "关键操作（删除、退款）有二次确认"。取消订单、退出登录等操作直接执行，无确认弹窗。

---

### 🔵 [LOW-3] AppScope 缺少 app_name 字符串

`AppScope/app.json5` 引用 `$string:app_name`，但 `string.json` 中未定义该 key（只有 `module_desc`、`EntryAbility_desc`、`EntryAbility_label`）。

---

### 🔵 [LOW-4] 颜色值使用不一致

部分颜色使用 `$r('app.color.xxx')` 资源引用，部分使用硬编码字符串（如 `'rgba(0, 83, 56, 0.1)'`、`'#FFB400'`）。建议所有颜色都定义在 `color.json` 中统一管理。

---

### 🔵 [LOW-5] 硬编码中文文本未国际化

所有 UI 文本均为硬编码中文，未使用 `$r('app.string.xxx')` 资源引用。对于国际化需求不高的毕设项目可接受，但不符合 HarmonyOS 推荐实践。

---

### 🔵 [LOW-6] code-linter.json5 未配置项目级规则

**文件**: `code-linter.json5`

项目根目录存在该文件但内容为模板默认值，未启用 ArkTS 特定的 lint 规则。

---

### 🔵 [LOW-7] build-profile.json5 混淆未启用

Release 模式下 `arkOptions.obfuscation.ruleOptions.enable: false`。对于正式交付，建议启用代码混淆。

---

### 🔵 [LOW-8] 未配置 signingConfigs

Release 构建需要配置签名，当前 `build-profile.json5` 中 `signingConfigs: []`。

---

## 六、优点与亮点

在指出问题的同时，以下方面值得肯定：

1. **页面完整性好**: 16 个页面全部实现，覆盖 PRD 100% 的页面需求
2. **设计 Token 体系完善**: 25 色 + 16 字号 + 间距定义，设计还原基础扎实
3. **组件化合理**: 7 个共享组件复用度高，InstrumentCard/OrderCard/StatusBadge 的设计尤其适合多场景
4. **PRD 业务理解到位**: 信用免押（creditScore ≥ 800）、时长折扣（95折/9折）、BEST VALUE 标记等业务逻辑在代码中正确体现
5. **加载/空/错误三态覆盖**: 大多数列表页都处理了 Loading / Empty / Error 三种状态
6. **Glassmorphism 风格统一**: BottomNavBar 玻璃态、详情页底部栏 backdropBlur 等细节处理一致
7. **订单状态机实现**: OrderDetail 根据 status 动态渲染底部按钮（续租/归还预约/评价），逻辑清晰
8. **维修时间轴五步展示**: MaintenanceDetail 的步骤指示器（已完成/进行中/待处理）直观

---

## 七、修复优先级建议

### 立即修复（答辩前必须）

| # | 问题 | 预计工时 |
|---|------|:--------:|
| CRITICAL-1 | HttpClient 异步模式重写 | 2h |
| HIGH-1 | 华为登录（或明确降级方案并写在论文中） | 4h |
| HIGH-2/3 | InstrumentCard/RatingStars 响应式修复 | 0.5h |
| HIGH-4 | Tab 导航架构调整 | 3h |
| MED-3 | 输入验证补充（手机号/身份证/租赁前置校验） | 2h |
| MED-12 | 相册/相机权限声明 | 0.5h |

### 建议修复（答辩前提升质量）

| # | 问题 | 预计工时 |
|---|------|:--------:|
| MED-2 | Mock 数据模式 | 4h |
| MED-4 | Token 刷新机制 | 2h |
| HIGH-5 | 删除重复 StatusBadge_ | 0.5h |
| MED-10 | 统一日志规范 | 1h |
| LOW-3 | app_name 字符串补充 | 0.25h |

### 可选优化

| # | 问题 | 说明 |
|---|------|------|
| MED-7 | 深色模式 | 毕设可标记为"后续版本" |
| MED-8 | 支付超时 | 论文中说明为模拟模式限制 |
| LOW-1/2 | 无障碍/二次确认 | 论文中说明为未来工作 |
| MED-11 | AuthService 服务端登出 | 简单修复 |

---

## 八、与文档对照检查清单

| PRD 功能 | 状态 | 备注 |
|----------|:----:|------|
| F-01 注册登录 | ⚠️ 部分 | 手机号登录实现，华为登录未实现 |
| F-02 个人资料 | ✅ | Profile 页展示与编辑 |
| F-03 实名认证 | ✅ | VerifyIdCard 页实现，缺少格式校验 |
| F-04 信用分 | ✅ | Profile 页展示信用分卡片 |
| F-05 乐器浏览搜索 | ✅ | Index(首页) + InstrumentList + InstrumentDetail |
| F-06 智能推荐 | ✅ | MainPage "猜你喜欢"区域 + AI推荐标签 |
| F-07 租赁下单 | ⚠️ 部分 | OrderCreate 实现，缺少实名前置校验和租赁数量限制 |
| F-08 订单管理 | ✅ | OrderList + OrderDetail 含时间轴 |
| F-09 续租 | ✅ | OrderRenew 含折扣选择 |
| F-10 归还预约 | ✅ | ReturnBooking 含日期选择和门店信息 |
| F-11 售后报修 | ✅ | MaintenanceCreate 含拍照和紧急程度 |
| F-12 维修跟踪 | ✅ | MaintenanceDetail 含五步时间轴 |
| F-13 评价 | ✅ | ReviewCreate + MyReviews |

---

*审查报告版本：v1.0 | 日期：2026-06-12*
