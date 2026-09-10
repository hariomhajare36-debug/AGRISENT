import apiClient from './apiClient';
import { ENDPOINTS } from '../constants/apiEndpoints';

export const equipmentService = {
  getAll: async (params = {}) => {
    const response = await apiClient.get(ENDPOINTS.EQUIPMENT.BASE, { params });
    return response.data;
  },

  getFeatured: async () => {
    const response = await apiClient.get(ENDPOINTS.EQUIPMENT.FEATURED);
    return response.data;
  },

  getById: async (id) => {
    const response = await apiClient.get(ENDPOINTS.EQUIPMENT.BY_ID(id));
    return response.data;
  },

  create: async (equipmentData) => {
    const response = await apiClient.post(ENDPOINTS.EQUIPMENT.BASE, equipmentData);
    return response.data;
  },

  update: async (id, equipmentData) => {
    const response = await apiClient.put(ENDPOINTS.EQUIPMENT.BY_ID(id), equipmentData);
    return response.data;
  },

  delete: async (id) => {
    const response = await apiClient.delete(ENDPOINTS.EQUIPMENT.BY_ID(id));
    return response.data;
  },

  getOwnerFleet: async () => {
    const response = await apiClient.get(ENDPOINTS.OWNER.FLEET);
    return response.data;
  },

  getOwnerStats: async () => {
    const response = await apiClient.get(ENDPOINTS.OWNER.STATS);
    return response.data;
  }
};
