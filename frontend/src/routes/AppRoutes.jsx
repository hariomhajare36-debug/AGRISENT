import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from '../components/layout/Layout';
import ProtectedRoute from './ProtectedRoute';

import LandingPage from '../pages/Landing/LandingPage';
import CatalogPage from '../pages/Catalog/CatalogPage';
import EquipmentDetailPage from '../pages/EquipmentDetail/EquipmentDetailPage';
import AddEquipmentPage from '../pages/AddEquipment/AddEquipmentPage';
import OwnerDashboardPage from '../pages/OwnerDashboard/OwnerDashboardPage';
import FarmerDashboardPage from '../pages/FarmerDashboard/FarmerDashboardPage';
import AdminConsolePage from '../pages/AdminConsole/AdminConsolePage';
import LoginPage from '../pages/Auth/LoginPage';
import RegisterPage from '../pages/Auth/RegisterPage';

export const AppRoutes = () => {
  return (
    <Routes>
      {/* Public Pages wrapped in Layout */}
      <Route
        path="/"
        element={
          <Layout>
            <LandingPage />
          </Layout>
        }
      />
      <Route
        path="/equipment"
        element={
          <Layout>
            <CatalogPage />
          </Layout>
        }
      />
      <Route
        path="/equipment/:id"
        element={
          <Layout>
            <EquipmentDetailPage />
          </Layout>
        }
      />

      {/* Auth Pages (wrapped in Layout) */}
      <Route
        path="/login"
        element={
          <Layout>
            <LoginPage />
          </Layout>
        }
      />
      <Route
        path="/register"
        element={
          <Layout>
            <RegisterPage />
          </Layout>
        }
      />

      {/* Protected: Farmer Workspace */}
      <Route
        path="/farmer/dashboard"
        element={
          <ProtectedRoute allowedRoles={['ROLE_FARMER', 'ROLE_ADMIN']}>
            <Layout>
              <FarmerDashboardPage />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Protected: Owner Workspace & Add Equipment */}
      <Route
        path="/owner/dashboard"
        element={
          <ProtectedRoute allowedRoles={['ROLE_OWNER', 'ROLE_ADMIN']}>
            <Layout>
              <OwnerDashboardPage />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/owner/add-equipment"
        element={
          <ProtectedRoute allowedRoles={['ROLE_OWNER', 'ROLE_ADMIN']}>
            <Layout>
              <AddEquipmentPage />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Protected: Admin Operations Console */}
      <Route
        path="/admin/console"
        element={
          <ProtectedRoute allowedRoles={['ROLE_ADMIN']}>
            <Layout>
              <AdminConsolePage />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
};

export default AppRoutes;
