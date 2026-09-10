import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import StatusBadge from './StatusBadge';
import { formatINR } from '../../utils/currency';
import { useWishlist } from '../../context/WishlistContext';
import { useCompare } from '../../context/CompareContext';
import BuyQuoteModal from './BuyQuoteModal';

export const EquipmentCard = ({ equipment }) => {
  if (!equipment) return null;

  const navigate = useNavigate();
  const { isInWishlist, toggleWishlist } = useWishlist();
  const { isInCompare, toggleCompare } = useCompare();
  const [buyModalOpen, setBuyModalOpen] = useState(false);

  const defaultImage = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80';
  const imageUrl = (equipment.images && equipment.images.split(',')[0]) || defaultImage;

  const isFavorited = isInWishlist(equipment.id);
  const isCompared = isInCompare(equipment.id);

  return (
    <div className="group bg-white rounded-2xl overflow-hidden border border-gray-200 hover:border-emerald-600/50 hover:shadow-xl transition-all duration-300 flex flex-col justify-between relative">
      <div>
        {/* Image Container */}
        <div className="relative aspect-[16/10] overflow-hidden bg-gray-100">
          <img
            src={imageUrl}
            alt={equipment.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            loading="lazy"
          />

          {/* Top badges */}
          <div className="absolute top-3 left-3 flex flex-wrap gap-1.5 z-10">
            <StatusBadge status={equipment.status} />
            {equipment.horsepower > 0 && (
              <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-white/90 text-gray-800 backdrop-blur-md shadow-sm">
                {equipment.horsepower} HP
              </span>
            )}
            {equipment.rating && (
              <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-amber-500 text-white shadow-sm flex items-center gap-0.5">
                ★ {equipment.rating}
              </span>
            )}
          </div>

          {/* Wishlist Heart Button */}
          <button
            type="button"
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              toggleWishlist(equipment);
            }}
            className={`absolute top-3 right-3 z-10 w-8 h-8 rounded-full shadow-md flex items-center justify-center transition-all ${
              isFavorited
                ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                : 'bg-white/90 text-gray-500 hover:text-rose-600 hover:bg-white'
            }`}
            title={isFavorited ? 'Remove from Wishlist' : 'Save to Wishlist'}
          >
            <span className="material-symbols-outlined text-lg">
              {isFavorited ? 'favorite' : 'favorite_border'}
            </span>
          </button>

          {/* Purchase Tag (₹ INR) */}
          {equipment.purchasePrice && (
            <div className="absolute bottom-3 right-3 bg-emerald-900/90 text-white backdrop-blur-sm text-xs font-bold px-2.5 py-1 rounded-lg shadow-sm">
              Buy: {formatINR(equipment.purchasePrice)}
            </div>
          )}
        </div>

        {/* Card Body */}
        <div className="p-5">
          <div className="flex items-center justify-between text-xs text-gray-500 mb-1.5">
            <div className="flex items-center gap-1 truncate">
              <span className="material-symbols-outlined text-sm text-emerald-700">location_on</span>
              <span className="truncate">{equipment.district || equipment.city}, Maharashtra</span>
            </div>
            <span className="font-bold text-emerald-800 bg-emerald-50 px-2 py-0.5 rounded text-[10px] uppercase tracking-wider shrink-0">
              {equipment.brand || equipment.make}
            </span>
          </div>

          <Link to={`/equipment/${equipment.id}`}>
            <h3 className="text-base font-bold text-gray-900 group-hover:text-emerald-700 transition-colors line-clamp-1">
              {equipment.title}
            </h3>
          </Link>
          <p className="text-xs text-gray-500 line-clamp-1 mt-0.5">
            {equipment.variant || `${equipment.category}`}
          </p>

          {/* Quick Specs Pill Row */}
          <div className="flex items-center gap-2 mt-3 text-xs text-gray-600">
            <span className="inline-flex items-center gap-1 bg-gray-50 px-2 py-1 rounded-md border border-gray-100">
              <span className="material-symbols-outlined text-xs">timer</span>
              {equipment.engineHours || 0} hrs
            </span>
            {equipment.driveType && equipment.driveType !== 'N/A' && (
              <span className="inline-flex items-center gap-1 bg-gray-50 px-2 py-1 rounded-md border border-gray-100">
                <span className="material-symbols-outlined text-xs">settings</span>
                {equipment.driveType}
              </span>
            )}
            <span className="inline-flex items-center gap-1 bg-emerald-50 text-emerald-800 px-2 py-1 rounded-md border border-emerald-100">
              <span className="material-symbols-outlined text-xs">verified</span>
              Escrow Insured
            </span>
          </div>
        </div>
      </div>

      {/* Card Footer */}
      <div className="px-5 py-4 border-t border-gray-100 bg-gray-50/70 space-y-3">
        {/* Pricing Rows */}
        <div className="flex items-baseline justify-between">
          <div>
            <div className="text-[10px] uppercase font-bold text-gray-400 tracking-wider">Rent Rate</div>
            <div className="flex items-baseline gap-1">
              <span className="text-xl font-extrabold text-emerald-700">
                {formatINR(equipment.dailyRate)}
              </span>
              <span className="text-xs text-gray-500 font-medium">/ day</span>
            </div>
          </div>

          <div className="text-right">
            <div className="text-[10px] uppercase font-bold text-gray-400 tracking-wider">Ex-Showroom</div>
            <div className="text-sm font-bold text-gray-900">
              {equipment.purchasePrice ? formatINR(equipment.purchasePrice) : 'Price on Request'}
            </div>
          </div>
        </div>

        {/* Dual Actions: Rent Now & Buy / Enquire */}
        <div className="grid grid-cols-2 gap-2">
          <button
            type="button"
            onClick={() => navigate(`/equipment/${equipment.id}`)}
            className="w-full py-2 px-3 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-sm hover:shadow transition-all flex items-center justify-center gap-1"
          >
            <span>Rent Now</span>
            <span className="material-symbols-outlined text-sm">arrow_forward</span>
          </button>

          <button
            type="button"
            onClick={() => setBuyModalOpen(true)}
            className="w-full py-2 px-3 bg-white hover:bg-gray-100 text-gray-800 border border-gray-300 text-xs font-bold rounded-xl shadow-sm transition-all flex items-center justify-center gap-1"
          >
            <span className="material-symbols-outlined text-sm text-emerald-700">shopping_cart</span>
            <span>Buy / Enquire</span>
          </button>
        </div>

        {/* Bottom compare & view details links */}
        <div className="flex items-center justify-between text-[11px] pt-1 text-gray-500">
          <label
            onClick={(e) => e.stopPropagation()}
            className="flex items-center gap-1.5 cursor-pointer hover:text-emerald-700 font-semibold"
          >
            <input
              type="checkbox"
              checked={isCompared}
              onChange={() => toggleCompare(equipment)}
              className="rounded text-emerald-600 focus:ring-emerald-500 w-3.5 h-3.5"
            />
            <span>Compare</span>
          </label>

          <Link
            to={`/equipment/${equipment.id}`}
            className="text-emerald-700 hover:text-emerald-800 font-bold hover:underline"
          >
            View Details →
          </Link>
        </div>
      </div>

      {/* Buy Quote Modal */}
      {buyModalOpen && (
        <BuyQuoteModal
          isOpen={buyModalOpen}
          onClose={() => setBuyModalOpen(false)}
          equipment={equipment}
        />
      )}
    </div>
  );
};

export default EquipmentCard;
