import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Layout from '../components/layout/Layout';
import ProtectedRoute from './ProtectedRoute';

import LandingPage from '../pages/Landing/LandingPage';
import CatalogPage from '../pages/Catalog/CatalogPage';
import EquipmentDetailPage from '../pages/EquipmentDetail/EquipmentDetailPage';
import HowItWorksPage from '../pages/HowItWorks/HowItWorksPage';
import ComparePage from '../pages/Compare/ComparePage';
import WishlistPage from '../pages/Wishlist/WishlistPage';
import PaymentPage from '../pages/Checkout/PaymentPage';
import AddEquipmentPage from '../pages/AddEquipment/AddEquipmentPage';
import OwnerDashboardPage from '../pages/OwnerDashboard/OwnerDashboardPage';
import FarmerDashboardPage from '../pages/FarmerDashboard/FarmerDashboardPage';
import AdminConsolePage from '../pages/AdminConsole/AdminConsolePage';
import LoginPage from '../pages/Auth/LoginPage';
import RegisterPage from '../pages/Auth/RegisterPage';
import ProfilePage from '../pages/Profile/ProfilePage';
import DealerDashboardPage from '../pages/DealerDashboard/DealerDashboardPage';

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
        path="/catalog"
        element={
          <Layout>
            <CatalogPage />
          </Layout>
        }
      />
      <Route
        path="/rent"
        element={<Navigate to="/catalog?type=rent" replace />}
      />
      <Route
        path="/buy"
        element={<Navigate to="/catalog?type=buy" replace />}
      />
      <Route
        path="/equipment/:id"
        element={
          <Layout>
            <EquipmentDetailPage />
          </Layout>
        }
      />

      {/* Dedicated Indian Marketplace Pages */}
      <Route
        path="/how-it-works"
        element={
          <Layout>
            <HowItWorksPage />
          </Layout>
        }
      />
      <Route
        path="/compare"
        element={
          <Layout>
            <ComparePage />
          </Layout>
        }
      />
      <Route
        path="/wishlist"
        element={
          <Layout>
            <WishlistPage />
          </Layout>
        }
      />
      <Route
        path="/checkout"
        element={
          <Layout>
            <PaymentPage />
          </Layout>
        }
      />
      <Route
        path="/payment"
        element={
          <Layout>
            <PaymentPage />
          </Layout>
        }
      />

      {/* Auth Pages */}
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
      <Route
        path="/farmer-dashboard"
        element={<Navigate to="/farmer/dashboard" replace />}
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
        path="/owner-dashboard"
        element={<Navigate to="/owner/dashboard" replace />}
      />
      <Route
        path="/owner/add-equipment"
        element={
          <ProtectedRoute allowedRoles={['ROLE_OWNER', 'ROLE_DEALER', 'ROLE_ADMIN']}>
            <Layout>
              <AddEquipmentPage />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Protected: Dealer Portal */}
      <Route
        path="/dealer/dashboard"
        element={
          <ProtectedRoute allowedRoles={['ROLE_DEALER', 'ROLE_OWNER', 'ROLE_ADMIN']}>
            <Layout>
              <DealerDashboardPage />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/dealer-dashboard"
        element={<Navigate to="/dealer/dashboard" replace />}
      />

      {/* Protected: User Profile Management */}
      <Route
        path="/profile"
        element={
          <ProtectedRoute>
            <Layout>
              <ProfilePage />
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
      <Route
        path="/admin-console"
        element={<Navigate to="/admin/console" replace />}
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
};

export default AppRoutes;
