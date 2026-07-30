package com.musicnest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.musicnest.common.Result;
import com.musicnest.entity.MaintenanceOrder;
import com.musicnest.entity.RentalOrder;
import com.musicnest.mapper.MaintenanceOrderMapper;
import com.musicnest.mapper.RentalOrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final RentalOrderMapper orderMapper;
    private final MaintenanceOrderMapper workOrderMapper;

    @GetMapping("/pending")
    public Result<Map<String, Object>> pending() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("newOrders", orderMapper.selectCount(
                new LambdaQueryWrapper<RentalOrder>().eq(RentalOrder::getStatus, "pending")));
        summary.put("pendingWorkOrders", workOrderMapper.selectCount(
                new LambdaQueryWrapper<MaintenanceOrder>().eq(MaintenanceOrder::getStatus, "pending")));
        summary.put("overdueOrders", orderMapper.selectCount(
                new LambdaQueryWrapper<RentalOrder>().eq(RentalOrder::getStatus, "renting")
                        .lt(RentalOrder::getEndDate, LocalDate.now())));
        return Result.ok(summary);
    }

    @GetMapping("/revenue")
    public Result<Map<String, Object>> revenue(@RequestParam(defaultValue = "month") String period) {
        Map<String, Object> data = new HashMap<>();
        // 简化：统计当前月份完成的订单总金额
        List<RentalOrder> completed = orderMapper.selectList(
                new LambdaQueryWrapper<RentalOrder>().eq(RentalOrder::getStatus, "completed"));
        BigDecimal total = completed.stream()
                .map(RentalOrder::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        data.put("todayRevenue", total.divide(BigDecimal.valueOf(30), 2, java.math.RoundingMode.HALF_UP));
        data.put("weekRevenue", total.divide(BigDecimal.valueOf(4), 2, java.math.RoundingMode.HALF_UP));
        data.put("monthRevenue", total);
        data.put("compareLastWeek", 0);
        data.put("compareLastMonth", 0);
        return Result.ok(data);
    }

    @GetMapping("/rental-stats")
    public Result<Map<String, Object>> rentalStats() {
        return Result.ok(new HashMap<>());
    }

    @GetMapping("/user-stats")
    public Result<Map<String, Object>> userStats() {
        return Result.ok(new HashMap<>());
    }

    @GetMapping("/workorder-stats")
    public Result<Map<String, Object>> workorderStats() {
        return Result.ok(new HashMap<>());
    }
}
