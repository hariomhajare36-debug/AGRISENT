package com.agrirent.app.mapper;

import com.agrirent.app.dto.response.BookingResponse;
import com.agrirent.app.entity.Booking;
import org.springframework.stereotype.Component;

@Component
public class BookingMapper {

    public BookingResponse toResponse(Booking booking) {
        if (booking == null) return null;
        BookingResponse response = new BookingResponse();
        response.setId(booking.getId());
        response.setEquipmentId(booking.getEquipment().getId());
        response.setEquipmentTitle(booking.getEquipment().getTitle());
        response.setRenterId(booking.getRenter().getId());
        response.setRenterName(booking.getRenter().getFullName());
        response.setRenterEmail(booking.getRenter().getEmail());
        response.setOwnerId(booking.getOwner().getId());
        response.setOwnerName(booking.getOwner().getFarmName() != null ? booking.getOwner().getFarmName() : booking.getOwner().getFullName());
        response.setStartDate(booking.getStartDate());
        response.setEndDate(booking.getEndDate());
        response.setTotalDays(booking.getTotalDays());
        response.setDeliveryMethod(booking.getDeliveryMethod());
        response.setDeliveryAddress(booking.getDeliveryAddress());
        response.setOperatorIncluded(booking.getOperatorIncluded());
        response.setDamageWaiverIncluded(booking.getDamageWaiverIncluded());
        response.setDailyRate(booking.getDailyRate());
        response.setEquipmentSubtotal(booking.getEquipmentSubtotal());
        response.setDeliveryFee(booking.getDeliveryFee());
        response.setInsuranceFee(booking.getInsuranceFee());
        response.setEscrowFee(booking.getEscrowFee());
        response.setTotalAmount(booking.getTotalAmount());
        response.setStatus(booking.getStatus());
        response.setPaymentStatus(booking.getPaymentStatus());
        response.setSpecialInstructions(booking.getSpecialInstructions());
        response.setHoursUsed(booking.getHoursUsed());
        response.setHoursAllowed(booking.getHoursAllowed());
        response.setCreatedAt(booking.getCreatedAt());
        return response;
    }
}
