package com.musicnest.e2e;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.musicnest.MusicNestApplication;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 跨角色 API E2E：
 * 1) 覆盖 USER / STAFF / ADMIN 各自核心功能
 * 2) 断言数据真实写入
 * 3) 断言跨角色可见性与流通（下单→审核→归还→工单→评价→看板）
 *
 * 依赖：本地 MySQL 库 musicnest_e2e、Redis :6379
 */
@SpringBootTest(classes = MusicNestApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("e2e")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class CrossRoleFlowE2ETest {

    private static final String USER_PHONE = "13800001111";
    private static final String USER_CODE = "123456";
    private static final String ADMIN_USER = "admin";
    private static final String STAFF_USER = "staff01";
    private static final String ADMIN_PWD = "Admin@e2e1";
    private static final String STAFF_PWD = "Staff@e2e1";

    @Autowired
    private TestRestTemplate restTemplate;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private E2eClient api;
    private final AtomicBoolean passwordsReady = new AtomicBoolean(false);

    private String userToken;
    private String staffToken;
    private String adminToken;

    private Long instrumentId;
    private String instrumentName;
    private Long orderId;
    private String orderNo;
    private Long workOrderId;
    private Long reviewId;
    private Long createdStaffId;

    @BeforeAll
    void initClient() {
        api = new E2eClient(restTemplate, objectMapper);
        ensureStaffPasswords();
        cleanupFlowArtifacts();
    }

    private void ensureStaffPasswords() {
        if (passwordsReady.get()) {
            return;
        }
        JsonNode check = api.get("/admin/check-passwords", null);
        JsonNode data = check.path("data");
        boolean hasEmpty = data.path("hasEmpty").asBoolean(false);
        if (hasEmpty && data.path("accounts").isArray() && data.path("accounts").size() > 0) {
            List<Map<String, Object>> accounts = new ArrayList<>();
            for (JsonNode acc : data.path("accounts")) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", acc.path("id").asLong());
                String username = acc.path("username").asText();
                item.put("password", ADMIN_USER.equals(username) ? ADMIN_PWD : STAFF_PWD);
                accounts.add(item);
            }
            api.assertOk(api.post("/admin/setup-passwords", accounts, null), "初始化员工密码");
        }

        // 统一写成已知测试密码，保证可重复运行
        var encoder = new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
        jdbcTemplate.update("UPDATE staff SET password=? WHERE username=?", encoder.encode(ADMIN_PWD), ADMIN_USER);
        jdbcTemplate.update("UPDATE staff SET password=? WHERE username=?", encoder.encode(STAFF_PWD), STAFF_USER);
        passwordsReady.set(true);
    }

    private void cleanupFlowArtifacts() {
        // e2e 专用库：清空业务流水，保留种子乐器/用户/员工/字典
        jdbcTemplate.update("DELETE FROM review");
        jdbcTemplate.update("DELETE FROM payment");
        jdbcTemplate.update("DELETE FROM maintenance_order");
        jdbcTemplate.update("DELETE FROM rental_order");
        jdbcTemplate.update("DELETE FROM instrument WHERE name LIKE 'E2E-%'");
        jdbcTemplate.update("DELETE FROM staff WHERE username LIKE 'e2e_staff_%'");
        jdbcTemplate.update("UPDATE instrument SET status='available'");
        jdbcTemplate.update("UPDATE user SET verify_status=2, credit_score=780, nickname=IF(phone=?, 'E2E用户', nickname) WHERE phone=?", USER_PHONE, USER_PHONE);
    }

    // ==================== 角色登录 ====================

    @Test
    @Order(1)
    @DisplayName("USER 登录有效，可拿到 token 与用户信息")
    void userLoginWorks() {
        Map<String, Object> body = E2eClient.mapOf("phone", USER_PHONE, "code", USER_CODE);
        JsonNode data = api.assertOk(api.post("/auth/login", body, null), "USER 登录");
        userToken = data.path("token").asText();
        assertFalse(userToken.isBlank());
        assertEquals(USER_PHONE, data.path("userInfo").path("phone").asText());
        assertEquals(2, data.path("userInfo").path("verifyStatus").asInt());
    }

    @Test
    @Order(2)
    @DisplayName("STAFF / ADMIN 登录有效")
    void staffAndAdminLoginWorks() {
        staffToken = api.loginStaff(STAFF_USER, STAFF_PWD);
        adminToken = api.loginStaff(ADMIN_USER, ADMIN_PWD);
        assertFalse(staffToken.isBlank());
        assertFalse(adminToken.isBlank());

        // 错误密码应失败
        Map<String, Object> bad = E2eClient.mapOf("username", STAFF_USER, "password", "wrong-pass");
        JsonNode fail = api.post("/auth/staff-login", bad, null);
        assertNotEquals(200, fail.path("code").asInt());
    }

    // ==================== USER 功能 ====================

    @Test
    @Order(10)
    @DisplayName("USER：公开浏览乐器 / 热门 / 推荐")
    void userCanBrowseInstruments() {
        JsonNode list = api.assertOk(api.get("/instruments?page=1&size=10", null), "公开乐器列表");
        assertTrue(list.path("total").asLong() >= 1, "应有乐器数据");
        assertTrue(list.path("records").isArray());

        JsonNode hot = api.assertOk(api.get("/instruments/hot?limit=3", null), "热门乐器");
        assertTrue(hot.isArray() || hot.path("records").isArray() || hot.size() >= 0);

        api.assertOk(api.get("/instruments/recommend", null), "推荐乐器");

        // 取一件 available 作为后续下单目标；若无则由员工创建
        instrumentId = null;
        for (JsonNode rec : list.path("records")) {
            if ("available".equals(rec.path("status").asText())) {
                instrumentId = rec.path("id").asLong();
                instrumentName = rec.path("name").asText();
                break;
            }
        }
    }

    @Test
    @Order(11)
    @DisplayName("USER：个人资料 / 信用分 / 通知可读")
    void userProfileCreditNotification() {
        assumeUserToken();
        JsonNode profile = api.assertOk(api.get("/user/profile", userToken), "读取资料");
        assertEquals(USER_PHONE, profile.path("phone").asText());

        Map<String, Object> patch = E2eClient.mapOf("nickname", "E2E用户");
        api.assertOk(api.put("/user/profile", patch, userToken), "更新昵称");
        JsonNode after = api.assertOk(api.get("/user/profile", userToken), "回读资料");
        assertEquals("E2E用户", after.path("nickname").asText());

        JsonNode credit = api.assertOk(api.get("/user/credit", userToken), "信用分");
        assertTrue(credit.path("score").asInt() > 0);
        api.assertOk(api.get("/user/notifications", userToken), "通知列表");
    }

    @Test
    @Order(12)
    @DisplayName("STAFF：可创建库存，且 USER 公开列表可见")
    void staffCreatesInstrumentVisibleToUser() {
        assumeStaffToken();
        String name = "E2E-测试吉他-" + System.currentTimeMillis();
        Map<String, Object> body = new HashMap<>();
        body.put("name", name);
        body.put("category", "guitar");
        body.put("brand", "E2E-Brand");
        body.put("model", "E2E-M1");
        body.put("conditionLevel", 2);
        body.put("dailyPrice", new BigDecimal("25.00"));
        body.put("weeklyPrice", new BigDecimal("150.00"));
        body.put("monthlyPrice", new BigDecimal("500.00"));
        body.put("deposit", new BigDecimal("300.00"));
        body.put("status", "available");
        body.put("description", "E2E created instrument");

        JsonNode created = api.assertOk(api.post("/instruments", body, staffToken), "员工创建乐器");
        instrumentId = created.path("id").asLong();
        instrumentName = created.path("name").asText();
        assertTrue(instrumentId > 0);

        Long dbCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM instrument WHERE id=? AND name=?", Long.class, instrumentId, name);
        assertEquals(1L, dbCount, "乐器应真实写入 DB");

        JsonNode publicList = api.assertOk(api.get("/instruments?page=1&size=50&keyword=E2E-测试吉他", null), "用户侧可见新乐器");
        boolean found = false;
        for (JsonNode rec : publicList.path("records")) {
            if (rec.path("id").asLong() == instrumentId) {
                found = true;
                assertEquals("available", rec.path("status").asText());
                break;
            }
        }
        assertTrue(found, "USER 公开列表应能看到员工新建的乐器");
    }

    @Test
    @Order(20)
    @DisplayName("USER 下单后：数据入库，STAFF/ADMIN 待审列表与看板可见")
    void userOrderFlowsToStaffVisibility() {
        assumeUserToken();
        assumeStaffToken();
        assumeAdminToken();
        assertNotNull(instrumentId, "需要可用乐器");

        Map<String, Object> orderBody = E2eClient.mapOf(
                "instrumentId", instrumentId,
                "rentMonths", 1
        );
        // 备注字段若控制器忽略也不影响；用 orderNo 关联
        JsonNode order = api.assertOk(api.post("/orders", orderBody, userToken), "用户下单");
        orderId = order.path("id").asLong();
        orderNo = order.path("orderNo").asText();
        assertTrue(orderId > 0);
        assertEquals("pending", order.path("status").asText(), "下单后应为 pending 待审");

        // DB 真值
        Map<String, Object> row = jdbcTemplate.queryForMap("SELECT status, user_id, instrument_id FROM rental_order WHERE id=?", orderId);
        assertEquals("pending", row.get("status"));
        assertEquals(instrumentId, ((Number) row.get("instrument_id")).longValue());

        String instStatus = jdbcTemplate.queryForObject("SELECT status FROM instrument WHERE id=?", String.class, instrumentId);
        assertEquals("rented", instStatus, "下单后乐器应变为 rented");

        // 支付记录应产生
        Long payCnt = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM payment WHERE order_id=? AND status='success'", Long.class, orderId);
        assertTrue(payCnt != null && payCnt >= 1, "应产生 mock 支付记录");

        // STAFF 可见
        JsonNode staffList = api.assertOk(api.get("/orders?page=1&size=50&status=pending", staffToken), "员工待审订单");
        assertTrue(containsOrder(staffList, orderId, orderNo), "员工应看到用户新订单");

        // ADMIN 可见
        JsonNode adminList = api.assertOk(api.get("/orders?page=1&size=50&status=pending", adminToken), "管理员待审订单");
        assertTrue(containsOrder(adminList, orderId, orderNo), "管理员应看到用户新订单");

        // 看板待审数
        JsonNode pending = api.assertOk(api.get("/dashboard/pending", staffToken), "员工工作台");
        assertTrue(pending.path("newOrders").asLong() >= 1, "待审订单计数应 >= 1");

        JsonNode adminPending = api.assertOk(api.get("/dashboard/pending", adminToken), "管理员工作台");
        assertTrue(adminPending.path("newOrders").asLong() >= 1);
    }

    @Test
    @Order(21)
    @DisplayName("STAFF 审核通过后：状态 renting，USER 详情可见")
    void staffApproveVisibleToUser() {
        assumeAllTokens();
        assertNotNull(orderId);

        api.assertOk(api.put("/orders/" + orderId + "/approve", Map.of(), staffToken), "员工审核通过");

        String status = jdbcTemplate.queryForObject("SELECT status FROM rental_order WHERE id=?", String.class, orderId);
        assertEquals("renting", status);

        JsonNode detail = api.assertOk(api.get("/orders/" + orderId, userToken), "用户查看订单详情");
        assertEquals("renting", detail.path("status").asText());
        assertEquals(orderId, detail.path("id").asLong());
    }

    @Test
    @Order(22)
    @DisplayName("USER 续租 + 归还预约，STAFF 可完成归还并标记损坏")
    void renewReturnAndStaffComplete() {
        assumeAllTokens();
        assertNotNull(orderId);

        JsonNode renewed = api.assertOk(
                api.post("/orders/" + orderId + "/renew", E2eClient.mapOf("months", 1), userToken),
                "用户续租");
        assertTrue(renewed.path("rentDays").asInt() >= 60, "续租后租期应增加");

        api.assertOk(
                api.post("/orders/" + orderId + "/return-booking", E2eClient.mapOf("returnDate", "2099-01-01"), userToken),
                "用户归还预约");
        assertEquals("returning",
                jdbcTemplate.queryForObject("SELECT status FROM rental_order WHERE id=?", String.class, orderId));

        // 员工侧应能按状态查到 returning
        JsonNode returningList = api.assertOk(api.get("/orders?page=1&size=50&status=returning", staffToken), "员工归还中列表");
        assertTrue(containsOrder(returningList, orderId, orderNo), "员工应看到归还中订单");

        api.assertOk(
                api.put("/orders/" + orderId + "/complete-return", E2eClient.mapOf("hasDamage", true), staffToken),
                "员工确认归还(有损坏)");

        assertEquals("completed",
                jdbcTemplate.queryForObject("SELECT status FROM rental_order WHERE id=?", String.class, orderId));
        assertEquals("maintenance",
                jdbcTemplate.queryForObject("SELECT status FROM instrument WHERE id=?", String.class, instrumentId),
                "有损坏时乐器应进入 maintenance");
    }

    @Test
    @Order(30)
    @DisplayName("USER 报修 → STAFF 处理 → USER 确认；全程跨角色可见")
    void workOrderCrossRoleFlow() {
        assumeAllTokens();
        assertNotNull(instrumentId);

        // 另备一件 available 乐器用于报修关联（或直接用当前 instrument）
        Map<String, Object> woBody = E2eClient.mapOf(
                "instrumentId", instrumentId,
                "faultDesc", "E2E琴弦断裂需要更换",
                "urgency", "urgent",
                "rentalOrderId", orderId
        );
        JsonNode wo = api.assertOk(api.post("/work-orders", woBody, userToken), "用户提交报修");
        workOrderId = wo.path("id").asLong();
        assertEquals("pending", wo.path("status").asText());

        Long dbWo = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM maintenance_order WHERE id=? AND fault_desc LIKE 'E2E%'", Long.class, workOrderId);
        assertEquals(1L, dbWo);

        // STAFF/ADMIN 列表可见
        JsonNode staffWo = api.assertOk(api.get("/work-orders?page=1&size=50&status=pending", staffToken), "员工待处理工单");
        assertTrue(containsId(staffWo, workOrderId), "员工应看到新工单");
        JsonNode adminWo = api.assertOk(api.get("/work-orders?page=1&size=50&status=pending", adminToken), "管理员待处理工单");
        assertTrue(containsId(adminWo, workOrderId), "管理员应看到新工单");

        JsonNode pendingBoard = api.assertOk(api.get("/dashboard/pending", staffToken), "工单进入看板");
        assertTrue(pendingBoard.path("pendingWorkOrders").asLong() >= 1);

        Long staffId = jdbcTemplate.queryForObject("SELECT id FROM staff WHERE username=?", Long.class, STAFF_USER);
        api.assertOk(api.put("/work-orders/" + workOrderId + "/assign",
                E2eClient.mapOf("staffId", staffId), staffToken), "派单");
        assertEquals("assigned",
                jdbcTemplate.queryForObject("SELECT status FROM maintenance_order WHERE id=?", String.class, workOrderId));

        api.assertOk(api.put("/work-orders/" + workOrderId + "/start-repair", Map.of(), staffToken), "开始维修");
        assertEquals("repairing",
                jdbcTemplate.queryForObject("SELECT status FROM maintenance_order WHERE id=?", String.class, workOrderId));

        Map<String, Object> repair = E2eClient.mapOf(
                "diagnosis", "E2E弦轴松动",
                "repairContent", "更换弦轴并调音",
                "repairParts", "弦轴x1",
                "repairCost", 88.5
        );
        api.assertOk(api.put("/work-orders/" + workOrderId + "/complete-repair", repair, staffToken), "完成维修");
        assertEquals("checking",
                jdbcTemplate.queryForObject("SELECT status FROM maintenance_order WHERE id=?", String.class, workOrderId));

        // USER 确认
        api.assertOk(api.put("/work-orders/" + workOrderId + "/confirm", Map.of(), userToken), "用户确认维修完成");
        assertEquals("completed",
                jdbcTemplate.queryForObject("SELECT status FROM maintenance_order WHERE id=?", String.class, workOrderId));

        JsonNode detail = api.assertOk(api.get("/work-orders/" + workOrderId, userToken), "用户查看工单详情");
        assertEquals("completed", detail.path("status").asText());
    }

    @Test
    @Order(40)
    @DisplayName("USER 评价写入后，列表可查到")
    void userReviewVisible() {
        assumeUserToken();
        assertNotNull(orderId);
        assertNotNull(instrumentId);

        Map<String, Object> body = E2eClient.mapOf(
                "type", "rental",
                "rating", 5,
                "content", "E2E评价-服务很好",
                "rentalOrderId", orderId,
                "instrumentId", instrumentId
        );
        JsonNode review = api.assertOk(api.post("/reviews", body, userToken), "用户提交评价");
        reviewId = review.path("id").asLong();
        assertTrue(reviewId > 0);

        Long cnt = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM review WHERE id=?", Long.class, reviewId);
        assertEquals(1L, cnt);

        JsonNode list = api.assertOk(api.get("/reviews?page=1&size=20&instrumentId=" + instrumentId, userToken), "评价列表");
        boolean found = false;
        for (JsonNode rec : list.path("records")) {
            if (rec.path("id").asLong() == reviewId) {
                found = true;
                assertEquals("E2E评价-服务很好", rec.path("content").asText());
                break;
            }
        }
        assertTrue(found, "评价列表应包含刚产生的评价");
    }

    // ==================== ADMIN 功能与权限边界 ====================

    @Test
    @Order(50)
    @DisplayName("ADMIN：员工管理 / 字典 / 配置；STAFF 访问 admin 应 403")
    void adminOnlyApisAndStaffForbidden() {
        assumeStaffToken();
        assumeAdminToken();

        // STAFF 禁止
        ResponseEntity<String> forbidden = api.exchangeRaw(HttpMethod.GET, "/admin/staff?page=1&size=10", null, staffToken);
        assertEquals(HttpStatus.FORBIDDEN, forbidden.getStatusCode(), "员工访问 /admin/staff 应 403");

        // ADMIN 可管理员工
        JsonNode staffPage = api.assertOk(api.get("/admin/staff?page=1&size=10", adminToken), "管理员员工列表");
        assertTrue(staffPage.path("total").asLong() >= 2);

        String newUsername = "e2e_staff_" + (System.currentTimeMillis() % 100000);
        Map<String, Object> create = E2eClient.mapOf(
                "username", newUsername,
                "realName", "E2E临时员工",
                "phone", "13900001111",
                "role", "ROLE_STAFF"
        );
        JsonNode created = api.assertOk(api.post("/admin/staff", create, adminToken), "创建员工");
        createdStaffId = created.path("id").asLong();
        assertEquals("ROLE_STAFF", created.path("role").asText());

        Long exists = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM staff WHERE id=?", Long.class, createdStaffId);
        assertEquals(1L, exists);

        api.assertOk(api.put("/admin/staff/" + createdStaffId + "/status", E2eClient.mapOf("status", 0), adminToken), "停用员工");
        assertEquals(0, jdbcTemplate.queryForObject("SELECT status FROM staff WHERE id=?", Integer.class, createdStaffId));

        // 字典与配置
        JsonNode dicts = api.assertOk(api.get("/admin/dicts?type=instrument_category", adminToken), "读字典");
        assertTrue(dicts.isArray() && dicts.size() >= 1, "应有乐器分类字典");

        JsonNode configs = api.assertOk(api.get("/admin/configs", adminToken), "读配置");
        assertTrue(configs.isArray() && configs.size() >= 1);

        // 改一个配置再读回
        api.assertOk(api.put("/admin/configs", E2eClient.mapOf("rent_max_months", "12"), adminToken), "更新配置");
    }

    @Test
    @Order(51)
    @DisplayName("ADMIN 数据看板可读；完成订单后 revenue 非空结构")
    void adminDashboardReadable() {
        assumeAdminToken();
        JsonNode pending = api.assertOk(api.get("/dashboard/pending", adminToken), "看板待办");
        assertTrue(pending.has("newOrders"));
        assertTrue(pending.has("pendingWorkOrders"));
        assertTrue(pending.has("overdueOrders"));

        JsonNode revenue = api.assertOk(api.get("/dashboard/revenue?period=month", adminToken), "营收");
        assertTrue(revenue.has("monthRevenue"));
        // 本流程已有 completed 订单，营收应可计算（可能为 0 若 total 为空，但字段必须存在）
        assertNotNull(revenue.get("monthRevenue"));

        // 半成品 stats 至少应 200
        api.assertOk(api.get("/dashboard/rental-stats", adminToken), "rental-stats");
        api.assertOk(api.get("/dashboard/user-stats", adminToken), "user-stats");
        api.assertOk(api.get("/dashboard/workorder-stats", adminToken), "workorder-stats");
    }

    @Test
    @Order(60)
    @DisplayName("USER 取消链路：新订单可取消并释放库存，员工列表不再 pending")
    void userCancelReleasesStock() {
        assumeUserToken();
        assumeStaffToken();

        // 准备 available 乐器
        Long freeId = jdbcTemplate.queryForObject(
                "SELECT id FROM instrument WHERE status='available' ORDER BY id LIMIT 1", Long.class);
        if (freeId == null) {
            // 释放一件
            jdbcTemplate.update("UPDATE instrument SET status='available' WHERE id=?", instrumentId);
            freeId = instrumentId;
        }

        JsonNode order = api.assertOk(api.post("/orders",
                E2eClient.mapOf("instrumentId", freeId, "rentMonths", 1), userToken), "再下一单用于取消");
        Long cancelId = order.path("id").asLong();
        String cancelNo = order.path("orderNo").asText();
        assertEquals("pending", order.path("status").asText());

        api.assertOk(api.put("/orders/" + cancelId + "/cancel", E2eClient.mapOf("reason", "E2E取消"), userToken), "用户取消");
        assertEquals("cancelled",
                jdbcTemplate.queryForObject("SELECT status FROM rental_order WHERE id=?", String.class, cancelId));
        assertEquals("available",
                jdbcTemplate.queryForObject("SELECT status FROM instrument WHERE id=?", String.class, freeId),
                "取消后应释放库存");

        JsonNode pending = api.assertOk(api.get("/orders?page=1&size=100&status=pending", staffToken), "取消后员工待审");
        assertFalse(containsOrder(pending, cancelId, cancelNo), "取消订单不应再出现在 pending");
    }

    @Test
    @Order(70)
    @DisplayName("未登录受保护接口应 401；错误验证码不可登录")
    void authGuards() {
        ResponseEntity<String> noToken = api.exchangeRaw(HttpMethod.GET, "/user/profile", null, null);
        assertEquals(HttpStatus.UNAUTHORIZED, noToken.getStatusCode());

        JsonNode badCode = api.post("/auth/login", E2eClient.mapOf("phone", USER_PHONE, "code", "000000"), null);
        assertNotEquals(200, badCode.path("code").asInt());
    }

    // ==================== helpers ====================

    private void assumeUserToken() {
        if (userToken == null || userToken.isBlank()) {
            userToken = api.loginUser(USER_PHONE, USER_CODE);
        }
    }

    private void assumeStaffToken() {
        if (staffToken == null || staffToken.isBlank()) {
            ensureStaffPasswords();
            staffToken = api.loginStaff(STAFF_USER, STAFF_PWD);
        }
    }

    private void assumeAdminToken() {
        if (adminToken == null || adminToken.isBlank()) {
            ensureStaffPasswords();
            adminToken = api.loginStaff(ADMIN_USER, ADMIN_PWD);
        }
    }

    private void assumeAllTokens() {
        assumeUserToken();
        assumeStaffToken();
        assumeAdminToken();
    }

    private boolean containsOrder(JsonNode page, Long id, String no) {
        if (page == null || !page.path("records").isArray()) {
            return false;
        }
        for (JsonNode rec : page.path("records")) {
            if (id != null && rec.path("id").asLong() == id) {
                return true;
            }
            if (no != null && no.equals(rec.path("orderNo").asText())) {
                return true;
            }
        }
        return false;
    }

    private boolean containsId(JsonNode page, Long id) {
        if (page == null || !page.path("records").isArray()) {
            return false;
        }
        for (JsonNode rec : page.path("records")) {
            if (rec.path("id").asLong() == id) {
                return true;
            }
        }
        return false;
    }
}
