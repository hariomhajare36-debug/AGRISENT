import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const ProtectedRoute = ({ children, allowedRoles }) => {
  const { isAuthenticated, loading, user } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="w-10 h-10 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
          <p className="text-sm text-on-surface-variant font-medium">Validating security session...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to={`/login?redirect=${encodeURIComponent(location.pathname)}`} replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user?.role)) {
    return (
      <div className="max-w-md mx-auto my-16 p-8 bg-surface-container-lowest rounded-2xl border border-error/30 text-center">
        <span className="material-symbols-outlined text-4xl text-error mb-2">lock_person</span>
        <h2 className="text-xl font-bold text-on-surface mb-2">Access Restricted</h2>
        <p className="text-sm text-on-surface-variant mb-6">
          Your account role ({user?.role?.replace('ROLE_', '')}) does not have permission to view this console.
        </p>
        <Navigate to="/" replace />
      </div>
    );
  }

  return children;
};

export default ProtectedRoute;
