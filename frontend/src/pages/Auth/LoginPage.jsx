import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';

export const LoginPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const redirectUrl = new URLSearchParams(location.search).get('redirect') || '/';

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const data = await login({ usernameOrEmail: email, password });
      // Redirect based on role or original URL
      if (redirectUrl !== '/') {
        navigate(redirectUrl);
      } else if (data.user.role === 'ROLE_ADMIN') {
        navigate('/admin/console');
      } else if (data.user.role === 'ROLE_OWNER') {
        navigate('/owner/dashboard');
      } else {
        navigate('/farmer/dashboard');
      }
    } catch (err) {
      console.error('Login failed:', err);
      setError(err.response?.data?.message || 'Invalid email or password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleQuickLogin = (demoEmail, demoPassword) => {
    setEmail(demoEmail);
    setPassword(demoPassword);
  };

  return (
    <div className="min-h-[75vh] flex items-center justify-center px-4 py-12">
      <div className="max-w-md w-full bg-surface-container-lowest rounded-3xl p-8 border border-outline-variant/50 shadow-xl space-y-6">
        {/* Brand Header */}
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-primary text-on-primary flex items-center justify-center mx-auto shadow-sm">
            <span className="material-symbols-outlined text-3xl">agriculture</span>
          </div>
          <h2 className="font-headline-lg text-2xl font-bold text-on-surface">Sign in to AgriRent</h2>
          <p className="text-xs text-on-surface-variant">
            Heavy agricultural equipment rentals, telematics, and escrow transactions
          </p>
        </div>

        {error && (
          <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2">
            <span className="material-symbols-outlined text-sm">error</span>
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-bold text-on-surface uppercase tracking-wider mb-1">
              Email or Username
            </label>
            <div className="relative flex items-center">
              <span className="material-symbols-outlined absolute left-3 text-on-surface-variant text-lg">
                mail
              </span>
              <input
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@farmmail.com or username"
                className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
                required
              />
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-1">
              <label className="block text-xs font-bold text-on-surface uppercase tracking-wider">
                Password
              </label>
              <a href="#" className="text-[11px] text-primary hover:underline">Forgot password?</a>
            </div>
            <div className="relative flex items-center">
              <span className="material-symbols-outlined absolute left-3 text-on-surface-variant text-lg">
                lock
              </span>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full h-11 pl-10 pr-3.5 rounded-xl bg-surface-container-low border border-outline-variant/40 text-xs font-medium outline-none focus:ring-2 focus:ring-primary/40"
                required
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full h-12 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs flex items-center justify-center gap-2 transition-all shadow-md disabled:opacity-50"
          >
            <span>{loading ? 'Authenticating...' : 'Sign In to Dashboard'}</span>
            <span className="material-symbols-outlined text-base">arrow_forward</span>
          </button>
        </form>

        {/* Quick Demo Accounts Selection */}
        <div className="pt-2 border-t border-outline-variant/30">
          <p className="text-[11px] font-bold text-on-surface-variant uppercase tracking-wider text-center mb-2">
            Quick Fill Demo Accounts (Password: Password123!)
          </p>
          <div className="grid grid-cols-3 gap-2">
            <button
              type="button"
              onClick={() => handleQuickLogin('david.miller@farmmail.com', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-surface-container-low hover:bg-surface-container-high border border-outline-variant/30 text-[11px] font-semibold text-on-surface transition-colors"
            >
              🌾 Farmer
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('marcus@cedarvalley.com', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-surface-container-low hover:bg-surface-container-high border border-outline-variant/30 text-[11px] font-semibold text-on-surface transition-colors"
            >
              🚜 Owner
            </button>
            <button
              type="button"
              onClick={() => handleQuickLogin('admin@agrirent.com', 'Password123!')}
              className="px-2 py-1.5 rounded-lg bg-surface-container-low hover:bg-surface-container-high border border-outline-variant/30 text-[11px] font-semibold text-on-surface transition-colors"
            >
              ⚡ Admin
            </button>
          </div>
        </div>

        <p className="text-xs text-center text-on-surface-variant">
          Don't have an account yet?{' '}
          <Link to="/register" className="font-bold text-primary hover:underline">
            Register your farm or fleet
          </Link>
        </p>
      </div>
    </div>
  );
};

export default LoginPage;
