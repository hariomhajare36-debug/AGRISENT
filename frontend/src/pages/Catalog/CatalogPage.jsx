import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { equipmentService } from '../../services/equipmentService';
import EquipmentCard from '../../components/common/EquipmentCard';
import { EQUIPMENT_CATEGORIES } from '../../constants/categories';

export const CatalogPage = () => {
  const [searchParams, setSearchParams] = useSearchParams();

  // Filter States
  const [search, setSearch] = useState(searchParams.get('search') || '');
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || 'all');
  const [listingType, setListingType] = useState(
    searchParams.get('isForSale') === 'true'
      ? 'buy'
      : searchParams.get('isForRent') === 'true'
      ? 'rent'
      : 'all'
  );
  const [minHp, setMinHp] = useState(searchParams.get('minHp') || '');
  const [maxHp, setMaxHp] = useState(searchParams.get('maxHp') || '');
  const [maxDailyRate, setMaxDailyRate] = useState(searchParams.get('maxRate') || '4000');
  const [selectedDriveType, setSelectedDriveType] = useState(searchParams.get('driveType') || 'all');

  // Data & State
  const [equipmentList, setEquipmentList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [mobileFilterOpen, setMobileFilterOpen] = useState(false);

  // Sync params when filters change
  const fetchEquipment = async () => {
    setLoading(true);
    try {
      const params = {};
      if (search) params.search = search;
      if (selectedCategory && selectedCategory !== 'all') params.category = selectedCategory;
      if (listingType === 'rent') params.isForRent = true;
      if (listingType === 'buy') params.isForSale = true;
      if (minHp) params.minHorsepower = minHp;
      if (maxHp) params.maxHorsepower = maxHp;
      if (maxDailyRate) params.maxDailyRate = maxDailyRate;
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
    fetchEquipment();
  }, [selectedCategory, listingType, selectedDriveType]);

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    fetchEquipment();
  };

  const handleClearFilters = () => {
    setSearch('');
    setSelectedCategory('all');
    setListingType('all');
    setMinHp('');
    setMaxHp('');
    setMaxDailyRate('4000');
    setSelectedDriveType('all');
    setSearchParams({});
    equipmentService.getAll().then((data) => setEquipmentList(data || []));
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Top Banner / Breadcrumb */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="font-headline-xl text-3xl font-extrabold text-on-surface">
            Equipment Search &amp; Marketplace Catalog
          </h1>
          <p className="text-sm text-on-surface-variant mt-1">
            Browse verified agricultural heavy machinery available for direct rental and purchase
          </p>
        </div>

        {/* Quick Search Input */}
        <form onSubmit={handleSearchSubmit} className="flex items-center gap-2 max-w-md w-full sm:w-auto">
          <div className="relative flex-1">
            <span className="material-symbols-outlined absolute left-3 top-2.5 text-on-surface-variant text-xl">
              search
            </span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search make, model, category..."
              className="w-full h-11 pl-10 pr-4 rounded-xl bg-surface-container-low border border-outline-variant/50 text-sm outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary/40 transition-all"
            />
          </div>
          <button
            type="submit"
            className="h-11 px-5 rounded-xl bg-primary text-on-primary font-semibold text-sm hover:bg-primary-container transition-all"
          >
            Search
          </button>
        </form>
      </div>

      {/* Quick Filter Bar Pills */}
      <div className="flex items-center gap-2 overflow-x-auto pb-4 mb-6 border-b border-outline-variant/30">
        <button
          onClick={() => setListingType('all')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'all'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          <span>All Equipment</span>
          <span className="opacity-80">({equipmentList.length})</span>
        </button>

        <button
          onClick={() => setListingType('rent')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'rent'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          <span className="material-symbols-outlined text-sm">calendar_month</span>
          <span>For Rent</span>
        </button>

        <button
          onClick={() => setListingType('buy')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            listingType === 'buy'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          <span className="material-symbols-outlined text-sm">storefront</span>
          <span>Buy Only</span>
        </button>

        <button
          onClick={() => {
            setMinHp('300');
            fetchEquipment();
          }}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 flex-shrink-0 ${
            minHp === '300'
              ? 'bg-primary text-on-primary shadow-sm'
              : 'bg-surface-container-low text-on-surface-variant hover:bg-surface-container-high'
          }`}
        >
          <span className="material-symbols-outlined text-sm text-secondary">bolt</span>
          <span>&gt; 300 HP Heavy Duty</span>
        </button>

        <button
          onClick={handleClearFilters}
          className="ml-auto text-xs font-semibold text-on-surface-variant hover:text-error transition-colors flex-shrink-0"
        >
          Clear all filters
        </button>
      </div>

      {/* Main Grid with Left Sidebar Filters */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Left Filter Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          <div className="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/50 shadow-sm space-y-6">
            <div className="flex items-center justify-between pb-3 border-b border-outline-variant/30">
              <span className="font-label-md text-sm font-bold text-on-surface uppercase tracking-wider">
                Filter Fleet
              </span>
              <button
                onClick={handleClearFilters}
                className="text-xs text-primary font-semibold hover:underline"
              >
                Reset
              </button>
            </div>

            {/* Category Select */}
            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-2">
                Machinery Category
              </label>
              <div className="space-y-1.5">
                {EQUIPMENT_CATEGORIES.map((cat) => (
                  <button
                    key={cat.id}
                    onClick={() => setSelectedCategory(cat.id)}
                    className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-medium transition-colors ${
                      selectedCategory === cat.id
                        ? 'bg-primary-container text-on-primary font-bold'
                        : 'text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface'
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-base">{cat.icon}</span>
                      {cat.label}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Daily Rate Slider */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-xs font-bold text-on-surface uppercase tracking-wider">
                  Max Daily Rate
                </label>
                <span className="text-xs font-bold text-primary">${maxDailyRate} / day</span>
              </div>
              <input
                type="range"
                min="300"
                max="5000"
                step="50"
                value={maxDailyRate}
                onChange={(e) => setMaxDailyRate(e.target.value)}
                onMouseUp={fetchEquipment}
                onTouchEnd={fetchEquipment}
                className="w-full accent-primary cursor-pointer"
              />
              <div className="flex justify-between text-[10px] text-on-surface-variant mt-1 font-semibold">
                <span>$300/day</span>
                <span>$5,000/day</span>
              </div>
            </div>

            {/* Drive Type */}
            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-2">
                Drive Configuration
              </label>
              <select
                value={selectedDriveType}
                onChange={(e) => setSelectedDriveType(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40 cursor-pointer"
              >
                <option value="all">All Drive Configurations</option>
                <option value="4WD">4WD (Four-Wheel Drive)</option>
                <option value="TRACK">Track / Quadtrac</option>
                <option value="MFWD">MFWD (Mechanical Front Wheel)</option>
                <option value="2WD">2WD (Two-Wheel Drive)</option>
              </select>
            </div>

            <button
              onClick={fetchEquipment}
              className="w-full py-2.5 rounded-xl bg-primary text-on-primary font-bold text-xs hover:bg-primary-container transition-colors shadow-sm"
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
                <div key={i} className="h-88 bg-surface-container-high rounded-2xl animate-pulse"></div>
              ))}
            </div>
          ) : equipmentList.length === 0 ? (
            <div className="bg-surface-container-lowest rounded-2xl p-12 text-center border border-outline-variant/40">
              <span className="material-symbols-outlined text-5xl text-on-surface-variant/40 mb-3">
                search_off
              </span>
              <h3 className="font-headline-sm text-xl font-bold text-on-surface mb-2">
                No Machinery Matches Found
              </h3>
              <p className="text-sm text-on-surface-variant max-w-md mx-auto mb-6">
                We could not find any active machinery matching your exact search criteria. Try adjusting your power range, daily rate slider, or category.
              </p>
              <button
                onClick={handleClearFilters}
                className="px-5 py-2.5 rounded-xl bg-primary text-on-primary font-bold text-sm hover:bg-primary-container transition-colors"
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

              {/* Callout box at bottom of catalog */}
              <div className="mt-12 bg-surface-container-low rounded-2xl p-6 border border-outline-variant/40 flex flex-col sm:flex-row items-center justify-between gap-4">
                <div>
                  <h4 className="font-headline-sm text-base font-bold text-on-surface">
                    Can't find the exact tractor or implement configuration?
                  </h4>
                  <p className="text-xs text-on-surface-variant mt-0.5">
                    Our platform concierge network can source high-spec machines across neighbouring counties with insured flatbed delivery.
                  </p>
                </div>
                <button
                  type="button"
                  className="px-4 py-2.5 rounded-xl bg-surface-container-highest hover:bg-surface-container font-bold text-xs text-on-surface flex-shrink-0 transition-colors"
                >
                  Request Custom Equipment Sourcing
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default CatalogPage;
