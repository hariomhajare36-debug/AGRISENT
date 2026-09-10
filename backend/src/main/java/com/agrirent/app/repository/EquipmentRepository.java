package com.agrirent.app.repository;

import com.agrirent.app.entity.Equipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EquipmentRepository extends JpaRepository<Equipment, Long>, JpaSpecificationExecutor<Equipment> {
    List<Equipment> findByOwnerId(Long ownerId);
    List<Equipment> findByApprovalStatus(String approvalStatus);
    List<Equipment> findByStatusAndApprovalStatus(String status, String approvalStatus);
    long countByApprovalStatus(String approvalStatus);
    long countByStatus(String status);
}
