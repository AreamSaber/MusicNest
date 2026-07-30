package com.musicnest.controller;

import com.musicnest.common.PageResult;
import com.musicnest.common.Result;
import com.musicnest.entity.RentalOrder;
import com.musicnest.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public Result<PageResult<RentalOrder>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status) {
        var pages = orderService.page(page, size, keyword, status);
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }

    @GetMapping("/{id}")
    public Result<RentalOrder> detail(@PathVariable Long id) {
        return Result.ok(orderService.getById(id));
    }

    @PutMapping("/{id}/approve")
    public Result<Void> approve(@PathVariable Long id) {
        orderService.approve(id);
        return Result.ok();
    }

    @PutMapping("/{id}/reject")
    public Result<Void> reject(@PathVariable Long id, @RequestBody RejectRequest req) {
        orderService.reject(id, req.getReason());
        return Result.ok();
    }

    @PutMapping("/{id}/complete-return")
    public Result<Void> completeReturn(@PathVariable Long id, @RequestBody ReturnRequest req) {
        orderService.completeReturn(id, req.isHasDamage());
        return Result.ok();
    }

    @GetMapping("/overdue")
    public Result<PageResult<RentalOrder>> overdue(
            @RequestParam(defaultValue = "1") int page, @RequestParam(defaultValue = "10") int size) {
        var pages = orderService.getOverdue(page, size);
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }
}

class RejectRequest { private String reason; public String getReason() { return reason; } public void setReason(String r) { this.reason = r; } }
class ReturnRequest { private boolean hasDamage; public boolean isHasDamage() { return hasDamage; } public void setHasDamage(boolean h) { this.hasDamage = h; } }
