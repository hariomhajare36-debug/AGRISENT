import React from 'react';
import { Link } from 'react-router-dom';

export const Footer = () => {
  return (
    <footer className="bg-inverse-surface text-inverse-on-surface border-t border-outline-variant/20 pt-16 pb-12 mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-10 mb-12">
          {/* Col 1: Brand */}
          <div className="lg:col-span-2 space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center text-on-primary">
                <span className="material-symbols-outlined text-2xl">agriculture</span>
              </div>
              <span className="font-headline-md text-2xl font-bold text-white">AgriRent</span>
            </div>
            <p className="text-sm text-outline-variant max-w-sm">
              The premier digital agricultural equipment marketplace. Connecting independent farmers with certified machinery owners through insured escrow transactions and real-time field telematics.
            </p>
            <div className="flex items-center gap-3 pt-2 text-outline-variant text-sm">
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-surface-container-highest/20 text-emerald-300 text-xs">
                <span className="w-2 h-2 rounded-full bg-secondary inline-block animate-pulse"></span>
                Escrow &amp; Telematics Guaranteed
              </span>
            </div>
          </div>

          {/* Col 2: Equipment */}
          <div>
            <h4 className="text-white font-label-md text-sm font-semibold uppercase tracking-wider mb-4">
              Machinery Fleet
            </h4>
            <ul className="space-y-2 text-sm text-outline-variant">
              <li>
                <Link to="/equipment?category=TRACTORS" className="hover:text-white transition-colors">
                  High-HP Tractors
                </Link>
              </li>
              <li>
                <Link to="/equipment?category=HARVESTERS" className="hover:text-white transition-colors">
                  Combine Harvesters
                </Link>
              </li>
              <li>
                <Link to="/equipment?category=TILLAGE" className="hover:text-white transition-colors">
                  Vertical Tillage &amp; Discs
                </Link>
              </li>
              <li>
                <Link to="/equipment?category=SEEDERS" className="hover:text-white transition-colors">
                  Planters &amp; Drills
                </Link>
              </li>
              <li>
                <Link to="/equipment?category=HAY_FORAGE" className="hover:text-white transition-colors">
                  Hay Balers &amp; Forage
                </Link>
              </li>
            </ul>
          </div>

          {/* Col 3: Solutions */}
          <div>
            <h4 className="text-white font-label-md text-sm font-semibold uppercase tracking-wider mb-4">
              Platform Portals
            </h4>
            <ul className="space-y-2 text-sm text-outline-variant">
              <li>
                <Link to="/farmer/dashboard" className="hover:text-white transition-colors">
                  Farmer Workspace
                </Link>
              </li>
              <li>
                <Link to="/owner/dashboard" className="hover:text-white transition-colors">
                  Fleet Owner Console
                </Link>
              </li>
              <li>
                <Link to="/owner/add-equipment" className="hover:text-white transition-colors">
                  List Heavy Machinery
                </Link>
              </li>
              <li>
                <Link to="/admin/console" className="hover:text-white transition-colors">
                  Escrow Operations
                </Link>
              </li>
            </ul>
          </div>

          {/* Col 4: Trust & Help */}
          <div>
            <h4 className="text-white font-label-md text-sm font-semibold uppercase tracking-wider mb-4">
              Security &amp; Support
            </h4>
            <ul className="space-y-2 text-sm text-outline-variant">
              <li>
                <span className="hover:text-white transition-colors cursor-pointer">
                  Escrow Protection Policy
                </span>
              </li>
              <li>
                <span className="hover:text-white transition-colors cursor-pointer">
                  Insurance &amp; Damage Waiver
                </span>
              </li>
              <li>
                <span className="hover:text-white transition-colors cursor-pointer">
                  24/7 Field Tech Dispatch
                </span>
              </li>
              <li>
                <span className="hover:text-white transition-colors cursor-pointer">
                  Equipment Telematics Spec
                </span>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-outline-variant/20 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-outline-variant">
          <p>© {new Date().getFullYear()} AgriRent Platform Inc. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <span className="hover:text-white cursor-pointer">Privacy Policy</span>
            <span className="hover:text-white cursor-pointer">Terms of Service</span>
            <span className="hover:text-white cursor-pointer">API Documentation</span>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
