package com.agrirent.app.service;

import com.agrirent.app.dto.request.BookingCreateRequest;
import com.agrirent.app.dto.request.BookingStatusUpdateRequest;
import com.agrirent.app.dto.response.BookingResponse;
import com.agrirent.app.dto.response.DashboardMetricsResponse;

import java.util.List;

public interface BookingService {
    BookingResponse create(BookingCreateRequest request);
    BookingResponse getById(Long id);
    BookingResponse updateStatus(Long id, BookingStatusUpdateRequest request);
    List<BookingResponse> getOwnerBookings();
    List<BookingResponse> getFarmerBookings();
    List<BookingResponse> getFarmerActiveRentals();
    DashboardMetricsResponse getFarmerStats();
}
