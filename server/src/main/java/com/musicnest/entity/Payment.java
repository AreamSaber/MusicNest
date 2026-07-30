package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("payment")
public class Payment {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private Long userId;
    private String paymentNo;
    private BigDecimal amount;
    private String type;
    private String method;
    private String status;
    private BigDecimal refundAmount;
    private String refundReason;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;
}
