package com.musicnest.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }

        String token = request.getHeader("Authorization");
        if (token == null || !token.startsWith("Bearer ")) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"未登录\",\"data\":null}");
            return false;
        }

        token = token.substring(7);
        try {
            if (jwtUtil.isTokenExpired(token)) {
                response.setStatus(401);
                response.getWriter().write("{\"code\":401,\"message\":\"Token已过期\",\"data\":null}");
                return false;
            }
            Long staffId = jwtUtil.getStaffId(token);
            String role = jwtUtil.getRole(token);
            if (staffId != null) request.setAttribute("staffId", staffId);
            Long userId = jwtUtil.getUserId(token);
            if (userId != null) request.setAttribute("userId", userId);
            request.setAttribute("role", role);

            // RBAC: ADMIN-only paths check
            String path = request.getRequestURI();
            if (path.startsWith("/api/v1/admin") && !"ROLE_ADMIN".equals(role)) {
                response.setStatus(403);
                response.getWriter().write("{\"code\":403,\"message\":\"权限不足\",\"data\":null}");
                return false;
            }
            return true;
        } catch (Exception e) {
            response.setStatus(401);
            response.getWriter().write("{\"code\":401,\"message\":\"Token无效\",\"data\":null}");
            return false;
        }
    }
}
