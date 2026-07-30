package com.musicnest.e2e;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 轻量 HTTP 客户端：统一鉴权头、JSON 解析与业务码断言。
 */
public class E2eClient {

    private final TestRestTemplate rest;
    private final ObjectMapper mapper;
    private final String basePath = "/api/v1";

    public E2eClient(TestRestTemplate rest, ObjectMapper mapper) {
        this.rest = rest;
        this.mapper = mapper;
    }

    public JsonNode get(String path, String token) {
        return exchange(HttpMethod.GET, path, null, token);
    }

    public JsonNode post(String path, Object body, String token) {
        return exchange(HttpMethod.POST, path, body, token);
    }

    public JsonNode put(String path, Object body, String token) {
        return exchange(HttpMethod.PUT, path, body, token);
    }

    public JsonNode delete(String path, String token) {
        return exchange(HttpMethod.DELETE, path, null, token);
    }

    public ResponseEntity<String> exchangeRaw(HttpMethod method, String path, Object body, String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(List.of(MediaType.APPLICATION_JSON));
        if (token != null && !token.isBlank()) {
            headers.setBearerAuth(token);
        }
        HttpEntity<Object> entity = new HttpEntity<>(body, headers);
        return rest.exchange(basePath + path, method, entity, String.class);
    }

    public JsonNode exchange(HttpMethod method, String path, Object body, String token) {
        ResponseEntity<String> response = exchangeRaw(method, path, body, token);
        try {
            if (response.getBody() == null || response.getBody().isBlank()) {
                throw new AssertionError(method + " " + path + " 返回空 body, http=" + response.getStatusCode());
            }
            return mapper.readTree(response.getBody());
        } catch (AssertionError e) {
            throw e;
        } catch (Exception e) {
            throw new AssertionError(method + " " + path + " JSON 解析失败: " + response.getBody(), e);
        }
    }

    public JsonNode assertOk(JsonNode node, String action) {
        if (node == null) {
            throw new AssertionError(action + " 响应为 null");
        }
        int code = node.path("code").asInt(-1);
        if (code != 200) {
            throw new AssertionError(action + " 失败: code=" + code + ", message=" + node.path("message").asText()
                    + ", body=" + node);
        }
        return node.path("data");
    }

    public String loginUser(String phone, String code) {
        Map<String, Object> body = new HashMap<>();
        body.put("phone", phone);
        body.put("code", code);
        JsonNode data = assertOk(post("/auth/login", body, null), "用户登录 " + phone);
        return data.path("token").asText();
    }

    public String loginStaff(String username, String password) {
        Map<String, Object> body = new HashMap<>();
        body.put("username", username);
        body.put("password", password);
        JsonNode data = assertOk(post("/auth/staff-login", body, null), "员工登录 " + username);
        return data.path("token").asText();
    }

    public static Map<String, Object> mapOf(Object... kv) {
        Map<String, Object> map = new HashMap<>();
        for (int i = 0; i < kv.length; i += 2) {
            map.put(String.valueOf(kv[i]), kv[i + 1]);
        }
        return map;
    }
}
