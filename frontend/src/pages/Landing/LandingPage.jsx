import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import EquipmentCard from '../../components/common/EquipmentCard';
import { EQUIPMENT_CATEGORIES } from '../../constants/categories';

export const LandingPage = () => {
  const navigate = useNavigate();
  const [searchTab, setSearchTab] = useState('rent'); // 'rent' or 'buy'
  const [keyword, setKeyword] = useState('');
  const [location, setLocation] = useState('Central Iowa');
  const [dates, setDates] = useState('May 12 - May 19, 2025');
  const [category, setCategory] = useState('all');
  const [featuredEquipment, setFeaturedEquipment] = useState([]);
  const [loading, setLoading] = useState(true);

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
    if (location) params.append('location', location);
    if (category !== 'all') params.append('category', category);
    if (searchTab === 'rent') params.append('isForRent', 'true');
    if (searchTab === 'buy') params.append('isForSale', 'true');
    navigate(`/equipment?${params.toString()}`);
  };

  const handleTrendingClick = (tagCategory, tagKeyword = '') => {
    const params = new URLSearchParams();
    if (tagCategory && tagCategory !== 'all') params.append('category', tagCategory);
    if (tagKeyword) params.append('search', tagKeyword);
    navigate(`/equipment?${params.toString()}`);
  };

  return (
    <div className="flex flex-col w-full">
      {/* Top Ambient Glow Decor */}
      <div className="relative w-full overflow-hidden">
        <div className="absolute -top-40 right-1/4 w-[600px] h-[600px] bg-primary/5 rounded-full blur-3xl pointer-events-none -z-10"></div>
        <div className="absolute top-80 -left-20 w-[500px] h-[500px] bg-secondary-container/20 rounded-full blur-3xl pointer-events-none -z-10"></div>

        {/* 1. HERO SECTION */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 pb-16 lg:pb-24">
          <div className="flex flex-col items-center text-center max-w-4xl mx-auto mb-10">
            {/* Badge */}
            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-surface-container-high text-primary mb-6 shadow-sm border border-outline-variant/30">
              <span className="w-2 h-2 rounded-full bg-secondary animate-pulse"></span>
              <span className="font-label-md text-sm font-semibold tracking-wide">
                Over 12,400 Verified Machines Across 48 States
              </span>
            </div>

            {/* Headline */}
            <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-extrabold text-on-surface tracking-tight mb-5 max-w-3xl leading-tight">
              Find the Right{' '}
              <span className="text-primary underline decoration-secondary decoration-4 underline-offset-8">
                Agricultural Equipment
              </span>{' '}
              for Your Farm
            </h1>

            {/* Subheading */}
            <p className="font-body-lg text-lg text-on-surface-variant max-w-2xl">
              Instantly rent modern high-horsepower tractors, harvesters, and implements by the day or season, or buy certified pre-owned machinery with guaranteed escrow protection.
            </p>
          </div>

          {/* Integrated Search Widget Card */}
          <div className="max-w-5xl mx-auto bg-surface-container-lowest rounded-2xl p-4 sm:p-6 md:p-8 shadow-xl border border-outline-variant/50 relative z-10">
            {/* Switch Tabs */}
            <div className="flex items-center justify-between gap-4 mb-6 pb-4 bg-surface-container-low/50 -mx-4 -mt-4 sm:-mx-6 sm:-mt-6 md:-mx-8 md:-mt-8 p-4 rounded-t-2xl border-b border-outline-variant/20">
              <div className="inline-flex p-1 bg-surface-container-high rounded-xl">
                <button
                  type="button"
                  onClick={() => setSearchTab('rent')}
                  className={`flex items-center gap-2 px-5 py-2.5 rounded-lg font-label-lg text-sm font-semibold transition-all ${
                    searchTab === 'rent'
                      ? 'bg-primary text-on-primary shadow-sm'
                      : 'text-on-surface-variant hover:text-on-surface'
                  }`}
                >
                  <span className="material-symbols-outlined text-lg">calendar_month</span>
                  <span>Rent Machinery</span>
                </button>
                <button
                  type="button"
                  onClick={() => setSearchTab('buy')}
                  className={`flex items-center gap-2 px-5 py-2.5 rounded-lg font-label-lg text-sm font-semibold transition-all ${
                    searchTab === 'buy'
                      ? 'bg-primary text-on-primary shadow-sm'
                      : 'text-on-surface-variant hover:text-on-surface'
                  }`}
                >
                  <span className="material-symbols-outlined text-lg">storefront</span>
                  <span>Buy Equipment</span>
                </button>
              </div>

              <div className="hidden sm:flex items-center gap-2 text-on-surface-variant font-label-sm text-xs font-semibold">
                <span className="material-symbols-outlined text-secondary text-sm">verified</span>
                <span>Escrow Guaranteed &amp; Insured</span>
              </div>
            </div>

            {/* Dynamic Search Form */}
            <form onSubmit={handleSearch} className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
              {/* Keyword Field */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="font-label-sm text-xs font-bold text-on-surface uppercase tracking-wider">
                  Equipment or Keyword
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-on-surface-variant">
                    agriculture
                  </span>
                  <input
                    type="text"
                    value={keyword}
                    onChange={(e) => setKeyword(e.target.value)}
                    placeholder="John Deere 8R, Combine, Rotavator"
                    className="w-full h-12 pl-10 pr-3 rounded-xl bg-surface-container-low text-on-surface text-sm outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 border border-outline-variant/30 transition-all placeholder:text-on-surface-variant/60"
                  />
                </div>
              </div>

              {/* Location Field */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="font-label-sm text-xs font-bold text-on-surface uppercase tracking-wider">
                  Location / Region
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-on-surface-variant">
                    location_on
                  </span>
                  <input
                    type="text"
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    placeholder="Des Moines, IA or Ames, IA"
                    className="w-full h-12 pl-10 pr-3 rounded-xl bg-surface-container-low text-on-surface text-sm outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 border border-outline-variant/30 transition-all placeholder:text-on-surface-variant/60"
                  />
                </div>
              </div>

              {/* Dates or Budget Field */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="font-label-sm text-xs font-bold text-on-surface uppercase tracking-wider">
                  {searchTab === 'rent' ? 'Rental Period' : 'Delivery Window'}
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-on-surface-variant">
                    date_range
                  </span>
                  <input
                    type="text"
                    value={dates}
                    onChange={(e) => setDates(e.target.value)}
                    placeholder="May 12 - May 19, 2025"
                    className="w-full h-12 pl-10 pr-3 rounded-xl bg-surface-container-low text-on-surface text-sm outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 border border-outline-variant/30 transition-all"
                  />
                </div>
              </div>

              {/* Category Filter */}
              <div className="flex flex-col gap-1.5 text-left">
                <label className="font-label-sm text-xs font-bold text-on-surface uppercase tracking-wider">
                  Category
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-on-surface-variant">tune</span>
                  <select
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full h-12 pl-10 pr-8 rounded-xl bg-surface-container-low text-on-surface text-sm outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 border border-outline-variant/30 transition-all appearance-none cursor-pointer"
                  >
                    <option value="all">All Categories</option>
                    <option value="TRACTORS">Tractors (Row Crop &amp; 4WD)</option>
                    <option value="HARVESTERS">Grain Combines &amp; Headers</option>
                    <option value="TILLAGE">Vertical Tillage &amp; Discs</option>
                    <option value="SEEDERS">No-Till Seeders &amp; Planters</option>
                    <option value="SPRAYERS">Self-Propelled Sprayers</option>
                  </select>
                  <span className="material-symbols-outlined absolute right-2 pointer-events-none text-on-surface-variant text-sm">
                    expand_more
                  </span>
                </div>
              </div>

              {/* Submit Button */}
              <div className="sm:col-span-2 lg:col-span-4 mt-2">
                <button
                  type="submit"
                  className="w-full h-12 bg-primary hover:bg-primary-container text-on-primary font-label-lg text-base font-semibold rounded-xl flex items-center justify-center gap-3 transition-all duration-200 shadow-md hover:shadow-lg"
                >
                  <span className="material-symbols-outlined text-xl">search</span>
                  <span>{searchTab === 'rent' ? 'Search Available Rental Machinery' : 'Browse Equipment for Sale'}</span>
                </button>
              </div>
            </form>

            {/* Quick Trending Chips */}
            <div className="flex flex-wrap items-center gap-2 pt-2 text-left">
              <span className="font-label-sm text-xs text-on-surface-variant mr-1 font-semibold">Trending:</span>
              <button
                type="button"
                onClick={() => handleTrendingClick('TRACTORS', '150-250 HP')}
                className="px-3 py-1 bg-surface-container-low hover:bg-surface-container-high rounded-full font-label-sm text-xs text-on-surface transition-colors flex items-center gap-1.5 border border-outline-variant/30"
              >
                <span>🚜</span> 150-250 HP Tractors
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('HARVESTERS')}
                className="px-3 py-1 bg-surface-container-low hover:bg-surface-container-high rounded-full font-label-sm text-xs text-on-surface transition-colors flex items-center gap-1.5 border border-outline-variant/30"
              >
                <span>🌾</span> Combine Harvesters
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('SEEDERS')}
                className="px-3 py-1 bg-surface-container-low hover:bg-surface-container-high rounded-full font-label-sm text-xs text-on-surface transition-colors flex items-center gap-1.5 border border-outline-variant/30"
              >
                <span>🌱</span> No-Till Seeders
              </button>
              <button
                type="button"
                onClick={() => handleTrendingClick('TILLAGE')}
                className="px-3 py-1 bg-surface-container-low hover:bg-surface-container-high rounded-full font-label-sm text-xs text-on-surface transition-colors flex items-center gap-1.5 border border-outline-variant/30"
              >
                <span>⚙️</span> Heavy Disc Harrows
              </button>
            </div>
          </div>
        </section>

        {/* 2. BROWSE BY CATEGORY */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="flex items-center justify-between mb-8">
            <div>
              <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-on-surface">
                Browse by Equipment Category
              </h2>
              <p className="text-sm text-on-surface-variant mt-1">
                Precision heavy machinery calibrated for high-yield row crop and livestock farming
              </p>
            </div>
            <Link
              to="/equipment"
              className="inline-flex items-center gap-1 text-primary font-semibold text-sm hover:underline"
            >
              <span>View All Fleet</span>
              <span className="material-symbols-outlined text-sm">arrow_forward</span>
            </Link>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
            {EQUIPMENT_CATEGORIES.filter((c) => c.id !== 'all').map((cat) => (
              <button
                key={cat.id}
                onClick={() => handleTrendingClick(cat.id)}
                className="bg-surface-container-lowest hover:bg-surface-container-low border border-outline-variant/50 hover:border-primary/50 rounded-2xl p-5 text-center flex flex-col items-center justify-center gap-3 transition-all hover:shadow-md group"
              >
                <div className="w-14 h-14 rounded-2xl bg-surface-container-high group-hover:bg-primary group-hover:text-on-primary flex items-center justify-center transition-colors">
                  <span className="material-symbols-outlined text-2xl text-primary group-hover:text-on-primary">
                    {cat.icon}
                  </span>
                </div>
                <div>
                  <h3 className="font-label-md text-sm font-bold text-on-surface group-hover:text-primary transition-colors">
                    {cat.label}
                  </h3>
                  <span className="text-xs text-on-surface-variant">{cat.count}+ Available</span>
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* 3. FEATURED EQUIPMENT GRID */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex items-center justify-between mb-8">
            <div>
              <span className="text-xs uppercase font-bold text-secondary tracking-wider">Top Field Performers</span>
              <h2 className="font-headline-lg text-2xl sm:text-3xl font-bold text-on-surface mt-1">
                Active Fleet Ready for Dispatch
              </h2>
            </div>
            <Link
              to="/equipment"
              className="px-4 py-2 rounded-xl bg-surface-container-high text-on-surface font-semibold text-sm hover:bg-surface-container transition-colors"
            >
              Explore 1,800+ Machines
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3].map((i) => (
                <div key={i} className="h-80 bg-surface-container-high rounded-2xl animate-pulse"></div>
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

        {/* 4. HOW IT WORKS */}
        <section id="how-it-works" className="bg-surface-container-low/60 border-y border-outline-variant/30 py-20 mt-12">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="text-center max-w-2xl mx-auto mb-14">
              <span className="text-xs uppercase font-bold text-primary tracking-wider">Streamlined Logistics</span>
              <h2 className="font-display text-3xl sm:text-4xl font-extrabold text-on-surface mt-1">
                How AgriRent Works
              </h2>
              <p className="text-base text-on-surface-variant mt-2">
                From finding the exact implement to flatbed transport right to your field gate.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
              <div className="bg-surface-container-lowest p-6 rounded-2xl border border-outline-variant/40 relative">
                <div className="w-12 h-12 rounded-xl bg-primary-container text-on-primary flex items-center justify-center font-bold text-xl mb-4">
                  1
                </div>
                <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-2">Search &amp; Filter</h3>
                <p className="text-sm text-on-surface-variant">
                  Pinpoint horsepower, drive type, hydraulic remotes, and GPS precision readiness within your county.
                </p>
              </div>

              <div className="bg-surface-container-lowest p-6 rounded-2xl border border-outline-variant/40 relative">
                <div className="w-12 h-12 rounded-xl bg-primary text-on-primary flex items-center justify-center font-bold text-xl mb-4">
                  2
                </div>
                <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-2">Book with Escrow</h3>
                <p className="text-sm text-on-surface-variant">
                  Funds stay protected in AgriRent Escrow until equipment arrives inspected and runs to specification.
                </p>
              </div>

              <div className="bg-surface-container-lowest p-6 rounded-2xl border border-outline-variant/40 relative">
                <div className="w-12 h-12 rounded-xl bg-primary text-on-primary flex items-center justify-center font-bold text-xl mb-4">
                  3
                </div>
                <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-2">Field Delivery</h3>
                <p className="text-sm text-on-surface-variant">
                  Coordinated flatbed transport or owner yard pickup with verified pre-delivery checklists.
                </p>
              </div>

              <div className="bg-surface-container-lowest p-6 rounded-2xl border border-outline-variant/40 relative">
                <div className="w-12 h-12 rounded-xl bg-secondary text-on-primary flex items-center justify-center font-bold text-xl mb-4">
                  4
                </div>
                <h3 className="font-headline-sm text-lg font-bold text-on-surface mb-2">Work &amp; Return</h3>
                <p className="text-sm text-on-surface-variant">
                  Telematics log working hours. Extend duration in one click or schedule carrier return.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* 5. OWNER CALLOUT CTA BANNER */}
        <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
          <div className="bg-primary rounded-3xl p-8 sm:p-12 text-on-primary shadow-2xl relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-8">
            <div className="space-y-4 max-w-xl">
              <span className="px-3 py-1 rounded-full bg-surface/20 text-emerald-200 text-xs font-semibold">
                Equipment Owners &amp; Dealerships
              </span>
              <h2 className="font-display text-3xl sm:text-4xl font-extrabold leading-tight">
                Turn Idle Field Machinery into Guaranteed Seasonal Revenue
              </h2>
              <p className="text-emerald-100 text-base">
                List tractors, sprayers, and tillage rigs. Benefit from vetted renters, automated security deposits, and full insurance coverage.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-4 flex-shrink-0">
              <Link
                to="/owner/add-equipment"
                className="px-6 py-3.5 rounded-xl bg-secondary text-on-primary font-bold text-sm hover:bg-emerald-600 transition-all shadow-lg flex items-center justify-center gap-2"
              >
                <span className="material-symbols-outlined">add_circle</span>
                <span>List Machinery Now</span>
              </Link>
              <Link
                to="/owner/dashboard"
                className="px-6 py-3.5 rounded-xl bg-surface/10 text-white border border-white/20 font-semibold text-sm hover:bg-surface/20 transition-all flex items-center justify-center"
              >
                <span>Owner Dashboard</span>
              </Link>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
};

export default LandingPage;
