import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Modal from './Modal';
import { formatINR } from '../../utils/currency';

export const BuyQuoteModal = ({ isOpen, onClose, equipment }) => {
  const navigate = useNavigate();
  const [district, setDistrict] = useState('Pune');
  const [deliveryType, setDeliveryType] = useState('DEALER_PICKUP'); // DEALER_PICKUP, FARM_DELIVERY

  if (!equipment) return null;

  const price = equipment.purchasePrice || 750000;
  const deliveryCost = deliveryType === 'FARM_DELIVERY' ? 4500 : 0;
  const platformFee = 1500;
  const totalAmount = price + deliveryCost + platformFee;

  const handleProceedToCheckout = () => {
    onClose();
    navigate('/checkout', {
      state: {
        type: 'PURCHASE',
        equipment,
        deliveryType,
        district,
        deliveryCost,
        platformFee,
        totalAmount
      }
    });
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Purchase Quotation & Order" maxWidth="max-w-xl">
      <div className="space-y-5">
        {/* Machine Summary */}
        <div className="flex items-center gap-4 bg-gray-50 border border-gray-200 rounded-2xl p-4">
          <img
            src={equipment.images || 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=300&q=80'}
            alt={equipment.title}
            className="w-20 h-20 object-cover rounded-xl border border-gray-200"
          />
          <div className="flex-1 min-w-0">
            <span className="text-[11px] font-bold text-emerald-700 uppercase tracking-wider">
              {equipment.brand || equipment.make} • {equipment.category}
            </span>
            <h4 className="text-sm font-bold text-gray-900 truncate">{equipment.title}</h4>
            <p className="text-xs text-gray-500 mt-0.5">{equipment.horsepower ? `${equipment.horsepower} HP • ` : ''}{equipment.district || equipment.city}, Maharashtra</p>
            <div className="text-base font-extrabold text-gray-900 mt-1">
              {formatINR(price)}
              <span className="text-xs font-normal text-gray-500 ml-1.5">(Ex-Showroom)</span>
            </div>
          </div>
        </div>

        {/* Verified Price Source Badge */}
        {equipment.priceSourceName && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 flex items-start gap-2.5">
            <span className="material-symbols-outlined text-blue-700 text-lg mt-0.5">verified</span>
            <div className="text-xs text-blue-900">
              <span className="font-bold">Verified Manufacturer Price:</span> Verified from <span className="font-semibold">{equipment.priceSourceName}</span>
              {equipment.lastVerifiedDate ? ` on ${equipment.lastVerifiedDate}` : ''}.
              {equipment.priceSourceUrl && (
                <a
                  href={equipment.priceSourceUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="block text-[11px] text-blue-700 underline font-semibold mt-0.5"
                >
                  View official source pricing documentation
                </a>
              )}
            </div>
          </div>
        )}

        {/* Delivery Options */}
        <div className="space-y-3">
          <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider">
            Fulfilment & Delivery Method
          </label>
          <div className="grid grid-cols-2 gap-3">
            <button
              type="button"
              onClick={() => setDeliveryType('DEALER_PICKUP')}
              className={`p-3 text-left rounded-xl border transition-all ${
                deliveryType === 'DEALER_PICKUP'
                  ? 'border-emerald-600 bg-emerald-50/70'
                  : 'border-gray-200 bg-white hover:border-gray-300'
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-bold text-gray-900">Authorized Dealer Pickup</span>
                <span className="text-[10px] font-bold text-emerald-700 bg-emerald-100 px-1.5 py-0.5 rounded">FREE</span>
              </div>
              <p className="text-[11px] text-gray-500">Pick up directly with full inspection at regional agro hub.</p>
            </button>

            <button
              type="button"
              onClick={() => setDeliveryType('FARM_DELIVERY')}
              className={`p-3 text-left rounded-xl border transition-all ${
                deliveryType === 'FARM_DELIVERY'
                  ? 'border-emerald-600 bg-emerald-50/70'
                  : 'border-gray-200 bg-white hover:border-gray-300'
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-bold text-gray-900">Direct Farm Delivery</span>
                <span className="text-[11px] font-bold text-gray-800">₹4,500</span>
              </div>
              <p className="text-[11px] text-gray-500">Delivered via heavy flatbed trailer right to your field gates.</p>
            </button>
          </div>
        </div>

        {/* Price Breakdown */}
        <div className="bg-gray-50 rounded-xl p-3.5 space-y-2 text-xs border border-gray-200">
          <div className="flex justify-between text-gray-600">
            <span>Machine Price</span>
            <span className="font-semibold text-gray-900">{formatINR(price)}</span>
          </div>
          <div className="flex justify-between text-gray-600">
            <span>Transportation / Fulfilment</span>
            <span className="font-semibold text-gray-900">{deliveryCost === 0 ? 'Free Pickup' : formatINR(deliveryCost)}</span>
          </div>
          <div className="flex justify-between text-gray-600">
            <span>Documentation & Registration Support</span>
            <span className="font-semibold text-gray-900">{formatINR(platformFee)}</span>
          </div>
          <div className="border-t border-gray-200 pt-2 flex justify-between text-sm font-bold text-gray-900">
            <span>Total Payable Amount</span>
            <span className="text-emerald-700">{formatINR(totalAmount)}</span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center justify-end gap-3 pt-2">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 text-xs font-semibold text-gray-600 hover:bg-gray-100 rounded-xl"
          >
            Back
          </button>
          <button
            type="button"
            onClick={handleProceedToCheckout}
            className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-md transition-all flex items-center gap-1.5"
          >
            <span className="material-symbols-outlined text-base">shopping_cart_checkout</span>
            Proceed to Secure Purchase / Booking
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default BuyQuoteModal;
