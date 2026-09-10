package com.agrirent.app.controller;

import com.agrirent.app.dto.request.ReviewCreateRequest;
import com.agrirent.app.dto.response.ReviewResponse;
import com.agrirent.app.service.ReviewService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @GetMapping("/equipment/{equipmentId}")
    public ResponseEntity<List<ReviewResponse>> getByEquipmentId(@PathVariable Long equipmentId) {
        return ResponseEntity.ok(reviewService.getByEquipmentId(equipmentId));
    }

    @PostMapping
    public ResponseEntity<ReviewResponse> create(@Valid @RequestBody ReviewCreateRequest request) {
        return new ResponseEntity<>(reviewService.create(request), HttpStatus.CREATED);
    }
}
