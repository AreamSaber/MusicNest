# 鸿音管家（MusicNest / HarmonySound）

> 面向中小型乐器租赁门店的 **租赁 + 售后** 全链路管理平台  
> 终端覆盖：**鸿蒙 App（C 端）** + **Vue Web 管理后台（B 端）** + **Spring Boot 统一 API**

---

## 一、项目简介

传统门店租赁常依赖纸质单据或微信记录，存在库存状态不透明、维修进度难追踪、经营数据缺失等问题。  
**鸿音管家** 打通：

```text
选琴 → 租赁下单 → 审核履约 → 使用中续租/报修 → 归还 → 评价 / 复购
```

| 维度 | 说明 |
|------|------|
| 项目定位 | 计算机本科毕业设计 / 全栈演示项目 |
| 工程名 | MusicNest |
| 产品名 | 鸿音管家（HarmonySound） |
| 核心价值 | 一站式乐器租赁与售后协同，提升门店效率与用户体验 |

---

## 二、角色与权限

| 角色 | 标识 | 终端 | 能力概要 |
|------|------|------|----------|
| 普通用户 | `ROLE_USER` | 鸿蒙 App | 登录/实名、浏览乐器、下单支付(mock)、续租、归还预约、报修、评价 |
| 门店员工 | `ROLE_STAFF` | Web 后台 | 订单审核/归还、库存管理、工单派发与维修、工作台待办 |
| 管理员 | `ROLE_ADMIN` | Web 后台 | 员工全部能力 + 数据看板 + 员工/字典/系统配置 |

---

## 三、功能一览

### 3.1 鸿蒙 C 端（用户）

- 手机号验证码登录（演示码 `123456`）、华为账号登录占位
- 个人资料、实名认证、信用分查看、通知
- 乐器列表/搜索/热门/推荐、详情浏览
- 租赁下单、mock 支付、订单列表与详情
- 续租、归还预约、取消待审订单
- 报修提交、维修进度、用户确认完工
- 评价提交与我的评价

### 3.2 Web 管理端（员工 / 管理员）

- 员工账号登录（BCrypt）、首次空密码可走设密页
- **工作台**：待审订单、待处理工单、逾期数
- **订单管理**：审核通过/驳回、确认归还（可标记损坏）、逾期列表
- **库存管理**：乐器 CRUD、状态维护
- **工单管理**：派单、开始维修、完成维修（诊断/配件/费用）
- **数据看板**（管理员）：营收与统计入口
- **系统管理**（管理员）：员工管理、字典、业务配置

### 3.3 后端核心能力

- 统一 REST：`/api/v1/**`，响应体 `Result{code,message,data}`
- JWT 鉴权；`/api/v1/admin/**` 强制 `ROLE_ADMIN`
- 租赁订单状态机：`pending → renting → returning → completed`（可取消）
- 维修工单状态机：`pending → assigned → repairing → checking → completed`
- 下单 **悲观锁** `SELECT ... FOR UPDATE`，降低超卖
- 信用分阈值影响押金（如高分免押演示规则）
- 本地文件上传、Knife4j API 文档
- 跨角色 API **E2E**（连通、造数、跨角色可见性、admin 越权 403）

---

## 四、技术栈

### 4.1 后端 `server/`

| 类别 | 技术 |
|------|------|
| 语言 / 运行时 | Java 17 |
| 框架 | Spring Boot 3.2.x |
| ORM | MyBatis-Plus 3.5.x |
| 数据库 | MySQL 8.0 |
| 缓存 | Redis 7.x（已接入配置） |
| 安全 | JWT（jjwt）、BCrypt |
| 文档 | Knife4j / springdoc |
| 工具 | Lombok、Hutool |
| 测试 | JUnit 5、`CrossRoleFlowE2ETest` / `RoleCapabilityMatrixE2ETest` |

### 4.2 Web 管理端 `web-ui/`

| 类别 | 技术 |
|------|------|
| 框架 | Vue 3 + TypeScript |
| 构建 | Vite 5 |
| UI | Element Plus + 图标 |
| 状态 / 路由 | Pinia、Vue Router |
| 请求 | Axios（`/api` 代理到后端） |
| 图表 | ECharts |

### 4.3 鸿蒙端 `entry/`

| 类别 | 技术 |
|------|------|
| 语言 / UI | ArkTS、ArkUI（Stage 模型） |
| 工程 | DevEco / hvigor、`oh-package.json5` |
| 网络 | 自研 `HttpClient`（Bearer Token） |
| 状态 | `AppStorage` 封装的 UserStore / CartStore |

