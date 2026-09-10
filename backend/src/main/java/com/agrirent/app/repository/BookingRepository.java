package com.agrirent.app.repository;

import com.agrirent.app.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Long> {
    List<Booking> findByRenterIdOrderByCreatedAtDesc(Long renterId);
    List<Booking> findByOwnerIdOrderByCreatedAtDesc(Long ownerId);
    List<Booking> findByRenterIdAndStatus(Long renterId, String status);
    List<Booking> findByOwnerIdAndStatus(Long ownerId, String status);
    long countByStatus(String status);
}
