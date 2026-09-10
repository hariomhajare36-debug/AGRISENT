package com.agrirent.app.service.impl;

import com.agrirent.app.dto.request.ReviewCreateRequest;
import com.agrirent.app.dto.response.ReviewResponse;
import com.agrirent.app.entity.Booking;
import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.Review;
import com.agrirent.app.entity.User;
import com.agrirent.app.exception.ResourceNotFoundException;
import com.agrirent.app.exception.UnauthorizedException;
import com.agrirent.app.mapper.ReviewMapper;
import com.agrirent.app.repository.BookingRepository;
import com.agrirent.app.repository.EquipmentRepository;
import com.agrirent.app.repository.ReviewRepository;
import com.agrirent.app.repository.UserRepository;
import com.agrirent.app.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ReviewServiceImpl implements ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private BookingRepository bookingRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ReviewMapper reviewMapper;

    private User getAuthenticatedUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new UnauthorizedException("Authentication required");
        }
        return userRepository.findByUsername(auth.getName())
                .orElseThrow(() -> new UnauthorizedException("User not found: " + auth.getName()));
    }

    @Override
    public List<ReviewResponse> getByEquipmentId(Long equipmentId) {
        return reviewRepository.findByEquipmentIdOrderByCreatedAtDesc(equipmentId).stream()
                .map(reviewMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ReviewResponse create(ReviewCreateRequest request) {
        User reviewer = getAuthenticatedUser();
        Equipment equipment = equipmentRepository.findById(request.getEquipmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Equipment not found: " + request.getEquipmentId()));

        Booking booking = null;
        if (request.getBookingId() != null) {
            booking = bookingRepository.findById(request.getBookingId()).orElse(null);
        }

        Review review = new Review();
        review.setEquipment(equipment);
        review.setBooking(booking);
        review.setReviewer(reviewer);
        review.setRating(request.getRating());
        review.setComment(request.getComment());
        review.setEquipmentConditionRating(request.getEquipmentConditionRating() != null ? request.getEquipmentConditionRating() : request.getRating());
        review.setCommunicationRating(request.getCommunicationRating() != null ? request.getCommunicationRating() : request.getRating());

        return reviewMapper.toResponse(reviewRepository.save(review));
    }
}
