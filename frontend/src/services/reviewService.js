import apiClient from './apiClient';
import { ENDPOINTS } from '../constants/apiEndpoints';

export const reviewService = {
  getByEquipmentId: async (equipmentId) => {
    const response = await apiClient.get(ENDPOINTS.REVIEWS.BY_EQUIPMENT(equipmentId));
    return response.data;
  },

  create: async (reviewData) => {
    const response = await apiClient.post(ENDPOINTS.REVIEWS.BASE, reviewData);
    return response.data;
  }
};
