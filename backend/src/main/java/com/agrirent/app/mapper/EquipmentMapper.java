package com.agrirent.app.mapper;

import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.dto.response.EquipmentTelemetryResponse;
import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.EquipmentTelemetry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class EquipmentMapper {

    @Autowired
    private UserMapper userMapper;

    public EquipmentResponse toResponse(Equipment equipment) {
        if (equipment == null) return null;
        EquipmentResponse response = new EquipmentResponse();
        response.setId(equipment.getId());
        response.setOwner(userMapper.toResponse(equipment.getOwner()));
        response.setTitle(equipment.getTitle());
        response.setMake(equipment.getMake());
        response.setModel(equipment.getModel());
        response.setYear(equipment.getYear());
        response.setCategory(equipment.getCategory());
        response.setSerialVin(equipment.getSerialVin());
        response.setHorsepower(equipment.getHorsepower());
        response.setEngineHours(equipment.getEngineHours());
        response.setDriveType(equipment.getDriveType());
        response.setFuelType(equipment.getFuelType());
        response.setTransmission(equipment.getTransmission());
        response.setHydraulicFlowGpm(equipment.getHydraulicFlowGpm());
        response.setPtoSpeed(equipment.getPtoSpeed());
        response.setHitchCategory(equipment.getHitchCategory());
        response.setDescription(equipment.getDescription());
        response.setImages(equipment.getImages());
        response.setDailyRate(equipment.getDailyRate());
        response.setWeeklyRate(equipment.getWeeklyRate());
        response.setMonthlyRate(equipment.getMonthlyRate());
        response.setSecurityDeposit(equipment.getSecurityDeposit());
        response.setPurchasePrice(equipment.getPurchasePrice());
        response.setIsForRent(equipment.getIsForRent());
        response.setIsForSale(equipment.getIsForSale());
        response.setStatus(equipment.getStatus());
        response.setApprovalStatus(equipment.getApprovalStatus());
        response.setAuditNotes(equipment.getAuditNotes());
        response.setLocationAddress(equipment.getLocationAddress());
        response.setCity(equipment.getCity());
        response.setState(equipment.getState());
        response.setZipCode(equipment.getZipCode());
        response.setLatitude(equipment.getLatitude());
        response.setLongitude(equipment.getLongitude());
        response.setCreatedAt(equipment.getCreatedAt());

        if (equipment.getTelemetry() != null) {
            response.setTelemetry(toTelemetryResponse(equipment.getTelemetry()));
        }

        return response;
    }

    public EquipmentTelemetryResponse toTelemetryResponse(EquipmentTelemetry telemetry) {
        if (telemetry == null) return null;
        EquipmentTelemetryResponse response = new EquipmentTelemetryResponse();
        response.setId(telemetry.getId());
        response.setEngineHours(telemetry.getEngineHours());
        response.setFuelLevelPercent(telemetry.getFuelLevelPercent());
        response.setDefFluidPercent(telemetry.getDefFluidPercent());
        response.setBatteryVoltage(telemetry.getBatteryVoltage());
        response.setCoolantTempF(telemetry.getCoolantTempF());
        response.setOilPressurePsi(telemetry.getOilPressurePsi());
        response.setGpsLatitude(telemetry.getGpsLatitude());
        response.setGpsLongitude(telemetry.getGpsLongitude());
        response.setNextServiceHours(telemetry.getNextServiceHours());
        response.setLastPingAt(telemetry.getLastPingAt());
        return response;
    }
}
