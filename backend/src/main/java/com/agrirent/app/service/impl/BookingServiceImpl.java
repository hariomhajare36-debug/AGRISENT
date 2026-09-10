package com.agrirent.app.service.impl;

import com.agrirent.app.dto.request.BookingCreateRequest;
import com.agrirent.app.dto.request.BookingStatusUpdateRequest;
import com.agrirent.app.dto.response.BookingResponse;
import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.entity.Booking;
import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.EscrowTransaction;
import com.agrirent.app.entity.User;
import com.agrirent.app.exception.BadRequestException;
import com.agrirent.app.exception.ResourceNotFoundException;
import com.agrirent.app.exception.UnauthorizedException;
import com.agrirent.app.mapper.BookingMapper;
import com.agrirent.app.repository.BookingRepository;
import com.agrirent.app.repository.EquipmentRepository;
import com.agrirent.app.repository.EscrowTransactionRepository;
import com.agrirent.app.repository.UserRepository;
import com.agrirent.app.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class BookingServiceImpl implements BookingService {

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EscrowTransactionRepository escrowRepository;

    @Autowired
    private BookingMapper bookingMapper;

    private User getAuthenticatedUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("Authentication required");
        }
        return userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new UnauthorizedException("User not found: " + auth.getName()));
    }

    @Override
    @Transactional
    public BookingResponse create(BookingCreateRequest request) {
        User renter = getAuthenticatedUser();
        Equipment equipment = equipmentRepository.findById(request.getEquipmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + request.getEquipmentId()));

        if (request.getEndDate().isBefore(request.getStartDate())) {
            throw new BadRequestException("End date cannot be before start date");
        }

        long days = Duration.between(request.getStartDate(), request.getEndDate()).toDays();
        int totalDays = (int) Math.max(1, days);

        BigDecimal dailyRate = equipment.getDailyRate();
        BigDecimal subtotal = dailyRate.multiply(BigDecimal.valueOf(totalDays));

        BigDecimal deliveryFee = "DELIVERY".equalsIgnoreCase(request.getDeliveryMethod())
                ? new BigDecimal("450.00")
                : BigDecimal.ZERO;

        BigDecimal insuranceFee = (request.getDamageWaiverIncluded() != null && request.getDamageWaiverIncluded())
                ? new BigDecimal("60.00").multiply(BigDecimal.valueOf(totalDays))
                : BigDecimal.ZERO;

        BigDecimal platformFee = new BigDecimal("150.00");
        BigDecimal totalAmount = subtotal.add(deliveryFee).add(insuranceFee).add(platformFee);

        Booking booking = new Booking();
        booking.setEquipment(equipment);
        booking.setRenter(renter);
        booking.setOwner(equipment.getOwner());
        booking.setStartDate(request.getStartDate());
        booking.setEndDate(request.getEndDate());
        booking.setTotalDays(totalDays);
        booking.setDeliveryMethod(request.getDeliveryMethod() != null ? request.getDeliveryMethod() : "DELIVERY");
        booking.setDeliveryAddress(request.getDeliveryAddress());
        booking.setOperatorIncluded(request.getOperatorIncluded() != null ? request.getOperatorIncluded() : false);
        booking.setDamageWaiverIncluded(request.getDamageWaiverIncluded() != null ? request.getDamageWaiverIncluded() : true);
        booking.setDailyRate(dailyRate);
        booking.setEquipmentSubtotal(subtotal);
        booking.setDeliveryFee(deliveryFee);
        booking.setInsuranceFee(insuranceFee);
        booking.setEscrowFee(platformFee);
        booking.setTotalAmount(totalAmount);
        booking.setStatus("PENDING");
        booking.setPaymentStatus("ESCROW_HOLD");
        booking.setSpecialInstructions(request.getSpecialInstructions());
        booking.setHoursUsed(0);
        booking.setHoursAllowed(totalDays * 10);

        Booking saved = bookingRepository.save(booking);

        // Auto-create Escrow Transaction record
        EscrowTransaction escrow = new EscrowTransaction();
        escrow.setBooking(saved);
        escrow.setPayer(renter);
        escrow.setPayee(equipment.getOwner());
        escrow.setAmount(totalAmount);
        escrow.setPlatformFee(platformFee);
        escrow.setEscrowStatus("HELD");
        escrow.setTransactionRef("ESC-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        escrowRepository.save(escrow);

        return bookingMapper.toResponse(saved);
    }

    @Override
    public BookingResponse getById(Long id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + id));
        return bookingMapper.toResponse(booking);
    }

    @Override
    @Transactional
    public BookingResponse updateStatus(Long id, BookingStatusUpdateRequest request) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking not found with id: " + id));

        User currentUser = getAuthenticatedUser();
        // Only owner, renter, or admin can update status
        boolean isOwner = booking.getOwner().getId().equals(currentUser.getId());
        boolean isRenter = booking.getRenter().getId().equals(currentUser.getId());
        boolean isAdmin = currentUser.getRole().equals("ROLE_ADMIN");

        if (!isOwner && !isRenter && !isAdmin) {
            throw new UnauthorizedException("Not authorized to update this booking");
        }

        booking.setStatus(request.getStatus().toUpperCase());
        if ("ACCEPTED".equalsIgnoreCase(request.getStatus())) {
            booking.getEquipment().setStatus("RENTED");
            equipmentRepository.save(booking.getEquipment());
        } else if ("COMPLETED".equalsIgnoreCase(request.getStatus()) || "CANCELLED".equalsIgnoreCase(request.getStatus())) {
            booking.getEquipment().setStatus("AVAILABLE");
            equipmentRepository.save(booking.getEquipment());
        }

        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    @Override
    public List<BookingResponse> getOwnerBookings() {
        User owner = getAuthenticatedUser();
        return bookingRepository.findByOwnerIdOrderByCreatedAtDesc(owner.getId()).stream()
                .map(bookingMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getFarmerBookings() {
        User renter = getAuthenticatedUser();
        return bookingRepository.findByRenterIdOrderByCreatedAtDesc(renter.getId()).stream()
                .map(bookingMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<BookingResponse> getFarmerActiveRentals() {
        User renter = getAuthenticatedUser();
        return bookingRepository.findByRenterIdAndStatus(renter.getId(), "ACTIVE").stream()
                .map(bookingMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public DashboardMetricsResponse getFarmerStats() {
        User renter = getAuthenticatedUser();
        List<Booking> all = bookingRepository.findByRenterIdOrderByCreatedAtDesc(renter.getId());

        DashboardMetricsResponse response = new DashboardMetricsResponse();
        response.setActiveRentals((long) bookingRepository.findByRenterIdAndStatus(renter.getId(), "ACTIVE").size());
        response.setTotalGmv(all.stream().map(Booking::getTotalAmount).reduce(BigDecimal.ZERO, BigDecimal::add));
        response.setDisputesCount(0L);
        return response;
    }
}
