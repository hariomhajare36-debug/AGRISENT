package com.agrirent.app.repository;

import com.agrirent.app.entity.EscrowTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, Long> {
    Optional<EscrowTransaction> findByTransactionRef(String transactionRef);
    List<EscrowTransaction> findByBookingId(Long bookingId);
    List<EscrowTransaction> findByEscrowStatus(String escrowStatus);
    long countByEscrowStatus(String escrowStatus);
}
