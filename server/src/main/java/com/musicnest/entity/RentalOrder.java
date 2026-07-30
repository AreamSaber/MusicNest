package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rental_order")
public class RentalOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long userId;
    private Long instrumentId;
    private LocalDate startDate;
    private LocalDate endDate;
    private LocalDate actualReturnDate;
    private Integer rentDays;
    private BigDecimal dailyPrice;
    private BigDecimal depositAmount;
    private BigDecimal rentAmount;
    private BigDecimal lateFee;
    private BigDecimal totalAmount;
    private String status;
    private String deliveryType;
    private String deliveryAddress;
    private String remark;
    private String cancelReason;
    private Long parentOrderId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
