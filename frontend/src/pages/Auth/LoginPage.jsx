import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { authService } from '../../services/authService';

export const LoginPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuth();

  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // Forgot password modal state
  const [showForgotModal, setShowForgotModal] = useState(false);
  const [forgotInput, setForgotInput] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotMsg, setForgotMsg] = useState('');
  const [forgotError, setForgotError] = useState('');

  const redirectUrl = new URLSearchParams(location.search).get('redirect') || '/';

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const data = await login({ usernameOrEmail: identifier.trim(), password });
      
      // Redirect based on role or original URL
      if (redirectUrl !== '/') {
        navigate(redirectUrl);
      } else if (data.user.role === 'ROLE_ADMIN') {
        navigate('/admin/console');
      } else if (data.user.role === 'ROLE_OWNER') {
        navigate('/owner/dashboard');
      } else if (data.user.role === 'ROLE_DEALER') {
        navigate('/dealer/dashboard');
      } else {
        navigate('/farmer/dashboard');
      }
    } catch (err) {
      console.error('Login failed:', err);
      setError(err.response?.data?.message || 'Invalid email, mobile number, or password. Please check your credentials and try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickLogin = (demoIdentifier, demoPassword) => {
    setIdentifier(demoIdentifier);
    setPassword(demoPassword);
  };

  const handleForgotPassword = async (e) => {
    e.preventDefault();
    setForgotError('');
    setForgotMsg('');
    if (!forgotInput.trim()) {
      setForgotError('Please enter your registered email or 10-digit mobile number.');
      return;
    }
    setForgotLoading(true);
    try {
      const res = await authService.forgotPassword(forgotInput.trim());
      setForgotMsg(res.message || 'Password reset link and OTP have been sent to your registered contact.');
      setTimeout(() => {
        setShowForgotModal(false);
        setForgotMsg('');
        setForgotInput('');
      }, 4000);
    } catch (err) {
      setForgotError(err.response?.data?.message || 'Unable to find an account with that email or mobile number.');
    } finally {
      setForgotLoading(false);
    }
  };

  return (
    <div className="min-h-[75vh] flex items-center justify-center px-4 py-12">
      <div className="max-w-md w-full bg-white rounded-3xl p-8 border border-gray-200 shadow-xl space-y-6">
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-emerald-700 text-white flex items-center justify-center mx-auto shadow-sm">
            <span className="material-symbols-outlined text-3xl">agriculture</span>
          </div>
          <h2 className="font-headline-lg text-2xl font-bold text-gray-900">Welcome to AgriRent India</h2>
          <p className="text-xs text-gray-500">
            Agricultural machinery rental, purchase, and escrow marketplace
          </p>
        </div>

        {/* Tab Switcher: Sign In vs Register */}
        <div className="grid grid-cols-2 p-1 bg-gray-100 rounded-2xl">
          <button
            type="button"
            className="py-2.5 rounded-xl text-xs font-bold bg-white text-emerald-800 shadow-sm transition-all text-center"
          >
            Sign In
          </button>
          <Link
            to="/register"
            className="py-2.5 rounded-xl text-xs font-bold text-gray-600 hover:text-gray-900 transition-all text-center"
          >
            New User? Register
          </Link>
        </div>

        {error && (
          <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-xs font-semibold text-rose-700 flex items-center gap-2">
            <span className="material-symbols-outlined text-sm flex-shrink-0">error</span>
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
              Email or Indian Mobile Number *
            </label>
            <div className="relative flex items-center">
              <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">
                account_circle
              </span>
              <input
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="e.g. 9822012345 or farmer1@agrirent.demo"
                className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white transition-all"
                required
              />
            </div>
            <p className="text-[10px] text-gray-400 mt-1">Log in using your 10-digit mobile number or registered email</p>
          </div>

          <div>
            <div className="flex items-center justify-between mb-1">
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider">
                Password *
              </label>
              <button
                type="button"
                onClick={() => setShowForgotModal(true)}
                className="text-[11px] font-semibold text-emerald-700 hover:underline cursor-pointer"
              >
                Forgot password?
              </button>
            </div>
            <div className="relative flex items-center">
              <span className="material-symbols-outlined absolute left-3 text-gray-400 text-lg">
                lock
              </span>
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter your account password"
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

          <button
            type="submit"
            disabled={loading}
            className="w-full h-12 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs flex items-center justify-center gap-2 transition-all shadow-md disabled:opacity-50 cursor-pointer"
          >
            <span>{loading ? 'Authenticating...' : 'Sign In to Dashboard'}</span>
            <span className="material-symbols-outlined text-base">arrow_forward</span>
          </button>
        </form>

        {/* Quick Demo Accounts Selection (Clearly labeled for testing) */}
        <div className="pt-3 border-t border-gray-100">
          <div className="flex items-center justify-between mb-2">
            <span className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">
              Tester Demo Accounts (Password123!)
            </span>
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-semibold">
              Instant Fill
            </span>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-1.5">
            <button
              type="button"
              onClick={() => handleQuickLogin('farmer1@agrirent.demo', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-gray-50 hover:bg-emerald-50 border border-gray-200 text-[11px] font-semibold text-gray-700 hover:text-emerald-800 transition-colors text-left"
            >
              🌾 Farmer 1
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('farmer2@agrirent.demo', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-gray-50 hover:bg-emerald-50 border border-gray-200 text-[11px] font-semibold text-gray-700 hover:text-emerald-800 transition-colors text-left"
            >
              🌾 Farmer 2
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('owner1@agrirent.demo', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-gray-50 hover:bg-emerald-50 border border-gray-200 text-[11px] font-semibold text-gray-700 hover:text-emerald-800 transition-colors text-left"
            >
              🚜 Owner 1
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('owner2@agrirent.demo', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-gray-50 hover:bg-emerald-50 border border-gray-200 text-[11px] font-semibold text-gray-700 hover:text-emerald-800 transition-colors text-left"
            >
              🚜 Owner 2
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('admin@agrirent.demo', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-gray-50 hover:bg-purple-50 border border-gray-200 text-[11px] font-semibold text-gray-700 hover:text-purple-800 transition-colors text-left col-span-2 sm:col-span-1"
            >
              ⚡ Admin
            </button>
          </div>
        </div>

        <p className="text-xs text-center text-gray-500">
          New to AgriRent?{' '}
          <Link to="/register" className="font-bold text-emerald-700 hover:underline">
            Register your farm or fleet
          </Link>
        </p>
      </div>

      {/* Forgot Password Modal */}
      {showForgotModal && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-white rounded-3xl p-6 sm:p-8 max-w-md w-full shadow-2xl border border-gray-200 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-emerald-700 text-xl">lock_reset</span>
                <h3 className="font-bold text-base text-gray-900">Reset Account Password</h3>
              </div>
              <button
                type="button"
                onClick={() => setShowForgotModal(false)}
                className="p-1 rounded-full text-gray-400 hover:text-gray-600 hover:bg-gray-100"
              >
                <span className="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <p className="text-xs text-gray-600">
              Enter your registered email address or 10-digit mobile number. We will send you instructions and a verification code to safely reset your password.
            </p>

            {forgotMsg && (
              <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-200 text-xs text-emerald-800 font-semibold flex items-center gap-2">
                <span className="material-symbols-outlined text-sm text-emerald-600">check_circle</span>
                <span>{forgotMsg}</span>
              </div>
            )}

            {forgotError && (
              <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-semibold flex items-center gap-2">
                <span className="material-symbols-outlined text-sm">error</span>
                <span>{forgotError}</span>
              </div>
            )}

            <form onSubmit={handleForgotPassword} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1">
                  Registered Email or Mobile Number
                </label>
                <input
                  type="text"
                  value={forgotInput}
                  onChange={(e) => setForgotInput(e.target.value)}
                  placeholder="e.g. 9822012345 or farmer@example.com"
                  className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
                  required
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowForgotModal(false)}
                  className="px-4 py-2 rounded-xl text-xs font-bold text-gray-600 hover:bg-gray-100"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={forgotLoading}
                  className="px-5 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white text-xs font-bold disabled:opacity-50 flex items-center gap-1.5"
                >
                  <span>{forgotLoading ? 'Sending...' : 'Send Reset Instructions'}</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default LoginPage;
