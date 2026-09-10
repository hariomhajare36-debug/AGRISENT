import React, { useState } from 'react';
import { Link, NavLink, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';

export const Navbar = () => {
  const { user, isAuthenticated, logout, isOwner, isAdmin } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [profileDropdownOpen, setProfileDropdownOpen] = useState(false);

  const handlePortalChange = (e) => {
    const portal = e.target.value;
    if (portal === 'farmer') navigate('/farmer/dashboard');
    else if (portal === 'owner') navigate('/owner/dashboard');
    else if (portal === 'admin') navigate('/admin/console');
  };

  // Determine current portal for the dropdown
  let currentPortal = 'farmer';
  if (location.pathname.startsWith('/owner')) currentPortal = 'owner';
  else if (location.pathname.startsWith('/admin')) currentPortal = 'admin';

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-surface/90 backdrop-blur-xl shadow-[0_1px_8px_rgba(0,0,0,0.04)] border-b border-outline-variant/30">
      <div className="h-20 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between gap-4">
        {/* Brand Logo */}
        <div className="flex items-center gap-4 flex-shrink-0">
          <Link to="/" className="flex items-center gap-3 group">
            <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center text-on-primary shadow-sm group-hover:bg-primary-container transition-colors">
              <span className="material-symbols-outlined text-2xl">agriculture</span>
            </div>
            <div className="flex flex-col">
              <span className="font-headline-sm text-headline-sm text-primary font-bold group-hover:text-primary-container transition-colors">
                AgriRent
              </span>
              <span className="font-label-sm text-label-sm text-on-surface-variant hidden sm:inline-block">
                Rent or Buy. Farm Smarter.
              </span>
            </div>
          </Link>
        </div>

        {/* Desktop Navigation */}
        <nav className="hidden xl:flex items-center gap-1">
          <NavLink
            to="/"
            end
            className={({ isActive }) =>
              `px-3 py-1.5 rounded-lg font-label-lg text-sm transition-colors ${
                isActive
                  ? 'bg-primary-container text-on-primary font-semibold'
                  : 'text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high'
              }`
            }
          >
            Home
          </NavLink>
          <NavLink
            to="/equipment"
            className={({ isActive }) =>
              `px-3 py-1.5 rounded-lg font-label-lg text-sm transition-colors ${
                isActive
                  ? 'bg-primary-container text-on-primary font-semibold'
                  : 'text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high'
              }`
            }
          >
            Equipment Catalog
          </NavLink>
          <NavLink
            to="/equipment?tab=rent"
            className="px-3 py-1.5 rounded-lg font-label-lg text-sm text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors"
          >
            Rent
          </NavLink>
          <NavLink
            to="/equipment?tab=buy"
            className="px-3 py-1.5 rounded-lg font-label-lg text-sm text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors"
          >
            Buy
          </NavLink>
          <a
            href="/#how-it-works"
            className="px-3 py-1.5 rounded-lg font-label-lg text-sm text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors"
          >
            How it Works
          </a>
        </nav>

        {/* Action Controls */}
        <div className="flex items-center gap-3 flex-shrink-0">
          {/* Portal Quick-Switcher */}
          {isAuthenticated && (
            <div className="hidden lg:flex items-center bg-surface-container-low px-3 py-1.5 rounded-lg border border-outline-variant/40">
              <label htmlFor="portal-select" className="sr-only">
                Select Portal
              </label>
              <select
                id="portal-select"
                value={currentPortal}
                onChange={handlePortalChange}
                className="bg-transparent font-label-sm text-xs font-semibold text-on-surface outline-none cursor-pointer pr-1"
              >
                <option value="farmer">Farmer Portal</option>
                <option value="owner">Fleet Owner Portal</option>
                {isAdmin && <option value="admin">Admin Console</option>}
              </select>
            </div>
          )}

          {/* List Equipment Button */}
          <Link
            to="/owner/add-equipment"
            className="hidden sm:inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-primary text-on-primary font-label-md text-sm font-semibold hover:bg-primary-container transition-all shadow-sm"
          >
            <span className="material-symbols-outlined text-sm">add</span>
            <span>List Equipment</span>
          </Link>

          {/* User Profile or Login */}
          {isAuthenticated ? (
            <div className="relative">
              <button
                onClick={() => setProfileDropdownOpen(!profileDropdownOpen)}
                className="flex items-center gap-2 bg-surface-container-low hover:bg-surface-container pl-1.5 pr-3 py-1 rounded-full border border-outline-variant/40 transition-colors"
              >
                <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-on-primary font-semibold text-sm">
                  {user?.fullName ? user.fullName[0] : 'U'}
                </div>
                <div className="hidden md:flex flex-col text-left">
                  <span className="font-label-sm text-xs font-bold text-on-surface leading-tight">
                    {user?.fullName || user?.username}
                  </span>
                  <span className="font-label-sm text-[10px] text-on-secondary-container flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-secondary inline-block"></span>
                    {user?.role?.replace('ROLE_', '')}
                  </span>
                </div>
                <span className="material-symbols-outlined text-sm text-on-surface-variant">
                  expand_more
                </span>
              </button>

              {/* Profile Dropdown */}
              {profileDropdownOpen && (
                <div className="absolute right-0 mt-2 w-56 bg-surface rounded-xl shadow-xl border border-outline-variant/50 py-2 z-50">
                  <div className="px-4 py-2 border-b border-outline-variant/30">
                    <p className="text-xs text-on-surface-variant">Signed in as</p>
                    <p className="text-sm font-bold text-on-surface truncate">{user?.email}</p>
                  </div>
                  <Link
                    to="/farmer/dashboard"
                    onClick={() => setProfileDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2 text-sm text-on-surface hover:bg-surface-container-high"
                  >
                    <span className="material-symbols-outlined text-sm">agriculture</span>
                    Farmer Dashboard
                  </Link>
                  <Link
                    to="/owner/dashboard"
                    onClick={() => setProfileDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2 text-sm text-on-surface hover:bg-surface-container-high"
                  >
                    <span className="material-symbols-outlined text-sm">fleet</span>
                    Fleet Owner Dashboard
                  </Link>
                  {isAdmin && (
                    <Link
                      to="/admin/console"
                      onClick={() => setProfileDropdownOpen(false)}
                      className="flex items-center gap-2 px-4 py-2 text-sm text-on-surface hover:bg-surface-container-high"
                    >
                      <span className="material-symbols-outlined text-sm">admin_panel_settings</span>
                      Admin Console
                    </Link>
                  )}
                  <div className="border-t border-outline-variant/30 mt-1 pt-1">
                    <button
                      onClick={() => {
                        setProfileDropdownOpen(false);
                        logout();
                      }}
                      className="w-full text-left flex items-center gap-2 px-4 py-2 text-sm text-error hover:bg-surface-container-high"
                    >
                      <span className="material-symbols-outlined text-sm">logout</span>
                      Sign Out
                    </button>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <Link
                to="/login"
                className="px-3.5 py-2 rounded-xl text-sm font-semibold text-primary hover:bg-surface-container-high transition-colors"
              >
                Sign In
              </Link>
              <Link
                to="/register"
                className="px-4 py-2 rounded-xl text-sm font-semibold bg-primary text-on-primary hover:bg-primary-container transition-all shadow-sm"
              >
                Register
              </Link>
            </div>
          )}

          {/* Mobile menu toggle */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="xl:hidden p-2 rounded-lg text-on-surface-variant hover:bg-surface-container-high"
            aria-label="Toggle Navigation"
          >
            <span className="material-symbols-outlined">{mobileMenuOpen ? 'close' : 'menu'}</span>
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {mobileMenuOpen && (
        <div className="xl:hidden bg-surface border-b border-outline-variant/40 px-4 pt-2 pb-6 space-y-2">
          <Link
            to="/"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-on-surface hover:bg-surface-container-high"
          >
            Home
          </Link>
          <Link
            to="/equipment"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-on-surface hover:bg-surface-container-high"
          >
            Equipment Catalog
          </Link>
          <Link
            to="/owner/add-equipment"
            onClick={() => setMobileMenuOpen(false)}
            className="block px-3 py-2 rounded-lg text-base font-medium text-primary font-semibold hover:bg-surface-container-high"
          >
            + List Equipment
          </Link>
          {isAuthenticated ? (
            <>
              <div className="border-t border-outline-variant/30 my-2 pt-2"></div>
              <Link
                to="/farmer/dashboard"
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2 rounded-lg text-base font-medium text-on-surface hover:bg-surface-container-high"
              >
                Farmer Dashboard
              </Link>
              <Link
                to="/owner/dashboard"
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2 rounded-lg text-base font-medium text-on-surface hover:bg-surface-container-high"
              >
                Owner Dashboard
              </Link>
              {isAdmin && (
                <Link
                  to="/admin/console"
                  onClick={() => setMobileMenuOpen(false)}
                  className="block px-3 py-2 rounded-lg text-base font-medium text-on-surface hover:bg-surface-container-high"
                >
                  Admin Console
                </Link>
              )}
              <button
                onClick={() => {
                  setMobileMenuOpen(false);
                  logout();
                }}
                className="w-full text-left px-3 py-2 rounded-lg text-base font-medium text-error hover:bg-surface-container-high"
              >
                Sign Out
              </button>
            </>
          ) : (
            <div className="pt-3 flex gap-2">
              <Link
                to="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="flex-1 text-center py-2 rounded-xl bg-surface-container-high font-semibold text-sm"
              >
                Sign In
              </Link>
              <Link
                to="/register"
                onClick={() => setMobileMenuOpen(false)}
                className="flex-1 text-center py-2 rounded-xl bg-primary text-on-primary font-semibold text-sm"
              >
                Register
              </Link>
            </div>
          )}
        </div>
      )}
    </header>
  );
};

export default Navbar;
