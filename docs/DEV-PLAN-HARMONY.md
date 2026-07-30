# 鸿音管家 — 鸿蒙端开发阶段文档

> 版本：v1.0 | 日期：2026-06-12 | 配套文档：PRD.md / SPEC.md

---

## 开发总览

### 项目当前状态

| 项 | 状态 |
|----|------|
| DevEco Studio 项目 | ✅ 已创建（Stage 模型，API 12+） |
| entry 模块 | ✅ `entry/` 存在 |
| 页面 | ❌ 仅有模板 `pages/Index`（Hello World） |
| 路由 | ❌ 仅注册 `pages/Index` |
| 资源 | ❌ color/string/float 均为模板默认值 |

### 最终状态（2026-06-12）

| 指标 | 值 |
|------|-----|
| 源文件数 | 34 个 `.ets` |
| 总代码量 | ~130 KB |
| 页面 | 16 页（1 Splash + 15 业务页） |
| 组件 | 7 个共享组件 |
| 服务 | 6 个 API Service |
| 状态管理 | 1 个 UserStore |
| 工具 | 1 个 HttpClient |
| 数据模型 | 1 个 Models.ets（8 类） |
| 设计 Token | color.json(25色) + float.json(16值) |

### 页面完成度

| 优先级 | 页面数 | 状态 |
|:------:|:------:|------|
| P0 | 11 | ✅ 全部实现（含完整 UI 交互逻辑） |
| P1 | 5 | ✅ 全部实现 |
| **合计** | **16** | **100%** |

### 页面总览

| # | 路由 | 优先级 | 设计稿 |
|:--:|------|:------:|:------:|
| 1 | `pages/Index` | P0 | ✅ _6 |
| 2 | `pages/Login` | P0 | ❓ _1 |
| 3 | `pages/InstrumentList` | P0 | ✅ _12 |
| 4 | `pages/InstrumentDetail` | P0 | ✅ _9 |
| 5 | `pages/OrderCreate` | P0 | ✅ _10 |
| 6 | `pages/OrderList` | P0 | ✅ _13 |
| 7 | `pages/OrderDetail` | P0 | ✅ _7 |
| 8 | `pages/OrderRenew` | P1 | ✅ _14 |
| 9 | `pages/ReturnBooking` | P1 | ✅ _5 |
| 10 | `pages/MaintenanceCreate` | P0 | ✅ _4 |
| 11 | `pages/MaintenanceDetail` | P0 | ✅ _3 |
| 12 | `pages/ReviewCreate` | P1 | ✅ _8 |
| 13 | `pages/MyReviews` | P1 | ❌ |
| 14 | `pages/Profile` | P0 | ❓ _2 |
| 15 | `pages/VerifyIdCard` | P1 | ❓ _11 |

---

## 阶段一：工程基础搭建（预计 0.5 周）

### 1.1 目录结构

在 `entry/src/main/ets/` 下创建以下子目录：

```
ets/
├── entryability/
│   └── EntryAbility.ets          # [已有] 微调：非强制深色模式
├── pages/                         # [扩展] 15 个页面
├── views/                         # [新建] 共享 UI 组件
├── model/                         # [新建] 数据模型定义
├── service/                       # [新建] API 服务层
├── store/                         # [新建] AppStorage 状态管理
└── utils/                         # [新建] 工具类
    └── HttpClient.ts              # 网络请求封装
```

### 1.2 路由注册

`entry/src/main/resources/base/profile/main_pages.json`：
```json
{
  "src": [
    "pages/Index",
    "pages/Login",
    "pages/InstrumentList",
    "pages/InstrumentDetail",
    "pages/OrderCreate",
    "pages/OrderList",
    "pages/OrderDetail",
    "pages/OrderRenew",
    "pages/ReturnBooking",
    "pages/MaintenanceCreate",
    "pages/MaintenanceDetail",
    "pages/ReviewCreate",
    "pages/MyReviews",
    "pages/Profile",
    "pages/VerifyIdCard"
  ]
}
```

### 1.3 Design Token

从 DESIGN.md 提取色板写入 `color.json`：

- `primary`: `#2e02e9`
- `primary_container`: `#4a3aff`
- `secondary`: `#503de4`
- `secondary_container`: `#6a5bfe`
- `background`: `#f9f9ff`
- `surface`: `#f9f9ff`
- `surface_container_lowest`: `#ffffff`
- `surface_container`: `#e7eeff`
- `surface_container_high`: `#dee8ff`
- `on_surface`: `#111c2d`
- `on_surface_variant`: `#464557`
- `outline`: `#777588`
- `outline_variant`: `#c7c4da`
- `tertiary`: `#005338`
- `tertiary_container`: `#006e4b`
- `error`: `#ba1a1a`
- `error_container`: `#ffdad6`

字号写入 `float.json`，字符串写入 `string.json`（app_name → 鸿音管家）。

### 1.4 启动页

`Index.ets` 改为：加载中 → 检查 AppStorage 中是否有 token → 有则跳首页，无则跳 Login。

---

## 阶段二：共享组件库（预计 0.5 周）

