import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const RENT_STEPS = [
  {
    step: '01',
    title: 'Explore Machinery & Implements',
    desc: 'Browse through 120+ verified Indian tractors, combine harvesters, rotavators, cultivators, and implements across 12 Maharashtra districts.',
    icon: 'search'
  },
  {
    step: '02',
    title: 'Filter by Power & Soil Needs',
    desc: 'Filter by brand (Mahindra, Swaraj, John Deere, etc.), horsepower class (under 30 HP to 75+ HP), 2WD/4WD drive type, and local Maharashtra agro belt.',
    icon: 'tune'
  },
  {
    step: '03',
    title: 'Inspect Live Telemetry & Maintenance',
    desc: 'Review real-time machine telemetry including engine hours, fuel levels, DEF fluid status, and previous farmer field ratings.',
    icon: 'speed'
  },
  {
    step: '04',
    title: 'Choose Rental Period & Book',
    desc: 'Select flexible rental duration (Daily ₹1,200/day, Weekly, or Monthly seasonal packages) with upfront transparent pricing in ₹ INR.',
    icon: 'calendar_month'
  },
  {
    step: '05',
    title: 'Secure Escrow Payment & Deposit',
    desc: 'Pay safely via UPI, NetBanking, or Cards. Your funds remain in a protected AgriRent Escrow account until the machine reaches your field in working condition.',
    icon: 'lock'
  },
  {
    step: '06',
    title: 'Owner Confirmation & Digital Agreement',
    desc: 'The verified owner confirms availability instantly. A legally binding digital agricultural equipment rental agreement is generated with zero paperwork.',
    icon: 'verified_user'
  },
  {
    step: '07',
    title: 'Direct Farm Delivery or Hub Pickup',
    desc: 'Choose doorstep flatbed delivery to your farm gates or pick up the tractor from an authorized regional hub in Nagpur, Pune, Nashik, or Sambhajinagar.',
    icon: 'local_shipping'
  },
  {
    step: '08',
    title: 'Farm Operation & 24/7 Field Support',
    desc: 'Put the equipment to work for ploughing, sowing, spraying, or harvesting. Dedicated technician helpline ready for any mechanical assistance.',
    icon: 'agriculture'
  },
  {
    step: '09',
    title: 'Machine Return & Joint Checklist',
    desc: 'On rental completion, a simple 5-point handover checklist verifies machine condition and operating hours.',
    icon: 'checklist'
  },
  {
    step: '10',
    title: 'Deposit Refund & Farmer Review',
    desc: 'Your security deposit is refunded back to your source bank account within 24 hours. Rate the owner to build rural community trust.',
    icon: 'currency_rupee'
  }
];

const BUY_STEPS = [
  {
    step: '01',
    title: 'Browse Verified Machinery Catalog',
    desc: 'Explore brand-new and certified pre-owned tractors, power tillers, and implements from authorized dealerships across Maharashtra.',
    icon: 'storefront'
  },
  {
    step: '02',
    title: 'Check Official Ex-Showroom Pricing',
    desc: 'Compare transparent manufacturer ex-showroom prices in ₹ INR, complete with last verified dates and direct manufacturer source links.',
    icon: 'price_check'
  },
  {
    step: '03',
    title: 'Compare Up to 4 Machines Side-by-Side',
    desc: 'Use our 4-way spec comparison tool to inspect horsepower, lifting capacity (kg), PTO speeds, transmission types, and fuel tank capacities.',
    icon: 'compare_arrows'
  },
  {
    step: '04',
    title: 'Request Dealer Inspection or Field Trial',
    desc: 'Schedule an on-field tractor trial or dealership inspection in your district to test PTO power with your existing farm implements.',
    icon: 'handyman'
  },
  {
    step: '05',
    title: 'Calculate Loan EMI & Check Subsidies',
    desc: 'Use our Kisan EMI calculator to model monthly installments. Get assistance checking state subsidy eligibility (MahaDBT Krishi Yantrikikaran).',
    icon: 'calculate'
  },
  {
    step: '06',
    title: 'Submit Purchase Booking & Lock Price',
    desc: 'Place a refundable booking deposit online to reserve your machinery and lock in exclusive seasonal festival discounts.',
    icon: 'shopping_cart'
  },
  {
    step: '07',
    title: 'RTO Registration & Paperwork Support',
    desc: 'Our dealer partners handle agricultural RTO registration, 7/12 land document verification, and tractor insurance issuance.',
    icon: 'description'
  },
  {
    step: '08',
    title: 'Safe Transportation to Your Village',
    desc: 'Professional tractor trailer logistics delivers the machine directly to your village, inspected and ready for immediate operation.',
    icon: 'home_pin'
  },
  {
    step: '09',
    title: 'Warranty Activation & Scheduled Service',
    desc: 'Activate official manufacturer warranty (up to 5 years / 5,000 hours) with free doorstep scheduled service visits.',
    icon: 'verified'
  }
];

