package com.agrirent.app.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class EquipmentTelemetryResponse {
    private Long id;
    private Integer engineHours;
    private Integer fuelLevelPercent;
    private Integer defFluidPercent;
    private BigDecimal batteryVoltage;
    private Integer coolantTempF;
    private Integer oilPressurePsi;
    private BigDecimal gpsLatitude;
    private BigDecimal gpsLongitude;
    private Integer nextServiceHours;
    private LocalDateTime lastPingAt;

    public EquipmentTelemetryResponse() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Integer getEngineHours() { return engineHours; }
    public void setEngineHours(Integer engineHours) { this.engineHours = engineHours; }

    public Integer getFuelLevelPercent() { return fuelLevelPercent; }
    public void setFuelLevelPercent(Integer fuelLevelPercent) { this.fuelLevelPercent = fuelLevelPercent; }

    public Integer getDefFluidPercent() { return defFluidPercent; }
    public void setDefFluidPercent(Integer defFluidPercent) { this.defFluidPercent = defFluidPercent; }

    public BigDecimal getBatteryVoltage() { return batteryVoltage; }
    public void setBatteryVoltage(BigDecimal batteryVoltage) { this.batteryVoltage = batteryVoltage; }

    public Integer getCoolantTempF() { return coolantTempF; }
    public void setCoolantTempF(Integer coolantTempF) { this.coolantTempF = coolantTempF; }

    public Integer getOilPressurePsi() { return oilPressurePsi; }
    public void setOilPressurePsi(Integer oilPressurePsi) { this.oilPressurePsi = oilPressurePsi; }

    public BigDecimal getGpsLatitude() { return gpsLatitude; }
    public void setGpsLatitude(BigDecimal gpsLatitude) { this.gpsLatitude = gpsLatitude; }

    public BigDecimal getGpsLongitude() { return gpsLongitude; }
    public void setGpsLongitude(BigDecimal gpsLongitude) { this.gpsLongitude = gpsLongitude; }

    public Integer getNextServiceHours() { return nextServiceHours; }
    public void setNextServiceHours(Integer nextServiceHours) { this.nextServiceHours = nextServiceHours; }

    public LocalDateTime getLastPingAt() { return lastPingAt; }
    public void setLastPingAt(LocalDateTime lastPingAt) { this.lastPingAt = lastPingAt; }
}
