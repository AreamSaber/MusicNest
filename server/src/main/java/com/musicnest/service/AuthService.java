package com.musicnest.service;

import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.Staff;
import com.musicnest.mapper.StaffMapper;
import com.musicnest.security.JwtUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final StaffMapper staffMapper;
    private final JwtUtil jwtUtil;

    public Map<String, Object> staffLogin(String username, String password) {
        Staff staff = staffMapper.selectOne(
                new LambdaQueryWrapper<Staff>().eq(Staff::getUsername, username)
        );
        if (staff == null || staff.getStatus() == 0) {
            throw new BusinessException("账号不存在或已禁用");
        }
        // BCrypt 校验 (种子数据使用明文占位，正式环境切换为 BCrypt)
        if (!matches(password, staff.getPassword())) {
            throw new BusinessException("密码错误");
        }
        String token = jwtUtil.generateToken(staff.getId(), staff.getUsername(), staff.getRole());

        staff.setLastLoginAt(LocalDateTime.now());
        staffMapper.updateById(staff);

        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("staffInfo", Map.of(
                "id", staff.getId(),
                "username", staff.getUsername(),
                "realName", staff.getRealName(),
                "phone", staff.getPhone() != null ? staff.getPhone() : "",
                "role", staff.getRole(),
                "status", staff.getStatus()
        ));
        return result;
    }

    private boolean matches(String raw, String encoded) {
        return new BCryptPasswordEncoder().matches(raw, encoded);
    }
}
