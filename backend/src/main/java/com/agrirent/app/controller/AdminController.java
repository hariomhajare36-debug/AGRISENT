package com.agrirent.app.controller;

import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.dto.response.EscrowTransactionResponse;
import com.agrirent.app.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    @GetMapping("/metrics")
    public ResponseEntity<DashboardMetricsResponse> getMetrics() {
        return ResponseEntity.ok(adminService.getMetrics());
    }

    @GetMapping("/equipment/pending")
    public ResponseEntity<List<EquipmentResponse>> getPendingEquipment() {
        return ResponseEntity.ok(adminService.getPendingEquipment());
    }

    @PutMapping("/equipment/{id}/approve")
    public ResponseEntity<EquipmentResponse> approveEquipment(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.approveEquipment(id));
    }

    @PutMapping("/equipment/{id}/reject")
    public ResponseEntity<EquipmentResponse> rejectEquipment(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body
    ) {
        String reason = body != null ? body.get("reason") : null;
        return ResponseEntity.ok(adminService.rejectEquipment(id, reason));
    }

    @GetMapping("/escrow")
    public ResponseEntity<List<EscrowTransactionResponse>> getEscrowTransactions() {
        return ResponseEntity.ok(adminService.getEscrowTransactions());
    }

    @PutMapping("/escrow/{id}/release")
    public ResponseEntity<EscrowTransactionResponse> releaseEscrow(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.releaseEscrow(id));
    }

    @PutMapping("/escrow/{id}/hold")
    public ResponseEntity<EscrowTransactionResponse> holdEscrow(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body
    ) {
        String reason = body != null ? body.get("reason") : null;
        return ResponseEntity.ok(adminService.holdEscrow(id, reason));
    }
}
