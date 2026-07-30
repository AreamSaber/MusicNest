package com.musicnest.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.PageResult;
import com.musicnest.common.Result;
import com.musicnest.entity.Instrument;
import com.musicnest.service.InstrumentService;
import com.musicnest.mapper.InstrumentMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/instruments")
@RequiredArgsConstructor
public class InstrumentController {

    private final InstrumentService instrumentService;
    private final InstrumentMapper instrumentMapper;

    @GetMapping
    public Result<PageResult<Instrument>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String status) {
        Page<Instrument> pages = instrumentService.page(page, size, keyword, category, status);
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }

    @GetMapping("/{id}")
    public Result<Instrument> detail(@PathVariable Long id) {
        return Result.ok(instrumentService.getById(id));
    }

    @PostMapping
    public Result<Instrument> create(@RequestBody Instrument instrument) {
        return Result.ok(instrumentService.create(instrument));
    }

    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody Instrument instrument) {
        instrumentService.update(id, instrument);
        return Result.ok();
    }

    @PutMapping("/{id}/status")
    public Result<Void> updateStatus(@PathVariable Long id, @RequestBody StatusRequest request) {
        instrumentService.updateStatus(id, request.getStatus());
        return Result.ok();
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        instrumentService.delete(id);
        return Result.ok();
    }

    @GetMapping("/hot")
    public Result<Object> hot(@RequestParam(defaultValue = "6") int limit) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Instrument>()
                .eq(Instrument::getStatus, "available")
                .orderByDesc(Instrument::getId);
        var page = new com.baomidou.mybatisplus.extension.plugins.pagination.Page<Instrument>(1, limit);
        return Result.ok(instrumentMapper.selectPage(page, wrapper).getRecords());
    }

    @GetMapping("/recommend")
    public Result<Object> recommend() {
        return Result.ok(instrumentService.page(1, 6, null, null, "available").getRecords());
    }

    @GetMapping("/{id}/reviews")
    public Result<Object> reviews(@PathVariable Long id,
                                   @RequestParam(defaultValue = "1") int page,
                                   @RequestParam(defaultValue = "10") int size) {
        return Result.ok(new PageResult<>(java.util.List.of(), 0, page, size));
    }
}

class StatusRequest {
    private String status;
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
