import apiClient from './apiClient';
import { ENDPOINTS } from '../constants/apiEndpoints';

export const adminService = {
  getMetrics: async () => {
    const response = await apiClient.get(ENDPOINTS.ADMIN.METRICS);
    return response.data;
  },

  getPendingEquipment: async () => {
    const response = await apiClient.get(ENDPOINTS.ADMIN.PENDING_EQUIPMENT);
    return response.data;
  },

  approveEquipment: async (id) => {
    const response = await apiClient.put(ENDPOINTS.ADMIN.APPROVE_EQUIPMENT(id));
    return response.data;
  },

  rejectEquipment: async (id, reason = '') => {
    const response = await apiClient.put(ENDPOINTS.ADMIN.REJECT_EQUIPMENT(id), { reason });
    return response.data;
  },

  getEscrowTransactions: async () => {
    const response = await apiClient.get(ENDPOINTS.ADMIN.ESCROW);
    return response.data;
  },

  releaseEscrow: async (id) => {
    const response = await apiClient.put(ENDPOINTS.ADMIN.RELEASE_ESCROW(id));
    return response.data;
  },

  holdEscrow: async (id, reason = '') => {
    const response = await apiClient.put(ENDPOINTS.ADMIN.HOLD_ESCROW(id), { reason });
    return response.data;
  }
};
