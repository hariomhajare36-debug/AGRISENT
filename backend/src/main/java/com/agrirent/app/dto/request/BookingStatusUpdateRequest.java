package com.agrirent.app.dto.request;

import jakarta.validation.constraints.NotBlank;

public class BookingStatusUpdateRequest {
    @NotBlank(message = "Status is required")
    private String status;

    private String notes;

    public BookingStatusUpdateRequest() {}

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
