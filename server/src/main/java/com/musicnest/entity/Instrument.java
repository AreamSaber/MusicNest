package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("instrument")
public class Instrument {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String category;
    private String brand;
    private String model;
    private String serialNo;
    private Integer conditionLevel;
    private String description;
    private String specs;
    private BigDecimal dailyPrice;
    private BigDecimal weeklyPrice;
    private BigDecimal monthlyPrice;
    private BigDecimal deposit;
    private BigDecimal depositRatio;
    private BigDecimal purchasePrice;
    private LocalDate purchaseDate;
    private BigDecimal currentValue;
    private BigDecimal depreciationRate;
    private String status;
    private String applicableLevel;
    private String coverImage;
    @TableField(exist = false)
    private Integer stockCount;
    @TableField(exist = false)
    private Integer rentCount;
    private Integer sortOrder;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