### 4.4 整体架构

```text
鸿蒙 App (entry)  ──HTTP JSON──┐
                               ├──► Spring Boot :8080  /api/v1  ──► MySQL
Web 管理端 (web-ui) ───────────┘         │
   Vite dev 代理 /api → 8080              └──► Redis
```

---

## 五、目录结构

```text
MusicNest/
├── entry/                 # 鸿蒙 C 端
├── web-ui/                # Vue3 B 端
├── server/                # Spring Boot 后端
│   ├── src/main/java/com/musicnest/
│   │   ├── controller/    # C/B API
│   │   ├── service/       # 订单/工单等
│   │   ├── mapper/ entity/ security/ config/
│   │   └── ...
│   ├── src/main/resources/
│   │   ├── schema.sql / data.sql
│   │   └── application*.yml
│   └── src/test/java/com/musicnest/e2e/   # 跨角色 E2E
├── docs/                  # PRD / SPEC / ER / 开发计划
├── AppScope/              # 鸿蒙应用级资源
├── setup-db.bat           # 本地 MySQL 初始化脚本
└── README.md
```

---

## 六、快速开始

### 6.1 环境要求

- JDK 17+
- Maven 3.9+
- Node.js 18+（建议）
- MySQL 8.0
- Redis 7.x（后端已配置依赖）
- DevEco Studio（运行鸿蒙端）

### 6.2 初始化数据库

1. 按本机环境修改 `setup-db.bat` 中的 MySQL 路径、用户名、密码  
2. 或手动执行：

```sql
CREATE DATABASE musicnest DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

然后导入：

- `server/src/main/resources/schema.sql`
- `server/src/main/resources/data.sql`

3. 修改 `server/src/main/resources/application-dev.yml` 中的数据源与 Redis 配置。

**种子账号（密码首次可能为空，需走 Web 设密页）：**

| 账号 | 角色 |
|------|------|
| `admin` | `ROLE_ADMIN` |
| `staff01` | `ROLE_STAFF` |
| 手机号 `13800001111` + 验证码 `123456` | C 端用户（已实名种子） |

### 6.3 启动后端

```bash
cd server
mvn spring-boot:run
```

- 默认端口：`8080`
- 接口前缀：`/api/v1`
- 文档（若开启）：Knife4j / swagger-ui

### 6.4 启动 Web 管理端

```bash
cd web-ui
npm install
npm run dev
```

- 开发地址一般是 `http://localhost:5173`
- `vite` 将 `/api` 代理到 `http://localhost:8080`

### 6.5 运行鸿蒙端

1. 用 DevEco Studio 打开本仓库  
2. 运行 `entry` 模块  
3. 模拟器访问宿主机后端示例：`http://10.0.2.2:8080/api/v1`（见 `entry/.../HttpClient.ets`）

### 6.6 运行 API E2E（可选）

准备独立库 `musicnest_e2e` 与 Redis 后：

```bash
cd server
mvn test -Dtest=CrossRoleFlowE2ETest,RoleCapabilityMatrixE2ETest
```

说明见：`server/src/test/java/com/musicnest/e2e/README.md`

---

## 七、关键业务状态机

### 租赁订单

```text
pending ──审核通过──► renting ──归还预约──► returning ──确认归还──► completed
   │
   └──取消/驳回──► cancelled
```

### 维修工单

```text
pending → assigned → repairing → checking → completed
```

---

## 八、文档

| 文档 | 说明 |
|------|------|
| [docs/PRD.md](./docs/PRD.md) | 产品需求 |
| [docs/SPEC.md](./docs/SPEC.md) | 技术规格 |
| [docs/ER-DIAGRAM.md](./docs/ER-DIAGRAM.md) | 库表 / ER |
| [docs/README.md](./docs/README.md) | 文档索引 |

---

## 九、演示说明与边界

本项目面向教学与毕设演示，以下能力为 **演示级实现**：

- 短信验证码固定演示值
- 支付为 mock 成功
- 华为账号登录为 stub
- 部分数据看板 stats 可能返回空结构
- 后端接口级 RBAC 以 `/admin/**` 强校验为主，其余依赖登录态（Web 菜单已按管理员收敛）

**请勿** 将仓库中的本地演示密钥直接用于生产环境；部署前请替换数据库口令、JWT secret，并关闭演示登录逻辑。

---

## 十、作者

- GitHub：[@AreamSaber](https://github.com/AreamSaber)
- Email：whk1085403136@gmail.com

---

## 十一、许可证

仅供学习与毕业设计演示使用。若需商用或二次分发，请自行评估依赖协议与业务合规。
