package com.agrirent.app.dto.response;

import java.time.LocalDateTime;

public class ReviewResponse {
    private Long id;
    private Long equipmentId;
    private Long reviewerId;
    private String reviewerName;
    private Integer rating;
    private String comment;
    private Integer equipmentConditionRating;
    private Integer communicationRating;
    private LocalDateTime createdAt;

    public ReviewResponse() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEquipmentId() { return equipmentId; }
    public void setEquipmentId(Long equipmentId) { this.equipmentId = equipmentId; }

    public Long getReviewerId() { return reviewerId; }
    public void setReviewerId(Long reviewerId) { this.reviewerId = reviewerId; }

    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Integer getEquipmentConditionRating() { return equipmentConditionRating; }
    public void setEquipmentConditionRating(Integer equipmentConditionRating) { this.equipmentConditionRating = equipmentConditionRating; }

    public Integer getCommunicationRating() { return communicationRating; }
    public void setCommunicationRating(Integer communicationRating) { this.communicationRating = communicationRating; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