| 组件 | 文件 | 参数 | 验收 |
|------|------|------|------|
| TopAppBar | `views/TopAppBar.ets` | `title`, `showBack`, `transparent` | 返回按钮可点击，标题居中 |
| BottomNavBar | `views/BottomNavBar.ets` | `activeTab`（0-3） | 四 Tab 切换正确，选中态高亮 + FILL 图标 |
| InstrumentCard | `views/InstrumentCard.ets` | `instrument: InstrumentVO` | 可租/已租两种渲染态 |
| OrderCard | `views/OrderCard.ets` | `order: OrderVO` | 三态配色（绿/红/灰） |
| StatusBadge | `views/StatusBadge.ets` | `status: string` | 自动映射颜色 |
| RatingStars | `views/RatingStars.ets` | `rating`, `interactive` | 只读展示 + 可点击评分 |
| ImagePicker | `views/ImagePicker.ets` | `maxCount`, `onChange` | 拍照/相册选择 + 预览 + 删除 |

---

## 阶段三：基础设施层（预计 0.5 周）

### 3.1 数据模型 (`model/`)

ArkTS `interface` 定义，与 SPEC DDL 对齐：

- `UserInfo`（id, phone, nickname, avatar, creditScore, creditLevel, verifyStatus）
- `InstrumentVO`（id, name, category, brand, model, conditionLevel, dailyPrice, weeklyPrice, monthlyPrice, deposit, status, coverImage, specs, avgRating, reviewCount）
- `RentalOrderVO`（id, orderNo, instrumentName, coverImage, startDate, endDate, rentDays, depositAmount, rentAmount, status, ...）
- `MaintenanceOrderVO`（id, orderNo, instrumentName, faultDesc, faultImages, urgency, status, diagnosis, repairContent, assigneeName, timeline[]）
- `PaymentVO`、`ReviewVO`、`NotificationVO`
- `ApiResponse<T>`：`{ code: number, message: string, data: T }`
- `PageResult<T>`：`{ records: T[], total: number, page: number, size: number }`

### 3.2 网络层 (`utils/HttpClient.ts`)

- `baseUrl` = 后端地址
- `request<T>(method, url, params?)` 泛型方法
- 请求拦截：自动附加 `Authorization: Bearer <token>`
- 响应拦截：`code !== 200` → Toast 提示；`401` → 清空 token 跳 Login

### 3.3 API 服务 (`service/`)

每个 Service 导出对应的网络调用方法，严格按照 SPEC §4.3 接口清单。

### 3.4 状态管理 (`store/`)

- `UserStore`：token、userInfo（AppStorage 持久化）
- `CartStore`：暂存下单流程中的选中乐器 + 租期参数

---

## 阶段四：P0 核心页面（预计 3 周）

按以下顺序逐页开发，每页完成后可独立在 DevEco 预览器中验证：

| 顺序 | 页面 | 设计稿引用 | 关键复杂度 |
|:----:|------|:---------:|------|
| 1 | `Login.ets` | _1 截图 | 验证码倒计时 + 华为账号 SDK |
| 2 | `Index.ets` | _6 HTML | Banner 轮播 + 分类宫格 + AI推荐横滑 + 热门网格 |
| 3 | `InstrumentList.ets` | _12 HTML | 筛选 Chip 栏 + InstrumentCard 列表 + 已租出灰显 |
| 4 | `InstrumentDetail.ets` | _9 HTML | 图片轮播 + 三级价格阶梯 + 可展开 Specs |
| 5 | `OrderCreate.ets` | _10 HTML | 进度条 + 时长选择 + 信用免押行 |
| 6 | `OrderList.ets` | _13 HTML | Tab 切换 + OrderCard 列表 |
| 7 | `OrderDetail.ets` | _7 HTML | 状态头 + 时间轴 + 动态底部按钮 |
| 8 | `MaintenanceCreate.ets` | _4 HTML | ImagePicker + 紧急程度单选 |
| 9 | `MaintenanceDetail.ets` | _3 HTML | 五步时间轴 + 脉冲动画 |
| 10 | `Profile.ets` | _2 截图 | 信用分卡片 + 菜单列表 |

---

## 阶段五：P1 补充页面（预计 1.5 周）

| 顺序 | 页面 | 设计稿引用 |
|:----:|------|:---------:|
| 1 | `OrderRenew.ets` | _14 HTML |
| 2 | `ReturnBooking.ets` | _5 HTML |
| 3 | `VerifyIdCard.ets` | _11 截图 |
| 4 | `ReviewCreate.ets` | _8 HTML |
| 5 | `MyReviews.ets` | 无设计稿 |

---

## 阶段六：集成联调与打磨（预计 1 周）

- 全流程走通（注册→租赁→续租→归还→报修→评价→信用分）
- 空态/错误态/加载态全覆盖
- 设计稿逐页校对
- 种子数据测试

---

## 验收标准

- [ ] 15 页路由全部可访问，无编译错误
- [ ] 核心闭环（租赁→续租→归还→报修→评价）无阻断
- [ ] 每页加载态 + 空态 + 错误态已处理
- [ ] 设计稿一致性：颜色/字体/间距/圆角与 DESIGN.md 偏差 ≤ 2px
- [ ] 独立于后端可演示（Mock 数据模式）

---

*文档版本：v1.0 | 日期：2026-06-12*
