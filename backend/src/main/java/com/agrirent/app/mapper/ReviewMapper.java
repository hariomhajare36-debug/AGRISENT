package com.agrirent.app.mapper;

import com.agrirent.app.dto.response.ReviewResponse;
import com.agrirent.app.entity.Review;
import org.springframework.stereotype.Component;

@Component
public class ReviewMapper {

    public ReviewResponse toResponse(Review review) {
        if (review == null) return null;
        ReviewResponse response = new ReviewResponse();
        response.setId(review.getId());
        response.setEquipmentId(review.getEquipment().getId());
        response.setReviewerId(review.getReviewer().getId());
        response.setReviewerName(review.getReviewer().getFullName());
        response.setRating(review.getRating());
        response.setComment(review.getComment());
        response.setEquipmentConditionRating(review.getEquipmentConditionRating());
        response.setCommunicationRating(review.getCommunicationRating());
        response.setCreatedAt(review.getCreatedAt());
        return response;
    }
}
