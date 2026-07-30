package com.musicnest.controller;

import com.musicnest.common.PageResult;
import com.musicnest.common.Result;
import com.musicnest.entity.MaintenanceOrder;
import com.musicnest.service.WorkOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/v1/work-orders")
@RequiredArgsConstructor
public class WorkOrderController {

    private final WorkOrderService workOrderService;

    @GetMapping
    public Result<PageResult<MaintenanceOrder>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String urgency) {
        var pages = workOrderService.page(page, size, status, urgency);
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }

    @GetMapping("/{id}")
    public Result<MaintenanceOrder> detail(@PathVariable Long id) {
        MaintenanceOrder order = workOrderService.getById(id);
        workOrderService.applyAutoTransitions(order);
        return Result.ok(order);
    }

    @PutMapping("/{id}/assign")
    public Result<Void> assign(@PathVariable Long id, @RequestBody AssignRequest req) {
        workOrderService.assign(id, req.getStaffId());
        return Result.ok();
    }

    @PutMapping("/{id}/start-repair")
    public Result<Void> startRepair(@PathVariable Long id) {
        workOrderService.startRepair(id);
        return Result.ok();
    }

    @PutMapping("/{id}/complete-repair")
    public Result<Void> completeRepair(@PathVariable Long id, @RequestBody RepairRequest req) {
        workOrderService.completeRepair(id, req.getDiagnosis(), req.getRepairContent(),
                req.getRepairParts(), req.getRepairCost());
        return Result.ok();
    }
}

class AssignRequest { private Long staffId; public Long getStaffId() { return staffId; } public void setStaffId(Long s) { this.staffId = s; } }
class RepairRequest {
    private String diagnosis; private String repairContent; private String repairParts; private BigDecimal repairCost;
    public String getDiagnosis() { return diagnosis; } public void setDiagnosis(String d) { this.diagnosis = d; }
    public String getRepairContent() { return repairContent; } public void setRepairContent(String c) { this.repairContent = c; }
    public String getRepairParts() { return repairParts; } public void setRepairParts(String p) { this.repairParts = p; }
    public BigDecimal getRepairCost() { return repairCost; } public void setRepairCost(BigDecimal c) { this.repairCost = c; }
}
