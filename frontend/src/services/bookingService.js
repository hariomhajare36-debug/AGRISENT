import apiClient from './apiClient';
import { ENDPOINTS } from '../constants/apiEndpoints';

export const bookingService = {
  create: async (bookingData) => {
    const response = await apiClient.post(ENDPOINTS.BOOKINGS.BASE, bookingData);
    return response.data;
  },

  getById: async (id) => {
    const response = await apiClient.get(ENDPOINTS.BOOKINGS.BY_ID(id));
    return response.data;
  },

  updateStatus: async (id, status, notes = '') => {
    const response = await apiClient.put(ENDPOINTS.BOOKINGS.STATUS(id), { status, notes });
    return response.data;
  },

  getOwnerBookings: async () => {
    const response = await apiClient.get(ENDPOINTS.OWNER.BOOKINGS);
    return response.data;
  },

  getFarmerBookings: async () => {
    const response = await apiClient.get(ENDPOINTS.FARMER.BOOKINGS);
    return response.data;
  },

  getFarmerStats: async () => {
    const response = await apiClient.get(ENDPOINTS.FARMER.STATS);
    return response.data;
  },

  getActiveRentals: async () => {
    const response = await apiClient.get(ENDPOINTS.FARMER.ACTIVE);
    return response.data;
  }
};
