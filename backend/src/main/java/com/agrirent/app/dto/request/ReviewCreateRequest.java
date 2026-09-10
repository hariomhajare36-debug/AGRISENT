package com.agrirent.app.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class ReviewCreateRequest {
    @NotNull(message = "Equipment ID is required")
    private Long equipmentId;

    private Long bookingId;

    @NotNull(message = "Rating is required")
    @Min(1) @Max(5)
    private Integer rating;

    private String comment;
    private Integer equipmentConditionRating;
    private Integer communicationRating;

    public ReviewCreateRequest() {}

    public Long getEquipmentId() { return equipmentId; }
    public void setEquipmentId(Long equipmentId) { this.equipmentId = equipmentId; }

    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Integer getEquipmentConditionRating() { return equipmentConditionRating; }
    public void setEquipmentConditionRating(Integer equipmentConditionRating) { this.equipmentConditionRating = equipmentConditionRating; }

    public Integer getCommunicationRating() { return communicationRating; }
    public void setCommunicationRating(Integer communicationRating) { this.communicationRating = communicationRating; }
}
