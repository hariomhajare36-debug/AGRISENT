package com.agrirent.app.service;

import com.agrirent.app.dto.request.EquipmentCreateRequest;
import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;

import java.math.BigDecimal;
import java.util.List;

public interface EquipmentService {
    List<EquipmentResponse> getAll(
            String search,
            String category,
            Boolean isForRent,
            Boolean isForSale,
            Integer minHorsepower,
            Integer maxHorsepower,
            BigDecimal maxDailyRate,
            String driveType,
            String brand,
            String district,
            BigDecimal maxPurchasePrice
    );

    List<EquipmentResponse> getFeatured();
    EquipmentResponse getById(Long id);
    EquipmentResponse create(EquipmentCreateRequest request);
    EquipmentResponse update(Long id, EquipmentCreateRequest request);
    void delete(Long id);
    List<EquipmentResponse> getOwnerFleet();
    DashboardMetricsResponse getOwnerStats();
}
