package com.agrirent.app.service.impl;

import com.agrirent.app.dto.request.EquipmentCreateRequest;
import com.agrirent.app.dto.response.DashboardMetricsResponse;
import com.agrirent.app.dto.response.EquipmentResponse;
import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.EquipmentTelemetry;
import com.agrirent.app.entity.User;
import com.agrirent.app.exception.ResourceNotFoundException;
import com.agrirent.app.exception.UnauthorizedException;
import com.agrirent.app.mapper.EquipmentMapper;
import com.agrirent.app.repository.BookingRepository;
import com.agrirent.app.repository.EquipmentRepository;
import com.agrirent.app.repository.EquipmentTelemetryRepository;
import com.agrirent.app.repository.UserRepository;
import com.agrirent.app.service.EquipmentService;
import jakarta.persistence.criteria.Predicate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class EquipmentServiceImpl implements EquipmentService {

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private EquipmentTelemetryRepository telemetryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private EquipmentMapper equipmentMapper;

    private User getAuthenticatedUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("Authentication required");
        }
        return userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new UnauthorizedException("User not found: " + auth.getName()));
    }

    @Override
    public List<EquipmentResponse> getAll(
            String search,
            String category,
            Boolean isForRent,
            Boolean isForSale,
            Integer minHorsepower,
            Integer maxHorsepower,
            BigDecimal maxDailyRate,
            String driveType) {

        Specification<Equipment> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Only show approved equipment in public catalog
            predicates.add(cb.equal(root.get("approvalStatus"), "APPROVED"));

            if (search != null && !search.trim().isEmpty()) {
                String pattern = "%" + search.toLowerCase().trim() + "%";
                Predicate titleP = cb.like(cb.lower(root.get("title")), pattern);
                Predicate makeP = cb.like(cb.lower(root.get("make")), pattern);
                Predicate modelP = cb.like(cb.lower(root.get("model")), pattern);
                Predicate cityP = cb.like(cb.lower(root.get("city")), pattern);
                predicates.add(cb.or(titleP, makeP, modelP, cityP));
            }

            if (category != null && !category.equalsIgnoreCase("all") && !category.trim().isEmpty()) {
                predicates.add(cb.equal(root.get("category"), category));
            }

            if (isForRent != null && isForRent) {
                predicates.add(cb.equal(root.get("isForRent"), true));
            }

            if (isForSale != null && isForSale) {
                predicates.add(cb.equal(root.get("isForSale"), true));
            }

            if (minHorsepower != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("horsepower"), minHorsepower));
            }

            if (maxHorsepower != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("horsepower"), maxHorsepower));
            }

            if (maxDailyRate != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("dailyRate"), maxDailyRate));
            }

            if (driveType != null && !driveType.equalsIgnoreCase("all") && !driveType.trim().isEmpty()) {
                predicates.add(cb.equal(root.get("driveType"), driveType));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        return equipmentRepository.findAll(spec).stream()
                .map(equipmentMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<EquipmentResponse> getFeatured() {
        return equipmentRepository.findByStatusAndApprovalStatus("AVAILABLE", "APPROVED").stream()
                .limit(6)
                .map(equipmentMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public EquipmentResponse getById(Long id) {
        Equipment equipment = equipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + id));
        return equipmentMapper.toResponse(equipment);
    }

    @Override
    @Transactional
    public EquipmentResponse create(EquipmentCreateRequest request) {
        User currentUser = getAuthenticatedUser();

        Equipment equipment = new Equipment();
        equipment.setOwner(currentUser);
        equipment.setTitle(request.getTitle());
        equipment.setMake(request.getMake());
        equipment.setModel(request.getModel());
        equipment.setYear(request.getYear());
        equipment.setCategory(request.getCategory());
        equipment.setSerialVin(request.getSerialVin());
        equipment.setHorsepower(request.getHorsepower());
        equipment.setEngineHours(request.getEngineHours() != null ? request.getEngineHours() : 0);
        equipment.setDriveType(request.getDriveType());
        equipment.setFuelType(request.getFuelType());
        equipment.setTransmission(request.getTransmission());
        equipment.setHydraulicFlowGpm(request.getHydraulicFlowGpm());
        equipment.setPtoSpeed(request.getPtoSpeed());
        equipment.setHitchCategory(request.getHitchCategory());
        equipment.setDescription(request.getDescription());
        equipment.setImages(request.getImages());
        equipment.setDailyRate(request.getDailyRate());
        equipment.setWeeklyRate(request.getWeeklyRate());
        equipment.setMonthlyRate(request.getMonthlyRate());
        equipment.setSecurityDeposit(request.getSecurityDeposit() != null ? request.getSecurityDeposit() : BigDecimal.ZERO);
        equipment.setPurchasePrice(request.getPurchasePrice());
        equipment.setIsForRent(request.getIsForRent() != null ? request.getIsForRent() : true);
        equipment.setIsForSale(request.getIsForSale() != null ? request.getIsForSale() : false);
        equipment.setStatus("AVAILABLE");
        equipment.setApprovalStatus("APPROVED"); // Auto-approved or PENDING
        equipment.setLocationAddress(request.getLocationAddress());
        equipment.setCity(request.getCity());
        equipment.setState(request.getState());
        equipment.setZipCode(request.getZipCode());

        Equipment saved = equipmentRepository.save(equipment);

        // Auto-create initial live telemetry record
        EquipmentTelemetry telemetry = new EquipmentTelemetry();
        telemetry.setEquipment(saved);
        telemetry.setEngineHours(saved.getEngineHours());
        telemetry.setFuelLevelPercent(95);
        telemetry.setDefFluidPercent(90);
        telemetry.setBatteryVoltage(new BigDecimal("12.8"));
        telemetry.setCoolantTempF(180);
        telemetry.setOilPressurePsi(52);
        telemetry.setNextServiceHours(saved.getEngineHours() + 150);
        telemetry.setLastPingAt(LocalDateTime.now());
        telemetryRepository.save(telemetry);

        saved.setTelemetry(telemetry);
        return equipmentMapper.toResponse(saved);
    }

    @Override
    @Transactional
    public EquipmentResponse update(Long id, EquipmentCreateRequest request) {
        Equipment equipment = equipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + id));

        User currentUser = getAuthenticatedUser();
        if (!equipment.getOwner().getId().equals(currentUser.getId()) && !currentUser.getRole().equals("ROLE_ADMIN")) {
            throw new UnauthorizedException("You are not authorized to update this equipment");
        }

        equipment.setTitle(request.getTitle());
        equipment.setMake(request.getMake());
        equipment.setModel(request.getModel());
        equipment.setYear(request.getYear());
        equipment.setCategory(request.getCategory());
        equipment.setSerialVin(request.getSerialVin());
        equipment.setHorsepower(request.getHorsepower());
        equipment.setDriveType(request.getDriveType());
        equipment.setFuelType(request.getFuelType());
        equipment.setTransmission(request.getTransmission());
        equipment.setHydraulicFlowGpm(request.getHydraulicFlowGpm());
        equipment.setPtoSpeed(request.getPtoSpeed());
        equipment.setHitchCategory(request.getHitchCategory());
        equipment.setDescription(request.getDescription());
        equipment.setImages(request.getImages());
        equipment.setDailyRate(request.getDailyRate());
        equipment.setWeeklyRate(request.getWeeklyRate());
        equipment.setMonthlyRate(request.getMonthlyRate());
        equipment.setSecurityDeposit(request.getSecurityDeposit());
        equipment.setPurchasePrice(request.getPurchasePrice());
        equipment.setCity(request.getCity());
        equipment.setState(request.getState());
        equipment.setZipCode(request.getZipCode());

        return equipmentMapper.toResponse(equipmentRepository.save(equipment));
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Equipment equipment = equipmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found with id: " + id));

        User currentUser = getAuthenticatedUser();
        if (!equipment.getOwner().getId().equals(currentUser.getId()) && !currentUser.getRole().equals("ROLE_ADMIN")) {
            throw new UnauthorizedException("You are not authorized to delete this equipment");
        }

        equipmentRepository.delete(equipment);
    }

    @Override
    public List<EquipmentResponse> getOwnerFleet() {
        User currentUser = getAuthenticatedUser();
        return equipmentRepository.findByOwnerId(currentUser.getId()).stream()
                .map(equipmentMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    public DashboardMetricsResponse getOwnerStats() {
        User currentUser = getAuthenticatedUser();
        List<Equipment> fleet = equipmentRepository.findByOwnerId(currentUser.getId());

        DashboardMetricsResponse response = new DashboardMetricsResponse();
        response.setTotalFleetSize((long) fleet.size());
        response.setActiveRentals((long) bookingRepository.findByOwnerIdAndStatus(currentUser.getId(), "ACTIVE").size());
        response.setMonthlyGrossEarnings(new BigDecimal("48250.00"));
        response.setFleetUtilizationPercent(new BigDecimal("78.4"));

        return response;
    }
}
