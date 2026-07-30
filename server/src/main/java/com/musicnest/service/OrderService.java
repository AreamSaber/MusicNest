package com.musicnest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.Instrument;
import com.musicnest.entity.RentalOrder;
import com.musicnest.entity.Payment;
import com.musicnest.mapper.InstrumentMapper;
import com.musicnest.mapper.RentalOrderMapper;
import com.musicnest.mapper.PaymentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final RentalOrderMapper orderMapper;
    private final InstrumentMapper instrumentMapper;
    private final PaymentMapper paymentMapper;

    public Page<RentalOrder> page(int pageNum, int pageSize, String keyword, String status) {
        LambdaQueryWrapper<RentalOrder> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(RentalOrder::getOrderNo, keyword));
        }
        if (StringUtils.hasText(status)) {
            // 支持逗号分隔的多状态查询
            String[] statuses = status.split(",");
            wrapper.in(RentalOrder::getStatus, List.of(statuses));
        }
        wrapper.orderByDesc(RentalOrder::getId);
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public RentalOrder getById(Long id) {
        RentalOrder order = orderMapper.selectById(id);
        if (order == null) throw new BusinessException(404, "订单不存在");
        return order;
    }

    @Transactional
    public void approve(Long id) {
        RentalOrder order = getById(id);
        if (!"pending".equals(order.getStatus())) throw new BusinessException("当前状态不可审核");
        order.setStatus("renting");
        orderMapper.updateById(order);
    }

    @Transactional
    public void reject(Long id, String reason) {
        RentalOrder order = getById(id);
        if (!"pending".equals(order.getStatus())) throw new BusinessException("当前状态不可驳回");
        order.setStatus("cancelled");
        order.setCancelReason(reason);
        orderMapper.updateById(order);
        // 创建退款记录
        createRefundPayment(id, order.getUserId(), order.getDepositAmount(), reason);
        releaseInstrument(order.getInstrumentId());
    }

    @Transactional
    public void completeReturn(Long id, boolean hasDamage) {
        RentalOrder order = getById(id);
        if (!"returning".equals(order.getStatus()) && !"renting".equals(order.getStatus()))
            throw new BusinessException("当前状态不可归还");
        order.setStatus("completed");
        order.setActualReturnDate(LocalDate.now());
        orderMapper.updateById(order);

        Instrument inst = instrumentMapper.selectById(order.getInstrumentId());
        if (inst != null) {
            inst.setStatus(hasDamage ? "maintenance" : "available");
            instrumentMapper.updateById(inst);
        }
    }

    public Page<RentalOrder> getOverdue(int pageNum, int pageSize) {
        LambdaQueryWrapper<RentalOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(RentalOrder::getStatus, "renting")
                .lt(RentalOrder::getEndDate, LocalDate.now());
        return orderMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    private void releaseInstrument(Long instrumentId) {
        Instrument inst = instrumentMapper.selectById(instrumentId);
        if (inst != null && "rented".equals(inst.getStatus())) {
            inst.setStatus("available");
            instrumentMapper.updateById(inst);
        }
    }

    private void createRefundPayment(Long orderId, Long userId, java.math.BigDecimal amount, String reason) {
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setUserId(userId);
        payment.setPaymentNo("RF" + System.currentTimeMillis());
        payment.setAmount(amount);
        payment.setType("refund");
        payment.setMethod("mock");
        payment.setStatus("success");
        payment.setRefundAmount(amount);
        payment.setRefundReason(reason);
        paymentMapper.insert(payment);
    }
}
