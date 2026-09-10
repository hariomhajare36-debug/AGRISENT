import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import { bookingService } from '../../services/bookingService';
import { reviewService } from '../../services/reviewService';
import { useAuth } from '../../hooks/useAuth';
import StatusBadge from '../../components/common/StatusBadge';
import TelemetryBar from '../../components/common/TelemetryBar';
import Modal from '../../components/common/Modal';

export const EquipmentDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user, isAuthenticated } = useAuth();

  const [equipment, setEquipment] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);

  // Booking Form State
  const [bookingMode, setBookingMode] = useState('rent'); // 'rent' or 'buy'
  const [startDate, setStartDate] = useState(new Date().toISOString().split('T')[0]);
  const [endDate, setEndDate] = useState(
    new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  );
  const [deliveryMethod, setDeliveryMethod] = useState('DELIVERY');
  const [operatorIncluded, setOperatorIncluded] = useState(false);
  const [damageWaiverIncluded, setDamageWaiverIncluded] = useState(true);
  const [specialInstructions, setSpecialInstructions] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [bookingSuccessModal, setBookingSuccessModal] = useState(false);
  const [newBookingId, setNewBookingId] = useState(null);
  const [bookingError, setBookingError] = useState('');

  // Selected Image state
  const [selectedImgIndex, setSelectedImgIndex] = useState(0);

  useEffect(() => {
    const loadDetails = async () => {
      setLoading(true);
      try {
        const eqData = await equipmentService.getById(id);
        setEquipment(eqData);

        const revData = await reviewService.getByEquipmentId(id);
        setReviews(revData || []);
      } catch (err) {
        console.error('Failed to load equipment details:', err);
      } finally {
        setLoading(false);
      }
    };
    loadDetails();
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-16 text-center">
        <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
        <p className="text-on-surface-variant">Loading heavy machinery specifications &amp; live telematics...</p>
      </div>
    );
  }

  if (!equipment) {
    return (
      <div className="max-w-md mx-auto my-20 p-8 bg-surface-container-lowest rounded-2xl text-center border border-outline-variant/50">
        <h2 className="text-xl font-bold text-on-surface mb-2">Equipment Not Found</h2>
        <p className="text-sm text-on-surface-variant mb-6">The requested equipment listing could not be found.</p>
        <Link to="/equipment" className="px-5 py-2.5 rounded-xl bg-primary text-on-primary font-bold text-sm">
          Return to Catalog
        </Link>
      </div>
    );
  }

  // Calculate rental pricing
  const start = new Date(startDate);
  const end = new Date(endDate);
  const diffTime = Math.max(0, end - start);
  const totalDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
  const dailyRate = Number(equipment.dailyRate) || 0;
  const equipmentSubtotal = dailyRate * totalDays;
  const deliveryFee = deliveryMethod === 'DELIVERY' ? 450.0 : 0.0;
  const insuranceFee = damageWaiverIncluded ? 60.0 * totalDays : 0.0;
  const operatorFee = operatorIncluded ? 45.0 * 8 * totalDays : 0.0;
  const platformEscrowFee = 150.0;
  const totalAmount = equipmentSubtotal + deliveryFee + insuranceFee + operatorFee + platformEscrowFee;

  const handleBookingSubmit = async (e) => {
    e.preventDefault();
    if (!isAuthenticated) {
      navigate(`/login?redirect=${encodeURIComponent(window.location.pathname)}`);
      return;
    }

    setIsSubmitting(true);
    setBookingError('');
    try {
      const payload = {
        equipmentId: equipment.id,
        startDate: `${startDate}T08:00:00`,
        endDate: `${endDate}T18:00:00`,
        deliveryMethod,
        deliveryAddress: deliveryMethod === 'DELIVERY' ? `${equipment.city}, ${equipment.state} (Field Site)` : '',
        operatorIncluded,
        damageWaiverIncluded,
        specialInstructions,
      };

      const result = await bookingService.create(payload);
      setNewBookingId(result.id);
      setBookingSuccessModal(true);
    } catch (err) {
      console.error('Booking submission failed:', err);
      setBookingError(err.response?.data?.message || 'Failed to submit booking. Please check dates and try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const imagesList = equipment.images ? equipment.images.split(',') : [
    'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80',
    'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80'
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Breadcrumb */}
      <nav className="flex items-center gap-2 text-xs text-on-surface-variant mb-6">
        <Link to="/" className="hover:text-primary">Home</Link>
        <span>/</span>
        <Link to="/equipment" className="hover:text-primary">Fleet Catalog</Link>
        <span>/</span>
        <span className="text-on-surface font-semibold">{equipment.title}</span>
      </nav>

      {/* Header Section */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4 mb-6 pb-6 border-b border-outline-variant/30">
        <div>
          <div className="flex items-center gap-2 mb-2">
            <StatusBadge status={equipment.status} />
            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-primary/10 text-primary border border-primary/20">
              <span className="material-symbols-outlined text-xs">verified</span>
              AgriRent Certified
            </span>
            <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-surface-container-high text-on-surface">
              <span className="material-symbols-outlined text-xs text-secondary">satellite_alt</span>
              GPS Monitored
            </span>
          </div>
          <h1 className="font-headline-xl text-3xl sm:text-4xl font-extrabold text-on-surface">
            {equipment.title}
          </h1>
          <p className="text-sm text-on-surface-variant flex items-center gap-2 mt-1">
            <span className="material-symbols-outlined text-sm text-primary">location_on</span>
            <span>{equipment.locationAddress ? `${equipment.locationAddress}, ` : ''}{equipment.city}, {equipment.state} {equipment.zipCode}</span>
            <span>•</span>
            <span>Serial: {equipment.serialVin || 'N/A'}</span>
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => alert('Link copied to clipboard!')}
            className="px-4 py-2 rounded-xl bg-surface-container-low hover:bg-surface-container-high border border-outline-variant/50 text-xs font-bold text-on-surface flex items-center gap-1.5 transition-colors"
          >
            <span className="material-symbols-outlined text-sm">share</span>
            <span>Share</span>
          </button>
          <button
            type="button"
            className="px-4 py-2 rounded-xl bg-surface-container-low hover:bg-surface-container-high border border-outline-variant/50 text-xs font-bold text-on-surface flex items-center gap-1.5 transition-colors"
          >
            <span className="material-symbols-outlined text-sm text-rose-500">favorite</span>
            <span>Save</span>
          </button>
        </div>
      </div>

      {/* Main Content Grid: Left 2 Cols (Details/Gallery), Right 1 Col (Booking Card) */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left 2 Cols */}
        <div className="lg:col-span-2 space-y-8">
          {/* Gallery View */}
          <div className="space-y-3">
            <div className="aspect-[16/10] rounded-2xl overflow-hidden bg-surface-container-high border border-outline-variant/40 shadow-sm">
              <img
                src={imagesList[selectedImgIndex] || imagesList[0]}
                alt={equipment.title}
                className="w-full h-full object-cover"
              />
            </div>
            {imagesList.length > 1 && (
              <div className="flex items-center gap-3 overflow-x-auto pb-2">
                {imagesList.map((img, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => setSelectedImgIndex(idx)}
                    className={`w-24 h-16 rounded-xl overflow-hidden border-2 transition-all flex-shrink-0 ${
                      selectedImgIndex === idx ? 'border-primary shadow-md' : 'border-transparent opacity-70 hover:opacity-100'
                    }`}
                  >
                    <img src={img} alt="Thumbnail" className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Machine Health Snapshot / Telemetry */}
          {equipment.telemetry && (
            <div>
              <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-3">
                Machine Health &amp; Telematics Snapshot
              </h3>
              <TelemetryBar telemetry={equipment.telemetry} />
            </div>
          )}

          {/* Narrative / Field Capability */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
            <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-3">
              Field Capability &amp; Equipment Overview
            </h3>
            <p className="text-sm text-on-surface-variant leading-relaxed whitespace-pre-line">
              {equipment.description ||
                'Factory-equipped heavy machinery serviced according to strict OEM preventative maintenance schedules. High-efficiency powertrain calibrated for minimal field compaction, precise row tracking, and continuous multi-acre endurance.'}
            </p>
          </div>

          {/* Technical Specifications Table */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
            <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-4">
              Factory Technical Specifications
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Rated Horsepower</span>
                <span className="font-bold text-on-surface">{equipment.horsepower ? `${equipment.horsepower} HP` : 'N/A'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Meter Engine Hours</span>
                <span className="font-bold text-on-surface">{equipment.engineHours || 0} hrs</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Transmission</span>
                <span className="font-bold text-on-surface">{equipment.transmission || 'PowerShift / Auto'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Drive Configuration</span>
                <span className="font-bold text-on-surface">{equipment.driveType || '4WD'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Hydraulic Output</span>
                <span className="font-bold text-on-surface">{equipment.hydraulicFlowGpm ? `${equipment.hydraulicFlowGpm} GPM` : 'Standard Flow'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">PTO Speed &amp; Shaft</span>
                <span className="font-bold text-on-surface">{equipment.ptoSpeed || '1000 RPM (1-3/4 in)'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Hitch Category</span>
                <span className="font-bold text-on-surface">{equipment.hitchCategory || 'Category 3/4N'}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-outline-variant/20">
                <span className="text-on-surface-variant font-medium">Fuel Type</span>
                <span className="font-bold text-on-surface">{equipment.fuelType || 'Ultra-Low Sulfur Diesel'}</span>
              </div>
            </div>
          </div>

          {/* Fleet Owner Profile */}
          <div className="bg-surface-container-low rounded-2xl p-6 border border-outline-variant/40 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-2xl bg-primary flex items-center justify-center text-on-primary font-bold text-xl flex-shrink-0">
                {equipment.owner?.fullName ? equipment.owner.fullName[0] : 'M'}
              </div>
              <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-secondary">Verified Fleet Provider</span>
                <h4 className="font-headline-sm text-base font-bold text-on-surface">
                  {equipment.owner?.farmName || equipment.owner?.fullName || 'Cedar Valley Farms & Agri-Fleet'}
                </h4>
                <p className="text-xs text-on-surface-variant">
                  {equipment.owner?.city || 'Cedar Rapids'}, {equipment.owner?.state || 'IA'} • 98% On-Time Delivery Rate
                </p>
              </div>
            </div>
            <button
              type="button"
              onClick={() => alert(`Direct message sent to owner: ${equipment.owner?.email || 'owner@cedarvalley.com'}`)}
              className="px-4 py-2 rounded-xl bg-surface-container-lowest hover:bg-surface-container-high border border-outline-variant/50 text-xs font-bold text-on-surface flex items-center gap-1.5 transition-colors"
            >
              <span className="material-symbols-outlined text-sm">mail</span>
              <span>Message Fleet Owner</span>
            </button>
          </div>

          {/* Customer Reviews Section */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm">
            <div className="flex items-center justify-between mb-6 pb-4 border-b border-outline-variant/20">
              <div>
                <h3 className="font-headline-sm text-lg font-bold text-on-surface">Verified Customer Feedback</h3>
                <p className="text-xs text-on-surface-variant">Real field reports from verified farm operators</p>
              </div>
              <div className="flex items-center gap-1 text-amber-500 font-bold text-sm">
                <span className="material-symbols-outlined text-lg fill-current">star</span>
                <span>4.9 / 5.0</span>
              </div>
            </div>

            {reviews.length === 0 ? (
              <p className="text-xs text-on-surface-variant italic">No reviews logged yet. Be the first to field test this machine!</p>
            ) : (
              <div className="space-y-4">
                {reviews.map((rev) => (
                  <div key={rev.id} className="p-4 rounded-xl bg-surface-container-low border border-outline-variant/30 space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-xs text-on-surface">{rev.reviewerName || 'David Miller'}</span>
                        <span className="px-2 py-0.5 rounded-full text-[10px] bg-emerald-100 text-emerald-800 font-semibold">
                          Verified Renter
                        </span>
                      </div>
                      <div className="flex items-center text-amber-500 text-xs">
                        {[...Array(rev.rating || 5)].map((_, i) => (
                          <span key={i} className="material-symbols-outlined text-sm fill-current">star</span>
                        ))}
                      </div>
                    </div>
                    <p className="text-xs text-on-surface-variant leading-normal">{rev.comment}</p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Right 1 Col: Sticky Booking & Rates Card */}
        <div className="lg:col-span-1">
          <div className="sticky top-28 bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/50 shadow-xl space-y-6">
            {/* Rent vs Buy Tabs */}
            <div className="grid grid-cols-2 p-1 bg-surface-container-high rounded-xl">
              <button
                type="button"
                onClick={() => setBookingMode('rent')}
                className={`py-2 text-xs font-bold rounded-lg transition-all ${
                  bookingMode === 'rent'
                    ? 'bg-primary text-on-primary shadow-sm'
                    : 'text-on-surface-variant hover:text-on-surface'
                }`}
              >
                Rent Machine
              </button>
              <button
                type="button"
                onClick={() => setBookingMode('buy')}
                className={`py-2 text-xs font-bold rounded-lg transition-all ${
                  bookingMode === 'buy'
                    ? 'bg-primary text-on-primary shadow-sm'
                    : 'text-on-surface-variant hover:text-on-surface'
                }`}
              >
                Buy (${equipment.purchasePrice ? Number(equipment.purchasePrice).toLocaleString() : 'Inquire'})
              </button>
            </div>

            {/* Rate Heading */}
            <div className="pb-4 border-b border-outline-variant/30">
              <div className="flex items-baseline gap-2">
                <span className="font-metric-val text-3xl font-extrabold text-primary">
                  ${Number(equipment.dailyRate).toLocaleString()}
                </span>
                <span className="text-xs text-on-surface-variant font-medium">/ day</span>
              </div>
              <p className="text-[11px] text-on-surface-variant mt-1">
                Weekly: ${equipment.weeklyRate ? Number(equipment.weeklyRate).toLocaleString() : (dailyRate * 6).toLocaleString()} • Security Deposit: ${Number(equipment.securityDeposit || 2000).toLocaleString()} (Escrow Protected)
              </p>
            </div>

            {/* Booking Form */}
            <form onSubmit={handleBookingSubmit} className="space-y-4">
              {bookingError && (
                <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700">
                  {bookingError}
                </div>
              )}

              {/* Dates */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[11px] font-bold text-on-surface uppercase tracking-wider mb-1">
                    Start Date
                  </label>
                  <input
                    type="date"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                    className="w-full h-10 px-2.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                    required
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-bold text-on-surface uppercase tracking-wider mb-1">
                    End Date
                  </label>
                  <input
                    type="date"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                    className="w-full h-10 px-2.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                    required
                  />
                </div>
              </div>

              {/* Delivery Option */}
              <div>
                <label className="block text-[11px] font-bold text-on-surface uppercase tracking-wider mb-2">
                  Delivery Logistics
                </label>
                <div className="space-y-2">
                  <label className={`flex items-center justify-between p-3 rounded-xl border text-xs cursor-pointer transition-colors ${
                    deliveryMethod === 'DELIVERY' ? 'border-primary bg-primary/5' : 'border-outline-variant/40 bg-surface-container-low'
                  }`}>
                    <div className="flex items-center gap-2">
                      <input
                        type="radio"
                        name="deliveryMethod"
                        checked={deliveryMethod === 'DELIVERY'}
                        onChange={() => setDeliveryMethod('DELIVERY')}
                        className="accent-primary"
                      />
                      <span className="font-semibold text-on-surface">Direct Field Flatbed Delivery</span>
                    </div>
                    <span className="font-bold text-primary">+$450</span>
                  </label>

                  <label className={`flex items-center justify-between p-3 rounded-xl border text-xs cursor-pointer transition-colors ${
                    deliveryMethod === 'PICKUP' ? 'border-primary bg-primary/5' : 'border-outline-variant/40 bg-surface-container-low'
                  }`}>
                    <div className="flex items-center gap-2">
                      <input
                        type="radio"
                        name="deliveryMethod"
                        checked={deliveryMethod === 'PICKUP'}
                        onChange={() => setDeliveryMethod('PICKUP')}
                        className="accent-primary"
                      />
                      <span className="font-semibold text-on-surface">Owner Yard Pickup</span>
                    </div>
                    <span className="font-bold text-secondary">Free</span>
                  </label>
                </div>
              </div>

              {/* Addons */}
              <div className="space-y-2 pt-2">
                <label className="flex items-center gap-2 text-xs text-on-surface cursor-pointer">
                  <input
                    type="checkbox"
                    checked={damageWaiverIncluded}
                    onChange={(e) => setDamageWaiverIncluded(e.target.checked)}
                    className="rounded accent-primary w-4 h-4"
                  />
                  <span>AgriRent Full Damage Waiver &amp; Theft Protection (+$60/day)</span>
                </label>

                <label className="flex items-center gap-2 text-xs text-on-surface cursor-pointer">
                  <input
                    type="checkbox"
                    checked={operatorIncluded}
                    onChange={(e) => setOperatorIncluded(e.target.checked)}
                    className="rounded accent-primary w-4 h-4"
                  />
                  <span>Include Certified Equipment Operator (+$45/hr)</span>
                </label>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-[11px] font-bold text-on-surface uppercase tracking-wider mb-1">
                  Field Gate / Delivery Instructions
                </label>
                <textarea
                  value={specialInstructions}
                  onChange={(e) => setSpecialInstructions(e.target.value)}
                  placeholder="Gate code, farm road access details, or soil moisture..."
                  rows={2}
                  className="w-full p-2.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              {/* Cost Calculation Summary */}
              <div className="p-4 rounded-xl bg-surface-container-low space-y-2 text-xs border border-outline-variant/30">
                <div className="flex justify-between text-on-surface-variant">
                  <span>${dailyRate} × {totalDays} Day{totalDays > 1 ? 's' : ''}</span>
                  <span className="font-semibold text-on-surface">${equipmentSubtotal.toLocaleString()}</span>
                </div>
                {deliveryFee > 0 && (
                  <div className="flex justify-between text-on-surface-variant">
                    <span>Flatbed Freight Delivery</span>
                    <span className="font-semibold text-on-surface">${deliveryFee.toFixed(2)}</span>
                  </div>
                )}
                {insuranceFee > 0 && (
                  <div className="flex justify-between text-on-surface-variant">
                    <span>Damage Waiver Protection</span>
                    <span className="font-semibold text-on-surface">${insuranceFee.toFixed(2)}</span>
                  </div>
                )}
                {operatorFee > 0 && (
                  <div className="flex justify-between text-on-surface-variant">
                    <span>Certified Operator Labor</span>
                    <span className="font-semibold text-on-surface">${operatorFee.toFixed(2)}</span>
                  </div>
                )}
                <div className="flex justify-between text-on-surface-variant">
                  <span>Platform Escrow Clearing Fee</span>
                  <span className="font-semibold text-on-surface">${platformEscrowFee.toFixed(2)}</span>
                </div>
                <div className="border-t border-outline-variant/30 pt-2 flex justify-between text-sm font-bold text-on-surface">
                  <span>Total Escrow Authorization</span>
                  <span className="text-primary text-base font-extrabold">${totalAmount.toLocaleString()}</span>
                </div>
              </div>

              {/* Submit CTA */}
              <button
                type="submit"
                disabled={isSubmitting}
                className="w-full h-12 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-sm flex items-center justify-center gap-2 transition-all shadow-md disabled:opacity-50"
              >
                <span className="material-symbols-outlined text-lg">lock</span>
                <span>{isSubmitting ? 'Securing Booking...' : 'Proceed to Secure Booking'}</span>
              </button>

              <p className="text-[11px] text-center text-on-surface-variant flex items-center justify-center gap-1">
                <span className="material-symbols-outlined text-xs text-secondary">verified_user</span>
                Payment is held in Escrow and released only after field inspection
              </p>
            </form>
          </div>
        </div>
      </div>

      {/* Booking Confirmation Modal */}
      <Modal
        isOpen={bookingSuccessModal}
        onClose={() => {
          setBookingSuccessModal(false);
          navigate('/farmer/dashboard');
        }}
        title="Booking Request Authorized"
      >
        <div className="text-center space-y-4">
          <div className="w-14 h-14 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto">
            <span className="material-symbols-outlined text-3xl">check_circle</span>
          </div>
          <h4 className="font-headline-sm text-lg font-bold text-on-surface">
            Booking Request #{newBookingId} Transmitted!
          </h4>
          <p className="text-xs text-on-surface-variant leading-relaxed">
            Your rental reservation for <strong className="text-on-surface">{equipment.title}</strong> has been created and escrow funds are locked. The fleet owner has received your request and will confirm dispatch shortly.
          </p>
          <div className="p-3 bg-surface-container-low rounded-xl text-xs text-left text-on-surface-variant space-y-1">
            <div><strong>Dates:</strong> {startDate} to {endDate} ({totalDays} days)</div>
            <div><strong>Total Escrow:</strong> ${totalAmount.toLocaleString()}</div>
            <div><strong>Logistics:</strong> {deliveryMethod === 'DELIVERY' ? 'Flatbed Field Delivery' : 'Customer Yard Pickup'}</div>
          </div>
          <button
            type="button"
            onClick={() => {
              setBookingSuccessModal(false);
              navigate('/farmer/dashboard');
            }}
            className="w-full py-3 rounded-xl bg-primary text-on-primary font-bold text-xs hover:bg-primary-container transition-colors"
          >
            View in Farmer Dashboard
          </button>
        </div>
      </Modal>
    </div>
  );
};

export default EquipmentDetailPage;
