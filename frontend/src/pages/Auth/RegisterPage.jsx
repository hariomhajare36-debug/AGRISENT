import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { MAHARASHTRA_DISTRICTS } from '../../constants/categories';

export const RegisterPage = () => {
  const navigate = useNavigate();
  const { register } = useAuth();

  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    role: 'ROLE_FARMER',
    farmName: '',
    district: 'Pune',
    city: 'Pune',
    state: 'Maharashtra',
    pincode: '411001',
    password: '',
    confirmPassword: '',
    agreeTerms: true,
  });

  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [error, setError] = useState('');
  const [successMsg, setSuccessMsg] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
      ...(name === 'district' ? { city: value } : {}),
    }));
  };

  const passwordsMatch = formData.password && formData.confirmPassword && formData.password === formData.confirmPassword;
  const passwordsMismatch = formData.confirmPassword && formData.password !== formData.confirmPassword;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccessMsg('');

    if (!formData.firstName.trim()) {
      setError('Please enter your First Name.');
      return;
    }

    if (!formData.lastName.trim()) {
      setError('Please enter your Last Name.');
      return;
    }

    // Validate 10-digit Indian phone
    const cleanPhone = formData.phone.replace(/[^0-9]/g, '').slice(-10);
    if (cleanPhone.length !== 10) {
      setError('Please enter a valid 10-digit Indian mobile number (e.g. 9822012345).');
      return;
    }

    if (formData.password.length < 6) {
      setError('Password must be at least 6 characters long.');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError('Passwords do not match. Please re-enter your password.');
      return;
    }

    if (!formData.agreeTerms) {
      setError('Please agree to the AgriRent Terms of Service and escrow guidelines.');
      return;
    }

    setLoading(true);
    try {
      const fullName = (formData.firstName.trim() + ' ' + formData.lastName.trim()).trim();
      const username = formData.email.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '_') + '_' + Math.floor(Math.random() * 900 + 100);
      
      const payload = {
        firstName: formData.firstName.trim(),
        lastName: formData.lastName.trim(),
        fullName: fullName,
        email: formData.email.trim().toLowerCase(),
        username: username,
        password: formData.password,
        role: formData.role,
        farmName: formData.farmName ? formData.farmName.trim() : (formData.role === 'ROLE_DEALER' ? fullName + ' Motors & Machinery' : fullName + ' Farm'),
        phone: cleanPhone,
        address: (formData.farmName || fullName) + ', ' + formData.district + ', Maharashtra',
        city: formData.city || formData.district,
        district: formData.district,
        state: 'Maharashtra',
        pincode: formData.pincode || '411001',
      };

      const data = await register(payload);
      setSuccessMsg('Namaste ' + fullName + '! Account created successfully. Redirecting to your dashboard...');

      setTimeout(() => {
        if (data.user.role === 'ROLE_DEALER') {
          navigate('/dealer/dashboard');
        } else if (data.user.role === 'ROLE_OWNER') {
          navigate('/owner/dashboard');
        } else {
          navigate('/farmer/dashboard');
        }
      }, 800);
    } catch (err) {
      console.error('Registration failed:', err);
      setError(err.response?.data?.message || 'Registration failed. An account with this email or mobile number may already exist.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center px-4 py-12">
      <div className="max-w-2xl w-full bg-white rounded-3xl p-8 border border-gray-200 shadow-xl space-y-6">
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-emerald-700 text-white flex items-center justify-center mx-auto shadow-sm">
            <span className="material-symbols-outlined text-3xl">agriculture</span>
          </div>
          <h2 className="font-headline-lg text-2xl font-bold text-gray-900">Create Your AgriRent Account</h2>
          <p className="text-xs text-gray-500">
            Join India's trusted network for tractor &amp; farm machinery rental, purchase, and escrow security
          </p>
        </div>

        {/* Tab Switcher: Sign In vs Register */}
        <div className="grid grid-cols-2 p-1 bg-gray-100 rounded-2xl">
          <Link
            to="/login"
            className="py-2.5 rounded-xl text-xs font-bold text-gray-600 hover:text-gray-900 transition-all text-center"
          >
            Sign In
          </Link>
          <button
            type="button"
            className="py-2.5 rounded-xl text-xs font-bold bg-white text-emerald-800 shadow-sm transition-all text-center"
          >
            Register New Account
          </button>
        </div>

        {error && (
          <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-xs font-semibold text-rose-700 flex items-center gap-2">
            <span className="material-symbols-outlined text-sm flex-shrink-0">error</span>
            <span>{error}</span>
          </div>
        )}

        {successMsg && (
          <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-xs font-semibold text-emerald-800 flex items-center gap-2">
            <span className="material-symbols-outlined text-sm flex-shrink-0 text-emerald-600">check_circle</span>
            <span>{successMsg}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Account Role Selection: 3 Roles */}
          <div>
            <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-2">
              Select Your Role *
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <label
                className={'p-3.5 rounded-2xl border text-xs font-semibold flex flex-col justify-between cursor-pointer transition-all ' + (
                  formData.role === 'ROLE_FARMER'
                    ? 'border-emerald-600 bg-emerald-50/70 text-emerald-900 ring-2 ring-emerald-500/20 shadow-sm'
                    : 'border-gray-200 bg-gray-50/50 text-gray-700 hover:bg-gray-50'
                )}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="font-bold flex items-center gap-1.5 text-gray-900">
                    <span className="material-symbols-outlined text-base text-emerald-700">agriculture</span>
                    Farmer / Renter
                  </span>
                  <input
                    type="radio"
                    name="role"
                    value="ROLE_FARMER"
                    checked={formData.role === 'ROLE_FARMER'}
                    onChange={handleChange}
                    className="accent-emerald-700 w-4 h-4"
                  />
                </div>
                <div className="text-[11px] text-gray-500 font-normal">
                  Rent machinery for field operations on daily/monthly terms
                </div>
              </label>

              <label
                className={'p-3.5 rounded-2xl border text-xs font-semibold flex flex-col justify-between cursor-pointer transition-all ' + (
                  formData.role === 'ROLE_OWNER'
                    ? 'border-emerald-600 bg-emerald-50/70 text-emerald-900 ring-2 ring-emerald-500/20 shadow-sm'
                    : 'border-gray-200 bg-gray-50/50 text-gray-700 hover:bg-gray-50'
                )}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="font-bold flex items-center gap-1.5 text-gray-900">
                    <span className="material-symbols-outlined text-base text-amber-700">garage</span>
                    Fleet Owner
                  </span>
                  <input
                    type="radio"
                    name="role"
                    value="ROLE_OWNER"
                    checked={formData.role === 'ROLE_OWNER'}
                    onChange={handleChange}
                    className="accent-emerald-700 w-4 h-4"
                  />
                </div>
                <div className="text-[11px] text-gray-500 font-normal">
                  List machinery, earn rental income &amp; manage bookings
                </div>
              </label>

              <label
                className={'p-3.5 rounded-2xl border text-xs font-semibold flex flex-col justify-between cursor-pointer transition-all ' + (
                  formData.role === 'ROLE_DEALER'
                    ? 'border-emerald-600 bg-emerald-50/70 text-emerald-900 ring-2 ring-emerald-500/20 shadow-sm'
                    : 'border-gray-200 bg-gray-50/50 text-gray-700 hover:bg-gray-50'
                )}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className="font-bold flex items-center gap-1.5 text-gray-900">
                    <span className="material-symbols-outlined text-base text-blue-700">storefront</span>
                    Machinery Dealer
                  </span>
                  <input
                    type="radio"
                    name="role"
                    value="ROLE_DEALER"
                    checked={formData.role === 'ROLE_DEALER'}
                    onChange={handleChange}
                    className="accent-emerald-700 w-4 h-4"
                  />
                </div>
                <div className="text-[11px] text-gray-500 font-normal">
                  Showroom sales, tractor inquiries &amp; trade sales
                </div>
              </label>
            </div>
          </div>

          {/* Name fields */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                First Name *
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">person</span>
                <input
                  type="text"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleChange}
                  placeholder="e.g. Ramesh"
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                Last Name *
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">person</span>
                <input
                  type="text"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleChange}
                  placeholder="e.g. Patil"
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                Mobile Number (10 Digits) *
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">phone</span>
                <input
                  type="tel"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  placeholder="e.g. 9822012345"
                  maxLength={13}
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                  required
                />
              </div>
              <p className="text-[10px] text-gray-400 mt-1">Can be used to log in instead of email</p>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                Email Address *
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">mail</span>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="e.g. ramesh.patil@example.com"
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                {formData.role === 'ROLE_DEALER' ? 'Dealership / Showroom Name' : 'Farm / Business Name'}
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">business</span>
                <input
                  type="text"
                  name="farmName"
                  value={formData.farmName}
                  onChange={handleChange}
                  placeholder={formData.role === 'ROLE_DEALER' ? 'e.g. Maharashtra Tractors & Motors' : 'e.g. Patil Krishi Farm'}
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                Maharashtra District *
              </label>
              <div className="relative flex items-center">
                <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">pin_drop</span>
                <select
                  name="district"
                  value={formData.district}
                  onChange={handleChange}
                  className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all cursor-pointer"
                  required
                >
                  {MAHARASHTRA_DISTRICTS.map((d) => (
                    <option key={d.id} value={d.id}>
                      {d.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {/* Password & Confirm Password */}
          <div className="pt-2 border-t border-gray-100 space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                  Choose Password *
                </label>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">lock</span>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    placeholder="Min. 6 characters"
                    minLength={6}
                    className="w-full h-11 pl-10 pr-10 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 text-gray-400 hover:text-gray-600 focus:outline-none"
                    title={showPassword ? 'Hide password' : 'Show password'}
                  >
                    <span className="material-symbols-outlined text-lg">
                      {showPassword ? 'visibility_off' : 'visibility'}
                    </span>
                  </button>
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider">
                    Confirm Password *
                  </label>
                  {passwordsMatch && (
                    <span className="text-[10px] text-emerald-600 font-bold flex items-center gap-0.5">
                      <span className="material-symbols-outlined text-xs">check</span> Matches
                    </span>
                  )}
                  {passwordsMismatch && (
                    <span className="text-[10px] text-rose-600 font-bold">Does not match</span>
                  )}
                </div>
                <div className="relative flex items-center">
                  <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">lock_reset</span>
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    name="confirmPassword"
                    value={formData.confirmPassword}
                    onChange={handleChange}
                    placeholder="Re-enter password"
                    minLength={6}
                    className={'w-full h-11 pl-10 pr-10 rounded-xl bg-gray-50 border text-xs font-medium outline-none focus:ring-2 transition-all ' + (
                      passwordsMismatch
                        ? 'border-rose-400 focus:ring-rose-400'
                        : 'border-gray-200 focus:ring-emerald-500 focus:bg-white'
                    )}
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 text-gray-400 hover:text-gray-600 focus:outline-none"
                    title={showConfirmPassword ? 'Hide password' : 'Show password'}
                  >
                    <span className="material-symbols-outlined text-lg">
                      {showConfirmPassword ? 'visibility_off' : 'visibility'}
                    </span>
                  </button>
                </div>
              </div>
            </div>
            <p className="text-[11px] text-gray-400">
              Your password will be securely hashed with BCrypt encryption. You can use it along with your email or mobile number to log in anytime.
            </p>
          </div>

          {/* Terms Agreement */}
          <div className="pt-2">
            <label className="flex items-start gap-2 text-xs text-gray-600 cursor-pointer">
              <input
                type="checkbox"
                name="agreeTerms"
                checked={formData.agreeTerms}
                onChange={handleChange}
                className="accent-emerald-700 mt-0.5 w-4 h-4 rounded"
                required
              />
              <span>
                I agree to the <strong>AgriRent Marketplace Terms of Service</strong>, escrow protection guidelines, and telematics equipment policies.
              </span>
            </label>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading || (formData.confirmPassword && formData.password !== formData.confirmPassword)}
            className="w-full h-12 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs flex items-center justify-center gap-2 transition-all shadow-md disabled:opacity-50 mt-4 cursor-pointer"
          >
            <span>{loading ? 'Creating Account & Logging In...' : 'Register Account & Sign In'}</span>
            <span className="material-symbols-outlined text-base">arrow_forward</span>
          </button>
        </form>

        <p className="text-xs text-center text-gray-500">
          Already have an AgriRent account?{' '}
          <Link to="/login" className="font-bold text-emerald-700 hover:underline">
            Sign In with Email or Mobile
          </Link>
        </p>
      </div>
    </div>
  );
};

export default RegisterPage;
