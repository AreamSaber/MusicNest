package com.musicnest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.PageResult;
import com.musicnest.common.Result;
import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.Staff;
import com.musicnest.entity.SysConfig;
import com.musicnest.entity.SysDict;
import com.musicnest.mapper.StaffMapper;
import com.musicnest.mapper.SysConfigMapper;
import com.musicnest.mapper.SysDictMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final StaffMapper staffMapper;
    private final SysDictMapper dictMapper;
    private final SysConfigMapper configMapper;

    // ==================== Setup Passwords ====================

    @GetMapping("/check-passwords")
    public Result<Map<String, Object>> checkPasswords() {
        List<Staff> emptyPwdList = staffMapper.selectList(
                new LambdaQueryWrapper<Staff>().eq(Staff::getPassword, "").or().isNull(Staff::getPassword));
        Map<String, Object> result = new HashMap<>();
        result.put("hasEmpty", !emptyPwdList.isEmpty());
        result.put("accounts", emptyPwdList.stream().map(s -> Map.of(
                "id", s.getId(),
                "username", s.getUsername(),
                "realName", s.getRealName()
        )).toList());
        return Result.ok(result);
    }

    @PostMapping("/setup-passwords")
    public Result<Void> setupPasswords(@RequestBody List<Map<String, Object>> accounts) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        for (var acc : accounts) {
            Long id = Long.valueOf(acc.get("id").toString());
            String pwd = acc.get("password").toString();
            Staff staff = new Staff();
            staff.setId(id);
            staff.setPassword(encoder.encode(pwd));
            staffMapper.updateById(staff);
        }
        return Result.ok();
    }

    // ==================== Staff ====================

    @GetMapping("/staff")
    public Result<PageResult<Staff>> staffList(@RequestParam(defaultValue = "1") int page,
                                                @RequestParam(defaultValue = "10") int size) {
        Page<Staff> pages = staffMapper.selectPage(new Page<>(page, size),
                new LambdaQueryWrapper<Staff>().orderByDesc(Staff::getId));
        pages.getRecords().forEach(s -> s.setPassword(null));
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }

    @PostMapping("/staff")
    public Result<Staff> createStaff(@RequestBody Staff staff) {
        if (staffMapper.selectCount(new LambdaQueryWrapper<Staff>().eq(Staff::getUsername, staff.getUsername())) > 0)
            throw new BusinessException("账号已存在");
        staff.setPassword(new BCryptPasswordEncoder().encode("123456"));
        if (staff.getRole() == null) staff.setRole("ROLE_STAFF");
        staffMapper.insert(staff);
        staff.setPassword(null);
        return Result.ok(staff);
    }

    @PutMapping("/staff/{id}")
    public Result<Void> updateStaff(@PathVariable Long id, @RequestBody Staff staff) {
        staff.setId(id);
        staff.setPassword(null);
        staffMapper.updateById(staff);
        return Result.ok();
    }

    @PutMapping("/staff/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        Staff s = new Staff(); s.setId(id); s.setStatus(body.get("status")); staffMapper.updateById(s); return Result.ok();
    }

    @PutMapping("/staff/{id}/reset-pwd")
    public Result<Void> resetPwd(@PathVariable Long id) {
        Staff s = new Staff(); s.setId(id); s.setPassword(new BCryptPasswordEncoder().encode("123456")); staffMapper.updateById(s); return Result.ok();
    }

    // ==================== Dicts ====================

    @GetMapping("/dicts")
    public Result<List<SysDict>> getDicts(@RequestParam(required = false) String type) {
        LambdaQueryWrapper<SysDict> w = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(type)) w.eq(SysDict::getDictType, type);
        w.orderByAsc(SysDict::getSortOrder);
        return Result.ok(dictMapper.selectList(w));
    }

    @PostMapping("/dicts")
    public Result<SysDict> createDict(@RequestBody SysDict dict) { dictMapper.insert(dict); return Result.ok(dict); }

    @PutMapping("/dicts/{id}")
    public Result<Void> updateDict(@PathVariable Long id, @RequestBody SysDict dict) { dict.setId(id); dictMapper.updateById(dict); return Result.ok(); }

    // ==================== Configs ====================

    @GetMapping("/configs")
    public Result<List<SysConfig>> getConfigs() { return Result.ok(configMapper.selectList(null)); }

    @PutMapping("/configs")
    public Result<Void> updateConfigs(@RequestBody Map<String, String> body) {
        for (var e : body.entrySet()) {
            SysConfig c = configMapper.selectOne(new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, e.getKey()));
            if (c != null) { c.setConfigValue(e.getValue()); c.setUpdatedAt(LocalDateTime.now()); configMapper.updateById(c); }
        }
        return Result.ok();
    }
}
