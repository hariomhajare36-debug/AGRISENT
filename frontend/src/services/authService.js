import apiClient from './apiClient';
import { ENDPOINTS } from '../constants/apiEndpoints';

export const authService = {
  login: async (credentials) => {
    const response = await apiClient.post(ENDPOINTS.AUTH.LOGIN, credentials);
    const { token, user } = response.data;
    if (token) {
      localStorage.setItem('agrirent_token', token);
      localStorage.setItem('agrirent_user', JSON.stringify(user));
    }
    return response.data;
  },

  register: async (userData) => {
    const response = await apiClient.post(ENDPOINTS.AUTH.REGISTER, userData);
    const { token, user } = response.data;
    if (token) {
      localStorage.setItem('agrirent_token', token);
      localStorage.setItem('agrirent_user', JSON.stringify(user));
    }
    return response.data;
  },

  getCurrentUser: async () => {
    const response = await apiClient.get(ENDPOINTS.AUTH.ME);
    if (response.data) {
      localStorage.setItem('agrirent_user', JSON.stringify(response.data));
    }
    return response.data;
  },

  updateProfile: async (profileData) => {
    const response = await apiClient.put(ENDPOINTS.AUTH.PROFILE, profileData);
    if (response.data) {
      localStorage.setItem('agrirent_user', JSON.stringify(response.data));
    }
    return response.data;
  },

  forgotPassword: async (emailOrPhone) => {
    const response = await apiClient.post(ENDPOINTS.AUTH.FORGOT_PASSWORD, { emailOrPhone });
    return response.data;
  },

  logout: () => {
    localStorage.removeItem('agrirent_token');
    localStorage.removeItem('agrirent_user');
  },

  getStoredUser: () => {
    const userStr = localStorage.getItem('agrirent_user');
    return userStr ? JSON.parse(userStr) : null;
  },

  getStoredToken: () => {
    return localStorage.getItem('agrirent_token');
  }
};
