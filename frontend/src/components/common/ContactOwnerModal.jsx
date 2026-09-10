import React, { useState } from 'react';
import Modal from './Modal';
import { formatINR } from '../../utils/currency';

export const ContactOwnerModal = ({ isOpen, onClose, equipment, owner }) => {
  const [message, setMessage] = useState('');
  const [purpose, setPurpose] = useState('RENTAL');
  const [phone, setPhone] = useState('');
  const [sent, setSent] = useState(false);

  const ownerName = owner?.fullName || equipment?.owner?.fullName || 'Vikram Shinde';
  const ownerPhone = owner?.phone || equipment?.owner?.phone || '+91 98220 12343';
  const ownerLocation = equipment?.district || equipment?.city || 'Nashik, Maharashtra';
  const machineTitle = equipment?.title || 'Agricultural Machine';

  const handleSendEnquiry = (e) => {
    e.preventDefault();
    setSent(true);
    setTimeout(() => {
      setSent(false);
      onClose();
    }, 2500);
  };

  const whatsappMessage = encodeURIComponent(
    `Namaste ${ownerName}, I found your listing "${machineTitle}" on AgriRent India. I would like to inquire about ${purpose === 'RENTAL' ? 'renting it' : 'purchasing it'}. Please share the current availability and field trial schedule.`
  );

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={`Contact Owner / Dealer`} maxWidth="max-w-xl">
      {sent ? (
        <div className="py-8 text-center space-y-4">
          <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto text-3xl">
            <span className="material-symbols-outlined text-4xl">check_circle</span>
          </div>
          <h4 className="text-xl font-bold text-gray-900">Enquiry Sent to Owner!</h4>
          <p className="text-sm text-gray-600 max-w-sm mx-auto">
            {ownerName} has been notified via SMS & AgriRent alert. You will also receive a callback on your contact number shortly.
          </p>
        </div>
      ) : (
        <div className="space-y-5">
          {/* Owner Profile Card */}
          <div className="bg-emerald-50/70 border border-emerald-200/80 rounded-2xl p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-full bg-emerald-700 text-white font-bold text-lg flex items-center justify-center shrink-0">
              {ownerName.charAt(0)}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h4 className="text-sm font-bold text-gray-900 truncate">{ownerName}</h4>
                <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800">
                  <span className="material-symbols-outlined text-xs mr-0.5">verified</span> Verified Owner
                </span>
              </div>
              <p className="text-xs text-gray-600 flex items-center gap-1 mt-0.5">
                <span className="material-symbols-outlined text-sm text-gray-400">location_on</span>
                {ownerLocation}
              </p>
              <p className="text-xs text-gray-500 font-mono mt-0.5">{ownerPhone}</p>
            </div>
          </div>

          {/* Quick Direct Actions: Call & WhatsApp */}
          <div className="grid grid-cols-2 gap-3">
            <a
              href={`tel:${ownerPhone.replace(/\s+/g, '')}`}
              className="flex items-center justify-center gap-2 py-2.5 px-3 bg-white border border-gray-300 hover:border-emerald-600 rounded-xl text-xs font-bold text-gray-800 shadow-sm transition-all"
            >
              <span className="material-symbols-outlined text-emerald-600 text-lg">call</span>
              Call Directly
            </a>
            <a
              href={`https://wa.me/${ownerPhone.replace(/[^0-9]/g, '')}?text=${whatsappMessage}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-center gap-2 py-2.5 px-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-sm transition-all"
            >
              <span className="material-symbols-outlined text-lg">chat</span>
              Chat on WhatsApp
            </a>
          </div>

          <div className="relative flex py-1 items-center">
            <div className="flex-grow border-t border-gray-200"></div>
            <span className="flex-shrink mx-3 text-xs text-gray-400 font-medium">Or send platform message</span>
            <div className="flex-grow border-t border-gray-200"></div>
          </div>

          {/* Enquiry Form */}
          <form onSubmit={handleSendEnquiry} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                I am interested in:
              </label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => setPurpose('RENTAL')}
                  className={`py-2 text-xs font-bold rounded-xl border transition-all ${
                    purpose === 'RENTAL'
                      ? 'bg-emerald-50 border-emerald-600 text-emerald-800'
                      : 'bg-white border-gray-200 text-gray-600'
                  }`}
                >
                  Renting Machinery
                </button>
                <button
                  type="button"
                  onClick={() => setPurpose('PURCHASE')}
                  className={`py-2 text-xs font-bold rounded-xl border transition-all ${
                    purpose === 'PURCHASE'
                      ? 'bg-emerald-50 border-emerald-600 text-emerald-800'
                      : 'bg-white border-gray-200 text-gray-600'
                  }`}
                >
                  Buying / Quotation
                </button>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                Your Contact Number
              </label>
              <input
                type="tel"
                required
                placeholder="+91 98XXX XXXXX"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                Message / Field Requirement
              </label>
              <textarea
                rows={3}
                required
                placeholder={`Hello ${ownerName}, I need this machine for my farm work in Maharashtra...`}
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
              />
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-2">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-xs font-semibold text-gray-600 hover:bg-gray-100 rounded-xl"
              >
                Close
              </button>
              <button
                type="submit"
                className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow transition-all flex items-center gap-1.5"
              >
                <span className="material-symbols-outlined text-base">send</span>
                Send Direct Message
              </button>
            </div>
          </form>
        </div>
      )}
    </Modal>
  );
};

export default ContactOwnerModal;
