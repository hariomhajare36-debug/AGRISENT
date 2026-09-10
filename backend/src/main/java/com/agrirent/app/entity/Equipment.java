package com.agrirent.app.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "equipment")
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(nullable = false, length = 255)
    private String title;

    @Column(nullable = false, length = 100)
    private String make;

    @Column(length = 100)
    private String brand;

    @Column(nullable = false, length = 100)
    private String model;

    @Column(length = 100)
    private String variant;

    @Column(nullable = false)
    private Integer year;

    @Column(nullable = false, length = 100)
    private String category; // TRACTORS, HARVESTERS, TILLAGE, SEEDERS, SPRAYERS, HAY_FORAGE

    @Column(name = "serial_vin", length = 100)
    private String serialVin;

    @Column(length = 10, nullable = false)
    private String currency = "INR";

    @Column(name = "price_type", length = 50, nullable = false)
    private String priceType = "FIXED";

    @Column(name = "price_source_name", length = 255)
    private String priceSourceName;

    @Column(name = "price_source_url", length = 1000)
    private String priceSourceUrl;

    @Column(name = "last_verified_date", length = 50)
    private String lastVerifiedDate;

    @Column(length = 100)
    private String district;

    @Column(name = "lifting_capacity_kg")
    private Integer liftingCapacityKg;

    @Column(name = "fuel_tank_litres")
    private Integer fuelTankLitres;

    @Column(name = "engine_cc")
    private Integer engineCc;

    @Column(name = "pto_rpm", length = 50)
    private String ptoRpm;

    @Column(precision = 3, scale = 2, nullable = false)
    private BigDecimal rating = new BigDecimal("4.8");

    private Integer horsepower;

    @Column(name = "engine_hours", nullable = false)
    private Integer engineHours = 0;

    @Column(name = "drive_type", length = 50)
    private String driveType;

    @Column(name = "fuel_type", length = 50)
    private String fuelType;

    @Column(length = 100)
    private String transmission;

    @Column(name = "hydraulic_flow_gpm", precision = 10, scale = 2)
    private BigDecimal hydraulicFlowGpm;

    @Column(name = "pto_speed", length = 50)
    private String ptoSpeed;

    @Column(name = "hitch_category", length = 50)
    private String hitchCategory;

    @Lob
    private String description;

    @Lob
    private String images;

    @Column(name = "daily_rate", nullable = false, precision = 18, scale = 2)
    private BigDecimal dailyRate;

    @Column(name = "weekly_rate", precision = 18, scale = 2)
    private BigDecimal weeklyRate;

    @Column(name = "monthly_rate", precision = 18, scale = 2)
    private BigDecimal monthlyRate;

    @Column(name = "security_deposit", nullable = false, precision = 18, scale = 2)
    private BigDecimal securityDeposit = BigDecimal.ZERO;

    @Column(name = "purchase_price", precision = 18, scale = 2)
    private BigDecimal purchasePrice;

    @Column(name = "is_for_rent", nullable = false)
    private Boolean isForRent = true;

    @Column(name = "is_for_sale", nullable = false)
    private Boolean isForSale = false;

    @Column(nullable = false, length = 50)
    private String status = "AVAILABLE"; // AVAILABLE, RENTED, MAINTENANCE, IN_TRANSIT, PENDING_APPROVAL, REJECTED

    @Column(name = "approval_status", nullable = false, length = 50)
    private String approvalStatus = "APPROVED"; // PENDING, APPROVED, REJECTED

    @Lob
    @Column(name = "audit_notes")
    private String auditNotes;

    @Column(name = "location_address", length = 255)
    private String locationAddress;

    @Column(nullable = false, length = 100)
    private String city;

    @Column(nullable = false, length = 50)
    private String state;

    @Column(name = "zip_code", nullable = false, length = 20)
    private String zipCode;

    @Column(precision = 10, scale = 6)
    private BigDecimal latitude;

    @Column(precision = 10, scale = 6)
    private BigDecimal longitude;

    @OneToOne(mappedBy = "equipment", cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    private EquipmentTelemetry telemetry;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Equipment() {}

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMake() { return make; }
    public void setMake(String make) { this.make = make; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSerialVin() { return serialVin; }
    public void setSerialVin(String serialVin) { this.serialVin = serialVin; }

    public Integer getHorsepower() { return horsepower; }
    public void setHorsepower(Integer horsepower) { this.horsepower = horsepower; }

    public Integer getEngineHours() { return engineHours; }
    public void setEngineHours(Integer engineHours) { this.engineHours = engineHours; }

    public String getDriveType() { return driveType; }
    public void setDriveType(String driveType) { this.driveType = driveType; }

    public String getFuelType() { return fuelType; }
    public void setFuelType(String fuelType) { this.fuelType = fuelType; }

    public String getTransmission() { return transmission; }
    public void setTransmission(String transmission) { this.transmission = transmission; }

    public BigDecimal getHydraulicFlowGpm() { return hydraulicFlowGpm; }
    public void setHydraulicFlowGpm(BigDecimal hydraulicFlowGpm) { this.hydraulicFlowGpm = hydraulicFlowGpm; }

    public String getPtoSpeed() { return ptoSpeed; }
    public void setPtoSpeed(String ptoSpeed) { this.ptoSpeed = ptoSpeed; }

    public String getHitchCategory() { return hitchCategory; }
    public void setHitchCategory(String hitchCategory) { this.hitchCategory = hitchCategory; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImages() { return images; }
    public void setImages(String images) { this.images = images; }

    public BigDecimal getDailyRate() { return dailyRate; }
    public void setDailyRate(BigDecimal dailyRate) { this.dailyRate = dailyRate; }

    public BigDecimal getWeeklyRate() { return weeklyRate; }
    public void setWeeklyRate(BigDecimal weeklyRate) { this.weeklyRate = weeklyRate; }

    public BigDecimal getMonthlyRate() { return monthlyRate; }
    public void setMonthlyRate(BigDecimal monthlyRate) { this.monthlyRate = monthlyRate; }

    public BigDecimal getSecurityDeposit() { return securityDeposit; }
    public void setSecurityDeposit(BigDecimal securityDeposit) { this.securityDeposit = securityDeposit; }

    public BigDecimal getPurchasePrice() { return purchasePrice; }
    public void setPurchasePrice(BigDecimal purchasePrice) { this.purchasePrice = purchasePrice; }

    public Boolean getIsForRent() { return isForRent; }
    public void setIsForRent(Boolean isForRent) { this.isForRent = isForRent; }

    public Boolean getIsForSale() { return isForSale; }
    public void setIsForSale(Boolean isForSale) { this.isForSale = isForSale; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }

    public String getAuditNotes() { return auditNotes; }
    public void setAuditNotes(String auditNotes) { this.auditNotes = auditNotes; }

    public String getLocationAddress() { return locationAddress; }
    public void setLocationAddress(String locationAddress) { this.locationAddress = locationAddress; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }

    public EquipmentTelemetry getTelemetry() { return telemetry; }
    public void setTelemetry(EquipmentTelemetry telemetry) { this.telemetry = telemetry; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }

    public String getVariant() { return variant; }
    public void setVariant(String variant) { this.variant = variant; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getPriceType() { return priceType; }
    public void setPriceType(String priceType) { this.priceType = priceType; }

    public String getPriceSourceName() { return priceSourceName; }
    public void setPriceSourceName(String priceSourceName) { this.priceSourceName = priceSourceName; }

    public String getPriceSourceUrl() { return priceSourceUrl; }
    public void setPriceSourceUrl(String priceSourceUrl) { this.priceSourceUrl = priceSourceUrl; }

    public String getLastVerifiedDate() { return lastVerifiedDate; }
    public void setLastVerifiedDate(String lastVerifiedDate) { this.lastVerifiedDate = lastVerifiedDate; }

    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }

    public Integer getLiftingCapacityKg() { return liftingCapacityKg; }
    public void setLiftingCapacityKg(Integer liftingCapacityKg) { this.liftingCapacityKg = liftingCapacityKg; }

    public Integer getFuelTankLitres() { return fuelTankLitres; }
    public void setFuelTankLitres(Integer fuelTankLitres) { this.fuelTankLitres = fuelTankLitres; }

    public Integer getEngineCc() { return engineCc; }
    public void setEngineCc(Integer engineCc) { this.engineCc = engineCc; }

    public String getPtoRpm() { return ptoRpm; }
    public void setPtoRpm(String ptoRpm) { this.ptoRpm = ptoRpm; }

    public BigDecimal getRating() { return rating; }
    public void setRating(BigDecimal rating) { this.rating = rating; }
}
