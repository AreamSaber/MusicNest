package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("review")
public class Review {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long rentalOrderId;
    private Long maintenanceOrderId;
    private Long instrumentId;
    private String type;
    private Integer rating;
    private String content;
    private String images;
    private LocalDateTime createdAt;
}
