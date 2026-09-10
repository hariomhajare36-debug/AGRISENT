import React from 'react';
import Navbar from './Navbar';
import Footer from './Footer';

export const Layout = ({ children }) => {
  return (
    <div className="flex flex-col min-h-screen bg-surface">
      <Navbar />
      <main className="flex-grow pt-20">{children}</main>
      <Footer />
    </div>
  );
};

export default Layout;
