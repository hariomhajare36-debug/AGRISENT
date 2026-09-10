package com.agrirent.app.controller;

import com.agrirent.app.dto.request.EquipmentCreateRequest;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.service.EquipmentService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/equipment")
public class EquipmentController {

    @Autowired
    private EquipmentService equipmentService;

    @GetMapping
    public ResponseEntity<List<EquipmentResponse>> getAll(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Boolean isForRent,
            @RequestParam(required = false) Boolean isForSale,
            @RequestParam(required = false) Integer minHorsepower,
            @RequestParam(required = false) Integer maxHorsepower,
            @RequestParam(required = false) BigDecimal maxDailyRate,
            @RequestParam(required = false) String driveType,
            @RequestParam(required = false) String brand,
            @RequestParam(required = false) String district,
            @RequestParam(required = false) BigDecimal maxPurchasePrice
    ) {
        return ResponseEntity.ok(equipmentService.getAll(
                search, category, isForRent, isForSale, minHorsepower, maxHorsepower, maxDailyRate, driveType,
                brand, district, maxPurchasePrice
        ));
    }

    @GetMapping("/featured")
    public ResponseEntity<List<EquipmentResponse>> getFeatured() {
        return ResponseEntity.ok(equipmentService.getFeatured());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EquipmentResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(equipmentService.getById(id));
    }

    @PostMapping
    public ResponseEntity<EquipmentResponse> create(@Valid @RequestBody EquipmentCreateRequest request) {
        return new ResponseEntity<>(equipmentService.create(request), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EquipmentResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody EquipmentCreateRequest request
    ) {
        return ResponseEntity.ok(equipmentService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        equipmentService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
