package com.musicnest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.musicnest.common.PageResult;
import com.musicnest.common.Result;
import com.musicnest.entity.Review;
import com.musicnest.mapper.ReviewMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewMapper reviewMapper;

    @PostMapping
    public Result<Review> create(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Review review = new Review();
        review.setUserId(userId);
        review.setType(body.get("type").toString());
        review.setRating(Integer.parseInt(body.get("rating").toString()));
        if (body.containsKey("content")) review.setContent(body.get("content").toString());
        if (body.containsKey("rentalOrderId") && body.get("rentalOrderId") != null)
            review.setRentalOrderId(Long.valueOf(body.get("rentalOrderId").toString()));
        if (body.containsKey("maintenanceOrderId") && body.get("maintenanceOrderId") != null)
            review.setMaintenanceOrderId(Long.valueOf(body.get("maintenanceOrderId").toString()));
        if (body.containsKey("instrumentId") && body.get("instrumentId") != null)
            review.setInstrumentId(Long.valueOf(body.get("instrumentId").toString()));
        reviewMapper.insert(review);
        return Result.ok(review);
    }

    @GetMapping
    public Result<PageResult<Review>> list(@RequestParam(defaultValue = "1") int page,
                                            @RequestParam(defaultValue = "10") int size,
                                            @RequestParam(required = false) Long instrumentId) {
        LambdaQueryWrapper<Review> wrapper = new LambdaQueryWrapper<>();
        if (instrumentId != null) wrapper.eq(Review::getInstrumentId, instrumentId);
        wrapper.orderByDesc(Review::getId);
        Page<Review> pages = reviewMapper.selectPage(new Page<>(page, size), wrapper);
        return Result.ok(new PageResult<>(pages.getRecords(), pages.getTotal(), pages.getCurrent(), pages.getSize()));
    }
}
