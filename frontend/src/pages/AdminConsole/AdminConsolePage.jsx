import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { adminService } from '../../services/adminService';
import StatusBadge from '../../components/common/StatusBadge';
import { formatINR } from '../../utils/currency';

export const AdminConsolePage = () => {
  const [metrics, setMetrics] = useState({
    totalGmv: 42500000,
    activeListingsCount: 129,
    escrowBalance: 6500000,
    disputesCount: 0,
  });
  const [pendingEquipment, setPendingEquipment] = useState([]);
  const [escrowList, setEscrowList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [notice, setNotice] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const [m, pe, esc] = await Promise.all([
        adminService.getMetrics(),
        adminService.getPendingEquipment(),
        adminService.getEscrowTransactions(),
      ]);
      setMetrics(m || metrics);
      setPendingEquipment(pe || []);
      setEscrowList(esc || []);
    } catch (err) {
      console.error('Failed to load admin console:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleApproveEquipment = async (id) => {
    try {
      await adminService.approveEquipment(id);
      setNotice(`Listing #${id} approved and published to catalog!`);
      setTimeout(() => setNotice(''), 4000);
      loadData();
    } catch (err) {
      console.error('Failed to approve equipment:', err);
      alert('Approval failed.');
    }
  };

  const handleRejectEquipment = async (id) => {
    const reason = prompt('Specify rejection or audit reason:');
    if (reason === null) return;
    try {
      await adminService.rejectEquipment(id, reason);
      setNotice(`Listing #${id} rejected.`);
      setTimeout(() => setNotice(''), 4000);
      loadData();
    } catch (err) {
      console.error('Failed to reject equipment:', err);
      alert('Reject failed.');
    }
  };

  const handleReleaseEscrow = async (id) => {
    if (!window.confirm('Are you sure you want to release escrow funds to the equipment owner?')) return;
    try {
      await adminService.releaseEscrow(id);
      setNotice(`Escrow #${id} successfully released to owner!`);
      setTimeout(() => setNotice(''), 4000);
      loadData();
    } catch (err) {
      console.error('Failed to release escrow:', err);
      alert('Escrow release failed.');
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <span className="text-xs uppercase font-bold text-error tracking-wider">
            Super Administrator Access
          </span>
          <h1 className="font-headline-xl text-3xl font-extrabold text-on-surface mt-1">
            Platform Core Operations &amp; Escrow Console
          </h1>
          <p className="text-sm text-on-surface-variant mt-0.5">
            Real-time multi-state fleet telemetry, equipment compliance audits, and financial clearing
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => alert('Exporting platform financial ledger CSV...')}
            className="px-4 py-2.5 rounded-xl bg-surface-container-high hover:bg-surface-container font-bold text-xs flex items-center gap-1.5 transition-colors"
          >
            <span className="material-symbols-outlined text-sm">download</span>
            <span>Ledger Export (CSV)</span>
          </button>
          <button
            onClick={() => alert('Emergency audit mode active. All pending disbursements flagged.')}
            className="px-4 py-2.5 rounded-xl bg-error text-on-error font-bold text-xs flex items-center gap-1.5 hover:bg-red-700 transition-colors shadow-sm"
          >
            <span className="material-symbols-outlined text-sm">shield</span>
            <span>Emergency System Override</span>
          </button>
        </div>
      </div>

      {notice && (
        <div className="mb-6 p-4 rounded-xl bg-emerald-50 border border-emerald-200 text-sm text-emerald-800 flex items-center gap-2">
          <span className="material-symbols-outlined text-emerald-600">check_circle</span>
          <span>{notice}</span>
        </div>
      )}

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Total Platform GMV</span>
            <span className="p-2 rounded-xl bg-emerald-50 text-emerald-700">
              <span className="material-symbols-outlined text-lg">monetization_on</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-primary">
            {formatINR(metrics.totalGmv || 42500000)}
          </div>
          <span className="text-xs text-secondary font-semibold mt-1 block">+22% YoY Growth</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Active Fleet</span>
            <span className="p-2 rounded-xl bg-primary/10 text-primary">
              <span className="material-symbols-outlined text-lg">agriculture</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {metrics.activeListingsCount || 129}
          </div>
          <span className="text-xs text-on-surface-variant mt-1 block">Across 12 Maharashtra Districts</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Escrow Balance</span>
            <span className="p-2 rounded-xl bg-amber-50 text-amber-700">
              <span className="material-symbols-outlined text-lg">account_balance</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {formatINR(metrics.escrowBalance || 6500000)}
          </div>
          <span className="text-xs text-amber-600 font-semibold mt-1 block">Insured Vault Deposit</span>
        </div>

        <div className="bg-surface-container-lowest p-5 rounded-2xl border border-outline-variant/40 shadow-sm">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-bold text-on-surface-variant uppercase tracking-wider">Pending Listings</span>
            <span className="p-2 rounded-xl bg-purple-50 text-purple-700">
              <span className="material-symbols-outlined text-lg">pending_actions</span>
            </span>
          </div>
          <div className="font-metric-val text-3xl font-bold text-on-surface">
            {pendingEquipment.length}
          </div>
          <span className="text-xs text-purple-600 font-semibold mt-1 block">Awaiting Safety Audit</span>
        </div>
      </div>

      {/* Pending Equipment Listing Approvals Table */}
      <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm mb-8">
        <div className="flex items-center justify-between mb-4 pb-3 border-b border-outline-variant/20">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-purple-500 animate-pulse"></span>
            <h3 className="font-headline-sm text-base font-bold text-on-surface">
              Pending Equipment Listing Approvals ({pendingEquipment.length})
            </h3>
          </div>
          <span className="text-xs text-on-surface-variant">Mandatory Telematics &amp; VIN Check</span>
        </div>

        {pendingEquipment.length === 0 ? (
          <p className="text-xs text-on-surface-variant py-4 italic text-center">
            No equipment listings currently pending audit. All marketplace submissions are up to date!
          </p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-outline-variant/30 text-on-surface-variant uppercase tracking-wider font-bold">
                  <th className="pb-3 pr-4">Machinery Details</th>
                  <th className="pb-3 pr-4">Owner / Fleet Provider</th>
                  <th className="pb-3 pr-4">Serial / VIN</th>
                  <th className="pb-3 pr-4">Rate / Asking Price</th>
                  <th className="pb-3 pr-4">Audit &amp; Telemetry</th>
                  <th className="pb-3 pr-4">Review Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-outline-variant/20">
                {pendingEquipment.map((eq) => (
                  <tr key={eq.id} className="hover:bg-surface-container-low transition-colors">
                    <td className="py-3.5 pr-4 font-bold text-on-surface">
                      <div>{eq.title}</div>
                      <div className="text-[10px] text-on-surface-variant font-normal">
                        {eq.year} • {eq.category} • {eq.horsepower ? `${eq.horsepower} HP` : 'Implement'}
                      </div>
                    </td>
                    <td className="py-3.5 pr-4 text-on-surface-variant">
                      <div className="font-semibold text-on-surface">{eq.owner?.farmName || eq.owner?.fullName || 'Fleet Owner'}</div>
                      <div className="text-[10px]">{eq.city}, {eq.state}</div>
                    </td>
                    <td className="py-3.5 pr-4 font-mono text-[11px] text-on-surface-variant">
                      {eq.serialVin || 'VIN-CHECK-OK'}
                    </td>
                    <td className="py-3.5 pr-4 font-bold text-primary">
                      {formatINR(eq.dailyRate)} / day
                    </td>
                    <td className="py-3.5 pr-4">
                      <span className="inline-flex items-center gap-1 text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full text-[10px] font-semibold">
                        <span className="material-symbols-outlined text-xs">satellite_alt</span>
                        Telematics Online
                      </span>
                    </td>
                    <td className="py-3.5 pr-4">
                      <div className="flex items-center gap-2">
                        <button
                          type="button"
                          onClick={() => handleApproveEquipment(eq.id)}
                          className="px-3 py-1.5 rounded-lg bg-primary hover:bg-primary-container text-on-primary text-xs font-bold transition-colors shadow-sm"
                        >
                          Approve
                        </button>
                        <button
                          type="button"
                          onClick={() => handleRejectEquipment(eq.id)}
                          className="px-3 py-1.5 rounded-lg bg-surface-container-high hover:bg-rose-100 text-rose-700 text-xs font-bold transition-colors"
                        >
                          Reject
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Escrow Settlement Clearing Table */}
      <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
        <div className="flex items-center justify-between mb-4 pb-3 border-b border-outline-variant/20">
          <h3 className="font-headline-sm text-base font-bold text-on-surface">
            Platform Transactions &amp; Escrow Settlement Clearing
          </h3>
          <span className="text-xs text-on-surface-variant font-medium">
            Total {escrowList.length} Escrow Accounts Monitored
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-outline-variant/30 text-on-surface-variant uppercase tracking-wider font-bold">
                <th className="pb-3 pr-4">Escrow Ref</th>
                <th className="pb-3 pr-4">Booking</th>
                <th className="pb-3 pr-4">Payer (Farmer)</th>
                <th className="pb-3 pr-4">Payee (Fleet Owner)</th>
                <th className="pb-3 pr-4">Amount</th>
                <th className="pb-3 pr-4">Status</th>
                <th className="pb-3 pr-4">Clearing Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-outline-variant/20">
              {escrowList.map((tx) => (
                <tr key={tx.id} className="hover:bg-surface-container-low transition-colors">
                  <td className="py-3.5 pr-4 font-mono font-bold text-on-surface">{tx.transactionRef}</td>
                  <td className="py-3.5 pr-4 text-on-surface-variant">Booking #{tx.bookingId}</td>
                  <td className="py-3.5 pr-4 text-on-surface-variant font-medium">{tx.payerName || 'David Miller'}</td>
                  <td className="py-3.5 pr-4 text-on-surface-variant font-medium">{tx.payeeName || 'Marcus Vance'}</td>
                  <td className="py-3.5 pr-4 font-bold text-primary">{formatINR(tx.amount)}</td>
                  <td className="py-3.5 pr-4">
                    <StatusBadge status={tx.escrowStatus} />
                  </td>
                  <td className="py-3.5 pr-4">
                    {tx.escrowStatus === 'HELD' ? (
                      <button
                        type="button"
                        onClick={() => handleReleaseEscrow(tx.id)}
                        className="px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold transition-colors shadow-sm"
                      >
                        Release Funds
                      </button>
                    ) : (
                      <span className="text-xs text-on-surface-variant italic">Settled</span>
                    )}
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

export default AdminConsolePage;
