package com.musicnest.controller;

import com.musicnest.common.Result;
import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.Instrument;
import com.musicnest.entity.Payment;
import com.musicnest.entity.RentalOrder;
import com.musicnest.entity.User;
import com.musicnest.mapper.InstrumentMapper;
import com.musicnest.mapper.PaymentMapper;
import com.musicnest.mapper.RentalOrderMapper;
import com.musicnest.mapper.UserMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderCController {

    private final RentalOrderMapper orderMapper;
    private final InstrumentMapper instrumentMapper;
    private final PaymentMapper paymentMapper;
    private final UserMapper userMapper;

    @PostMapping
    @Transactional
    public Result<RentalOrder> create(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Long instrumentId = Long.valueOf(body.get("instrumentId").toString());
        int months = body.containsKey("rentMonths") ? Integer.parseInt(body.get("rentMonths").toString()) : 1;

        User user = userMapper.selectById(userId);
        if (user.getVerifyStatus() != 2) throw new BusinessException("请先完成实名认证");

        Instrument inst = instrumentMapper.selectByIdForUpdate(instrumentId);
        if (inst == null || !"available".equals(inst.getStatus())) throw new BusinessException("乐器不可租");

        int rentDays = months * 30;
        BigDecimal rentAmount = inst.getMonthlyPrice().multiply(BigDecimal.valueOf(months));
        BigDecimal deposit = user.getCreditScore() >= 800 ? BigDecimal.ZERO : inst.getDeposit();

        RentalOrder order = new RentalOrder();
        order.setOrderNo("R" + System.currentTimeMillis());
        order.setUserId(userId);
        order.setInstrumentId(instrumentId);
        order.setStartDate(LocalDate.now());
        order.setEndDate(LocalDate.now().plusDays(rentDays));
        order.setRentDays(rentDays);
        order.setDailyPrice(inst.getDailyPrice());
        order.setDepositAmount(deposit);
        order.setRentAmount(rentAmount);
        order.setTotalAmount(rentAmount);
        order.setStatus("pending");
        orderMapper.insert(order);

        inst.setStatus("rented");
        instrumentMapper.updateById(inst);

        // 模拟支付（支付完成但仍需管理员审核）
        payOrderInternal(order.getId(), userId, rentAmount);

        return Result.ok(order);
    }

    @PostMapping("/{id}/pay")
    public Result<Void> pay(@PathVariable Long id, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        RentalOrder order = orderMapper.selectById(id);
        payOrderInternal(id, userId, order.getTotalAmount());
        return Result.ok();
    }

    @PostMapping("/{id}/renew")
    public Result<RentalOrder> renew(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        RentalOrder order = orderMapper.selectById(id);
        int months = body.getOrDefault("months", 1);
        order.setEndDate(order.getEndDate().plusDays(months * 30L));
        order.setRentDays(order.getRentDays() + months * 30);
        orderMapper.updateById(order);
        return Result.ok(order);
    }

    @PostMapping("/{id}/return-booking")
    public Result<Void> returnBooking(@PathVariable Long id, @RequestBody Map<String, String> body) {
        RentalOrder order = orderMapper.selectById(id);
        order.setStatus("returning");
        orderMapper.updateById(order);
        return Result.ok();
    }

    @PutMapping("/{id}/cancel")
    @Transactional
    public Result<Void> cancel(@PathVariable Long id, HttpServletRequest request) {
        RentalOrder order = orderMapper.selectById(id);
        if (!"pending".equals(order.getStatus())) throw new BusinessException("当前状态不可取消");
        order.setStatus("cancelled");
        orderMapper.updateById(order);
        Instrument inst = instrumentMapper.selectById(order.getInstrumentId());
        if (inst != null && "rented".equals(inst.getStatus())) {
            inst.setStatus("available");
            instrumentMapper.updateById(inst);
        }
        // 退款记录
        createRefundPayment(id, order.getUserId(), order.getDepositAmount());
        return Result.ok();
    }

    private void createRefundPayment(Long orderId, Long userId, java.math.BigDecimal amount) {
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setUserId(userId);
        payment.setPaymentNo("RF" + System.currentTimeMillis());
        payment.setAmount(amount);
        payment.setType("refund");
        payment.setMethod("mock");
        payment.setStatus("success");
        payment.setRefundAmount(amount);
        paymentMapper.insert(payment);
    }

    private void payOrderInternal(Long orderId, Long userId, BigDecimal amount) {
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setUserId(userId);
        payment.setPaymentNo("P" + UUID.randomUUID().toString().substring(0, 8));
        payment.setAmount(amount);
        payment.setType("rental");
        payment.setMethod("mock");
        payment.setStatus("success");
        payment.setPaidAt(LocalDateTime.now());
        paymentMapper.insert(payment);
    }
}
