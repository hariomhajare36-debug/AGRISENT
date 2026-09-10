package com.agrirent.app.service;

import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.dto.response.EscrowTransactionResponse;

import java.util.List;

public interface AdminService {
    DashboardMetricsResponse getMetrics();
    List<EquipmentResponse> getPendingEquipment();
    EquipmentResponse approveEquipment(Long id);
    EquipmentResponse rejectEquipment(Long id, String reason);
    List<EscrowTransactionResponse> getEscrowTransactions();
    EscrowTransactionResponse releaseEscrow(Long id);
    EscrowTransactionResponse holdEscrow(Long id, String reason);
}
