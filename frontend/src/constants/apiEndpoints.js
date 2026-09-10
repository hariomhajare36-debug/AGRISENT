export const API_BASE_URL = '/api';

export const ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    ME: '/auth/me',
    PROFILE: '/auth/profile',
    FORGOT_PASSWORD: '/auth/forgot-password',
  },
  EQUIPMENT: {
    BASE: '/equipment',
    FEATURED: '/equipment/featured',
    BY_ID: (id) => `/equipment/${id}`,
  },
  BOOKINGS: {
    BASE: '/bookings',
    BY_ID: (id) => `/bookings/${id}`,
    STATUS: (id) => `/bookings/${id}/status`,
  },
  REVIEWS: {
    BASE: '/reviews',
    BY_EQUIPMENT: (id) => `/reviews/equipment/${id}`,
  },
  OWNER: {
    FLEET: '/owner/fleet',
    BOOKINGS: '/owner/bookings',
    STATS: '/owner/stats',
  },
  FARMER: {
    BOOKINGS: '/farmer/bookings',
    STATS: '/farmer/stats',
    ACTIVE: '/farmer/active-rentals',
  },
  ADMIN: {
    METRICS: '/admin/metrics',
    PENDING_EQUIPMENT: '/admin/equipment/pending',
    APPROVE_EQUIPMENT: (id) => `/admin/equipment/${id}/approve`,
    REJECT_EQUIPMENT: (id) => `/admin/equipment/${id}/reject`,
    ESCROW: '/admin/escrow',
    RELEASE_ESCROW: (id) => `/admin/escrow/${id}/release`,
    HOLD_ESCROW: (id) => `/admin/escrow/${id}/hold`,
  },
};
