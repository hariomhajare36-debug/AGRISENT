import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import { bookingService } from '../../services/bookingService';
import StatusBadge from '../../components/common/StatusBadge';
import { useAuth } from '../../hooks/useAuth';

export const OwnerDashboardPage = () => {
  const { user } = useAuth();
  const [fleet, setFleet] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [stats, setStats] = useState({
    totalFleetSize: 0,
    activeRentals: 0,
    monthlyGrossEarnings: 0,
    fleetUtilizationPercent: 0,
  });
  const [loading, setLoading] = useState(true);
  const [actionSuccess, setActionSuccess] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const [fleetData, bookingsData, statsData] = await Promise.all([
        equipmentService.getOwnerFleet(),
        bookingService.getOwnerBookings(),
        equipmentService.getOwnerStats(),
      ]);
      setFleet(fleetData || []);
      setBookings(bookingsData || []);
      setStats(statsData || {});
    } catch (err) {
      console.error('Failed to load owner dashboard:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleBookingAction = async (bookingId, newStatus) => {
    try {
      await bookingService.updateStatus(bookingId, newStatus);
      setActionSuccess(`Booking #${bookingId} marked as ${newStatus}!`);
      setTimeout(() => setActionSuccess(''), 4000);
      loadData();
    } catch (err) {
      console.error('Failed to update booking status:', err);
      alert('Error updating booking status. Please try again.');
    }
  };

  const pendingBookings = bookings.filter((b) => b.status === 'PENDING');

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <span className="text-xs uppercase font-bold text-secondary tracking-wider">
            Commercial Fleet Management
          </span>
          <h1 className="font-headline-xl text-3xl font-extrabold text-on-surface mt-1">
            {user?.farmName || 'Cedar Valley Farms & Agri-Fleet'}
          </h1>
          <p className="text-sm text-on-surface-variant mt-0.5">
            Real-time fleet telematics, booking requests, and escrow clearing console
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link
            to="/owner/add-equipment"
            className="px-4 py-2.5 rounded-xl bg-primary text-on-primary font-bold text-xs flex items-center gap-1.5 hover:bg-primary-container transition-all shadow-sm"
          >
            <span className="material-symbols-outlined text-sm">add_circle</span>
            <span>+ Add New Equipment</span>
          </Link>
          <button
            onClick={() => alert('Exporting tax & earnings ledger CSV...')}
            className="px-4 py-2.5 rounded-xl bg-surface-container-high hover:bg-surface-container text-on-surface font-bold text-xs flex items-center gap-1.5 transition-colors"
          >
            <span className="material-symbols-outlined text-sm">receipt_long</span>
            <span>Export Tax &amp; Earnings</span>
          </button>
        </div>
      </div>

      {actionSuccess && (
        <div className="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-sm text-emerald-800 flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-600">check_circle</span>
          <span>{actionSuccess}</span>
        </div>
      )}

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Fleet Units</span>
            <span className="p-2 rounded-xl bg-primary/10 text-primary">
              <span className="material-symbols-outlined text-lg">agriculture</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">{fleet.length}</div>
          <span className="text-xs text-secondary font-semibold flex items-center gap-1 mt-1">
            <span className="material-symbols-outlined text-xs">check</span>
            {fleet.filter((f) => f.status === 'AVAILABLE').length} Available Now
          </span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">In-Field Rentals</span>
            <span className="p-2 rounded-xl bg-blue-50 text-blue-700">
              <span className="material-symbols-outlined text-lg">event_available</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {bookings.filter((b) => b.status === 'ACTIVE').length}
          </div>
          <span className="text-xs text-blue-600 font-semibold mt-1 block">Active Field Dispatches</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Monthly Revenue</span>
            <span className="p-2 rounded-xl bg-emerald-50 text-emerald-700">
              <span className="material-symbols-outlined text-lg">payments</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-primary">
            ${(stats.monthlyGrossEarnings || 48250).toLocaleString()}
          </div>
          <span className="text-xs text-secondary font-semibold mt-1 block">+18.4% vs last harvest</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Fleet Utilization</span>
            <span className="p-2 rounded-xl bg-amber-50 text-amber-700">
              <span className="material-symbols-outlined text-lg">trending_up</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {stats.fleetUtilizationPercent || '78.4'}%
          </div>
          <span className="text-xs text-on-surface-variant mt-1 block">Seasonal Peak Target: 85%</span>
        </div>
      </div>

      {/* Urgent Action Queue: Pending Booking Requests */}
      <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm mb-8">
        <div className="flex items-center justify-between mb-4 pb-3 border-b border-outline-variant/20">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
            <h3 className="font-headline-sm text-base font-bold text-on-surface">
              Urgent Action Queue: Pending Rental &amp; Order Requests ({pendingBookings.length})
            </h3>
          </div>
          <span className="text-xs text-on-surface-variant">Instant 24-hr Auto-Release Window</span>
        </div>

        {pendingBookings.length === 0 ? (
          <p className="text-xs text-on-surface-variant py-4 italic text-center">
            No pending booking requests right now. All reservation requests have been processed!
          </p>
        ) : (
          <div className="space-y-4">
            {pendingBookings.map((b) => (
              <div
                key={b.id}
                className="p-5 rounded-2xl bg-surface-container-low border border-outline-variant/30 flex flex-col md:flex-row items-start md:items-center justify-between gap-4"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-sm text-on-surface">{b.equipmentTitle || 'John Deere 8R 410'}</span>
                    <StatusBadge status="PENDING" />
                    <span className="text-xs font-semibold text-primary">
                      ${Number(b.totalAmount || 0).toLocaleString()} (In Escrow)
                    </span>
                  </div>
                  <p className="text-xs text-on-surface-variant">
                    Renter: <strong className="text-on-surface">{b.renterName || 'David Miller'}</strong> ({b.renterEmail})
                    • Period: {new Date(b.startDate).toLocaleDateString()} to {new Date(b.endDate).toLocaleDateString()} ({b.totalDays} Days)
                  </p>
                  <p className="text-xs text-on-surface-variant italic">
                    Instructions: "{b.specialInstructions || 'Standard field delivery requested'}"
                  </p>
                </div>

                <div className="flex items-center gap-2 flex-shrink-0">
                  <button
                    type="button"
                    onClick={() => handleBookingAction(b.id, 'ACCEPTED')}
                    className="px-4 py-2 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs flex items-center gap-1 transition-colors shadow-sm"
                  >
                    <span className="material-symbols-outlined text-sm">check</span>
                    <span>Accept Booking</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => handleBookingAction(b.id, 'REJECTED')}
                    className="px-4 py-2 rounded-xl bg-surface-container-high hover:bg-rose-100 text-rose-700 font-bold text-xs flex items-center gap-1 transition-colors"
                  >
                    <span className="material-symbols-outlined text-sm">close</span>
                    <span>Decline</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Fleet Inventory Table */}
      <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
        <div className="flex items-center justify-between mb-4 pb-3 border-b border-outline-variant/20">
          <h3 className="font-headline-sm text-base font-bold text-on-surface">
            Fleet Inventory &amp; Live Availability Status
          </h3>
          <span className="text-xs text-on-surface-variant font-medium">
            Total {fleet.length} Units Registered
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-outline-variant/30 text-on-surface-variant uppercase tracking-wider font-bold">
                <th className="pb-3 pr-4">Machinery &amp; Unit</th>
                <th className="pb-3 pr-4">Category</th>
                <th className="pb-3 pr-4">Serial / VIN</th>
                <th className="pb-3 pr-4">Dispatch Status</th>
                <th className="pb-3 pr-4">Telematics &amp; Hours</th>
                <th className="pb-3 pr-4">Daily Rate</th>
                <th className="pb-3 pr-4">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/20">
              {fleet.map((item) => (
                <tr key={item.id} className="hover:bg-surface-container-low transition-colors">
                  <td className="py-3.5 pr-4 font-bold text-on-surface">
                    <Link to={`/equipment/${item.id}`} className="hover:text-primary transition-colors">
                      {item.title}
                    </Link>
                    <div className="text-[10px] text-on-surface-variant font-normal">
                      {item.year} • {item.horsepower ? `${item.horsepower} HP` : 'Implement'}
                    </div>
                  </td>
                  <td className="py-3.5 pr-4 text-on-surface-variant font-medium">{item.category}</td>
                  <td className="py-3.5 pr-4 font-mono text-[11px] text-on-surface-variant">
                    {item.serialVin || 'N/A'}
                  </td>
                  <td className="py-3.5 pr-4">
                    <StatusBadge status={item.status} />
                  </td>
                  <td className="py-3.5 pr-4 text-on-surface-variant">
                    <div className="font-semibold text-on-surface">{item.engineHours || 0} hrs</div>
                    <div className="text-[10px] text-secondary flex items-center gap-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-secondary inline-block"></span>
                      GPS Active
                    </div>
                  </td>
                  <td className="py-3.5 pr-4 font-bold text-primary">
                    ${Number(item.dailyRate).toLocaleString()} / day
                  </td>
                  <td className="py-3.5 pr-4">
                    <Link
                      to={`/equipment/${item.id}`}
                      className="px-3 py-1.5 rounded-lg bg-surface-container-high hover:bg-primary hover:text-on-primary text-xs font-semibold transition-colors"
                    >
                      View Specs
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default OwnerDashboardPage;
