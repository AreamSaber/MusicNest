package com.musicnest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.MaintenanceOrder;
import com.musicnest.mapper.MaintenanceOrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class WorkOrderService {

    private final MaintenanceOrderMapper orderMapper;

    public Page<MaintenanceOrder> page(int pageNum, int pageSize, String status, String urgency) {
        LambdaQueryWrapper<MaintenanceOrder> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(status)) wrapper.eq(MaintenanceOrder::getStatus, status);
        if ("urgent".equals(urgency)) wrapper.eq(MaintenanceOrder::getUrgency, "urgent");
        wrapper.orderByDesc(MaintenanceOrder::getUrgency).orderByDesc(MaintenanceOrder::getId);
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public MaintenanceOrder getById(Long id) {
        MaintenanceOrder order = orderMapper.selectById(id);
        if (order == null) throw new BusinessException(404, "工单不存在");
        return order;
    }

    @Transactional
    public void assign(Long id, Long staffId) {
        MaintenanceOrder order = getById(id);
        if (!"pending".equals(order.getStatus())) throw new BusinessException("当前状态不可派单");
        order.setStatus("assigned");
        order.setAssigneeId(staffId);
        orderMapper.updateById(order);
    }

    @Transactional
    public void startRepair(Long id) {
        MaintenanceOrder order = getById(id);
        if (!"assigned".equals(order.getStatus())) throw new BusinessException("当前状态不可开始维修");
        order.setStatus("repairing");
        orderMapper.updateById(order);
    }

    @Transactional
    public void completeRepair(Long id, String diagnosis, String repairContent, String repairParts, java.math.BigDecimal repairCost) {
        MaintenanceOrder order = getById(id);
        if (!"repairing".equals(order.getStatus())) throw new BusinessException("当前状态不可完成维修");
        order.setStatus("checking");
        order.setDiagnosis(diagnosis);
        order.setRepairContent(repairContent);
        order.setRepairParts(repairParts);
        order.setRepairCost(repairCost);
        order.setCheckingStartedAt(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    @Transactional
    public void confirm(Long id) {
        MaintenanceOrder order = getById(id);
        if (!"checking".equals(order.getStatus())) throw new BusinessException("当前状态不可确认");
        order.setStatus("completed");
        order.setCompletedAt(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    // 查询时动态标记：repairing超7天 → overdue标记；checking超3天 → 自动完成
    public void applyAutoTransitions(MaintenanceOrder order) {
        if ("repairing".equals(order.getStatus()) &&
                order.getCreatedAt().plusDays(7).isBefore(LocalDateTime.now())) {
            // 前端展示超期标记，不自动改状态
        }
        if ("checking".equals(order.getStatus()) && order.getCheckingStartedAt() != null &&
                order.getCheckingStartedAt().plusDays(3).isBefore(LocalDateTime.now())) {
            confirm(order.getId());
        }
    }
}
