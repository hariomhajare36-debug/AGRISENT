import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';

export const RegisterPage = () => {
  const navigate = useNavigate();
  const { register } = useAuth();

  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    username: '',
    password: '',
    role: 'ROLE_FARMER',
    farmName: '',
    phone: '',
    city: 'Ames',
    state: 'IA',
    zipCode: '50010',
  });

  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const data = await register({
        ...formData,
        username: formData.username || formData.email.split('@')[0],
      });
      if (data.user.role === 'ROLE_OWNER') {
        navigate('/owner/dashboard');
      } else {
        navigate('/farmer/dashboard');
      }
    } catch (err) {
      console.error('Registration failed:', err);
      setError(err.response?.data?.message || 'Registration failed. Please check inputs and try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[75vh] flex items-center justify-center px-4 py-12">
      <div className="max-w-xl w-full bg-surface-container-lowest rounded-3xl p-8 border border-outline-variant/50 shadow-xl space-y-6">
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-primary text-on-primary flex items-center justify-center mx-auto shadow-sm">
            <span className="material-symbols-outlined text-3xl">agriculture</span>
          </div>
          <h2 className="font-headline-lg text-2xl font-bold text-on-surface">Create an AgriRent Account</h2>
          <p className="text-xs text-on-surface-variant">
            Connect to the regional equipment sharing network with escrow protection
          </p>
        </div>

        {error && (
          <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2">
            <span className="material-symbols-outlined text-sm">error</span>
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Role Selection */}
          <div>
            <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-2">
              Select Your Primary Account Role
            </label>
            <div className="grid grid-cols-2 gap-3">
              <label
                className={`p-3.5 rounded-xl border text-xs font-semibold flex items-center gap-2 cursor-pointer transition-all ${
                  formData.role === 'ROLE_FARMER'
                    ? 'border-primary bg-primary/5 text-primary'
                    : 'border-outline-variant/40 bg-surface-container-low text-on-surface-variant'
                }`}
              >
                <input
                  type="radio"
                  name="role"
                  value="ROLE_FARMER"
                  checked={formData.role === 'ROLE_FARMER'}
                  onChange={handleChange}
                  className="accent-primary"
                />
                <div>
                  <div className="font-bold text-on-surface">Farmer / Renter</div>
                  <div className="text-[10px] text-on-surface-variant font-normal">Rent machinery for seasonal jobs</div>
                </div>
              </label>

              <label
                className={`p-3.5 rounded-xl border text-xs font-semibold flex items-center gap-2 cursor-pointer transition-all ${
                  formData.role === 'ROLE_OWNER'
                    ? 'border-primary bg-primary/5 text-primary'
                    : 'border-outline-variant/40 bg-surface-container-low text-on-surface-variant'
                }`}
              >
                <input
                  type="radio"
                  name="role"
                  value="ROLE_OWNER"
                  checked={formData.role === 'ROLE_OWNER'}
                  onChange={handleChange}
                  className="accent-primary"
                />
                <div>
                  <div className="font-bold text-on-surface">Equipment Fleet Owner</div>
                  <div className="text-[10px] text-on-surface-variant font-normal">List machines &amp; generate revenue</div>
                </div>
              </label>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Full Name *
              </label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleChange}
                placeholder="e.g. David Miller"
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Farm or Company Name
              </label>
              <input
                type="text"
                name="farmName"
                value={formData.farmName}
                onChange={handleChange}
                placeholder="e.g. Miller Family Row Crop"
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Email Address *
              </label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="name@farmmail.com"
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Phone Number
              </label>
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                placeholder="(515) 555-0177"
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                Password *
              </label>
              <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="At least 8 characters"
                className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
                required
                minLength={6}
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
                City &amp; State
              </label>
              <div className="grid grid-cols-2 gap-2">
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleChange}
                  placeholder="Ames"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none"
                />
                <input
                  type="text"
                  name="state"
                  value={formData.state}
                  onChange={handleChange}
                  placeholder="IA"
                  className="w-full h-11 px-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none"
                />
              </div>
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full h-12 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs flex items-center justify-center gap-2 transition-all shadow-md disabled:opacity-50 mt-4"
          >
            <span>{loading ? 'Creating Account...' : 'Complete Registration'}</span>
            <span className="material-symbols-outlined text-base">arrow_forward</span>
          </button>
        </form>

        <p className="text-xs text-center text-on-surface-variant">
          Already have an account?{' '}
          <Link to="/login" className="font-bold text-primary hover:underline">
            Sign In
          </Link>
        </p>
      </div>
    </div>
  );
};

export default RegisterPage;
