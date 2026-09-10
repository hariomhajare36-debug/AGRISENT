import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import EquipmentCard from '../../components/common/EquipmentCard';
import { EQUIPMENT_CATEGORIES, MAHARASHTRA_DISTRICTS } from '../../constants/categories';
import { formatINR } from '../../utils/currency';
import EMICalculatorModal from '../../components/common/EMICalculatorModal';

export const LandingPage = () => {
  const navigate = useNavigate();
  const [searchTab, setSearchTab] = useState('rent'); // 'rent' or 'buy'
  const [keyword, setKeyword] = useState('');
  const [district, setDistrict] = useState('all');
  const [category, setCategory] = useState('all');
  const [featuredEquipment, setFeaturedEquipment] = useState([]);
  const [loading, setLoading] = useState(true);
  const [emiModalOpen, setEmiModalOpen] = useState(false);

  useEffect(() => {
    const loadFeatured = async () => {
      try {
        const data = await equipmentService.getFeatured();
        setFeaturedEquipment(data || []);
      } catch (err) {
        console.error('Failed to load featured equipment:', err);
      } finally {
        setLoading(false);
      }
    };
    loadFeatured();
  }, []);

  const handleSearch = (e) => {
    e.preventDefault();
    const params = new URLSearchParams();
    if (keyword) params.append('search', keyword);
    if (district !== 'all') params.append('district', district);
    if (category !== 'all') params.append('category', category);
    if (searchTab === 'rent') params.append('type', 'rent');
    if (searchTab === 'buy') params.append('type', 'buy');
    navigate(`/catalog?${params.toString()}`);
  };

  const handleCategoryClick = (catId) => {
    navigate(`/catalog?category=${catId}`);
  };

  const handleTrendingClick = (tagCategory, tagKeyword = '') => {
    const params = new URLSearchParams();
    if (tagCategory && tagCategory !== 'all') params.append('category', tagCategory);
    if (tagKeyword) params.append('search', tagKeyword);
    navigate(`/catalog?${params.toString()}`);
  };

  return (
    <div className="flex flex-col w-full">
      {/* Top Ambient Glow Decor */}
      <div className="relative w-full overflow-hidden">
        {/* 1. HERO SECTION */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-6 pb-16 lg:pb-20">
          <div className="flex flex-col items-center text-center max-w-4xl mx-auto mb-8">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-emerald-50 text-emerald-800 mb-5 shadow-sm border border-emerald-200">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              <span className="text-xs font-bold tracking-wide">
                120+ Verified Agricultural Machines Across Maharashtra (₹ INR)
              </span>
            </div>

            {/* Headline */}
            <h1 className="text-3xl sm:text-5xl lg:text-6xl font-black text-gray-900 tracking-tight mb-4 max-w-3xl leading-tight">
              Rent or Buy Machinery.{' '}
              <span className="text-emerald-700 underline decoration-emerald-400 decoration-4 underline-offset-8">
                Farm Smarter.
              </span>
            </h1>

            {/* Subheading */}
            <p className="text-base sm:text-lg text-gray-600 max-w-2xl leading-relaxed">
              India's premier agricultural marketplace. Instantly rent high-power tractors, combine harvesters, and rotavators in ₹ INR, or purchase certified farm equipment with 100% Escrow security.
            </p>
          </div>

          {/* Integrated Search Widget Card */}
          <div className="max-w-5xl mx-auto bg-white rounded-3xl p-4 sm:p-6 md:p-8 shadow-xl border border-gray-200 relative z-10">
            {/* Switch Tabs */}
            <div className="flex items-center justify-between gap-4 mb-6 pb-4 bg-gray-50/70 -mx-4 -mt-4 sm:-mx-6 sm:-mt-6 md:-mx-8 md:-mt-8 p-4 rounded-t-3xl border-b border-gray-100">
              <div className="inline-flex p-1 bg-gray-200/70 rounded-2xl">
                <button
                  type="button"
                  onClick={() => setSearchTab('rent')}
                  className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-bold transition-all ${
                    searchTab === 'rent'
                      ? 'bg-emerald-700 text-white shadow-md'
                      : 'text-gray-700 hover:text-emerald-900'
                  }`}
                >
                  <span className="material-symbols-outlined text-base">calendar_month</span>
                  <span>Rent Machinery</span>
                </button>
                <button
                  type="button"
                  onClick={() => setSearchTab('buy')}
                  className={`flex items-center gap-2 px-5 py-2.5 rounded-xl text-xs font-bold transition-all ${
                    searchTab === 'buy'
                      ? 'bg-emerald-700 text-white shadow-md'
                      : 'text-gray-700 hover:text-emerald-900'
                  }`}
                >
                  <span className="material-symbols-outlined text-base">storefront</span>
                  <span>Buy Equipment</span>
                </button>
              </div>

              <div className="hidden sm:flex items-center gap-2 text-emerald-800 text-xs font-bold">
                <span className="material-symbols-outlined text-emerald-600 text-base">verified</span>
                <span>Kisan Escrow Protected • Zero Middlemen</span>
              </div>
            </div>

            {/* Dynamic Search Form */}
            <form onSubmit={handleSearch} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
              {/* Keyword Field */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">
                  Equipment / Model
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">
                    agriculture
                  </span>
                  <input
                    type="text"
                    value={keyword}
                    onChange={(e) => setKeyword(e.target.value)}
                    placeholder="Mahindra 575, Swaraj 744, Rotavator"
                    className="w-full h-12 pl-10 pr-3 rounded-xl bg-gray-50 text-gray-900 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-600 border border-gray-300 transition-all placeholder:text-gray-400"
                  />
                </div>
              </div>

              {/* Location (District) Field */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">
                  Maharashtra Hub
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">
                    location_on
                  </span>
                  <select
                    value={district}
                    onChange={(e) => setDistrict(e.target.value)}
                    className="w-full h-12 pl-10 pr-8 rounded-xl bg-gray-50 text-gray-900 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-600 border border-gray-300 transition-all appearance-none cursor-pointer"
                  >
                    {MAHARASHTRA_DISTRICTS.map((d) => (
                      <option key={d.id} value={d.id}>{d.label}</option>
                    ))}
                  </select>
                  <span className="material-symbols-outlined absolute right-2 pointer-events-none text-gray-400 text-sm">
                    expand_more
                  </span>
                </div>
              </div>

              {/* Category Filter */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">
                  Machinery Type
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">tune</span>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full h-12 pl-10 pr-8 rounded-xl bg-gray-50 text-gray-900 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-600 border border-gray-300 transition-all appearance-none cursor-pointer"
                  >
                    {EQUIPMENT_CATEGORIES.map((c) => (
                      <option key={c.id} value={c.id}>{c.label}</option>
                    ))}
                  </select>
                  <span className="material-symbols-outlined absolute right-2 pointer-events-none text-gray-400 text-sm">
                    expand_more
                  </span>
                </div>
              </div>

              {/* Submit Button */}
              <div className="flex flex-col justify-end">
                <button
                  type="submit"
                  className="w-full h-12 bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-all shadow-md hover:shadow-lg"
                >
                  <span className="material-symbols-outlined text-lg">search</span>
                  <span>{searchTab === 'rent' ? 'Search Rental Machinery' : 'Browse Tractors for Sale'}</span>
                </button>
              </div>
            </form>

            {/* Quick Trending Chips */}
            <div className="flex flex-wrap items-center gap-2 pt-2 text-left border-t border-gray-100">
              <span className="text-xs text-gray-500 font-semibold mr-1">Popular in Maharashtra:</span>
              <button
                type="button"
                onClick={() => handleTrendingClick('TRACTORS', 'Mahindra 575')}
                className="px-3 py-1 bg-gray-100 hover:bg-emerald-50 hover:text-emerald-800 rounded-full text-xs text-gray-700 transition-colors flex items-center gap-1 border border-gray-200"
              >
                <span>🚜</span> Mahindra 575 DI XP
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('TRACTORS', 'Swaraj 744')}
                className="px-3 py-1 bg-gray-100 hover:bg-emerald-50 hover:text-emerald-800 rounded-full text-xs text-gray-700 transition-colors flex items-center gap-1 border border-gray-200"
              >
                <span>🚜</span> Swaraj 744 XT
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('HARVESTERS')}
                className="px-3 py-1 bg-gray-100 hover:bg-emerald-50 hover:text-emerald-800 rounded-full text-xs text-gray-700 transition-colors flex items-center gap-1 border border-gray-200"
              >
                <span>🌾</span> Combine Harvesters
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('ROTAVATORS')}
                className="px-3 py-1 bg-gray-100 hover:bg-emerald-50 hover:text-emerald-800 rounded-full text-xs text-gray-700 transition-colors flex items-center gap-1 border border-gray-200"
              >
                <span>⚙️</span> Shaktiman Rotavators
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('THRESHERS')}
                className="px-3 py-1 bg-gray-100 hover:bg-emerald-50 hover:text-emerald-800 rounded-full text-xs text-gray-700 transition-colors flex items-center gap-1 border border-gray-200"
              >
                <span>🌾</span> Multi-Crop Threshers
              </button>
            </div>
          </div>
        </section>

        {/* 2. BROWSE ALL 12 CATEGORIES (Requirement 8) */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex items-center justify-between mb-8">
            <div>
              <span className="text-xs font-bold text-emerald-700 uppercase tracking-wider">12 Verified Agricultural Categories</span>
              <h2 className="text-2xl sm:text-3xl font-black text-gray-900 mt-0.5">
                Browse Indian Farm Machinery
              </h2>
              <p className="text-xs text-gray-500 mt-1">
                Engineered and tested for black cotton, alluvial, and laterite soils across Maharashtra.
              </p>
            </div>
            <Link
              to="/catalog"
              className="inline-flex items-center gap-1 text-emerald-700 font-bold text-xs hover:underline"
            >
              <span>View All 120+ Machines</span>
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {EQUIPMENT_CATEGORIES.filter((c) => c.id !== 'all').map((cat) => (
              <button
                key={cat.id}
                type="button"
                onClick={() => handleCategoryClick(cat.id)}
                className="bg-white hover:bg-emerald-50/50 border border-gray-200 hover:border-emerald-600 rounded-2xl p-4 text-center flex flex-col items-center justify-between gap-3 transition-all hover:shadow-md group h-44"
              >
                <div className="w-12 h-12 rounded-2xl bg-emerald-50 group-hover:bg-emerald-700 group-hover:text-white text-emerald-800 flex items-center justify-center transition-colors shadow-sm">
                  <span className="material-symbols-outlined text-2xl">
                    {cat.icon}
                  </span>
                </div>
                <div className="space-y-1">
                  <h3 className="text-xs font-bold text-gray-900 group-hover:text-emerald-800 transition-colors line-clamp-2">
                    {cat.label}
                  </h3>
                  <span className="text-[11px] text-gray-500 font-medium block">
                    {cat.count} Available
                  </span>
                </div>
                <span className="text-[10px] font-bold text-emerald-700 group-hover:underline">
                  View Catalog →
                </span>
              </button>
            ))}
          </div>
        </section>

        {/* 3. FEATURED EQUIPMENT GRID (₹ INR) */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex items-center justify-between mb-8">
            <div>
              <span className="text-xs uppercase font-bold text-emerald-700 tracking-wider">Top Field Performers</span>
              <h2 className="text-2xl sm:text-3xl font-black text-gray-900 mt-1">
                Featured Fleet Ready for Field Dispatch
              </h2>
            </div>
            <Link
              to="/catalog"
              className="px-4 py-2 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold text-xs transition-colors"
            >
              Explore 120+ Machines
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3].map((i) => (
                <div key={i} className="h-80 bg-gray-100 rounded-2xl animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {featuredEquipment.slice(0, 6).map((item) => (
                <EquipmentCard key={item.id} equipment={item} />
              ))}
            </div>
          )}
        </section>

        {/* 4. KISAN TRACTOR EMI CALCULATOR CALLOUT */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="bg-gradient-to-r from-emerald-800 to-emerald-950 text-white rounded-3xl p-8 sm:p-12 shadow-xl flex flex-col lg:flex-row items-center justify-between gap-8">
            <div className="space-y-3 max-w-xl text-left">
              <span className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-emerald-700/60 text-emerald-200 text-xs font-bold border border-emerald-600">
                <span className="material-symbols-outlined text-sm">calculate</span>
                Interactive Agricultural Finance Tool
              </span>
              <h3 className="text-2xl sm:text-3xl font-black leading-tight">
                Plan Your Machinery Purchase with Kisan EMI Calculator
              </h3>
              <p className="text-emerald-100 text-xs sm:text-sm leading-relaxed">
                Estimate monthly installments for new tractors from Mahindra, Swaraj, John Deere, and Sonalika. Explore low-interest agricultural loans starting at 8.9% with seasonal harvest-linked repayment cycles.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row items-center gap-3 shrink-0">
              <button
                type="button"
                onClick={() => setEmiModalOpen(true)}
                className="px-6 py-3.5 rounded-xl bg-white hover:bg-emerald-50 text-emerald-900 font-bold text-xs shadow-lg transition-all flex items-center gap-2"
              >
                <span className="material-symbols-outlined text-lg">calculate</span>
                Calculate Tractor EMI Now
              </button>
              <Link
                to="/how-it-works"
                className="px-6 py-3.5 rounded-xl bg-emerald-900/80 hover:bg-emerald-900 text-emerald-200 border border-emerald-700 font-bold text-xs transition-colors"
              >
                Learn How It Works
              </Link>
            </div>
          </div>
        </section>

        {/* 5. HOW IT WORKS SUMMARY SECTION */}
        <section className="bg-gray-50 border-y border-gray-200 py-16 mt-8">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-2xl mx-auto mb-12 space-y-2">
              <span className="text-xs uppercase font-bold text-emerald-700 tracking-wider">Streamlined Logistics & Escrow</span>
              <h2 className="text-2xl sm:text-3xl font-black text-gray-900">
                How AgriRent Works in 4 Simple Steps
              </h2>
              <p className="text-xs text-gray-600">
                Transparent rental booking and machinery purchases with guaranteed field delivery across Maharashtra.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm relative">
                <div className="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-800 flex items-center justify-center font-black text-lg mb-3">
                  1
                </div>
                <h3 className="text-sm font-bold text-gray-900 mb-1.5">Filter by Soil & HP</h3>
                <p className="text-xs text-gray-600 leading-relaxed">
                  Pinpoint horsepower, drive type, lifting capacity, and implement compatibility in your district.
                </p>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm relative">
                <div className="w-10 h-10 rounded-xl bg-emerald-700 text-white flex items-center justify-center font-black text-lg mb-3">
                  2
                </div>
                <h3 className="text-sm font-bold text-gray-900 mb-1.5">Book with Kisan Escrow</h3>
                <p className="text-xs text-gray-600 leading-relaxed">
                  Your payment is protected in Escrow until the machinery arrives on your farm in full operating condition.
                </p>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm relative">
                <div className="w-10 h-10 rounded-xl bg-emerald-700 text-white flex items-center justify-center font-black text-lg mb-3">
                  3
                </div>
                <h3 className="text-sm font-bold text-gray-900 mb-1.5">Field Gate Delivery</h3>
                <p className="text-xs text-gray-600 leading-relaxed">
                  Flatbed transportation to your village or authorized dealer yard pickup in Nagpur, Pune, and Nashik.
                </p>
              </div>

              <div className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm relative">
                <div className="w-10 h-10 rounded-xl bg-emerald-900 text-white flex items-center justify-center font-black text-lg mb-3">
                  4
                </div>
                <h3 className="text-sm font-bold text-gray-900 mb-1.5">Field Work & Return</h3>
                <p className="text-xs text-gray-600 leading-relaxed">
                  Telemetry logs hours. Extend your rental in one click or get your security deposit refunded within 24 hours.
                </p>
              </div>
            </div>

            <div className="text-center pt-8">
              <Link
                to="/how-it-works"
                className="inline-flex items-center gap-2 text-xs font-bold text-emerald-800 hover:text-emerald-900 bg-emerald-100 hover:bg-emerald-200 px-5 py-2.5 rounded-xl transition-colors"
              >
                <span>Read Complete 10 Rent & 9 Buy Steps Guide</span>
                <span className="material-symbols-outlined text-sm">arrow_forward</span>
              </Link>
            </div>
          </div>
        </section>

        {/* 6. OWNER CALLOUT CTA BANNER */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="bg-emerald-800 rounded-3xl p-8 sm:p-12 text-white shadow-xl relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8">
            <div className="space-y-3 max-w-xl text-left">
              <span className="px-3 py-1 rounded-full bg-emerald-700 text-emerald-200 text-xs font-bold">
                Tractor Owners &amp; Regional Dealerships
              </span>
              <h2 className="text-2xl sm:text-3xl font-black leading-tight">
                Turn Idle Field Machinery into Guaranteed Farm Income
              </h2>
              <p className="text-emerald-100 text-xs sm:text-sm">
                List tractors, harvesters, and sprayers. Benefit from verified renters, automated security deposits in ₹ INR, and GPS telematics tracking.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-3 flex-shrink-0">
              <Link
                to="/owner/add-equipment"
                className="px-6 py-3.5 rounded-xl bg-white hover:bg-gray-100 text-emerald-900 font-bold text-xs transition-all shadow-md flex items-center justify-center gap-1.5"
              >
                <span className="material-symbols-outlined text-base">add_circle</span>
                <span>List Machinery Now</span>
              </Link>
              <Link
                to="/owner/dashboard"
                className="px-6 py-3.5 rounded-xl bg-emerald-900/60 hover:bg-emerald-900 text-white border border-emerald-600 font-bold text-xs transition-colors flex items-center justify-center"
              >
                <span>Fleet Owner Dashboard</span>
              </Link>
            </div>
          </div>
        </section>
      </div>

      {/* EMI Calculator Modal */}
      <EMICalculatorModal
        isOpen={emiModalOpen}
        onClose={() => setEmiModalOpen(false)}
        initialPrice={725000}
        machineTitle="Mahindra 575 DI XP Plus"
      />
    </div>
  );
};

export default LandingPage;
