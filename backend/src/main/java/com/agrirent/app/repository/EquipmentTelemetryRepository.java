package com.agrirent.app.repository;

import com.agrirent.app.entity.EquipmentTelemetry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EquipmentTelemetryRepository extends JpaRepository<EquipmentTelemetry, Long> {
    Optional<EquipmentTelemetry> findByEquipmentId(Long equipmentId);
}
