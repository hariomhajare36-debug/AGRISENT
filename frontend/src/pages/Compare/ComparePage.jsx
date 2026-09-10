import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useCompare } from '../../context/CompareContext';
import { formatINR } from '../../utils/currency';
import BuyQuoteModal from '../../components/common/BuyQuoteModal';
import ContactOwnerModal from '../../components/common/ContactOwnerModal';

export const ComparePage = () => {
  const { compareList, removeFromCompare, clearCompare } = useCompare();
  const [highlightDiff, setHighlightDiff] = useState(false);
  const [selectedBuyItem, setSelectedBuyItem] = useState(null);
  const [selectedContactItem, setSelectedContactItem] = useState(null);
  const navigate = useNavigate();

  const specs = [
    { key: 'brand', label: 'Brand / Manufacturer', render: (item) => item.brand || item.make },
    { key: 'category', label: 'Equipment Category', render: (item) => item.category },
    { key: 'horsepower', label: 'Horsepower (HP)', render: (item) => item.horsepower ? `${item.horsepower} HP` : 'N/A' },
    { key: 'driveType', label: 'Drive Type', render: (item) => item.driveType || 'Standard' },
    { key: 'dailyRate', label: 'Rental Rate (Daily)', render: (item) => <strong className="text-emerald-700">{formatINR(item.dailyRate)}/day</strong> },
    { key: 'weeklyRate', label: 'Rental Rate (Weekly)', render: (item) => formatINR(item.weeklyRate || item.dailyRate * 6.2) },
    { key: 'purchasePrice', label: 'Ex-Showroom Price', render: (item) => <strong className="text-gray-900">{formatINR(item.purchasePrice)}</strong> },
    { key: 'priceSourceName', label: 'Price Verification', render: (item) => item.priceSourceName || 'AgriRent Verified' },
    { key: 'liftingCapacityKg', label: 'Lifting Capacity', render: (item) => item.liftingCapacityKg ? `${item.liftingCapacityKg} kg` : 'N/A' },
    { key: 'fuelTankLitres', label: 'Fuel Tank Capacity', render: (item) => item.fuelTankLitres ? `${item.fuelTankLitres} Litres` : 'N/A' },
    { key: 'transmission', label: 'Transmission', render: (item) => item.transmission || 'Standard Gearbox' },
    { key: 'ptoSpeed', label: 'PTO Speed', render: (item) => item.ptoSpeed || item.ptoRpm || '540 RPM' },
    { key: 'district', label: 'Location (District)', render: (item) => `${item.district || item.city}, Maharashtra` },
    { key: 'rating', label: 'Field Rating', render: (item) => `★ ${item.rating || '4.8'} / 5.0` },
    { key: 'engineHours', label: 'Operating Hours', render: (item) => `${item.engineHours || 120} hrs` },
  ];

  return (
    <div className="min-h-screen bg-surface flex flex-col">
      <main className="flex-1 max-w-7xl mx-auto px-4 py-10 w-full space-y-8">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-200 pb-6">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="material-symbols-outlined text-emerald-700 text-2xl">compare_arrows</span>
              <h1 className="text-2xl md:text-3xl font-black text-gray-900">Equipment Comparison Matrix</h1>
            </div>
            <p className="text-sm text-gray-600">
              Compare up to 4 tractors or agricultural implements side-by-side on horsepower, lifting capacity, rental rates, and purchase prices.
            </p>
          </div>

          <div className="flex items-center gap-3">
            {compareList.length > 1 && (
              <label className="flex items-center gap-2 text-xs font-semibold text-gray-700 cursor-pointer bg-gray-100 hover:bg-gray-200 px-3.5 py-2 rounded-xl transition-colors">
                <input
                  type="checkbox"
                  checked={highlightDiff}
                  onChange={(e) => setHighlightDiff(e.target.checked)}
                  className="rounded text-emerald-600 focus:ring-emerald-500"
                />
                Highlight Differences
              </label>
            )}

            {compareList.length > 0 && (
              <button
                type="button"
                onClick={clearCompare}
                className="text-xs font-semibold text-red-600 hover:text-red-700 px-3 py-2 border border-red-200 rounded-xl hover:bg-red-50 transition-colors"
              >
                Clear All ({compareList.length})
              </button>
            )}

            <Link
              to="/catalog"
              className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow transition-all flex items-center gap-1.5"
            >
              <span className="material-symbols-outlined text-base">add</span>
              Add More Machines
            </Link>
          </div>
        </div>

        {/* Empty State */}
        {compareList.length === 0 ? (
          <div className="bg-white border border-gray-200 rounded-3xl p-12 text-center space-y-4 max-w-xl mx-auto my-8">
            <div className="w-16 h-16 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center mx-auto text-3xl">
              <span className="material-symbols-outlined text-4xl">compare_arrows</span>
            </div>
            <h3 className="text-lg font-bold text-gray-900">No Machines Selected for Comparison</h3>
            <p className="text-xs text-gray-600 leading-relaxed">
              Explore our catalog of 120+ Indian tractors and farm implements. Click the <strong className="text-emerald-700">"Compare"</strong> checkbox on any equipment card to compare specs side-by-side.
            </p>
            <div className="pt-2">
              <Link
                to="/catalog"
                className="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-md transition-all"
              >
                <span className="material-symbols-outlined text-base">storefront</span>
                Explore Machinery Catalog
              </Link>
            </div>
          </div>
        ) : (
          /* Comparison Table */
          <div className="bg-white border border-gray-200 rounded-2xl shadow-sm overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="border-b border-gray-200 bg-gray-50/70">
                  <th className="p-4 text-xs font-bold text-gray-500 uppercase tracking-wider w-56 sticky left-0 bg-gray-50/90 backdrop-blur z-10">
                    Feature / Specification
                  </th>
                  {compareList.map((item) => (
                    <th key={item.id} className="p-4 min-w-[260px] max-w-[300px] align-top">
                      <div className="relative space-y-3 bg-white border border-gray-200 rounded-xl p-3.5 shadow-sm">
                        <button
                          type="button"
                          onClick={() => removeFromCompare(item.id)}
                          className="absolute -top-2 -right-2 w-6 h-6 bg-red-100 hover:bg-red-200 text-red-600 rounded-full flex items-center justify-center text-xs shadow transition-colors"
                          title="Remove from comparison"
                        >
                          ✕
                        </button>
                        <img
                          src={item.images || 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=400&q=80'}
                          alt={item.title}
                          className="w-full h-36 object-cover rounded-lg border border-gray-100"
                        />
                        <div>
                          <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-wider">
                            {item.brand || item.make}
                          </span>
                          <h4 className="text-sm font-bold text-gray-900 line-clamp-1">{item.title}</h4>
                          <p className="text-[11px] text-gray-500">{item.variant || item.model}</p>
                        </div>
                        <div className="flex gap-2 pt-1">
                          <button
                            type="button"
                            onClick={() => navigate(`/equipment/${item.id}`)}
                            className="flex-1 py-1.5 px-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-[11px] font-bold text-center shadow-sm"
                          >
                            Rent Now
                          </button>
                          <button
                            type="button"
                            onClick={() => setSelectedBuyItem(item)}
                            className="flex-1 py-1.5 px-2 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-lg text-[11px] font-bold text-center"
                          >
                            Buy / Quote
                          </button>
                        </div>
                      </div>
                    </th>
                  ))}
                  {/* Fill empty comparison slots if under 4 */}
                  {Array.from({ length: 4 - compareList.length }).map((_, idx) => (
                    <th key={`empty-${idx}`} className="p-4 min-w-[240px] align-middle text-center">
                      <Link
                        to="/catalog"
                        className="block border-2 border-dashed border-gray-300 hover:border-emerald-500 rounded-xl p-8 text-gray-400 hover:text-emerald-700 transition-all group"
                      >
                        <span className="material-symbols-outlined text-3xl group-hover:scale-110 transition-transform">
                          add_circle
                        </span>
                        <div className="text-xs font-bold mt-2">Add Machine to Slot {compareList.length + idx + 1}</div>
                      </Link>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 text-xs">
                {specs.map((spec) => {
                  const values = compareList.map((item) => String(spec.render(item)));
                  const isDifferent = compareList.length > 1 && new Set(values).size > 1;

                  return (
                    <tr
                      key={spec.key}
                      className={`transition-colors ${
                        highlightDiff && isDifferent ? 'bg-amber-50/60 font-medium' : 'hover:bg-gray-50/80'
                      }`}
                    >
                      <td className="p-4 font-semibold text-gray-700 sticky left-0 bg-white/95 backdrop-blur z-10 border-r border-gray-200">
                        {spec.label}
                        {highlightDiff && isDifferent && (
                          <span className="ml-2 text-[10px] font-bold text-amber-700 bg-amber-100 px-1.5 py-0.5 rounded">
                            Differs
                          </span>
                        )}
                      </td>
                      {compareList.map((item) => (
                        <td key={item.id} className="p-4 text-gray-800 align-middle">
                          {spec.render(item)}
                        </td>
                      ))}
                      {Array.from({ length: 4 - compareList.length }).map((_, idx) => (
                        <td key={`empty-cell-${idx}`} className="p-4 text-gray-300 italic text-center">
                          —
                        </td>
                      ))}
                    </tr>
                  );
                })}
              </tbody>
            </table>
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

export default ComparePage;
