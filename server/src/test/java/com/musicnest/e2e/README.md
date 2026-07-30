# MusicNest API E2E（跨角色数据流通）

## 覆盖目标

- **角色**：`ROLE_USER` / `ROLE_STAFF` / `ROLE_ADMIN`
- **能力**：登录、浏览、库存、下单、审核、续租、归还、工单、评价、看板、员工/字典/配置
- **流通断言**：数据写入 MySQL 后，该看到的角色能在列表/详情/看板中看到

## 前置条件

1. MySQL 可访问，并已准备库 `musicnest_e2e`  
2. Redis `localhost:6379`（可用 Docker：`docker run -d --name musicnest-redis -p 6379:6379 redis:7-alpine`）

初始化库（PowerShell）：

```powershell
$mysql='C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
& $mysql -uroot -pyour_mysql_password -e "DROP DATABASE IF EXISTS musicnest_e2e; CREATE DATABASE musicnest_e2e DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
Get-Content src\main\resources\schema.sql -Raw -Encoding UTF8 | & $mysql -uroot -pyour_mysql_password --default-character-set=utf8mb4 musicnest_e2e
Get-Content src\main\resources\data.sql -Raw -Encoding UTF8 | & $mysql -uroot -pyour_mysql_password --default-character-set=utf8mb4 musicnest_e2e
```

## 运行

```powershell
cd server
mvn test -Dtest=CrossRoleFlowE2ETest,RoleCapabilityMatrixE2ETest
```

或：

```powershell
mvn test
```

## 用例说明

| 类 | 作用 |
|---|---|
| `CrossRoleFlowE2ETest` | 主链路：下单→员工可见→审核→续租归还→工单→评价→管理员权限与看板 |
| `RoleCapabilityMatrixE2ETest` | 角色×功能连通矩阵冒烟 |
| `E2eClient` | HTTP/JSON 辅助 |

配置见 `src/test/resources/application-e2e.yml`（独立库，不污染 `musicnest` 主库）。
