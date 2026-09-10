import React, { useState, useRef, useEffect } from 'react';
import { Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { useWishlist } from '../../context/WishlistContext';
import { useCompare } from '../../context/CompareContext';

const DEMO_USERS = [
  { label: 'Farmer 1 (Ramesh Patil)', email: 'farmer1@agrirent.demo', role: 'ROLE_FARMER', icon: 'agriculture' },
  { label: 'Farmer 2 (Suresh Deshmukh)', email: 'farmer2@agrirent.demo', role: 'ROLE_FARMER', icon: 'agriculture' },
  { label: 'Fleet Owner 1 (Vikram Shinde)', email: 'owner1@agrirent.demo', role: 'ROLE_OWNER', icon: 'garage' },
  { label: 'Fleet Owner 2 (Anand Kulkarni)', email: 'owner2@agrirent.demo', role: 'ROLE_OWNER', icon: 'garage' },
  { label: 'Admin (Pooja Kadam)', email: 'admin@agrirent.demo', role: 'ROLE_ADMIN', icon: 'admin_panel_settings' }
];

export const Navbar = () => {
  const { user, isAuthenticated, isFarmer, isOwner, isDealer, isAdmin, login, logout } = useAuth();
  const { wishlistCount } = useWishlist();
  const { compareCount } = useCompare();
  const navigate = useNavigate();
  const location = useLocation();

  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [profileDropdownOpen, setProfileDropdownOpen] = useState(false);
  const [demoDropdownOpen, setDemoDropdownOpen] = useState(false);
  const [switchingUser, setSwitchingUser] = useState(false);

  const profileRef = useRef(null);
  const demoRef = useRef(null);

  // Close dropdowns when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (profileRef.current && !profileRef.current.contains(event.target)) {
        setProfileDropdownOpen(false);
      }
      if (demoRef.current && !demoRef.current.contains(event.target)) {
        setDemoDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleQuickSwitchUser = async (email) => {
    if (!email || switchingUser) return;
    setSwitchingUser(true);
    setDemoDropdownOpen(false);
    try {
      await login({ usernameOrEmail: email, password: 'Password123!' });
      const targetUser = DEMO_USERS.find((u) => u.email === email);
      if (targetUser?.role === 'ROLE_ADMIN') navigate('/admin/console');
      else if (targetUser?.role === 'ROLE_OWNER') navigate('/owner/dashboard');
      else navigate('/farmer/dashboard');
    } catch (err) {
      console.error('Failed to switch demo user:', err);
    } finally {
      setSwitchingUser(false);
    }
  };

  const getDashboardRoute = () => {
    if (isAdmin) return '/admin/console';
    if (isDealer) return '/dealer/dashboard';
    if (isOwner) return '/owner/dashboard';
    return '/farmer/dashboard';
  };

  const getDashboardLabel = () => {
    if (isAdmin) return 'Admin Console';
    if (isDealer) return 'Dealer Dashboard';
    if (isOwner) return 'Fleet Owner Dashboard';
    return 'Farmer Dashboard';
  };

  const getRoleBadge = (role) => {
    switch (role) {
      case 'ROLE_FARMER':
        return { label: 'Farmer / Renter', bg: 'bg-emerald-100 text-emerald-800' };
      case 'ROLE_OWNER':
        return { label: 'Equipment Owner', bg: 'bg-amber-100 text-amber-800' };
      case 'ROLE_DEALER':
        return { label: 'Machinery Dealer', bg: 'bg-blue-100 text-blue-800' };
      case 'ROLE_ADMIN':
        return { label: 'Administrator', bg: 'bg-purple-100 text-purple-800' };
      default:
        return { label: 'Member', bg: 'bg-gray-100 text-gray-800' };
    }
  };

  const roleInfo = getRoleBadge(user?.role);

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-md shadow-sm border-b border-gray-200">
      <div className="h-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between gap-4">
        {/* Brand Logo */}
        <div className="flex items-center gap-4 flex-shrink-0">
          <Link to="/" className="flex items-center gap-3 group">
            <div className="w-10 h-10 rounded-xl bg-emerald-700 flex items-center justify-center text-white shadow-sm group-hover:bg-emerald-800 transition-colors">
              <span className="material-symbols-outlined text-2xl">agriculture</span>
            </div>
            <div className="flex flex-col">
              <span className="text-xl font-black text-emerald-900 group-hover:text-emerald-700 transition-colors tracking-tight">
                AgriRent
              </span>
              <span className="text-[11px] font-semibold text-gray-500 hidden sm:inline-block">
                Rent or Buy. Farm Smarter. (₹ INR)
              </span>
            </div>
          </Link>
        </div>

        {/* Desktop Navigation */}
        <nav className="hidden xl:flex items-center gap-1.5">
          <NavLink
            to="/"
            end
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all ' + (
                isActive
                  ? 'bg-emerald-100 text-emerald-900 shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            Home
          </NavLink>
          <NavLink
            to="/catalog"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all ' + (
                isActive && !location.search
                  ? 'bg-emerald-100 text-emerald-900 shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            Equipment
          </NavLink>
          <NavLink
            to="/catalog?type=rent"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all ' + (
                location.search.includes('type=rent')
                  ? 'bg-emerald-600 text-white shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            Rent
          </NavLink>
          <NavLink
            to="/catalog?type=buy"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all ' + (
                location.search.includes('type=buy')
                  ? 'bg-emerald-600 text-white shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            Buy
          </NavLink>
          <NavLink
            to="/how-it-works"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all ' + (
                isActive
                  ? 'bg-emerald-100 text-emerald-900 shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            How It Works
          </NavLink>
          <NavLink
            to="/compare"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ' + (
                isActive
                  ? 'bg-emerald-100 text-emerald-900 shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            <span>Compare</span>
            {compareCount > 0 && (
              <span className="w-4 h-4 bg-emerald-600 text-white text-[10px] rounded-full flex items-center justify-center font-bold">
                {compareCount}
              </span>
            )}
          </NavLink>
          <NavLink
            to="/wishlist"
            className={({ isActive }) =>
              'px-3 py-1.5 rounded-xl text-xs font-bold transition-all flex items-center gap-1.5 ' + (
                isActive
                  ? 'bg-emerald-100 text-emerald-900 shadow-sm'
                  : 'text-gray-700 hover:text-emerald-700 hover:bg-emerald-50'
              )
            }
          >
            <span>Wishlist</span>
            {wishlistCount > 0 && (
              <span className="w-4 h-4 bg-rose-600 text-white text-[10px] rounded-full flex items-center justify-center font-bold">
                {wishlistCount}
              </span>
            )}
          </NavLink>
        </nav>

        {/* Action Controls & Authentication Area */}
        <div className="flex items-center gap-2.5 flex-shrink-0">
          {/* List Machinery Button */}
          <Link
            to="/owner/add-equipment"
            className="hidden lg:inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-emerald-700 text-white text-xs font-bold hover:bg-emerald-800 transition-all shadow-sm"
          >
            <span className="material-symbols-outlined text-sm">add</span>
            <span>List Machinery</span>
          </Link>

          {/* If NOT Authenticated: Show Secondary [ Demo Accounts ▾ ] + Prominent [ Login ] [ Register ] */}
          {!isAuthenticated ? (
            <div className="flex items-center gap-2">
              {/* Secondary Demo Accounts Dropdown */}
              <div className="relative hidden md:block" ref={demoRef}>
                <button
                  type="button"
                  onClick={() => setDemoDropdownOpen(!demoDropdownOpen)}
                  className="inline-flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-bold transition-colors border border-gray-200"
                  title="Quick test with 5 pre-configured demo users"
                >
                  <span className="material-symbols-outlined text-sm text-emerald-700">science</span>
                  <span>Demo Accounts</span>
                  <span className="material-symbols-outlined text-xs">expand_more</span>
                </button>

                {demoDropdownOpen && (
                  <div className="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-gray-200 py-2 z-50 animate-in fade-in zoom-in-95">
                    <div className="px-3.5 py-1.5 border-b border-gray-100">
                      <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider">Quick Fill Test Accounts</p>
                      <p className="text-[11px] text-gray-500">Password: Password123!</p>
                    </div>
                    <div className="py-1">
                      {DEMO_USERS.map((u) => (
                        <button
                          key={u.email}
                          type="button"
                          onClick={() => handleQuickSwitchUser(u.email)}
                          disabled={switchingUser}
                          className="w-full text-left px-3.5 py-2 hover:bg-emerald-50 flex items-center gap-2.5 transition-colors text-xs font-semibold text-gray-800"
                        >
                          <span className="material-symbols-outlined text-base text-emerald-700">{u.icon}</span>
                          <span className="truncate">{u.label}</span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Primary Authentication Buttons */}
              <Link
                to="/login"
                className="px-3.5 py-2 rounded-xl text-xs font-bold text-gray-700 hover:text-emerald-800 hover:bg-gray-100 transition-colors"
              >
                Login
              </Link>
              <Link
                to="/register"
                className="px-4 py-2 rounded-xl text-xs font-bold bg-emerald-700 text-white hover:bg-emerald-800 transition-all shadow-sm"
              >
                Register
              </Link>
            </div>
          ) : (
            /* If Authenticated: Show [ User Icon ] User Name ▾ */
            <div className="relative" ref={profileRef}>
              <button
                type="button"
                onClick={() => setProfileDropdownOpen(!profileDropdownOpen)}
                className="flex items-center gap-2.5 bg-gray-50 hover:bg-gray-100 pl-1.5 pr-3 py-1 rounded-full border border-gray-200 transition-colors cursor-pointer"
              >
                <div className="w-8 h-8 rounded-full bg-emerald-700 flex items-center justify-center text-white font-bold text-xs shadow-sm">
                  {user?.fullName ? user.fullName[0].toUpperCase() : (user?.username ? user.username[0].toUpperCase() : 'U')}
                </div>
                <div className="hidden sm:flex flex-col text-left">
                  <span className="text-xs font-bold text-gray-900 leading-tight truncate max-w-[120px]">
                    {user?.fullName || user?.username}
                  </span>
                  <span className="text-[10px] text-emerald-700 font-semibold flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 inline-block"></span>
                    {roleInfo.label}
                  </span>
                </div>
                <span className="material-symbols-outlined text-sm text-gray-500">
                  expand_more
                </span>
              </button>

              {/* User Dropdown Menu */}
              {profileDropdownOpen && (
                <div className="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-gray-200 py-2 z-50 animate-in fade-in zoom-in-95">
                  {/* Header info */}
                  <div className="px-4 py-2.5 border-b border-gray-100">
                    <div className="flex items-center justify-between mb-1">
                      <span className={'px-2 py-0.5 rounded-full text-[10px] font-bold ' + roleInfo.bg}>
                        {roleInfo.label}
                      </span>
                    </div>
                    <p className="text-xs font-bold text-gray-900 truncate">
                      {user?.fullName || user?.username}
                    </p>
                    <p className="text-[11px] text-gray-500 truncate">{user?.email || user?.phone}</p>
                  </div>

                  {/* Navigation Links */}
                  <div className="py-1">
                    <Link
                      to={getDashboardRoute()}
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center gap-2.5 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-emerald-50 hover:text-emerald-800"
                    >
                      <span className="material-symbols-outlined text-base text-emerald-700">dashboard</span>
                      {getDashboardLabel()}
                    </Link>

                    <Link
                      to="/profile"
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center gap-2.5 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-emerald-50 hover:text-emerald-800"
                    >
                      <span className="material-symbols-outlined text-base text-gray-500">manage_accounts</span>
                      My Profile
                    </Link>

                    <Link
                      to={isOwner ? "/owner/dashboard" : "/farmer/dashboard"}
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center gap-2.5 px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-emerald-50 hover:text-emerald-800"
                    >
                      <span className="material-symbols-outlined text-base text-gray-500">receipt_long</span>
                      My Bookings &amp; Orders
                    </Link>

                    <Link
                      to="/wishlist"
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center justify-between px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-emerald-50 hover:text-emerald-800"
                    >
                      <span className="flex items-center gap-2.5">
                        <span className="material-symbols-outlined text-base text-rose-500">favorite</span>
                        Saved Wishlist
                      </span>
                      {wishlistCount > 0 && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-rose-100 text-rose-700">
                          {wishlistCount}
                        </span>
                      )}
                    </Link>

                    <Link
                      to="/compare"
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center justify-between px-4 py-2 text-xs font-semibold text-gray-700 hover:bg-emerald-50 hover:text-emerald-800"
                    >
                      <span className="flex items-center gap-2.5">
                        <span className="material-symbols-outlined text-base text-emerald-600">compare_arrows</span>
                        Compare Machinery
                      </span>
                      {compareCount > 0 && (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-700">
                          {compareCount}
                        </span>
                      )}
                    </Link>
                  </div>

                  {/* Secondary Demo Switcher inside dropdown for developers */}
                  <div className="border-t border-gray-100 px-4 py-2 bg-gray-50/50">
                    <p className="text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1">Switch Demo Account</p>
                    <div className="grid grid-cols-2 gap-1">
                      {DEMO_USERS.map((u) => (
                        <button
                          key={u.email}
                          type="button"
                          onClick={() => {
                            setProfileDropdownOpen(false);
                            handleQuickSwitchUser(u.email);
                          }}
                          className="text-left px-1.5 py-1 rounded text-[10px] text-gray-600 hover:bg-emerald-50 hover:text-emerald-800 truncate"
                        >
                          {u.label.split(' ')[0]} {u.label.split(' ')[1]}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Logout Button */}
                  <div className="border-t border-gray-100 pt-1">
                    <button
                      type="button"
                      onClick={() => {
                        setProfileDropdownOpen(false);
                        logout();
                      }}
                      className="w-full text-left flex items-center gap-2.5 px-4 py-2 text-xs font-bold text-rose-600 hover:bg-rose-50 transition-colors cursor-pointer"
                    >
                      <span className="material-symbols-outlined text-base">logout</span>
                      Sign Out
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Mobile menu hamburger button */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="xl:hidden p-2 rounded-xl text-gray-700 hover:bg-gray-100"
            aria-label="Toggle Navigation"
          >
            <span className="material-symbols-outlined">{mobileMenuOpen ? 'close' : 'menu'}</span>
          </button>
        </div>
      </div>

      {/* Mobile Navigation Drawer */}
      {mobileMenuOpen && (
        <div className="xl:hidden bg-white border-b border-gray-200 px-4 pt-2 pb-6 space-y-2 max-h-[85vh] overflow-y-auto">
          {/* User profile card in mobile when logged in */}
          {isAuthenticated && (
            <div className="p-3 mb-2 rounded-2xl bg-emerald-50/70 border border-emerald-200 flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-full bg-emerald-700 text-white flex items-center justify-center font-bold text-xs">
                  {user?.fullName ? user.fullName[0].toUpperCase() : 'U'}
                </div>
                <div>
                  <p className="text-xs font-bold text-gray-900">{user?.fullName || user?.username}</p>
                  <span className={'inline-block px-2 py-0.2 rounded-full text-[10px] font-bold ' + roleInfo.bg}>
                    {roleInfo.label}
                  </span>
                </div>
              </div>
              <Link
                to="/profile"
                onClick={() => setMobileMenuOpen(false)}
                className="px-2.5 py-1 rounded-xl bg-white text-gray-700 text-xs font-bold shadow-sm"
              >
                Profile
              </Link>
            </div>
          )}

          <Link
            to="/"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            Home
          </Link>
          <Link
            to="/catalog"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            Equipment Catalog
          </Link>
          <Link
            to="/catalog?type=rent"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            Rent Equipment
          </Link>
          <Link
            to="/catalog?type=buy"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            Buy Equipment
          </Link>
          <Link
            to="/how-it-works"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            How It Works (Step-by-Step)
          </Link>
          <Link
            to="/compare"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center justify-between px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            <span>Compare Equipment</span>
            {compareCount > 0 && (
              <span className="w-5 h-5 bg-emerald-600 text-white text-xs rounded-full flex items-center justify-center font-bold">
                {compareCount}
              </span>
            )}
          </Link>
          <Link
            to="/wishlist"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center justify-between px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-emerald-50"
          >
            <span>Saved Wishlist</span>
            {wishlistCount > 0 && (
              <span className="w-5 h-5 bg-rose-600 text-white text-xs rounded-full flex items-center justify-center font-bold">
                {wishlistCount}
              </span>
            )}
          </Link>
          <Link
            to="/owner/add-equipment"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-xl text-sm font-bold text-emerald-800 bg-emerald-50"
          >
            + List Equipment for Rent/Sale
          </Link>

          {/* Authenticated user actions */}
          {isAuthenticated ? (
            <div className="pt-2 border-t border-gray-100 space-y-1">
              <Link
                to={getDashboardRoute()}
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-gray-100"
              >
                {getDashboardLabel()}
              </Link>
              <Link
                to="/profile"
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2 rounded-xl text-sm font-semibold text-gray-800 hover:bg-gray-100"
              >
                My Profile
              </Link>
              <button
                type="button"
                onClick={() => {
                  setMobileMenuOpen(false);
                  logout();
                }}
                className="w-full text-left px-3 py-2 rounded-xl text-sm font-bold text-red-600 hover:bg-red-50"
              >
                Sign Out
              </button>
            </div>
          ) : (
            <div className="pt-3 border-t border-gray-100 space-y-3">
              <div className="flex gap-2">
                <Link
                  to="/login"
                  onClick={() => setMobileMenuOpen(false)}
                  className="flex-1 text-center py-2.5 rounded-xl bg-gray-100 font-bold text-xs text-gray-800"
                >
                  Login
                </Link>
                <Link
                  to="/register"
                  onClick={() => setMobileMenuOpen(false)}
                  className="flex-1 text-center py-2.5 rounded-xl bg-emerald-700 text-white font-bold text-xs"
                >
                  Register
                </Link>
              </div>

              {/* Demo accounts quick picker in mobile */}
              <div className="pt-2 border-t border-gray-100">
                <label className="block text-[10px] font-bold text-gray-400 uppercase tracking-wider mb-1 px-1">
                  Tester Demo Accounts
                </label>
                <div className="grid grid-cols-1 gap-1">
                  {DEMO_USERS.map((u) => (
                    <button
                      key={u.email}
                      type="button"
                      onClick={() => {
                        handleQuickSwitchUser(u.email);
                        setMobileMenuOpen(false);
                      }}
                      className="text-left px-3 py-1.5 text-xs text-emerald-800 font-semibold hover:bg-emerald-50 rounded-lg flex items-center gap-2"
                    >
                      <span className="material-symbols-outlined text-sm">{u.icon}</span>
                      <span>{u.label}</span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      )}
    </header>
  );
};

export default Navbar;
