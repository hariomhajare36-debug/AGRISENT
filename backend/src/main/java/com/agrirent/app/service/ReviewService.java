package com.agrirent.app.service;

import com.agrirent.app.dto.request.ReviewCreateRequest;
import com.agrirent.app.dto.response.ReviewResponse;

import java.util.List;

public interface ReviewService {
    List<ReviewResponse> getByEquipmentId(Long equipmentId);
    ReviewResponse create(ReviewCreateRequest request);
}
