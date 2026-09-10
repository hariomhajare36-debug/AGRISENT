package com.agrirent.app.repository;

import com.agrirent.app.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByEquipmentIdOrderByCreatedAtDesc(Long equipmentId);
    List<Review> findByReviewerId(Long reviewerId);
}
