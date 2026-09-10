import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useWishlist } from '../../context/WishlistContext';
import { useCompare } from '../../context/CompareContext';
import { formatINR } from '../../utils/currency';
import BuyQuoteModal from '../../components/common/BuyQuoteModal';
import ContactOwnerModal from '../../components/common/ContactOwnerModal';

export const WishlistPage = () => {
  const { wishlist, removeFromWishlist, clearWishlist } = useWishlist();
  const { addToCompare, isInCompare } = useCompare();
  const [selectedBuyItem, setSelectedBuyItem] = useState(null);
  const [selectedContactItem, setSelectedContactItem] = useState(null);
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-surface flex flex-col">
      <main className="flex-1 max-w-7xl mx-auto px-4 py-10 w-full space-y-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200 pb-6">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="material-symbols-outlined text-rose-600 text-2xl">favorite</span>
              <h1 className="text-2xl md:text-3xl font-black text-gray-900">Saved Farm Machinery (Wishlist)</h1>
            </div>
            <p className="text-sm text-gray-600">
              Your shortlisted tractors, implements, and combine harvesters saved for seasonal farm operations.
            </p>
          </div>

          <div className="flex items-center gap-3">
            {wishlist.length > 0 && (
              <button
                type="button"
                onClick={clearWishlist}
                className="text-xs font-semibold text-red-600 hover:text-red-700 px-3 py-2 border border-red-200 rounded-xl hover:bg-red-50 transition-colors"
              >
                Clear Wishlist ({wishlist.length})
              </button>
            )}
            <Link
              to="/catalog"
              className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow transition-all flex items-center gap-1.5"
            >
              <span className="material-symbols-outlined text-base">storefront</span>
              Explore Machinery
            </Link>
          </div>
        </div>

        {/* Wishlist Items */}
        {wishlist.length === 0 ? (
          <div className="bg-white border border-gray-200 rounded-3xl p-12 text-center space-y-4 max-w-xl mx-auto my-8">
            <div className="w-16 h-16 bg-rose-50 text-rose-500 rounded-2xl flex items-center justify-center mx-auto text-3xl">
              <span className="material-symbols-outlined text-4xl">favorite_border</span>
            </div>
            <h3 className="text-lg font-bold text-gray-900">Your Wishlist is Empty</h3>
            <p className="text-xs text-gray-600 leading-relaxed">
              You haven't saved any tractors or implements yet. Browse through our catalog and click the heart icon to shortlist machinery for your upcoming harvest or sowing season.
            </p>
            <div className="pt-2">
              <Link
                to="/catalog"
                className="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-md transition-all"
              >
                <span className="material-symbols-outlined text-base">agriculture</span>
                Browse 120+ Indian Machines
              </Link>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {wishlist.map((item) => (
              <div
                key={item.id}
                className="bg-white border border-gray-200 rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-all flex flex-col group relative"
              >
                {/* Remove Button */}
                <button
                  type="button"
                  onClick={() => removeFromWishlist(item.id)}
                  className="absolute top-3 right-3 z-10 w-8 h-8 rounded-full bg-white/90 hover:bg-white text-rose-600 shadow flex items-center justify-center transition-transform hover:scale-110"
                  title="Remove from wishlist"
                >
                  <span className="material-symbols-outlined text-lg">favorite</span>
                </button>

                {/* Image */}
                <div className="relative aspect-[16/10] overflow-hidden bg-gray-100">
                  <img
                    src={item.images || 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=600&q=80'}
                    alt={item.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                  <div className="absolute bottom-2 left-2 flex gap-1.5">
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-900/80 text-white backdrop-blur-sm">
                      {item.category}
                    </span>
                    {item.horsepower && (
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-black/60 text-white backdrop-blur-sm">
                        {item.horsepower} HP
                      </span>
                    )}
                  </div>
                </div>

                {/* Details */}
                <div className="p-4 flex-1 flex flex-col justify-between space-y-3">
                  <div>
                    <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-wider">
                      {item.brand || item.make}
                    </span>
                    <h3 className="text-sm font-bold text-gray-900 line-clamp-1">{item.title}</h3>
                    <p className="text-xs text-gray-500 flex items-center gap-1 mt-0.5">
                      <span className="material-symbols-outlined text-xs">location_on</span>
                      {item.district || item.city}, Maharashtra
                    </p>
                  </div>

                  {/* Pricing */}
                  <div className="bg-gray-50 rounded-xl p-2.5 flex items-center justify-between">
                    <div>
                      <span className="text-[10px] text-gray-500 block">Rent Rate</span>
                      <strong className="text-xs font-bold text-emerald-700">
                        {formatINR(item.dailyRate)}/day
                      </strong>
                    </div>
                    <div className="text-right">
                      <span className="text-[10px] text-gray-500 block">Ex-Showroom Price</span>
                      <strong className="text-xs font-bold text-gray-900">
                        {item.purchasePrice ? formatINR(item.purchasePrice) : 'On Request'}
                      </strong>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="grid grid-cols-2 gap-2 pt-1">
                    <button
                      type="button"
                      onClick={() => navigate(`/equipment/${item.id}`)}
                      className="py-2 px-3 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl text-center shadow-sm transition-colors"
                    >
                      Rent Now
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedBuyItem(item)}
                      className="py-2 px-3 bg-gray-100 hover:bg-gray-200 text-gray-800 text-xs font-bold rounded-xl text-center transition-colors"
                    >
                      Buy / Quote
                    </button>
                  </div>

                  <div className="flex items-center justify-between pt-1 border-t border-gray-100 text-[11px]">
                    <button
                      type="button"
                      onClick={() => addToCompare(item)}
                      className="text-gray-600 hover:text-emerald-700 flex items-center gap-1 font-semibold"
                    >
                      <span className="material-symbols-outlined text-sm">
                        {isInCompare(item.id) ? 'check_box' : 'add_box'}
                      </span>
                      {isInCompare(item.id) ? 'In Compare' : 'Add to Compare'}
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedContactItem(item)}
                      className="text-gray-600 hover:text-emerald-700 flex items-center gap-1 font-semibold"
                    >
                      <span className="material-symbols-outlined text-sm">chat</span>
                      Contact Owner
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Buy Quote Modal */}
      {selectedBuyItem && (
        <BuyQuoteModal
          isOpen={!!selectedBuyItem}
          onClose={() => setSelectedBuyItem(null)}
          equipment={selectedBuyItem}
        />
      )}

      {/* Contact Owner Modal */}
      {selectedContactItem && (
        <ContactOwnerModal
          isOpen={!!selectedContactItem}
          onClose={() => setSelectedContactItem(null)}
          equipment={selectedContactItem}
        />
      )}
    </div>
  );
};

export default WishlistPage;
