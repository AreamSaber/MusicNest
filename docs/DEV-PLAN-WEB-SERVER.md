# 鸿音管家 — Web 管理端 + 后端 统一开发计划

> 版本：v1.0 | 日期：2026-06-12 | 配套：DEV-PLAN-HARMONY.md

---

## 一、总览

| 维度 | Web 管理端 | 后端 |
|------|-----------|------|
| 框架 | Vue 3.4 + TypeScript + Vite 5 | Spring Boot 3.x + JDK 17 |
| UI/ORM | Element Plus 2.5 + Pinia | MyBatis-Plus 3.5 + MySQL 8.0 |
| 页面/端点 | 12 页 | ~50 REST API |
| 产出目录 | `web-ui/` | `server/` |
| 策略 | **模块并行**：后端接口 Knife4j 可调 → 前端对接 |

---

## 二、阶段一：双端工程脚手架

### 后端
- Maven 项目 `pom.xml`（spring-boot 3 / mybatis-plus / mysql / redis / jjwt / knife4j / hutool / mapstruct / lombok / validation）
- 启动类 + `application-dev.yml` + `application.yml`
- 包结构：`config/ controller/ service/impl/ mapper/ entity/ dto/ vo/ enums/ common/ security/`
- 通用类：`Result` / `PageResult` / `BusinessException` / `GlobalExceptionHandler`

### Web端
- `package.json` / `vite.config.ts` / `tsconfig.json` / `index.html`
- `src/main.ts`（注册 ElementPlus / Pinia / Router）
- `src/App.vue`（`<router-view>`）
- 子目录：`api/ components/ composables/ layouts/ router/ stores/ views/ utils/ assets/`

---

## 三、阶段二：基础设施层

### 后端
- `JwtUtil` + `AuthInterceptor` + `WebMvcConfig`（拦截器+CORS+静态资源映射）
- `MyBatisPlusConfig`（分页插件）+ `RedisConfig`
- `schema.sql`（12 表 DDL）+ `data.sql`（种子数据）

### Web端
- `utils/request.ts`（Axios 封装：Token 注入 + 401 处理 + 错误 toast）
- `router/index.ts`（12 路由 + `beforeEach` 守卫）
- `stores/auth.ts`（Pinia：token/staffInfo/role + login/logout）
- `api/types.ts`（TS interface 对齐 SPEC DDL）
- `api/*.ts`（6 个 API 模块）
- `components/StatusTag.vue` + `Pagination.vue` + `ImageUpload.vue`

---

## 四、阶段三：认证 + 布局

- **后端**：Staff 实体+Mapper+Service + `POST /auth/staff-login` + `GET /auth/logout`
- **Web端**：`Login.vue` + `layouts/Layout.vue` + `layouts/Sidebar.vue`

---

## 五、阶段四：乐器管理

- **后端**：Instrument 实体+Mapper+Service + Controller（CRUD+状态变更）+ `POST /files/upload` + 字典初始化
- **Web端**：`views/inventory/InstrumentList.vue` + `views/inventory/InstrumentForm.vue`

---

## 六、阶段五：订单管理

- **后端**：Order 实体+Mapper+Service（状态机+库存扣减+回滚+逾期）+ Controller（审核/归还/逾期列表）
- **Web端**：`views/order/OrderList.vue` + `views/order/OrderDetail.vue`

---

## 七、阶段六：工单管理

- **后端**：MaintenanceOrder 实体+Mapper+Service（流转+日志+超时）+ Controller（派单/维修/完成）
- **Web端**：`views/workorder/WorkOrderList.vue` + `views/workorder/WorkOrderDetail.vue`

---

## 八、阶段七：数据看板 + 系统管理

- **后端**：DashboardController（聚合统计）+ AdminController（员工/字典/配置 CRUD）
- **Web端**：`DataBoard.vue`(ECharts) + `StaffList.vue` + `SystemConfig.vue`

---

## 九、阶段八：集成联调与收尾

- 全链路测试：登录→乐器入库→下单→审核→归还→工单→看板
- 主题色统一 `#2e02e9` + 空态 `el-empty` + 加载 `v-loading`
- 路由守卫：未登录→`/login`，权限不足→403
- 种子数据验证

---

*文档版本：v1.0 | 日期：2026-06-12*
