package com.musicnest.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String phone;
    /** 表结构无 password 列（C 端验证码登录），仅作兼容字段 */
    @TableField(exist = false)
    private String password;
    private String nickname;
    private String avatar;
    private String realName;
    private String idCard;
    private String idCardFront;
    private String idCardBack;
    private Integer verifyStatus;
    private Integer creditScore;
    private Integer creditLevel;
    private Integer status;
    private String huaweiOpenId;
    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
