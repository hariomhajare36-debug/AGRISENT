import React, { useState, useEffect } from 'react';
import { useAuth } from '../../hooks/useAuth';
import { MAHARASHTRA_DISTRICTS } from '../../constants/categories';

export const ProfilePage = () => {
  const { user, updateProfile } = useAuth();
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    phone: '',
    district: 'Pune',
    city: 'Pune',
    address: '',
    state: 'Maharashtra',
    pincode: '411001',
    avatarUrl: '',
  });

  const [isSaving, setIsSaving] = useState(false);
  const [successMsg, setSuccessMsg] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    if (user) {
      const nameParts = (user.fullName || user.username || '').split(' ');
      setFormData({
        firstName: user.firstName || nameParts[0] || '',
        lastName: user.lastName || nameParts.slice(1).join(' ') || '',
        phone: user.phone || '',
        district: user.district || 'Pune',
        city: user.city || user.district || 'Pune',
        address: user.address || '',
        state: user.state || 'Maharashtra',
        pincode: user.pincode || '411001',
        avatarUrl: user.avatarUrl || '',
      });
    }
  }, [user]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSaving(true);
    setSuccessMsg('');
    setErrorMsg('');

    try {
      await updateProfile(formData);
      setSuccessMsg('Your profile details have been successfully updated!');
      setTimeout(() => setSuccessMsg(''), 4000);
    } catch (err) {
      console.error('Failed to update profile:', err);
      setErrorMsg(err.response?.data?.message || 'Failed to update profile. Please check your inputs.');
    } finally {
      setIsSaving(false);
    }
  };

  const getRoleBadge = (role) => {
    switch (role) {
      case 'ROLE_FARMER':
        return { label: 'Verified Farmer / Machine Renter', color: 'bg-emerald-100 text-emerald-800 border-emerald-300', icon: 'agriculture' };
      case 'ROLE_OWNER':
        return { label: 'Equipment Fleet Owner', color: 'bg-amber-100 text-amber-800 border-amber-300', icon: 'garage' };
      case 'ROLE_DEALER':
        return { label: 'Authorized Machinery Dealer', color: 'bg-blue-100 text-blue-800 border-blue-300', icon: 'storefront' };
      case 'ROLE_ADMIN':
        return { label: 'Platform Administrator', color: 'bg-purple-100 text-purple-800 border-purple-300', icon: 'admin_panel_settings' };
      default:
        return { label: 'AgriRent Member', color: 'bg-gray-100 text-gray-800 border-gray-300', icon: 'person' };
    }
  };

  const badge = getRoleBadge(user?.role);

  return (
    <div className="min-h-[80vh] max-w-4xl mx-auto px-4 py-10">
      <div className="bg-white rounded-3xl p-8 border border-gray-200 shadow-xl space-y-8">
        {/* Profile Header */}
        <div className="flex flex-col sm:flex-row items-center gap-5 pb-6 border-b border-gray-100">
          <div className="w-20 h-20 rounded-2xl bg-emerald-700 text-white text-3xl font-black flex items-center justify-center shadow-md">
            {formData.firstName ? formData.firstName[0].toUpperCase() : 'U'}
          </div>
          <div className="text-center sm:text-left space-y-1">
            <h2 className="font-headline-lg text-2xl font-bold text-gray-900">
              {formData.firstName} {formData.lastName || (user?.username)}
            </h2>
            <p className="text-xs text-gray-500 font-medium">
              Registered ID: <span className="font-mono text-gray-700">{user?.id}</span> • Joined AgriRent Platform
            </p>
            <div className="pt-1 flex items-center justify-center sm:justify-start gap-2">
              <span className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-bold border ${badge.color}`}>
                <span className="material-symbols-outlined text-sm">{badge.icon}</span>
                {badge.label}
              </span>
            </div>
          </div>
        </div>

        {/* Notifications */}
        {successMsg && (
          <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-xs font-semibold text-emerald-800 flex items-center gap-2">
            <span className="material-symbols-outlined text-emerald-600">check_circle</span>
            <span>{successMsg}</span>
          </div>
        )}
        {errorMsg && (
          <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs font-semibold text-rose-800 flex items-center gap-2">
            <span className="material-symbols-outlined text-rose-600">error</span>
            <span>{errorMsg}</span>
          </div>
        )}

        {/* Profile Edit Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                First Name *
              </label>
              <input
                type="text"
                name="firstName"
                value={formData.firstName}
                onChange={handleChange}
                placeholder="First name"
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Last Name *
              </label>
              <input
                type="text"
                name="lastName"
                value={formData.lastName}
                onChange={handleChange}
                placeholder="Last name"
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Email Address (Read-only)
              </label>
              <input
                type="email"
                value={user?.email || ''}
                readOnly
                disabled
                className="w-full h-11 px-3.5 rounded-xl bg-gray-100 border border-gray-200 text-xs font-medium text-gray-500 cursor-not-allowed"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Mobile Phone (Used for Login &amp; SMS) *
              </label>
              <input
                type="tel"
                name="phone"
                value={formData.phone}
                onChange={handleChange}
                placeholder="10-digit Indian Mobile e.g. 9822012345"
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
                required
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Maharashtra District *
              </label>
              <select
                name="district"
                value={formData.district}
                onChange={handleChange}
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-semibold outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white cursor-pointer"
                required
              >
                {MAHARASHTRA_DISTRICTS.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Taluka / City
              </label>
              <input
                type="text"
                name="city"
                value={formData.city}
                onChange={handleChange}
                placeholder="e.g. Baramati, Haveli"
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
              />
            </div>

            <div className="sm:col-span-2">
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Village / Street Address / Landmark
              </label>
              <input
                type="text"
                name="address"
                value={formData.address}
                onChange={handleChange}
                placeholder="e.g. Near Krishi Vigyan Kendra, Post Malegaon"
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                PIN Code
              </label>
              <input
                type="text"
                name="pincode"
                value={formData.pincode}
                onChange={handleChange}
                placeholder="e.g. 411001"
                maxLength={6}
                className="w-full h-11 px-3.5 rounded-xl bg-gray-50 border border-gray-200 text-xs font-medium outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-gray-700 uppercase tracking-wider mb-1.5">
                Account Role (Fixed)
              </label>
              <div className="h-11 px-3.5 rounded-xl bg-gray-100 border border-gray-200 text-xs font-semibold text-gray-600 flex items-center">
                {badge.label}
              </div>
            </div>
          </div>

          <div className="pt-4 border-t border-gray-100 flex items-center justify-end gap-3">
            <button
              type="submit"
              disabled={isSaving}
              className="px-6 py-2.5 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs flex items-center gap-2 transition-all shadow-md disabled:opacity-50 cursor-pointer"
            >
              <span className="material-symbols-outlined text-sm">save</span>
              <span>{isSaving ? 'Saving Changes...' : 'Save Profile Details'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default ProfilePage;
