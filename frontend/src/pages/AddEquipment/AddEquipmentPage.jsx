import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import { useAuth } from '../../hooks/useAuth';
import EquipmentCard from '../../components/common/EquipmentCard';
import { EQUIPMENT_CATEGORIES } from '../../constants/categories';

export const AddEquipmentPage = () => {
  const navigate = useNavigate();
  const { user } = useAuth();

  const [formData, setFormData] = useState({
    title: '',
    make: '',
    model: '',
    year: 2023,
    category: 'TRACTORS',
    serialVin: '',
    horsepower: 55,
    engineHours: 120,
    driveType: '2WD',
    fuelType: 'DIESEL',
    transmission: '8 Forward + 2 Reverse',
    hydraulicFlowGpm: 45.0,
    ptoSpeed: '540 RPM',
    hitchCategory: 'Category II',
    description: '',
    images: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80',
    dailyRate: 3500,
    weeklyRate: 21000,
    monthlyRate: 75000,
    securityDeposit: 15000,
    purchasePrice: 850000,
    isForRent: true,
    isForSale: false,
    city: 'Pune',
    state: 'Maharashtra',
    zipCode: '411001',
    locationAddress: 'Pune Agricultural Market, Haveli',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setErrorMessage('');
    try {
      const payload = {
        ...formData,
        year: Number(formData.year),
        horsepower: Number(formData.horsepower),
        engineHours: Number(formData.engineHours),
        hydraulicFlowGpm: Number(formData.hydraulicFlowGpm),
        dailyRate: Number(formData.dailyRate),
        weeklyRate: formData.weeklyRate ? Number(formData.weeklyRate) : null,
        monthlyRate: formData.monthlyRate ? Number(formData.monthlyRate) : null,
        securityDeposit: Number(formData.securityDeposit),
        purchasePrice: formData.isForSale && formData.purchasePrice ? Number(formData.purchasePrice) : null,
      };

      const result = await equipmentService.create(payload);
      navigate(`/equipment/${result.id}`);
    } catch (err) {
      console.error('Failed to list equipment:', err);
      setErrorMessage(err.response?.data?.message || 'Error creating equipment listing. Please verify all required fields.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8">
        <span className="text-xs uppercase font-bold text-secondary tracking-wider">Fleet Management &amp; Listings</span>
        <h1 className="font-headline-xl text-3xl font-extrabold text-on-surface mt-1">
          List Your Agricultural Equipment for Rent or Sale
        </h1>
        <p className="text-sm text-on-surface-variant mt-1">
          Add heavy machinery to the AgriRent marketplace. Listings undergo instant telemetry verification and escrow qualification.
        </p>
      </div>

      {errorMessage && (
        <div className="mb-6 p-4 rounded-xl bg-rose-50 border border-rose-200 text-sm text-rose-700">
          {errorMessage}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left 2 Cols: Form Sections */}
        <form onSubmit={handleSubmit} className="lg:col-span-2 space-y-6">
          {/* 1. Identity & Intent */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm space-y-4">
            <h3 className="font-headline-sm text-base font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">feed</span>
              <span>1. Listing Intent &amp; Machinery Identity</span>
            </h3>

            {/* Listing Type Checkboxes */}
            <div className="flex items-center gap-6 pt-1">
              <label className="flex items-center gap-2 text-xs font-semibold text-on-surface cursor-pointer">
                <input
                  type="checkbox"
                  name="isForRent"
                  checked={formData.isForRent}
                  onChange={handleChange}
                  className="rounded accent-primary w-4 h-4"
                />
                <span>Available for Field Rental</span>
              </label>

              <label className="flex items-center gap-2 text-xs font-semibold text-on-surface cursor-pointer">
                <input
                  type="checkbox"
                  name="isForSale"
                  checked={formData.isForSale}
                  onChange={handleChange}
                  className="rounded accent-primary w-4 h-4"
                />
                <span>Available for Outright Purchase</span>
              </label>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="sm:col-span-2">
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Listing Title *
                </label>
                <input
                  type="text"
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  placeholder="e.g. 2023 John Deere 8R 410 Row Crop Tractor"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Manufacturer / Make *
                </label>
                <input
                  type="text"
                  name="make"
                  value={formData.make}
                  onChange={handleChange}
                  placeholder="e.g. John Deere, Case IH, Kubota"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Model Identifier *
                </label>
                <input
                  type="text"
                  name="model"
                  value={formData.model}
                  onChange={handleChange}
                  placeholder="e.g. 8R 410, CR8.90, 3600"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Model Year *
                </label>
                <input
                  type="number"
                  name="year"
                  value={formData.year}
                  onChange={handleChange}
                  min="1990"
                  max="2026"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Machinery Category *
                </label>
                <select
                  name="category"
                  value={formData.category}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40 cursor-pointer"
                >
                  {EQUIPMENT_CATEGORIES.filter((c) => c.id !== 'all').map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.label}
                    </option>
                  ))}
                </select>
              </div>

              <div className="sm:col-span-2">
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Serial Number / VIN (For Telematics Audit)
                </label>
                <input
                  type="text"
                  name="serialVin"
                  value={formData.serialVin}
                  onChange={handleChange}
                  placeholder="e.g. 1RW8410RLPC041289"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>
            </div>
          </div>

          {/* 2. Technical Specs */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm space-y-4">
            <h3 className="font-headline-sm text-base font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">tune</span>
              <span>2. Technical Specifications &amp; Field Systems</span>
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Rated Horsepower
                </label>
                <input
                  type="number"
                  name="horsepower"
                  value={formData.horsepower}
                  onChange={handleChange}
                  placeholder="e.g. 410"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Current Engine Hours
                </label>
                <input
                  type="number"
                  name="engineHours"
                  value={formData.engineHours}
                  onChange={handleChange}
                  placeholder="e.g. 420"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Drive Configuration
                </label>
                <select
                  name="driveType"
                  value={formData.driveType}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                >
                  <option value="4WD">4WD (Four-Wheel Drive)</option>
                  <option value="MFWD">MFWD (Mechanical Front Wheel)</option>
                  <option value="TRACK">Track / Quadtrac</option>
                  <option value="2WD">2WD (Two-Wheel Drive)</option>
                  <option value="N/A">Not Applicable (Implement)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Transmission
                </label>
                <input
                  type="text"
                  name="transmission"
                  value={formData.transmission}
                  onChange={handleChange}
                  placeholder="e.g. e23 PowerShift, IVT, CVT"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Hydraulic Flow (GPM)
                </label>
                <input
                  type="number"
                  name="hydraulicFlowGpm"
                  value={formData.hydraulicFlowGpm}
                  onChange={handleChange}
                  step="0.5"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  PTO Speed
                </label>
                <input
                  type="text"
                  name="ptoSpeed"
                  value={formData.ptoSpeed}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Detailed Field Description &amp; Precision Ag Features
              </label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows={3}
                placeholder="Include details about cab comfort, display terminals, tire tread %, auto-guidance unlocks, or service history..."
                className="w-full p-3 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs outline-none focus:ring-2 focus:ring-primary/40"
              />
            </div>
          </div>

          {/* 3. Field Photos */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm space-y-4">
            <h3 className="font-headline-sm text-base font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">add_photo_alternate</span>
              <span>3. High-Resolution Field Photos</span>
            </h3>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Image URL (Hosted or CDN)
              </label>
              <input
                type="text"
                name="images"
                value={formData.images}
                onChange={handleChange}
                placeholder="https://..."
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
              />
              <p className="text-[11px] text-on-surface-variant mt-1">
                Provide one or more comma-separated URLs showcasing clean exterior, tire tread, cab interior, and engine bay.
              </p>
            </div>
          </div>

          {/* 4. Pricing & Rates */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm space-y-4">
            <h3 className="font-headline-sm text-base font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">payments</span>
              <span>4. Pricing &amp; Operational Rates</span>
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Daily Rental Rate (₹/day) *
                </label>
                <input
                  type="number"
                  name="dailyRate"
                  value={formData.dailyRate}
                  onChange={handleChange}
                  min="50"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Weekly Rate (₹)
                </label>
                <input
                  type="number"
                  name="weeklyRate"
                  value={formData.weeklyRate}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Security Deposit (₹)
                </label>
                <input
                  type="number"
                  name="securityDeposit"
                  value={formData.securityDeposit}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              {formData.isForSale && (
                <div className="sm:col-span-3">
                  <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                    Outright Purchase Asking Price (₹)
                  </label>
                  <input
                    type="number"
                    name="purchasePrice"
                    value={formData.purchasePrice}
                    onChange={handleChange}
                    className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  />
                </div>
              )}
            </div>
          </div>

          {/* 5. Field Location */}
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/40 shadow-sm space-y-4">
            <h3 className="font-headline-sm text-base font-bold text-on-surface flex items-center gap-2">
              <span className="material-symbols-outlined text-primary">pin_drop</span>
              <span>5. Farm &amp; Machinery Location</span>
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="sm:col-span-3">
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  Physical Storage Address
                </label>
                <input
                  type="text"
                  name="locationAddress"
                  value={formData.locationAddress}
                  onChange={handleChange}
                  placeholder="e.g. Gat No. 42, Baramati"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  City *
                </label>
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  State *
                </label>
                <input
                  type="text"
                  name="state"
                  value={formData.state}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                  ZIP Code *
                </label>
                <input
                  type="text"
                  name="zipCode"
                  value={formData.zipCode}
                  onChange={handleChange}
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-semibold outline-none focus:ring-2 focus:ring-primary/40"
                  required
                />
              </div>
            </div>
          </div>

          {/* Submit Actions */}
          <div className="flex items-center justify-end gap-4 pt-4">
            <button
              type="button"
              onClick={() => navigate('/owner/dashboard')}
              className="px-5 py-3 rounded-xl bg-surface-container-high text-on-surface font-semibold text-xs hover:bg-surface-container transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-8 py-3 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs flex items-center gap-2 transition-all shadow-md disabled:opacity-50"
            >
              <span className="material-symbols-outlined text-base">rocket_launch</span>
              <span>{isSubmitting ? 'Publishing...' : 'Publish Equipment Listing'}</span>
            </button>
          </div>
        </form>

        {/* Right 1 Col: Live Preview Card */}
        <div className="lg:col-span-1 space-y-4">
          <div className="sticky top-28">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                Live Marketplace Card Preview
              </span>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-secondary/10 text-secondary font-bold">
                Auto-Updating
              </span>
            </div>

            <EquipmentCard
              equipment={{
                id: 'preview',
                title: formData.title || '2023 Mahindra 575 DI Sarpanch',
                city: formData.city || 'Pune',
                state: formData.state || 'Maharashtra',
                category: formData.category,
                horsepower: formData.horsepower,
                engineHours: formData.engineHours,
                driveType: formData.driveType,
                dailyRate: formData.dailyRate,
                isForSale: formData.isForSale,
                purchasePrice: formData.purchasePrice,
                status: 'AVAILABLE',
                images: formData.images,
              }}
            />

            <div className="mt-4 p-4 rounded-xl bg-surface-container-low border border-outline-variant/30 text-xs text-on-surface-variant space-y-2">
              <div className="flex items-center gap-2 text-on-surface font-bold">
                <span className="material-symbols-outlined text-secondary text-sm">shield</span>
                <span>AgriRent Guarantee</span>
              </div>
              <p className="text-[11px] leading-relaxed">
                All newly published machinery is immediately protected with our ₹50 Lakh comprehensive equipment damage policy and automated escrow payment clearing.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AddEquipmentPage;
