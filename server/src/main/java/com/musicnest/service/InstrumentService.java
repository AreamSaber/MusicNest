package com.musicnest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.exception.BusinessException;
import com.musicnest.entity.Instrument;
import com.musicnest.mapper.InstrumentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class InstrumentService {

    private final InstrumentMapper instrumentMapper;

    public Page<Instrument> page(int pageNum, int pageSize, String keyword, String category, String status) {
        LambdaQueryWrapper<Instrument> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Instrument::getName, keyword).or().like(Instrument::getBrand, keyword));
        }
        if (StringUtils.hasText(category)) {
            wrapper.eq(Instrument::getCategory, category);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Instrument::getStatus, status);
        }
        wrapper.orderByDesc(Instrument::getSortOrder).orderByDesc(Instrument::getId);
        return instrumentMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public Instrument getById(Long id) {
        Instrument inst = instrumentMapper.selectById(id);
        if (inst == null) throw new BusinessException(404, "乐器不存在");
        return inst;
    }

@Transactional
    public Instrument create(Instrument inst) {
        if (inst.getStatus() == null) inst.setStatus("available");
        instrumentMapper.insert(inst);
        return inst;
    }

    @Transactional
    public void update(Long id, Instrument inst) {
        Instrument exist = getById(id);
        if ("rented".equals(exist.getStatus()) && (inst.getBrand() != null || inst.getModel() != null)) {
            throw new BusinessException("已租出乐器不可修改品牌/型号");
        }
        inst.setId(id);
        instrumentMapper.updateById(inst);
    }

    public void updateStatus(Long id, String status) {
        Instrument inst = getById(id);
        inst.setStatus(status);
        instrumentMapper.updateById(inst);
    }

    public void delete(Long id) {
        updateStatus(id, "scrapped");
    }
}
