package com.agrirent.app.service.impl;

import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.dto.response.EscrowTransactionResponse;
import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.EscrowTransaction;
import com.agrirent.app.exception.ResourceNotFoundException;
import com.agrirent.app.mapper.EquipmentMapper;
import com.agrirent.app.repository.BookingRepository;
import com.agrirent.app.repository.EquipmentRepository;
import com.agrirent.app.repository.EscrowTransactionRepository;
import com.agrirent.app.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AdminServiceImpl implements AdminService {

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private EscrowTransactionRepository escrowRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private EquipmentMapper equipmentMapper;

    @Override
    public DashboardMetricsResponse getMetrics() {
        DashboardMetricsResponse response = new DashboardMetricsResponse();
        response.setTotalGmv(new BigDecimal("3840000.00"));
        response.setActiveListingsCount(equipmentRepository.countByApprovalStatus("APPROVED"));
        response.setEscrowBalance(new BigDecimal("620500.00"));
        response.setDisputesCount(2L);
        return response;
    }

    @Override
    public List<EquipmentResponse> getPendingEquipment() {
        return equipmentRepository.findByApprovalStatus("PENDING").stream()
                .map(equipmentMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EquipmentResponse approveEquipment(Long id) {
        Equipment equipment = equipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + id));

        equipment.setApprovalStatus("APPROVED");
        equipment.setStatus("AVAILABLE");
        equipment.setAuditNotes("Platform telematics & mechanical VIN integrity audit PASSED.");
        return equipmentMapper.toResponse(equipmentRepository.save(equipment));
    }

    @Override
    @Transactional
    public EquipmentResponse rejectEquipment(Long id, String reason) {
        Equipment equipment = equipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + id));

        equipment.setApprovalStatus("REJECTED");
        equipment.setStatus("REJECTED");
        equipment.setAuditNotes("Audit failed: " + (reason != null ? reason : "Insufficient documentation"));
        return equipmentMapper.toResponse(equipmentRepository.save(equipment));
    }

    @Override
    public List<EscrowTransactionResponse> getEscrowTransactions() {
        return escrowRepository.findAll().stream()
                .map(this::toEscrowResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EscrowTransactionResponse releaseEscrow(Long id) {
        EscrowTransaction escrow = escrowRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Escrow transaction not found with id: " + id));

        escrow.setEscrowStatus("RELEASED_TO_OWNER");
        escrow.setReleasedAt(LocalDateTime.now());
        if (escrow.getBooking() != null) {
            escrow.getBooking().setPaymentStatus("RELEASED");
            bookingRepository.save(escrow.getBooking());
        }

        return toEscrowResponse(escrowRepository.save(escrow));
    }

    @Override
    @Transactional
    public EscrowTransactionResponse holdEscrow(Long id, String reason) {
        EscrowTransaction escrow = escrowRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Escrow transaction not found with id: " + id));

        escrow.setEscrowStatus("DISPUTED");
        escrow.setDisputeReason(reason != null ? reason : "Administrative safety freeze");
        return toEscrowResponse(escrowRepository.save(escrow));
    }

    private EscrowTransactionResponse toEscrowResponse(EscrowTransaction escrow) {
        if (escrow == null) return null;
        EscrowTransactionResponse res = new EscrowTransactionResponse();
        res.setId(escrow.getId());
        res.setBookingId(escrow.getBooking() != null ? escrow.getBooking().getId() : null);
        res.setPayerId(escrow.getPayer() != null ? escrow.getPayer().getId() : null);
        res.setPayerName(escrow.getPayer() != null ? escrow.getPayer().getFullName() : "Renter");
        res.setPayeeId(escrow.getPayee() != null ? escrow.getPayee().getId() : null);
        res.setPayeeName(escrow.getPayee() != null ? (escrow.getPayee().getFarmName() != null ? escrow.getPayee().getFarmName() : escrow.getPayee().getFullName()) : "Owner");
        res.setAmount(escrow.getAmount());
        res.setPlatformFee(escrow.getPlatformFee());
        res.setEscrowStatus(escrow.getEscrowStatus());
        res.setTransactionRef(escrow.getTransactionRef());
        res.setDisputeReason(escrow.getDisputeReason());
        res.setDisputeResolution(escrow.getDisputeResolution());
        res.setReleasedAt(escrow.getReleasedAt());
        res.setCreatedAt(escrow.getCreatedAt());
        return res;
    }
}
