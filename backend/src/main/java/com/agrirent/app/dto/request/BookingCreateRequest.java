package com.agrirent.app.dto.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

public class BookingCreateRequest {
    @NotNull(message = "Equipment ID is required")
    private Long equipmentId;

    @NotNull(message = "Start date is required")
    private LocalDateTime startDate;

    @NotNull(message = "End date is required")
    private LocalDateTime endDate;

    private String deliveryMethod; // DELIVERY, PICKUP
    private String deliveryAddress;
    private Boolean operatorIncluded;
    private Boolean damageWaiverIncluded;
    private String specialInstructions;

    public BookingCreateRequest() {}

    public Long getEquipmentId() { return equipmentId; }
    public void setEquipmentId(Long equipmentId) { this.equipmentId = equipmentId; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public String getDeliveryMethod() { return deliveryMethod; }
    public void setDeliveryMethod(String deliveryMethod) { this.deliveryMethod = deliveryMethod; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public Boolean getOperatorIncluded() { return operatorIncluded; }
    public void setOperatorIncluded(Boolean operatorIncluded) { this.operatorIncluded = operatorIncluded; }

    public Boolean getDamageWaiverIncluded() { return damageWaiverIncluded; }
    public void setDamageWaiverIncluded(Boolean damageWaiverIncluded) { this.damageWaiverIncluded = damageWaiverIncluded; }

    public String getSpecialInstructions() { return specialInstructions; }
    public void setSpecialInstructions(String specialInstructions) { this.specialInstructions = specialInstructions; }
}
