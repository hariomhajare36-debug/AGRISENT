package com.agrirent.app.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class EquipmentResponse {
    private Long id;
    private UserResponse owner;
    private String title;
    private String make;
    private String brand;
    private String model;
    private String variant;
    private Integer year;
    private String category;
    private String serialVin;
    private String currency;
    private String priceType;
    private String priceSourceName;
    private String priceSourceUrl;
    private String lastVerifiedDate;
    private String district;
    private Integer liftingCapacityKg;
    private Integer fuelTankLitres;
    private Integer engineCc;
    private String ptoRpm;
    private BigDecimal rating;
    private Integer horsepower;
    private Integer engineHours;
    private String driveType;
    private String fuelType;
    private String transmission;
    private BigDecimal hydraulicFlowGpm;
    private String ptoSpeed;
    private String hitchCategory;
    private String description;
    private String images;
    private BigDecimal dailyRate;
    private BigDecimal weeklyRate;
    private BigDecimal monthlyRate;
    private BigDecimal securityDeposit;
    private BigDecimal purchasePrice;
    private Boolean isForRent;
    private Boolean isForSale;
    private String status;
    private String approvalStatus;
    private String auditNotes;
    private String locationAddress;
    private String city;
    private String state;
    private String zipCode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private EquipmentTelemetryResponse telemetry;
    private LocalDateTime createdAt;

    public EquipmentResponse() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public UserResponse getOwner() { return owner; }
    public void setOwner(UserResponse owner) { this.owner = owner; }

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

    public EquipmentTelemetryResponse getTelemetry() { return telemetry; }
    public void setTelemetry(EquipmentTelemetryResponse telemetry) { this.telemetry = telemetry; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

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
