package com.musicnest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.musicnest.entity.Instrument;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface InstrumentMapper extends BaseMapper<Instrument> {
    @Select("SELECT * FROM instrument WHERE id = #{id} FOR UPDATE")
    Instrument selectByIdForUpdate(@Param("id") Long id);
}
