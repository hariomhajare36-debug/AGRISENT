package com.agrirent.app.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class EquipmentCreateRequest {
    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Make is required")
    private String make;

    @NotBlank(message = "Model is required")
    private String model;

    @NotNull(message = "Year is required")
    private Integer year;

    @NotBlank(message = "Category is required")
    private String category;

    private String serialVin;
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

    @NotNull(message = "Daily rate is required")
    private BigDecimal dailyRate;

    private BigDecimal weeklyRate;
    private BigDecimal monthlyRate;
    private BigDecimal securityDeposit;
    private BigDecimal purchasePrice;
    private Boolean isForRent;
    private Boolean isForSale;
    private String locationAddress;

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "State is required")
    private String state;

    @NotBlank(message = "ZIP code is required")
    private String zipCode;

    public EquipmentCreateRequest() {}

    // Getters and Setters
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

    public String getLocationAddress() { return locationAddress; }
    public void setLocationAddress(String locationAddress) { this.locationAddress = locationAddress; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }
}
