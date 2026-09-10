/**
 * Formats a number to Indian Rupee (INR) currency format (₹ 1,25,000)
 * Handles null, undefined, strings, and zero gracefully.
 */
export const formatINR = (value, showDecimals = false) => {
  if (value === null || value === undefined || isNaN(Number(value))) {
    return '₹0';
  }
  
  const num = Number(value);
  const options = {
    maximumFractionDigits: showDecimals ? 2 : 0,
    minimumFractionDigits: showDecimals ? 2 : 0
  };
  
  return '₹' + num.toLocaleString('en-IN', options);
};

/**
 * Formats a price into compact Indian numbering system (e.g., ₹7.5 Lakh, ₹1.2 Cr)
 */
export const formatCompactINR = (value) => {
  if (value === null || value === undefined || isNaN(Number(value))) {
    return '₹0';
  }
  
  const num = Number(value);
  if (num >= 10000000) {
    return '₹' + (num / 10000000).toFixed(2).replace(/\.00$/, '') + ' Cr';
  } else if (num >= 100000) {
    return '₹' + (num / 100000).toFixed(2).replace(/\.00$/, '') + ' Lakh';
  } else if (num >= 1000) {
    return '₹' + (num / 1000).toFixed(1).replace(/\.0$/, '') + 'k';
  }
  return '₹' + num.toLocaleString('en-IN');
};

/**
 * Calculates monthly EMI given principal, annual interest rate (e.g. 9.5%), and tenure in months
 */
export const calculateEMI = (principal, annualRatePercent, tenureMonths) => {
  const p = Number(principal);
  const n = Number(tenureMonths);
  const r = Number(annualRatePercent) / (12 * 100); // monthly interest rate
  
  if (!p || p <= 0 || !n || n <= 0) return 0;
  if (!r || r <= 0) return Math.round(p / n);
  
  const emi = (p * r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1);
  return Math.round(emi);
};
