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
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.context.ActiveProfiles;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * 角色 × 功能矩阵冒烟：
 * 对每个角色的「设计归属能力」做连通性探测，并记录是否真正返回业务成功。
 */
@SpringBootTest(classes = MusicNestApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("e2e")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class RoleCapabilityMatrixE2ETest {

    private static final String ADMIN_PWD = "Admin@e2e1";
    private static final String STAFF_PWD = "Staff@e2e1";

    @Autowired
    private TestRestTemplate restTemplate;
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private JdbcTemplate jdbcTemplate;

    private E2eClient api;
    private String userToken;
    private String staffToken;
    private String adminToken;

    private final Map<String, String> matrix = new LinkedHashMap<>();

    @BeforeAll
    void setUp() {
        api = new E2eClient(restTemplate, objectMapper);
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        jdbcTemplate.update("UPDATE staff SET password=? WHERE username='admin'", encoder.encode(ADMIN_PWD));
        jdbcTemplate.update("UPDATE staff SET password=? WHERE username='staff01'", encoder.encode(STAFF_PWD));
        jdbcTemplate.update("UPDATE user SET verify_status=2 WHERE phone='13800001111'");

        userToken = api.loginUser("13800001111", "123456");
        staffToken = api.loginStaff("staff01", STAFF_PWD);
        adminToken = api.loginStaff("admin", ADMIN_PWD);
    }

    @AfterAll
    void printMatrix() {
        StringBuilder sb = new StringBuilder("\n===== 角色功能连通矩阵 =====\n");
        matrix.forEach((k, v) -> sb.append(String.format("%-48s %s%n", k, v)));
        System.out.println(sb);
    }

    @Test
    @DisplayName("矩阵：USER 能力连通")
    void userCapabilities() {
        check("USER.login", true, () -> assertFalse(userToken.isBlank()));
        check("USER.send-code", true, () ->
                api.assertOk(api.post("/auth/send-code", E2eClient.mapOf("phone", "13800001111"), null), "send-code"));
        check("USER.profile.get", true, () ->
                api.assertOk(api.get("/user/profile", userToken), "profile"));
        check("USER.credit", true, () ->
                api.assertOk(api.get("/user/credit", userToken), "credit"));
        check("USER.instruments.public", true, () ->
                api.assertOk(api.get("/instruments?page=1&size=5", null), "instruments"));
        check("USER.instruments.hot", true, () ->
                api.assertOk(api.get("/instruments/hot?limit=3", null), "hot"));
        check("USER.instruments.recommend", true, () ->
                api.assertOk(api.get("/instruments/recommend", null), "recommend"));
        check("USER.notifications", true, () ->
                api.assertOk(api.get("/user/notifications", userToken), "notifications"));
        check("USER.reviews.list", true, () ->
                api.assertOk(api.get("/reviews?page=1&size=5", userToken), "reviews"));
        // 下单能力：有 available 才测写路径
        Long availableId = findAvailableInstrument();
        check("USER.order.create", availableId != null, () -> {
            JsonNode order = api.assertOk(api.post("/orders",
                    E2eClient.mapOf("instrumentId", availableId, "rentMonths", 1), userToken), "create order");
            Long id = order.path("id").asLong();
            api.assertOk(api.put("/orders/" + id + "/cancel", E2eClient.mapOf("reason", "matrix"), userToken), "cancel");
        });
    }

    @Test
    @DisplayName("矩阵：STAFF 能力连通")
    void staffCapabilities() {
        check("STAFF.login", true, () -> assertFalse(staffToken.isBlank()));
        check("STAFF.dashboard.pending", true, () ->
                api.assertOk(api.get("/dashboard/pending", staffToken), "pending"));
        check("STAFF.orders.list", true, () ->
                api.assertOk(api.get("/orders?page=1&size=5", staffToken), "orders"));
        check("STAFF.orders.overdue", true, () ->
                api.assertOk(api.get("/orders/overdue?page=1&size=5", staffToken), "overdue"));
        check("STAFF.instruments.list", true, () ->
                api.assertOk(api.get("/instruments?page=1&size=5", staffToken), "instruments"));
        check("STAFF.workorders.list", true, () ->
                api.assertOk(api.get("/work-orders?page=1&size=5", staffToken), "work-orders"));
        check("STAFF.admin.staff.forbidden", true, () -> {
            ResponseEntity<String> resp = api.exchangeRaw(HttpMethod.GET, "/admin/staff", null, staffToken);
            assertEquals(HttpStatus.FORBIDDEN, resp.getStatusCode());
        });
    }

    @Test
    @DisplayName("矩阵：ADMIN 能力连通")
    void adminCapabilities() {
        check("ADMIN.login", true, () -> assertFalse(adminToken.isBlank()));
        check("ADMIN.dashboard.pending", true, () ->
                api.assertOk(api.get("/dashboard/pending", adminToken), "pending"));
        check("ADMIN.dashboard.revenue", true, () ->
                api.assertOk(api.get("/dashboard/revenue", adminToken), "revenue"));
        check("ADMIN.staff.list", true, () ->
                api.assertOk(api.get("/admin/staff?page=1&size=5", adminToken), "staff"));
        check("ADMIN.dicts", true, () ->
                api.assertOk(api.get("/admin/dicts", adminToken), "dicts"));
        check("ADMIN.configs", true, () ->
                api.assertOk(api.get("/admin/configs", adminToken), "configs"));
        check("ADMIN.orders.list", true, () ->
                api.assertOk(api.get("/orders?page=1&size=5", adminToken), "orders"));
        check("ADMIN.workorders.list", true, () ->
                api.assertOk(api.get("/work-orders?page=1&size=5", adminToken), "work-orders"));
    }

    private Long findAvailableInstrument() {
        List<Long> ids = jdbcTemplate.query(
                "SELECT id FROM instrument WHERE status='available' ORDER BY id LIMIT 1",
                (rs, rowNum) -> rs.getLong(1));
        return ids.isEmpty() ? null : ids.get(0);
    }

    private void check(String name, boolean applicable, Runnable action) {
        if (!applicable) {
            matrix.put(name, "SKIP");
            return;
        }
        try {
            action.run();
            matrix.put(name, "PASS");
        } catch (AssertionError | Exception e) {
            matrix.put(name, "FAIL: " + e.getMessage());
            fail(name + " => " + e.getMessage(), e);
        }
    }
}
