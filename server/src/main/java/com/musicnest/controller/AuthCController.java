package com.musicnest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.musicnest.common.Result;
import com.musicnest.entity.User;
import com.musicnest.mapper.UserMapper;
import com.musicnest.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthCController {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;

    @PostMapping("/send-code")
    public Result<Void> sendCode(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        if (phone == null || !phone.matches("^1[3-9]\\d{9}$")) {
            return Result.fail("手机号格式错误");
        }
        return Result.ok();
    }

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String phone = body.get("phone");
        String code = body.get("code");
        if (!"123456".equals(code)) return Result.fail("验证码错误");
        User user = findOrCreateUser(phone);
        user.setLastLoginAt(LocalDateTime.now());
        userMapper.updateById(user);
        return buildLoginResult(user);
    }

    @PostMapping("/huawei-login")
    public Result<Map<String, Object>> huaweiLogin(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", "13800000000");
        User user = findOrCreateUser(phone);
        return buildLoginResult(user);
    }

    private User findOrCreateUser(String phone) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getPhone, phone));
        if (user == null) {
            user = new User();
            user.setPhone(phone);
            user.setNickname("用户" + phone.substring(7));
            user.setCreditScore(600);
            user.setCreditLevel(2);
            user.setVerifyStatus(0);
            userMapper.insert(user);
        }
        return user;
    }

    private Result<Map<String, Object>> buildLoginResult(User user) {
        String token = jwtUtil.generateUserToken(user.getId(), user.getPhone(), "ROLE_USER");
        user.setPassword(null);
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userInfo", user);
        return Result.ok(data);
    }
}
