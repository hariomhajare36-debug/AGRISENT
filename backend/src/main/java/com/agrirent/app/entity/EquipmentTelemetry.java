package com.agrirent.app.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "equipment_telemetry")
public class EquipmentTelemetry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_id", nullable = false, unique = true)
    @JsonIgnore
    private Equipment equipment;

    @Column(name = "engine_hours", nullable = false)
    private Integer engineHours = 0;

    @Column(name = "fuel_level_percent", nullable = false)
    private Integer fuelLevelPercent = 100;

    @Column(name = "def_fluid_percent", nullable = false)
    private Integer defFluidPercent = 100;

    @Column(name = "battery_voltage", precision = 5, scale = 2)
    private BigDecimal batteryVoltage = new BigDecimal("12.6");

    @Column(name = "coolant_temp_f")
    private Integer coolantTempF = 185;

    @Column(name = "oil_pressure_psi")
    private Integer oilPressurePsi = 48;

    @Column(name = "gps_latitude", precision = 10, scale = 6)
    private BigDecimal gpsLatitude;

    @Column(name = "gps_longitude", precision = 10, scale = 6)
    private BigDecimal gpsLongitude;

    @Column(name = "next_service_hours")
    private Integer nextServiceHours;

    @Column(name = "last_ping_at", nullable = false)
    private LocalDateTime lastPingAt = LocalDateTime.now();

    public EquipmentTelemetry() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Equipment getEquipment() { return equipment; }
    public void setEquipment(Equipment equipment) { this.equipment = equipment; }

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