const FAQS = [
  {
    q: 'How does the AgriRent Escrow protection work for rentals?',
    a: 'When you book a tractor or implement, your payment is held securely in an AgriRent Escrow account. The owner is only paid after you receive the machinery on your farm and verify that it is fully operational.'
  },
  {
    q: 'Can I apply for tractor loans through AgriRent?',
    a: 'Yes! AgriRent partners with major rural lenders (SBI, HDFC Kisan Seva, Bank of Maharashtra) offering low-interest farm loans starting at 8.9% with flexible harvest-linked repayment cycles.'
  },
  {
    q: 'What documents are required to rent equipment?',
    a: 'A simple Aadhaar card, mobile number for OTP verification, and basic farm land details (7/12 extract or village name) are sufficient.'
  },
  {
    q: 'What happens if a rented tractor breaks down during field work?',
    a: 'Our 24/7 Kisan Helpline dispatches a local mobile technician within 3 hours. If the repair takes longer than 6 hours, a replacement tractor is arranged at no extra charge.'
  }
];

export const HowItWorksPage = () => {
  const [activeTab, setActiveTab] = useState('RENT');
  const [openFaq, setOpenFaq] = useState(null);

  const steps = activeTab === 'RENT' ? RENT_STEPS : BUY_STEPS;

  return (
    <div className="min-h-screen bg-surface flex flex-col">
      {/* Hero Banner */}
      <div className="bg-gradient-to-b from-emerald-900 to-emerald-950 text-white py-16 px-4">
        <div className="max-w-5xl mx-auto text-center space-y-4">
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-800/80 text-emerald-300 text-xs font-bold uppercase tracking-wider border border-emerald-700">
            <span className="material-symbols-outlined text-sm">handshake</span>
            Complete Step-by-Step Guide
          </span>
          <h1 className="text-3xl md:text-5xl font-black tracking-tight">
            How AgriRent Works in India
          </h1>
          <p className="text-emerald-200/90 text-sm md:text-base max-w-2xl mx-auto">
            Everything you need to know about renting high-power farm machinery or purchasing verified tractors across Maharashtra.
          </p>

          {/* Tab Switcher */}
          <div className="pt-6 flex justify-center">
            <div className="inline-flex p-1.5 bg-emerald-950/80 border border-emerald-800 rounded-2xl shadow-lg">
              <button
                type="button"
                onClick={() => setActiveTab('RENT')}
                className={`flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                  activeTab === 'RENT'
                    ? 'bg-emerald-500 text-white shadow'
                    : 'text-emerald-300 hover:text-white'
                }`}
              >
                <span className="material-symbols-outlined text-lg">calendar_today</span>
                How Renting Works (10 Steps)
              </button>
              <button
                type="button"
                onClick={() => setActiveTab('BUY')}
                className={`flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-bold transition-all ${
                  activeTab === 'BUY'
                    ? 'bg-emerald-500 text-white shadow'
                    : 'text-emerald-300 hover:text-white'
                }`}
              >
                <span className="material-symbols-outlined text-lg">shopping_bag</span>
                How Buying Works (9 Steps)
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Steps Section */}
      <main className="flex-1 max-w-5xl mx-auto px-4 py-12 w-full space-y-12">
        <div className="text-center space-y-2">
          <h2 className="text-2xl md:text-3xl font-extrabold text-gray-900">
            {activeTab === 'RENT' ? '10 Simple Steps to Rent Equipment' : '9 Simple Steps to Purchase Equipment'}
          </h2>
          <p className="text-sm text-gray-600 max-w-xl mx-auto">
            {activeTab === 'RENT'
              ? 'From browsing to field delivery, transparent pricing with 100% Escrow security.'
              : 'Verified dealer pricing, 4-way spec comparison, EMI loan support, and doorstep registration.'}
          </p>
        </div>

        {/* Steps Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {steps.map((item) => (
            <div
              key={item.step}
              className="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm hover:shadow-md hover:border-emerald-500 transition-all flex gap-4 group"
            >
              <div className="flex flex-col items-center">
                <span className="text-2xl font-black text-emerald-600/80 group-hover:text-emerald-600 font-mono">
                  {item.step}
                </span>
                <div className="w-10 h-10 mt-2 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center shrink-0 group-hover:bg-emerald-600 group-hover:text-white transition-colors">
                  <span className="material-symbols-outlined text-xl">{item.icon}</span>
                </div>
              </div>
              <div className="flex-1 space-y-1.5 pt-0.5">
                <h3 className="text-base font-bold text-gray-900 group-hover:text-emerald-800 transition-colors">
                  {item.title}
                </h3>
                <p className="text-xs text-gray-600 leading-relaxed">{item.desc}</p>
              </div>
            </div>
          ))}
        </div>

        {/* CTA Banner */}
        <div className="bg-emerald-50 border border-emerald-200 rounded-3xl p-8 text-center space-y-4">
          <h3 className="text-xl md:text-2xl font-bold text-emerald-950">
            Ready to get started on your farm?
          </h3>
          <p className="text-sm text-emerald-800 max-w-md mx-auto">
            Browse our 120+ verified machines across Maharashtra. Choose between daily rentals or direct purchase with verified pricing.
          </p>
          <div className="flex flex-wrap items-center justify-center gap-4 pt-2">
            <Link
              to="/catalog?type=rent"
              className="px-6 py-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-sm font-bold shadow-md hover:shadow-lg transition-all flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">calendar_month</span>
              Rent Farm Machinery
            </Link>
            <Link
              to="/catalog?type=buy"
              className="px-6 py-3 bg-white hover:bg-gray-50 text-emerald-800 border border-emerald-300 rounded-xl text-sm font-bold shadow-sm transition-all flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">shopping_cart</span>
              Buy Farm Machinery
            </Link>
          </div>
        </div>

        {/* Support Helpline Card */}
        <div className="bg-white border border-gray-200 rounded-2xl p-6 flex flex-col md:flex-row items-center justify-between gap-6 shadow-sm">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 bg-emerald-100 text-emerald-700 rounded-2xl flex items-center justify-center shrink-0">
              <span className="material-symbols-outlined text-3xl">support_agent</span>
            </div>
            <div>
              <h4 className="text-base font-bold text-gray-900">AgriRent Kisan Helpline & WhatsApp Support</h4>
              <p className="text-xs text-gray-600 mt-0.5">
                Need help booking or finding an implement for your crop? Speak directly with our Marathi / Hindi speaking agronomists.
              </p>
            </div>
          </div>
          <div className="flex items-center gap-3 shrink-0">
            <a
              href="tel:+911800247473"
              className="px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-xl text-xs font-bold flex items-center gap-2 transition-colors"
            >
              <span className="material-symbols-outlined text-base text-emerald-700">call</span>
              1800-AGRI-RENT
            </a>
            <a
              href="https://wa.me/919822012345?text=Namaste%20AgriRent,%20I%20need%20help%20with%20machinery"
              target="_blank"
              rel="noopener noreferrer"
              className="px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold flex items-center gap-2 shadow transition-all"
            >
              <span className="material-symbols-outlined text-base">chat</span>
              WhatsApp Helpline
            </a>
          </div>
        </div>

        {/* FAQs */}
        <div className="space-y-4">
          <h3 className="text-xl font-bold text-gray-900 text-center">Frequently Asked Questions</h3>
          <div className="space-y-3">
            {FAQS.map((faq, idx) => (
              <div
                key={idx}
                className="bg-white border border-gray-200 rounded-2xl overflow-hidden transition-colors"
              >
                <button
                  type="button"
                  onClick={() => setOpenFaq(openFaq === idx ? null : idx)}
                  className="w-full text-left px-5 py-4 flex items-center justify-between font-bold text-sm text-gray-900 hover:bg-gray-50"
                >
                  <span>{faq.q}</span>
                  <span className="material-symbols-outlined text-gray-400">
                    {openFaq === idx ? 'expand_less' : 'expand_more'}
                  </span>
                </button>
                {openFaq === idx && (
                  <div className="px-5 pb-4 text-xs text-gray-600 leading-relaxed border-t border-gray-100 pt-3">
                    {faq.a}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
};

export default HowItWorksPage;
