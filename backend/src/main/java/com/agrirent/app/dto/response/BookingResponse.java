package com.agrirent.app.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class BookingResponse {
    private Long id;
    private Long equipmentId;
    private String equipmentTitle;
    private Long renterId;
    private String renterName;
    private String renterEmail;
    private Long ownerId;
    private String ownerName;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Integer totalDays;
    private String deliveryMethod;
    private String deliveryAddress;
    private Boolean operatorIncluded;
    private Boolean damageWaiverIncluded;
    private BigDecimal dailyRate;
    private BigDecimal equipmentSubtotal;
    private BigDecimal deliveryFee;
    private BigDecimal insuranceFee;
    private BigDecimal escrowFee;
    private BigDecimal totalAmount;
    private String status;
    private String paymentStatus;
    private String specialInstructions;
    private Integer hoursUsed;
    private Integer hoursAllowed;
    private LocalDateTime createdAt;

    public BookingResponse() {}

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEquipmentId() { return equipmentId; }
    public void setEquipmentId(Long equipmentId) { this.equipmentId = equipmentId; }

    public String getEquipmentTitle() { return equipmentTitle; }
    public void setEquipmentTitle(String equipmentTitle) { this.equipmentTitle = equipmentTitle; }

    public Long getRenterId() { return renterId; }
    public void setRenterId(Long renterId) { this.renterId = renterId; }

    public String getRenterName() { return renterName; }
    public void setRenterName(String renterName) { this.renterName = renterName; }

    public String getRenterEmail() { return renterEmail; }
    public void setRenterEmail(String renterEmail) { this.renterEmail = renterEmail; }

    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }

    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public Integer getTotalDays() { return totalDays; }
    public void setTotalDays(Integer totalDays) { this.totalDays = totalDays; }

    public String getDeliveryMethod() { return deliveryMethod; }
    public void setDeliveryMethod(String deliveryMethod) { this.deliveryMethod = deliveryMethod; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public Boolean getOperatorIncluded() { return operatorIncluded; }
    public void setOperatorIncluded(Boolean operatorIncluded) { this.operatorIncluded = operatorIncluded; }

    public Boolean getDamageWaiverIncluded() { return damageWaiverIncluded; }
    public void setDamageWaiverIncluded(Boolean damageWaiverIncluded) { this.damageWaiverIncluded = damageWaiverIncluded; }

    public BigDecimal getDailyRate() { return dailyRate; }
    public void setDailyRate(BigDecimal dailyRate) { this.dailyRate = dailyRate; }

    public BigDecimal getEquipmentSubtotal() { return equipmentSubtotal; }
    public void setEquipmentSubtotal(BigDecimal equipmentSubtotal) { this.equipmentSubtotal = equipmentSubtotal; }

    public BigDecimal getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(BigDecimal deliveryFee) { this.deliveryFee = deliveryFee; }

    public BigDecimal getInsuranceFee() { return insuranceFee; }
    public void setInsuranceFee(BigDecimal insuranceFee) { this.insuranceFee = insuranceFee; }

    public BigDecimal getEscrowFee() { return escrowFee; }
    public void setEscrowFee(BigDecimal escrowFee) { this.escrowFee = escrowFee; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }

    public Integer getHoursUsed() { return hoursUsed; }
    public void setHoursUsed(Integer hoursUsed) { this.hoursUsed = hoursUsed; }

    public Integer getHoursAllowed() { return hoursAllowed; }
    public void setHoursAllowed(Integer hoursAllowed) { this.hoursAllowed = hoursAllowed; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
