package com.agrirent.app.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "equipment_id", nullable = false)
    private Equipment equipment;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "renter_id", nullable = false)
    private User renter;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(name = "start_date", nullable = false)
    private LocalDateTime startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDateTime endDate;

    @Column(name = "total_days", nullable = false)
    private Integer totalDays;

    @Column(name = "delivery_method", nullable = false, length = 50)
    private String deliveryMethod = "DELIVERY"; // DELIVERY, PICKUP

    @Column(name = "delivery_address", length = 255)
    private String deliveryAddress;

    @Column(name = "operator_included", nullable = false)
    private Boolean operatorIncluded = false;

    @Column(name = "damage_waiver_included", nullable = false)
    private Boolean damageWaiverIncluded = true;

    @Column(name = "daily_rate", nullable = false, precision = 18, scale = 2)
    private BigDecimal dailyRate;

    @Column(name = "equipment_subtotal", nullable = false, precision = 18, scale = 2)
    private BigDecimal equipmentSubtotal;

    @Column(name = "delivery_fee", nullable = false, precision = 18, scale = 2)
    private BigDecimal deliveryFee = BigDecimal.ZERO;

    @Column(name = "insurance_fee", nullable = false, precision = 18, scale = 2)
    private BigDecimal insuranceFee = BigDecimal.ZERO;

    @Column(name = "escrow_fee", nullable = false, precision = 18, scale = 2)
    private BigDecimal escrowFee = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal totalAmount;

    @Column(nullable = false, length = 50)
    private String status = "PENDING"; // PENDING, ACCEPTED, ACTIVE, COMPLETED, CANCELLED, REJECTED

    @Column(name = "payment_status", nullable = false, length = 50)
    private String paymentStatus = "ESCROW_HOLD"; // PENDING, ESCROW_HOLD, RELEASED, REFUNDED

    @Lob
    @Column(name = "special_instructions")
    private String specialInstructions;

    @Column(name = "hours_used", nullable = false)
    private Integer hoursUsed = 0;

    @Column(name = "hours_allowed", nullable = false)
    private Integer hoursAllowed = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Booking() {}

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

    public Equipment getEquipment() { return equipment; }
    public void setEquipment(Equipment equipment) { this.equipment = equipment; }

    public User getRenter() { return renter; }
    public void setRenter(User renter) { this.renter = renter; }

    public User getOwner() { return owner; }
    public void setOwner(User owner) { this.owner = owner; }

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

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
