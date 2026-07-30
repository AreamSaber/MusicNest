package com.musicnest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicnest.entity.Payment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {
}
