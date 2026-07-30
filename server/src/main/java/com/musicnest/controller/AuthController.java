package com.musicnest.controller;

import com.musicnest.common.Result;
import com.musicnest.service.AuthService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/staff-login")
    public Result<Object> staffLogin(@Valid @RequestBody StaffLoginRequest request) {
        return Result.ok(authService.staffLogin(request.getUsername(), request.getPassword()));
    }

    @GetMapping("/logout")
    public Result<Void> logout() {
        return Result.ok();
    }
}

@Data
class StaffLoginRequest {
    @NotBlank(message = "账号不能为空")
    private String username;
    @NotBlank(message = "密码不能为空")
    private String password;
}
