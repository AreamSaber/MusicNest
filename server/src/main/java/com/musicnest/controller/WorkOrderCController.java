package com.musicnest.controller;

import com.musicnest.common.Result;
import com.musicnest.entity.MaintenanceOrder;
import com.musicnest.mapper.MaintenanceOrderMapper;
import com.musicnest.service.WorkOrderService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/work-orders")
@RequiredArgsConstructor
public class WorkOrderCController {

    private final MaintenanceOrderMapper orderMapper;
    private final WorkOrderService workOrderService;

    @PostMapping
    public Result<MaintenanceOrder> create(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Long instrumentId = Long.valueOf(body.get("instrumentId").toString());
        String faultDesc = body.get("faultDesc").toString();
        String urgency = body.getOrDefault("urgency", "normal").toString();

        MaintenanceOrder order = new MaintenanceOrder();
        order.setOrderNo("MO" + System.currentTimeMillis());
        order.setUserId(userId);
        order.setInstrumentId(instrumentId);
        order.setFaultDesc(faultDesc);
        order.setUrgency(urgency);
        if (body.containsKey("rentalOrderId")) order.setRentalOrderId(Long.valueOf(body.get("rentalOrderId").toString()));
        order.setStatus("pending");
        orderMapper.insert(order);
        return Result.ok(order);
    }

    @PutMapping("/{id}/confirm")
    public Result<Void> confirm(@PathVariable Long id) {
        workOrderService.confirm(id);
        return Result.ok();
    }
}
