package com.agrirent.app.controller;

import com.agrirent.app.dto.response.BookingResponse;
import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.service.BookingService;
import com.agrirent.app.service.EquipmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/owner")
public class OwnerController {

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private BookingService bookingService;

    @GetMapping("/fleet")
    public ResponseEntity<List<EquipmentResponse>> getFleet() {
        return ResponseEntity.ok(equipmentService.getOwnerFleet());
    }

    @GetMapping("/bookings")
    public ResponseEntity<List<BookingResponse>> getBookings() {
        return ResponseEntity.ok(bookingService.getOwnerBookings());
    }

    @GetMapping("/stats")
    public ResponseEntity<DashboardMetricsResponse> getStats() {
        return ResponseEntity.ok(equipmentService.getOwnerStats());
    }
}
