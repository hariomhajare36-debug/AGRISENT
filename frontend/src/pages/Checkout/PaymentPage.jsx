import React, { useState } from 'react';
import { useLocation, useNavigate, Link } from 'react-router-dom';
import { formatINR } from '../../utils/currency';

export const PaymentPage = () => {
  const location = useLocation();
  const navigate = useNavigate();

  const checkoutData = location.state || {};
  const isPurchase = checkoutData.type === 'PURCHASE';
  const equipment = checkoutData.equipment || {
    id: 1,
    title: 'Mahindra 575 DI XP Plus (47 HP Tractor)',
    brand: 'Mahindra',
    category: 'TRACTORS',
    dailyRate: 1850,
    purchasePrice: 695000,
    securityDeposit: 5000,
    district: 'Nagpur',
    images: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=600&q=80'
  };

  const days = checkoutData.days || 3;
  const baseRate = isPurchase ? (equipment.purchasePrice || 695000) : (equipment.dailyRate || 1850) * days;
  const deposit = isPurchase ? 0 : (equipment.securityDeposit || 5000);
  const deliveryCost = checkoutData.deliveryCost || (isPurchase ? 4500 : 800);
  const platformFee = isPurchase ? 1500 : 250;
  const totalAmount = baseRate + deposit + deliveryCost + platformFee;

  const [paymentMethod, setPaymentMethod] = useState('UPI'); // UPI, CARD, NETBANKING, EMI
  const [upiId, setUpiId] = useState('');
  const [selectedBank, setSelectedBank] = useState('SBI');
  const [emiTenure, setEmiTenure] = useState(24);
  const [farmerName, setFarmerName] = useState('Ramesh Patil');
  const [farmerPhone, setFarmerPhone] = useState('+91 98220 12341');
  const [farmAddress, setFarmAddress] = useState('Gat No. 42, Wardha Road');
  const [district, setDistrict] = useState(equipment.district || 'Nagpur');
  const [pincode, setPincode] = useState('440015');

  const [isProcessing, setIsProcessing] = useState(false);
  const [orderConfirmed, setOrderConfirmed] = useState(false);
  const [orderRef, setOrderRef] = useState('');

  const handlePayNow = (e) => {
    e.preventDefault();
    setIsProcessing(true);

    setTimeout(() => {
      setIsProcessing(false);
      setOrderRef('AGRI-' + (isPurchase ? 'BUY' : 'RNT') + '-' + Math.floor(100000 + Math.random() * 900000));
      setOrderConfirmed(true);
    }, 2000);
  };

  return (
    <div className="min-h-screen bg-surface flex flex-col">
      <main className="flex-1 max-w-5xl mx-auto px-4 py-10 w-full space-y-8">
        {/* Breadcrumbs */}
        <div className="flex items-center gap-2 text-xs text-gray-500">
          <Link to="/" className="hover:text-emerald-700">Home</Link>
          <span>/</span>
          <Link to="/catalog" className="hover:text-emerald-700">Equipment</Link>
          <span>/</span>
          <span className="text-gray-900 font-bold">{isPurchase ? 'Purchase Checkout' : 'Rental Booking & Escrow'}</span>
        </div>

        {orderConfirmed ? (
          /* Order Confirmation / Success View */
          <div className="bg-white border border-gray-200 rounded-3xl p-8 md:p-12 shadow-sm text-center space-y-6 max-w-2xl mx-auto animate-in fade-in zoom-in duration-300">
            <div className="w-20 h-20 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto text-4xl shadow-inner">
              <span className="material-symbols-outlined text-5xl">verified</span>
            </div>

            <div className="space-y-1">
              <span className="px-3 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800">
                Payment Successful • Escrow Protected
              </span>
              <h2 className="text-2xl md:text-3xl font-black text-gray-900 pt-2">
                {isPurchase ? 'Machinery Purchase Order Placed!' : 'Rental Booking Confirmed!'}
              </h2>
              <p className="text-xs text-gray-600">
                Order Reference: <span className="font-mono font-bold text-gray-900">{orderRef}</span>
              </p>
            </div>

            <div className="bg-gray-50 border border-gray-200 rounded-2xl p-5 text-left space-y-3 text-xs">
              <div className="flex justify-between border-b border-gray-200 pb-2">
                <span className="text-gray-500">Machinery:</span>
                <span className="font-bold text-gray-900">{equipment.title}</span>
              </div>
              <div className="flex justify-between border-b border-gray-200 pb-2">
                <span className="text-gray-500">Beneficiary / Delivery To:</span>
                <span className="font-semibold text-gray-900">{farmerName} ({farmerPhone})</span>
              </div>
              <div className="flex justify-between border-b border-gray-200 pb-2">
                <span className="text-gray-500">Destination:</span>
                <span className="font-semibold text-gray-900">{farmAddress}, {district}, Maharashtra - {pincode}</span>
              </div>
              <div className="flex justify-between border-b border-gray-200 pb-2">
                <span className="text-gray-500">Payment Mode:</span>
                <span className="font-bold text-gray-900">{paymentMethod}</span>
              </div>
              <div className="flex justify-between pt-1 text-sm font-extrabold text-emerald-800">
                <span>Total Amount Paid:</span>
                <span>{formatINR(totalAmount)}</span>
              </div>
            </div>

            <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-3.5 text-xs text-emerald-900 text-left flex items-start gap-2.5">
              <span className="material-symbols-outlined text-emerald-700 text-lg mt-0.5">security</span>
              <div>
                <span className="font-bold">AgriRent Escrow Shield Active:</span> Your funds are held securely. The equipment owner / authorized dealership will deliver the machine to your farm by tomorrow 10:00 AM.
              </div>
            </div>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
              <button
                type="button"
                onClick={() => window.print()}
                className="w-full sm:w-auto px-5 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-800 rounded-xl text-xs font-bold transition-colors flex items-center justify-center gap-1.5"
              >
                <span className="material-symbols-outlined text-base">print</span>
                Print Tax Receipt
              </button>
              <button
                type="button"
                onClick={() => navigate('/farmer-dashboard')}
                className="w-full sm:w-auto px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center justify-center gap-1.5"
              >
                <span className="material-symbols-outlined text-base">dashboard</span>
                Go to Farmer Dashboard
              </button>
            </div>
          </div>
        ) : (
          /* Checkout Layout */
          <form onSubmit={handlePayNow} className="grid grid-cols-1 lg:grid-cols-12 gap-8">
            {/* Left Column: Delivery & Payment Details */}
            <div className="lg:col-span-7 space-y-6">
              {/* Delivery Address Section */}
              <div className="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm space-y-4">
                <div className="flex items-center gap-2 border-b border-gray-100 pb-3">
                  <span className="material-symbols-outlined text-emerald-700">pin_drop</span>
                  <h3 className="text-base font-bold text-gray-900">1. Delivery Location & Farmer Details</h3>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                      Farmer Full Name
                    </label>
                    <input
                      type="text"
                      required
                      value={farmerName}
                      onChange={(e) => setFarmerName(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                      Phone Number (For OTP / Delivery)
                    </label>
                    <input
                      type="tel"
                      required
                      value={farmerPhone}
                      onChange={(e) => setFarmerPhone(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                    />
                  </div>

                  <div className="sm:col-span-2">
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                      Farm / Field Address (Gat No. / Village)
                    </label>
                    <input
                      type="text"
                      required
                      value={farmAddress}
                      onChange={(e) => setFarmAddress(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                      District (Maharashtra)
                    </label>
                    <input
                      type="text"
                      required
                      value={district}
                      onChange={(e) => setDistrict(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1">
                      PIN Code
                    </label>
                    <input
                      type="text"
                      required
                      value={pincode}
                      onChange={(e) => setPincode(e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none"
                    />
                  </div>
                </div>
              </div>

              {/* Payment Methods */}
              <div className="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm space-y-5">
                <div className="flex items-center justify-between border-b border-gray-100 pb-3">
                  <div className="flex items-center gap-2">
                    <span className="material-symbols-outlined text-emerald-700">payments</span>
                    <h3 className="text-base font-bold text-gray-900">2. Select Payment Method (₹ INR)</h3>
                  </div>
                  <span className="text-[11px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                    256-bit SSL Encrypted
                  </span>
                </div>

                {/* Method Tabs */}
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                  {[
                    { id: 'UPI', label: 'UPI / QR', icon: 'qr_code_scanner' },
                    { id: 'CARD', label: 'Cards', icon: 'credit_card' },
                    { id: 'NETBANKING', label: 'Net Banking', icon: 'account_balance' },
                    { id: 'EMI', label: 'Kisan EMI', icon: 'calendar_month' },
                  ].map((m) => (
                    <button
                      key={m.id}
                      type="button"
                      onClick={() => setPaymentMethod(m.id)}
                      className={`p-3 rounded-xl border text-center transition-all flex flex-col items-center gap-1 ${
                        paymentMethod === m.id
                          ? 'border-emerald-600 bg-emerald-50/80 text-emerald-800 shadow-sm'
                          : 'border-gray-200 hover:border-gray-300 text-gray-600'
                      }`}
                    >
                      <span className="material-symbols-outlined text-xl">{m.icon}</span>
                      <span className="text-xs font-bold">{m.label}</span>
                    </button>
                  ))}
                </div>

                {/* Method Details */}
                <div className="bg-gray-50 border border-gray-200 rounded-2xl p-4">
                  {paymentMethod === 'UPI' && (
                    <div className="space-y-3 text-xs">
                      <div className="flex items-center justify-between">
                        <span className="font-semibold text-gray-800">Instant UPI Payment</span>
                        <span className="text-gray-400">GPay, PhonePe, Paytm, BHIM</span>
                      </div>
                      <div className="flex gap-2">
                        <input
                          type="text"
                          placeholder="e.g. 9822012341@ybl or farmer@okhdfcbank"
                          value={upiId}
                          onChange={(e) => setUpiId(e.target.value)}
                          className="flex-1 px-3 py-2 border border-gray-300 rounded-xl text-xs focus:ring-2 focus:ring-emerald-500 focus:outline-none bg-white"
                        />
                        <button
                          type="button"
                          className="px-3 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold"
                        >
                          Verify
                        </button>
                      </div>
                      <div className="flex items-center justify-center p-3 bg-white border border-dashed border-gray-300 rounded-xl">
                        <div className="text-center space-y-1">
                          <span className="material-symbols-outlined text-4xl text-gray-700">qr_code_2</span>
                          <p className="text-[10px] text-gray-500">Scan UPI QR code from any mobile banking app</p>
                        </div>
                      </div>
                    </div>
                  )}

                  {paymentMethod === 'CARD' && (
                    <div className="space-y-3 text-xs">
                      <div>
                        <label className="block text-gray-600 font-semibold mb-1">Card Number (RuPay, Visa, MasterCard)</label>
                        <input
                          type="text"
                          placeholder="4111 2222 3333 4444"
                          maxLength={19}
                          className="w-full px-3 py-2 border border-gray-300 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
                        />
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-gray-600 font-semibold mb-1">Expiry Date</label>
                          <input
                            type="text"
                            placeholder="MM / YY"
                            maxLength={5}
                            className="w-full px-3 py-2 border border-gray-300 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
                          />
                        </div>
                        <div>
                          <label className="block text-gray-600 font-semibold mb-1">CVV</label>
                          <input
                            type="password"
                            placeholder="123"
                            maxLength={3}
                            className="w-full px-3 py-2 border border-gray-300 rounded-xl bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500"
                          />
                        </div>
                      </div>
                    </div>
                  )}

                  {paymentMethod === 'NETBANKING' && (
                    <div className="space-y-3 text-xs">
                      <label className="block text-gray-600 font-semibold mb-1">Select Your Bank</label>
                      <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                        {['SBI', 'HDFC Bank', 'ICICI Bank', 'Bank of Maharashtra', 'Axis Bank', 'Bank of Baroda'].map((b) => (
                          <button
                            key={b}
                            type="button"
                            onClick={() => setSelectedBank(b)}
                            className={`p-2 rounded-xl border text-center font-bold transition-colors ${
                              selectedBank === b
                                ? 'border-emerald-600 bg-white text-emerald-800'
                                : 'border-gray-200 bg-white hover:border-gray-300 text-gray-700'
                            }`}
                          >
                            {b}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}

                  {paymentMethod === 'EMI' && (
                    <div className="space-y-3 text-xs">
                      <div className="flex justify-between items-center">
                        <span className="font-semibold text-gray-800">Agricultural Equipment Loan & EMI</span>
                        <span className="text-emerald-700 font-bold">Starting at 8.9% p.a.</span>
                      </div>
                      <div className="grid grid-cols-3 gap-2">
                        {[12, 24, 36].map((m) => (
                          <button
                            key={m}
                            type="button"
                            onClick={() => setEmiTenure(m)}
                            className={`p-2.5 rounded-xl border text-center transition-colors ${
                              emiTenure === m
                                ? 'border-emerald-600 bg-white text-emerald-800 font-bold'
                                : 'border-gray-200 bg-white text-gray-700'
                            }`}
                          >
                            <div>{m} Months</div>
                            <div className="text-[11px] text-emerald-700 font-extrabold mt-0.5">
                              {formatINR(Math.round((totalAmount * 1.09) / m))}/mo
                            </div>
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Right Column: Order Summary & Escrow Guarantee */}
            <div className="lg:col-span-5 space-y-6">
              <div className="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm space-y-4">
                <h3 className="text-base font-bold text-gray-900 border-b border-gray-100 pb-3">
                  {isPurchase ? 'Purchase Quotation Summary' : 'Rental Booking Summary'}
                </h3>

                {/* Machine Mini Card */}
                <div className="flex gap-3">
                  <img
                    src={equipment.images || 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=200&q=80'}
                    alt={equipment.title}
                    className="w-16 h-16 object-cover rounded-xl border border-gray-100 shrink-0"
                  />
                  <div className="min-w-0">
                    <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-wider block">
                      {equipment.brand || equipment.make} • {equipment.category}
                    </span>
                    <h4 className="text-xs font-bold text-gray-900 truncate">{equipment.title}</h4>
                    <p className="text-[11px] text-gray-500 mt-0.5">
                      {isPurchase ? 'Direct Purchase' : `${days} Days Rental`} • {district}, Maharashtra
                    </p>
                  </div>
                </div>

                {/* Line Items */}
                <div className="border-t border-gray-100 pt-3 space-y-2 text-xs">
                  <div className="flex justify-between text-gray-600">
                    <span>{isPurchase ? 'Ex-Showroom Price' : `Daily Rate (${days} days × ${formatINR(equipment.dailyRate)})`}</span>
                    <span className="font-semibold text-gray-900">{formatINR(baseRate)}</span>
                  </div>

                  {!isPurchase && (
                    <div className="flex justify-between text-gray-600">
                      <span className="flex items-center gap-1">
                        Security Deposit
                        <span className="text-[10px] text-emerald-700 font-bold bg-emerald-50 px-1 rounded">Refundable</span>
                      </span>
                      <span className="font-semibold text-gray-900">{formatINR(deposit)}</span>
                    </div>
                  )}

                  <div className="flex justify-between text-gray-600">
                    <span>Doorstep Flatbed Delivery</span>
                    <span className="font-semibold text-gray-900">{formatINR(deliveryCost)}</span>
                  </div>

                  <div className="flex justify-between text-gray-600">
                    <span>Escrow Protection & Documentation Fee</span>
                    <span className="font-semibold text-gray-900">{formatINR(platformFee)}</span>
                  </div>

                  <div className="border-t border-gray-200 pt-3 flex justify-between items-baseline">
                    <span className="text-sm font-bold text-gray-900">Total Payable Amount</span>
                    <div className="text-right">
                      <span className="text-2xl font-black text-emerald-700">{formatINR(totalAmount)}</span>
                      <span className="text-[10px] text-gray-400 block">Inclusive of all agricultural GST</span>
                    </div>
                  </div>
                </div>

                {/* Submit Payment Button */}
                <button
                  type="submit"
                  disabled={isProcessing}
                  className="w-full py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-sm font-bold shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-2 disabled:opacity-50"
                >
                  {isProcessing ? (
                    <>
                      <span className="material-symbols-outlined animate-spin text-lg">progress_activity</span>
                      Processing with Bank Gateway...
                    </>
                  ) : (
                    <>
                      <span className="material-symbols-outlined text-lg">lock</span>
                      Pay {formatINR(totalAmount)} Securely
                    </>
                  )}
                </button>

                <p className="text-[10px] text-gray-400 text-center leading-relaxed">
                  By clicking Pay, you agree to AgriRent's Terms of Agricultural Rental and Escrow Protection Policy.
                </p>
              </div>

              {/* Escrow Badge Card */}
              <div className="bg-emerald-50/80 border border-emerald-200 rounded-2xl p-4 flex items-center gap-3">
                <span className="material-symbols-outlined text-emerald-700 text-3xl">verified_user</span>
                <div className="text-xs text-emerald-900">
                  <span className="font-bold block">100% Kisan Escrow Guarantee</span>
                  Money is released to equipment owner only after tractor is delivered in verified working condition.
                </div>
              </div>
            </div>
          </form>
        )}
      </main>
    </div>
  );
};

export default PaymentPage;
