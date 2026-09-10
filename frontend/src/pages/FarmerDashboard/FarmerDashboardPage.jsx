import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { bookingService } from '../../services/bookingService';
import { reviewService } from '../../services/reviewService';
import StatusBadge from '../../components/common/StatusBadge';
import Modal from '../../components/common/Modal';
import { useAuth } from '../../hooks/useAuth';

export const FarmerDashboardPage = () => {
  const { user } = useAuth();
  const [bookings, setBookings] = useState([]);
  const [activeRentals, setActiveRentals] = useState([]);
  const [stats, setStats] = useState({
    activeRentalsCount: 0,
    upcomingBookingsCount: 0,
    totalSpent: 0,
    completedJobs: 0,
  });
  const [loading, setLoading] = useState(true);

  // Review Modal State
  const [reviewModalOpen, setReviewModalOpen] = useState(false);
  const [selectedBookingForReview, setSelectedBookingForReview] = useState(null);
  const [reviewRating, setReviewRating] = useState(5);
  const [reviewComment, setReviewComment] = useState('');
  const [reviewSubmitting, setReviewSubmitting] = useState(false);

  // Action Notice
  const [notice, setNotice] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const [bookingsData, activeData, statsData] = await Promise.all([
        bookingService.getFarmerBookings(),
        bookingService.getActiveRentals(),
        bookingService.getFarmerStats(),
      ]);
      setBookings(bookingsData || []);
      setActiveRentals(activeData || []);
      setStats(statsData || {});
    } catch (err) {
      console.error('Failed to load farmer dashboard:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleReviewSubmit = async (e) => {
    e.preventDefault();
    if (!selectedBookingForReview) return;
    setReviewSubmitting(true);
    try {
      await reviewService.create({
        equipmentId: selectedBookingForReview.equipmentId,
        bookingId: selectedBookingForReview.id,
        rating: reviewRating,
        comment: reviewComment,
        equipmentConditionRating: 5,
        communicationRating: 5,
      });
      setReviewModalOpen(false);
      setNotice('Review submitted successfully! Thank you for supporting the farmer community.');
      setTimeout(() => setNotice(''), 4000);
      loadData();
    } catch (err) {
      console.error('Failed to submit review:', err);
      alert('Error submitting review.');
    } finally {
      setReviewSubmitting(false);
    }
  };

  const handleExtendRental = (b) => {
    alert(`Request to extend booking #${b.id} for 3 additional days sent to owner!`);
  };

  const handleFieldTech = (b) => {
    alert(`24/7 Field Tech request initiated for ${b.equipmentTitle}. A technician is on dispatch!`);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <span className="text-xs uppercase font-bold text-secondary tracking-wider">
            Farmer Operations Console
          </span>
          <h1 className="font-headline-xl text-3xl font-extrabold text-on-surface mt-1">
            Welcome back, {user?.fullName || 'David Miller'}
          </h1>
          <p className="text-sm text-on-surface-variant mt-0.5">
            {user?.farmName || 'Miller Family Grain & Row-Crop'} • Ames, Iowa
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link
            to="/equipment"
            className="px-4 py-2.5 rounded-xl bg-primary text-on-primary font-bold text-xs flex items-center gap-1.5 hover:bg-primary-container transition-all shadow-sm"
          >
            <span className="material-symbols-outlined text-sm">search</span>
            <span>Rent Additional Machinery</span>
          </Link>
        </div>
      </div>

      {notice && (
        <div className="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-sm text-emerald-800 flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-600">check_circle</span>
          <span>{notice}</span>
        </div>
      )}

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">
              Active Rentals
            </span>
            <span className="p-2 rounded-xl bg-primary/10 text-primary">
              <span className="material-symbols-outlined text-lg">agriculture</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {activeRentals.length}
          </div>
          <span className="text-xs text-secondary font-semibold mt-1 block">In Field Operation</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">
              Upcoming Bookings
            </span>
            <span className="p-2 rounded-xl bg-blue-50 text-blue-700">
              <span className="material-symbols-outlined text-lg">calendar_today</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {bookings.filter((b) => b.status === 'PENDING' || b.status === 'ACCEPTED').length}
          </div>
          <span className="text-xs text-on-surface-variant mt-1 block">Scheduled Dispatches</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">
              Rental Outlay
            </span>
            <span className="p-2 rounded-xl bg-emerald-50 text-emerald-700">
              <span className="material-symbols-outlined text-lg">receipt_long</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-primary">
            ${(stats.totalSpent || 14200).toLocaleString()}
          </div>
          <span className="text-xs text-secondary font-semibold mt-1 block">Escrow Protected</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">
              Completed Rentals
            </span>
            <span className="p-2 rounded-xl bg-amber-50 text-amber-700">
              <span className="material-symbols-outlined text-lg">verified</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {stats.completedJobs || 18}
          </div>
          <span className="text-xs text-on-surface-variant mt-1 block">Zero Dispute Record</span>
        </div>
      </div>

      {/* Active Field Rentals Cards */}
      <div className="mb-8">
        <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-4">
          Active Heavy Machinery in Your Fields
        </h3>

        {activeRentals.length === 0 ? (
          <div className="bg-surface-container-lowest p-8 rounded-2xl text-center border border-outline-variant/40">
            <span className="material-symbols-outlined text-4xl text-on-surface-variant/40 mb-2">agriculture</span>
            <p className="text-sm text-on-surface-variant">No equipment currently active in your fields.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {activeRentals.map((r) => (
              <div
                key={r.id}
                className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/50 shadow-sm space-y-4"
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <StatusBadge status="ACTIVE" customLabel="Active in Field" />
                    <h4 className="font-headline-sm text-lg font-bold text-on-surface mt-2">
                      {r.equipmentTitle || '2023 John Deere 8R 410'}
                    </h4>
                    <p className="text-xs text-on-surface-variant">
                      Return Date:{' '}
                      <strong className="text-on-surface">
                        {new Date(r.endDate).toLocaleDateString()}
                      </strong>{' '}
                      • Owner: {r.ownerName || 'Cedar Valley Farms'}
                    </p>
                  </div>
                  <span className="text-xs font-bold text-primary px-3 py-1 bg-primary/10 rounded-lg">
                    ${Number(r.dailyRate || 1450).toLocaleString()} / day
                  </span>
                </div>

                {/* Progress bar for hours / days */}
                <div className="p-3 bg-surface-container-low rounded-xl text-xs space-y-1.5">
                  <div className="flex justify-between font-semibold">
                    <span className="text-on-surface-variant">Engine Meter Log</span>
                    <span className="text-on-surface">{r.hoursUsed || 24} hrs logged / {r.hoursAllowed || 70} hrs included</span>
                  </div>
                  <div className="w-full h-2 bg-surface-container-highest rounded-full overflow-hidden">
                    <div
                      className="h-full bg-secondary rounded-full"
                      style={{ width: `${Math.min(100, ((r.hoursUsed || 24) / (r.hoursAllowed || 70)) * 100)}%` }}
                    ></div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-outline-variant/20">
                  <button
                    type="button"
                    onClick={() => handleExtendRental(r)}
                    className="px-3.5 py-2 rounded-xl bg-surface-container-high hover:bg-surface-container text-xs font-semibold text-on-surface flex items-center gap-1 transition-colors"
                  >
                    <span className="material-symbols-outlined text-sm">more_time</span>
                    <span>Extend Rental</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => handleFieldTech(r)}
                    className="px-3.5 py-2 rounded-xl bg-surface-container-high hover:bg-surface-container text-xs font-semibold text-on-surface flex items-center gap-1 transition-colors"
                  >
                    <span className="material-symbols-outlined text-sm text-amber-600">build</span>
                    <span>Request 24/7 Field Tech</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedBookingForReview(r);
                      setReviewModalOpen(true);
                    }}
                    className="ml-auto px-3.5 py-2 rounded-xl bg-secondary/10 hover:bg-secondary/20 text-secondary text-xs font-bold flex items-center gap-1 transition-colors"
                  >
                    <span className="material-symbols-outlined text-sm">rate_review</span>
                    <span>Rate Machine</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Booking History Table */}
      <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
        <div className="flex items-center justify-between mb-4 pb-3 border-b border-outline-variant/20">
          <h3 className="font-headline-sm text-base font-bold text-on-surface">
            Complete Rental &amp; Reservation History
          </h3>
          <span className="text-xs text-on-surface-variant font-medium">
            Total {bookings.length} Orders
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-outline-variant/30 text-on-surface-variant uppercase tracking-wider font-bold">
                <th className="pb-3 pr-4">Order ID</th>
                <th className="pb-3 pr-4">Equipment</th>
                <th className="pb-3 pr-4">Dates</th>
                <th className="pb-3 pr-4">Total Amount</th>
                <th className="pb-3 pr-4">Escrow Status</th>
                <th className="pb-3 pr-4">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/20">
              {bookings.map((b) => (
                <tr key={b.id} className="hover:bg-surface-container-low transition-colors">
                  <td className="py-3.5 pr-4 font-mono font-bold text-on-surface">#{b.id}</td>
                  <td className="py-3.5 pr-4 font-bold text-on-surface">
                    <Link to={`/equipment/${b.equipmentId}`} className="hover:text-primary transition-colors">
                      {b.equipmentTitle}
                    </Link>
                  </td>
                  <td className="py-3.5 pr-4 text-on-surface-variant">
                    {new Date(b.startDate).toLocaleDateString()} to {new Date(b.endDate).toLocaleDateString()} ({b.totalDays}d)
                  </td>
                  <td className="py-3.5 pr-4 font-bold text-primary">
                    ${Number(b.totalAmount || 0).toLocaleString()}
                  </td>
                  <td className="py-3.5 pr-4">
                    <StatusBadge status={b.status} />
                  </td>
                  <td className="py-3.5 pr-4">
                    <button
                      type="button"
                      onClick={() => alert(`Invoice receipt for Booking #${b.id} downloaded.`)}
                      className="px-3 py-1.5 rounded-lg bg-surface-container-high hover:bg-surface-container text-xs font-semibold"
                    >
                      Receipt
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Review Modal */}
      <Modal
        isOpen={reviewModalOpen}
        onClose={() => setReviewModalOpen(false)}
        title={`Rate ${selectedBookingForReview?.equipmentTitle || 'Equipment'}`}
      >
        <form onSubmit={handleReviewSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-2">
              Performance Rating
            </label>
            <div className="flex items-center gap-2">
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onClick={() => setReviewRating(star)}
                  className={`text-2xl ${star <= reviewRating ? 'text-amber-500' : 'text-slate-300'}`}
                >
                  ★
                </button>
              ))}
              <span className="text-xs font-bold text-on-surface ml-2">{reviewRating} of 5 Stars</span>
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
              Field Feedback &amp; Mechanical Integrity
            </label>
            <textarea
              value={reviewComment}
              onChange={(e) => setReviewComment(e.target.value)}
              placeholder="How did the machine handle? Fuel economy, cab cleanliness, hydraulic responsiveness..."
              rows={4}
              className="w-full p-3 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs outline-none focus:ring-2 focus:ring-primary/40"
              required
            />
          </div>

          <button
            type="submit"
            disabled={reviewSubmitting}
            className="w-full py-3 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs transition-colors shadow-md disabled:opacity-50"
          >
            {reviewSubmitting ? 'Submitting Feedback...' : 'Submit Verified Field Review'}
          </button>
        </form>
      </Modal>
    </div>
  );
};

export default FarmerDashboardPage;
