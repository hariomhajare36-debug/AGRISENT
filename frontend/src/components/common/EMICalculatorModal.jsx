import React, { useState, useEffect } from 'react';
import Modal from './Modal';
import { formatINR, calculateEMI } from '../../utils/currency';

export const EMICalculatorModal = ({ isOpen, onClose, initialPrice = 750000, machineTitle = 'Agricultural Machinery' }) => {
  const [price, setPrice] = useState(initialPrice || 750000);
  const [downPaymentPercent, setDownPaymentPercent] = useState(20);
  const [interestRate, setInterestRate] = useState(9.5);
  const [tenureMonths, setTenureMonths] = useState(36);
  const [loanApplied, setLoanApplied] = useState(false);

  useEffect(() => {
    if (initialPrice) {
      setPrice(Number(initialPrice));
    }
  }, [initialPrice]);

  const downPaymentAmount = Math.round((price * downPaymentPercent) / 100);
  const loanPrincipal = Math.max(0, price - downPaymentAmount);
  const monthlyEMI = calculateEMI(loanPrincipal, interestRate, tenureMonths);
  const totalPayable = monthlyEMI * tenureMonths;
  const totalInterest = Math.max(0, totalPayable - loanPrincipal);

  const handleApplyLoan = (e) => {
    e.preventDefault();
    setLoanApplied(true);
    setTimeout(() => {
      setLoanApplied(false);
      onClose();
    }, 2500);
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Kisan Tractor & Equipment EMI Calculator" maxWidth="max-w-2xl">
      {loanApplied ? (
        <div className="py-8 text-center space-y-4">
          <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto text-3xl">
            <span className="material-symbols-outlined text-4xl">verified</span>
          </div>
          <h4 className="text-xl font-bold text-gray-900">Loan Enquiry Submitted!</h4>
          <p className="text-sm text-gray-600 max-w-md mx-auto">
            Our agricultural finance partner (SBI & HDFC Krishi Seva) has received your quotation for <span className="font-semibold text-gray-900">{machineTitle}</span> with an estimated monthly EMI of <span className="font-bold text-emerald-700">{formatINR(monthlyEMI)}</span>. A loan officer will call you within 2 business hours.
          </p>
        </div>
      ) : (
        <div className="space-y-6">
          <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-3.5 flex items-start gap-3">
            <span className="material-symbols-outlined text-emerald-700 text-xl mt-0.5">account_balance</span>
            <div className="text-xs text-emerald-900 leading-relaxed">
              <span className="font-bold">Krishi Finance Subsidy Available:</span> Low-interest agricultural loans starting at 8.9% with flexible harvest-linked repayment cycles for Maharashtra farmers.
            </div>
          </div>

          <div className="space-y-4">
            {/* Price Slider */}
            <div>
              <div className="flex justify-between items-center mb-1.5">
                <label className="text-xs font-semibold text-gray-700 uppercase tracking-wider">Equipment Purchase Price</label>
                <span className="text-base font-bold text-gray-900">{formatINR(price)}</span>
              </div>
              <input
                type="range"
                min="100000"
                max="4500000"
                step="25000"
                value={price}
                onChange={(e) => setPrice(Number(e.target.value))}
                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-emerald-600"
              />
              <div className="flex justify-between text-[11px] text-gray-400 mt-1">
                <span>₹1 Lakh</span>
                <span>₹20 Lakh</span>
                <span>₹45 Lakh</span>
              </div>
            </div>

            {/* Down Payment Slider */}
            <div>
              <div className="flex justify-between items-center mb-1.5">
                <label className="text-xs font-semibold text-gray-700 uppercase tracking-wider">
                  Down Payment ({downPaymentPercent}%)
                </label>
                <span className="text-sm font-bold text-gray-900">{formatINR(downPaymentAmount)}</span>
              </div>
              <input
                type="range"
                min="10"
                max="60"
                step="5"
                value={downPaymentPercent}
                onChange={(e) => setDownPaymentPercent(Number(e.target.value))}
                className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer accent-emerald-600"
              />
              <div className="flex justify-between text-[11px] text-gray-500 mt-1">
                <span>Loan Principal: <strong className="text-gray-800">{formatINR(loanPrincipal)}</strong></span>
                <span>10% Min - 60% Max</span>
              </div>
            </div>

            {/* Interest Rate & Tenure */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                  Interest Rate (% p.a.)
                </label>
                <div className="flex items-center gap-2">
                  <input
                    type="number"
                    step="0.1"
                    min="6"
                    max="18"
                    value={interestRate}
                    onChange={(e) => setInterestRate(Number(e.target.value))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-semibold text-gray-900 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                  />
                  <span className="text-sm font-bold text-gray-500">%</span>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 uppercase tracking-wider mb-1.5">
                  Loan Tenure
                </label>
                <div className="grid grid-cols-4 gap-1.5">
                  {[12, 24, 36, 60].map((months) => (
                    <button
                      key={months}
                      type="button"
                      onClick={() => setTenureMonths(months)}
                      className={`py-2 text-xs font-bold rounded-lg border transition-all ${
                        tenureMonths === months
                          ? 'bg-emerald-600 border-emerald-600 text-white shadow-sm'
                          : 'bg-white border-gray-200 text-gray-700 hover:border-gray-300'
                      }`}
                    >
                      {months / 12} {months === 12 ? 'Yr' : 'Yrs'}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Results Card */}
          <div className="bg-gray-50 border border-gray-200 rounded-2xl p-5 space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-gray-200 pb-3">
              <div>
                <span className="text-xs font-medium text-gray-500">Estimated Monthly EMI</span>
                <div className="text-3xl font-extrabold text-emerald-700 tracking-tight">
                  {formatINR(monthlyEMI)}
                  <span className="text-sm font-normal text-gray-500"> / month</span>
                </div>
              </div>
              <div className="text-right sm:text-right">
                <span className="text-[11px] font-medium text-gray-500 uppercase tracking-wider">Total Repayment</span>
                <div className="text-base font-bold text-gray-900">{formatINR(totalPayable)}</div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 text-xs">
              <div className="flex justify-between items-center py-1">
                <span className="text-gray-500 flex items-center gap-1.5">
                  <span className="w-2.5 h-2.5 rounded-full bg-emerald-600 inline-block"></span>
                  Principal Loan
                </span>
                <span className="font-bold text-gray-900">{formatINR(loanPrincipal)}</span>
              </div>
              <div className="flex justify-between items-center py-1">
                <span className="text-gray-500 flex items-center gap-1.5">
                  <span className="w-2.5 h-2.5 rounded-full bg-amber-500 inline-block"></span>
                  Total Interest
                </span>
                <span className="font-bold text-gray-900">{formatINR(totalInterest)}</span>
              </div>
            </div>

            {/* Visual ratio bar */}
            <div className="h-2 w-full bg-gray-200 rounded-full overflow-hidden flex">
              <div
                style={{ width: `${totalPayable > 0 ? (loanPrincipal / totalPayable) * 100 : 50}%` }}
                className="bg-emerald-600 h-full"
                title="Principal"
              />
              <div
                style={{ width: `${totalPayable > 0 ? (totalInterest / totalPayable) * 100 : 50}%` }}
                className="bg-amber-500 h-full"
                title="Interest"
              />
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-xl transition-colors"
            >
              Cancel
            </button>
            <button
              type="button"
              onClick={handleApplyLoan}
              className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold rounded-xl shadow-md hover:shadow-lg transition-all flex items-center gap-2"
            >
              <span className="material-symbols-outlined text-lg">payments</span>
              Apply for Loan with this EMI
            </button>
          </div>
        </div>
      )}
    </Modal>
  );
};

export default EMICalculatorModal;
