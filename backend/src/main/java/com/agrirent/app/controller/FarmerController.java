package com.agrirent.app.controller;

import com.agrirent.app.dto.response.BookingResponse;
import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/farmer")
public class FarmerController {

    @Autowired
    private BookingService bookingService;

    @GetMapping("/bookings")
    public ResponseEntity<List<BookingResponse>> getBookings() {
        return ResponseEntity.ok(bookingService.getFarmerBookings());
    }

    @GetMapping("/active-rentals")
    public ResponseEntity<List<BookingResponse>> getActiveRentals() {
        return ResponseEntity.ok(bookingService.getFarmerActiveRentals());
    }

    @GetMapping("/stats")
    public ResponseEntity<DashboardMetricsResponse> getStats() {
        return ResponseEntity.ok(bookingService.getFarmerStats());
    }
}
