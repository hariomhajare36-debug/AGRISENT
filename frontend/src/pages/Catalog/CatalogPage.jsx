import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import EquipmentCard from '../../components/common/EquipmentCard';
import { EQUIPMENT_CATEGORIES, INDIAN_BRANDS, MAHARASHTRA_DISTRICTS } from '../../constants/categories';
import { formatINR } from '../../utils/currency';

export const CatalogPage = () => {
  const [searchParams, setSearchParams] = useSearchParams();

  // Filter States initialized from URL params
  const typeParam = searchParams.get('type');
  const isForSaleParam = searchParams.get('isForSale');
  const isForRentParam = searchParams.get('isForRent');

  const initialListingType =
    typeParam === 'buy' || isForSaleParam === 'true'
      ? 'buy'
      : typeParam === 'rent' || isForRentParam === 'true'
      ? 'rent'
      : 'all';

  const [search, setSearch] = useState(searchParams.get('search') || '');
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || 'all');
  const [selectedBrand, setSelectedBrand] = useState(searchParams.get('brand') || 'all');
  const [selectedDistrict, setSelectedDistrict] = useState(searchParams.get('district') || 'all');
  const [listingType, setListingType] = useState(initialListingType);
  const [hpRange, setHpRange] = useState(searchParams.get('hpRange') || 'all');
  const [maxDailyRate, setMaxDailyRate] = useState(searchParams.get('maxDailyRate') || '8000');
  const [selectedDriveType, setSelectedDriveType] = useState(searchParams.get('driveType') || 'all');

  // Data & State
  const [equipmentList, setEquipmentList] = useState([]);
  const [loading, setLoading] = useState(true);

  // Sync params when filters change
  const fetchEquipment = async () => {
    setLoading(true);
    try {
      const params = {};
      if (search) params.search = search;
      if (selectedCategory && selectedCategory !== 'all') params.category = selectedCategory;
      if (selectedBrand && selectedBrand !== 'all') params.brand = selectedBrand;
      if (selectedDistrict && selectedDistrict !== 'all') params.district = selectedDistrict;
      if (listingType === 'rent') params.isForRent = true;
      if (listingType === 'buy') params.isForSale = true;

      if (hpRange === 'under-30') {
        params.maxHorsepower = 30;
      } else if (hpRange === '30-45') {
        params.minHorsepower = 30;
        params.maxHorsepower = 45;
      } else if (hpRange === '45-60') {
        params.minHorsepower = 45;
        params.maxHorsepower = 60;
      } else if (hpRange === '60-75') {
        params.minHorsepower = 60;
        params.maxHorsepower = 75;
      } else if (hpRange === '75-plus') {
        params.minHorsepower = 75;
      }

      if (maxDailyRate && Number(maxDailyRate) < 8000) {
        params.maxDailyRate = maxDailyRate;
      }

      if (selectedDriveType !== 'all') params.driveType = selectedDriveType;

      const data = await equipmentService.getAll(params);
      setEquipmentList(data || []);
    } catch (err) {
      console.error('Failed to fetch equipment catalog:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    // If URL params change (e.g. clicking Rent or Buy in Navbar)
    const newType = searchParams.get('type');
    if (newType === 'rent' && listingType !== 'rent') setListingType('rent');
    else if (newType === 'buy' && listingType !== 'buy') setListingType('buy');
  }, [searchParams]);

  useEffect(() => {
    fetchEquipment();
  }, [selectedCategory, selectedBrand, selectedDistrict, listingType, selectedDriveType, hpRange]);

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    fetchEquipment();
  };

  const handleClearFilters = () => {
    setSearch('');
    setSelectedCategory('all');
    setSelectedBrand('all');
    setSelectedDistrict('all');
    setListingType('all');
    setHpRange('all');
    setMaxDailyRate('8000');
    setSelectedDriveType('all');
    setSearchParams({});
    equipmentService.getAll().then((data) => setEquipmentList(data || []));
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Top Banner / Breadcrumb */}
      <div className="mb-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-black text-gray-900">
            Indian Agricultural Machinery Marketplace
          </h1>
          <p className="text-xs sm:text-sm text-gray-600 mt-1">
            Browse 120+ verified tractors, combine harvesters, and implements across Maharashtra with live ₹ INR pricing.
          </p>
        </div>

        {/* Quick Search Input */}
        <form onSubmit={handleSearchSubmit} className="flex items-center gap-2 max-w-md w-full">
          <div className="relative flex-1">
            <span className="material-symbols-outlined absolute left-3 top-2.5 text-gray-400 text-lg">
              search
            </span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search Mahindra, Swaraj, Rotavator..."
              className="w-full h-11 pl-10 pr-4 rounded-xl bg-gray-50 border border-gray-300 text-xs font-semibold outline-none focus:bg-white focus:ring-2 focus:ring-emerald-600 transition-all placeholder:text-gray-400"
            />
          </div>
          <button
            type="submit"
            className="h-11 px-5 rounded-xl bg-emerald-700 text-white font-bold text-xs hover:bg-emerald-800 transition-all shadow-sm shrink-0"
          >
            Search
          </button>
        </form>
      </div>

      {/* Quick Filter Bar Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-4 mb-6 border-b border-gray-200">
        <button
          type="button"
          onClick={() => {
            setListingType('all');
            setSearchParams({});
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'all'
              ? 'bg-emerald-700 text-white shadow-sm'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          <span>All Machinery</span>
          <span className="opacity-80">({equipmentList.length})</span>
        </button>

        <button
          type="button"
          onClick={() => {
            setListingType('rent');
            setSearchParams({ type: 'rent' });
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'rent'
              ? 'bg-emerald-700 text-white shadow-sm'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          <span className="material-symbols-outlined text-sm">calendar_month</span>
          <span>Rent Equipment</span>
        </button>

        <button
          type="button"
          onClick={() => {
            setListingType('buy');
            setSearchParams({ type: 'buy' });
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'buy'
              ? 'bg-emerald-700 text-white shadow-sm'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          <span className="material-symbols-outlined text-sm">storefront</span>
          <span>Buy Equipment</span>
        </button>

        <button
          type="button"
          onClick={() => {
            setSelectedCategory('TRACTORS');
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            selectedCategory === 'TRACTORS'
              ? 'bg-emerald-700 text-white shadow-sm'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          <span className="material-symbols-outlined text-sm">agriculture</span>
          <span>Tractors (45+)</span>
        </button>

        <button
          type="button"
          onClick={() => {
            setSelectedCategory('HARVESTERS');
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            selectedCategory === 'HARVESTERS'
              ? 'bg-emerald-700 text-white shadow-sm'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          }`}
        >
          <span className="material-symbols-outlined text-sm">grain</span>
          <span>Combines (10)</span>
        </button>

        <button
          type="button"
          onClick={handleClearFilters}
          className="ml-auto text-xs font-bold text-gray-500 hover:text-red-600 transition-colors flex-shrink-0"
        >
          Clear all filters
        </button>
      </div>

      {/* Main Grid with Left Sidebar Filters */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Left Filter Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-white rounded-2xl p-5 border border-gray-200 shadow-sm space-y-5">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <span className="text-xs font-bold text-gray-900 uppercase tracking-wider">
                Filter Marketplace
              </span>
              <button
                type="button"
                onClick={handleClearFilters}
                className="text-xs text-emerald-700 font-bold hover:underline"
              >
                Reset
              </button>
            </div>

            {/* Brand Filter */}
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                Brand / Manufacturer
              </label>
              <select
                value={selectedBrand}
                onChange={(e) => setSelectedBrand(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-gray-50 border border-gray-300 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-600 cursor-pointer"
              >
                {INDIAN_BRANDS.map((b) => (
                  <option key={b.id} value={b.id}>{b.label}</option>
                ))}
              </select>
            </div>

            {/* District Filter */}
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                Maharashtra District
              </label>
              <select
                value={selectedDistrict}
                onChange={(e) => setSelectedDistrict(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-gray-50 border border-gray-300 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-600 cursor-pointer"
              >
                {MAHARASHTRA_DISTRICTS.map((d) => (
                  <option key={d.id} value={d.id}>{d.label}</option>
                ))}
              </select>
            </div>

            {/* Category Select */}
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                12 Machinery Categories
              </label>
              <div className="space-y-1 max-h-60 overflow-y-auto pr-1">
                {EQUIPMENT_CATEGORIES.map((cat) => (
                  <button
                    key={cat.id}
                    type="button"
                    onClick={() => setSelectedCategory(cat.id)}
                    className={`w-full flex items-center justify-between px-3 py-1.5 rounded-xl text-xs transition-colors ${
                      selectedCategory === cat.id
                        ? 'bg-emerald-100 text-emerald-900 font-bold'
                        : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                    }`}
                  >
                    <span className="flex items-center gap-2 truncate">
                      <span className="material-symbols-outlined text-sm text-emerald-700">{cat.icon}</span>
                      <span className="truncate">{cat.label}</span>
                    </span>
                    <span className="text-[10px] text-gray-400 font-mono shrink-0">
                      {cat.count}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Horsepower Range */}
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                Power Class (HP)
              </label>
              <select
                value={hpRange}
                onChange={(e) => setHpRange(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-gray-50 border border-gray-300 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-600 cursor-pointer"
              >
                <option value="all">All Horsepower</option>
                <option value="under-30">&lt; 30 HP (Mini &amp; Orchard)</option>
                <option value="30-45">30 - 45 HP (Light Utility)</option>
                <option value="45-60">45 - 60 HP (Standard Farmland)</option>
                <option value="60-75">60 - 75 HP (Heavy Duty)</option>
                <option value="75-plus">75+ HP (High Power &amp; Commercial)</option>
              </select>
            </div>

            {/* Daily Rate Slider in ₹ INR */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-bold text-gray-700 uppercase tracking-wider">
                  Max Daily Rate
                </label>
                <span className="text-xs font-bold text-emerald-700">{formatINR(maxDailyRate)}/day</span>
              </div>
              <input
                type="range"
                min="500"
                max="8000"
                step="250"
                value={maxDailyRate}
                onChange={(e) => setMaxDailyRate(e.target.value)}
                onMouseUp={fetchEquipment}
                onTouchEnd={fetchEquipment}
                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-emerald-700"
              />
              <div className="flex justify-between text-[10px] text-gray-400 mt-1 font-semibold">
                <span>₹500/day</span>
                <span>₹8,000/day</span>
              </div>
            </div>

            {/* Drive Type */}
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
                Drive Configuration
              </label>
              <select
                value={selectedDriveType}
                onChange={(e) => setSelectedDriveType(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-gray-50 border border-gray-300 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-600 cursor-pointer"
              >
                <option value="all">All Drive Types</option>
                <option value="4WD">4WD (Four-Wheel Drive)</option>
                <option value="2WD">2WD (Two-Wheel Drive)</option>
                <option value="TRACK">Track / Rubber Tracks</option>
              </select>
            </div>

            <button
              type="button"
              onClick={fetchEquipment}
              className="w-full py-2.5 rounded-xl bg-emerald-700 text-white font-bold text-xs hover:bg-emerald-800 transition-colors shadow-sm"
            >
              Apply Filter Updates
            </button>
          </div>
        </div>

        {/* Right Catalog Equipment Grid */}
        <div className="lg:col-span-3">
          {loading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="h-88 bg-gray-100 rounded-2xl animate-pulse"></div>
              ))}
            </div>
          ) : equipmentList.length === 0 ? (
            <div className="bg-white rounded-2xl p-12 text-center border border-gray-200 space-y-3">
              <span className="material-symbols-outlined text-5xl text-gray-300">
                search_off
              </span>
              <h3 className="text-lg font-bold text-gray-900">
                No Machinery Matches Found
              </h3>
              <p className="text-xs text-gray-500 max-w-md mx-auto">
                We could not find any active machinery matching your exact filters in Maharashtra. Try clearing the district, category, or power class filter.
              </p>
              <button
                type="button"
                onClick={handleClearFilters}
                className="px-5 py-2.5 rounded-xl bg-emerald-700 text-white font-bold text-xs hover:bg-emerald-800 transition-colors"
              >
                Clear All Filters
              </button>
            </div>
          ) : (
            <>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {equipmentList.map((item) => (
                  <EquipmentCard key={item.id} equipment={item} />
                ))}
              </div>

              {/* Kisan Support Callout */}
              <div className="mt-10 bg-emerald-50 border border-emerald-200 rounded-2xl p-5 flex flex-col sm:flex-row items-center justify-between gap-4">
                <div>
                  <h4 className="text-sm font-bold text-emerald-950">
                    Need a custom implement or seasonal operator?
                  </h4>
                  <p className="text-xs text-emerald-800 mt-0.5">
                    Our Maharashtra field network can source specialized harvesters and laser land levellers with vetted tractor drivers.
                  </p>
                </div>
                <a
                  href="tel:+911800247473"
                  className="px-4 py-2 bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs rounded-xl shadow shrink-0 transition-colors flex items-center gap-1.5"
                >
                  <span className="material-symbols-outlined text-base">call</span>
                  Call Kisan Helpline
                </a>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default CatalogPage;
