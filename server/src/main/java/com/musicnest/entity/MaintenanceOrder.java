package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("maintenance_order")
public class MaintenanceOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long rentalOrderId;
    private Long instrumentId;
    private Long userId;
    private Long assigneeId;
    private String faultDesc;
    private String faultImages;
    private String urgency;
    private String status;
    private String diagnosis;
    private String repairContent;
    private String repairParts;
    private BigDecimal repairCost;
    private LocalDateTime checkingStartedAt;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
