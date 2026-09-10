package com.agrirent.app.dto.response;

import java.math.BigDecimal;

public class DashboardMetricsResponse {
    private BigDecimal totalGmv;
    private Long activeListingsCount;
    private BigDecimal escrowBalance;
    private Long disputesCount;
    private Long totalFleetSize;
    private Long activeRentals;
    private BigDecimal monthlyGrossEarnings;
    private BigDecimal fleetUtilizationPercent;

    public DashboardMetricsResponse() {}

    public BigDecimal getTotalGmv() { return totalGmv; }
    public void setTotalGmv(BigDecimal totalGmv) { this.totalGmv = totalGmv; }

    public Long getActiveListingsCount() { return activeListingsCount; }
    public void setActiveListingsCount(Long activeListingsCount) { this.activeListingsCount = activeListingsCount; }

    public BigDecimal getEscrowBalance() { return escrowBalance; }
    public void setEscrowBalance(BigDecimal escrowBalance) { this.escrowBalance = escrowBalance; }

    public Long getDisputesCount() { return disputesCount; }
    public void setDisputesCount(Long disputesCount) { this.disputesCount = disputesCount; }

    public Long getTotalFleetSize() { return totalFleetSize; }
    public void setTotalFleetSize(Long totalFleetSize) { this.totalFleetSize = totalFleetSize; }

    public Long getActiveRentals() { return activeRentals; }
    public void setActiveRentals(Long activeRentals) { this.activeRentals = activeRentals; }

    public BigDecimal getMonthlyGrossEarnings() { return monthlyGrossEarnings; }
    public void setMonthlyGrossEarnings(BigDecimal monthlyGrossEarnings) { this.monthlyGrossEarnings = monthlyGrossEarnings; }

    public BigDecimal getFleetUtilizationPercent() { return fleetUtilizationPercent; }
    public void setFleetUtilizationPercent(BigDecimal fleetUtilizationPercent) { this.fleetUtilizationPercent = fleetUtilizationPercent; }
}
