package com.musicnest.controller;

import com.musicnest.common.Result;
import com.musicnest.entity.Notification;
import com.musicnest.entity.User;
import com.musicnest.mapper.NotificationMapper;
import com.musicnest.mapper.UserMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserMapper userMapper;
    private final NotificationMapper notificationMapper;

    @GetMapping("/profile")
    public Result<User> getProfile(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        if (userId == null) return Result.fail(401, "未登录");
        User user = userMapper.selectById(userId);
        if (user != null) user.setPassword(null);
        return Result.ok(user);
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Map<String, String> body, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = userMapper.selectById(userId);
        // 仅允许更新昵称和头像，防止越权修改 creditScore/verifyStatus 等敏感字段
        if (body.containsKey("nickname")) user.setNickname(body.get("nickname"));
        if (body.containsKey("avatar")) user.setAvatar(body.get("avatar"));
        userMapper.updateById(user);
        return Result.ok();
    }

    @PostMapping("/verify")
    public Result<Void> verify(@RequestBody Map<String, String> body, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = new User();
        user.setId(userId);
        user.setRealName(body.get("realName"));
        user.setIdCard(body.get("idCard"));
        user.setIdCardFront(body.get("idCardFront"));
        user.setIdCardBack(body.get("idCardBack"));
        user.setVerifyStatus(1);
        userMapper.updateById(user);
        return Result.ok();
    }

    @GetMapping("/credit")
    public Result<Map<String, Object>> getCredit(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        User user = userMapper.selectById(userId);
        return Result.ok(Map.of("score", user.getCreditScore(), "level", user.getCreditLevel(),
                "levelLabel", getLevelLabel(user.getCreditLevel())));
    }

    @GetMapping("/notifications")
    public Result<Object> getNotifications(HttpServletRequest request) {
        return Result.ok(new com.musicnest.common.PageResult<>(
                notificationMapper.selectList(null), 0, 1, 10));
    }

    @PutMapping("/notifications/{id}/read")
    public Result<Void> markRead(@PathVariable Long id) {
        Notification n = new Notification();
        n.setId(id);
        n.setIsRead(1);
        notificationMapper.updateById(n);
        return Result.ok();
    }

    private String getLevelLabel(int level) {
        return switch (level) { case 1 -> "优秀"; case 2 -> "良好"; case 3 -> "一般"; default -> "较差"; };
    }
}
