import React from 'react';
import { Link } from 'react-router-dom';
import StatusBadge from './StatusBadge';

export const EquipmentCard = ({ equipment }) => {
  if (!equipment) return null;

  const defaultImage = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80';
  const imageUrl = (equipment.images && equipment.images.split(',')[0]) || defaultImage;

  return (
    <div className="group bg-surface-container-lowest rounded-2xl overflow-hidden border border-outline-variant/60 hover:border-primary/40 hover:shadow-xl transition-all duration-300 flex flex-col justify-between">
      <div>
        {/* Image Container */}
        <div className="relative aspect-[16/10] overflow-hidden bg-surface-container-high">
          <img
            src={imageUrl}
            alt={equipment.title}
            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
            loading="lazy"
          />
          <div className="absolute top-3 left-3 flex flex-wrap gap-1.5 z-10">
            <StatusBadge status={equipment.status} />
            {equipment.horsepower > 0 && (
              <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-surface/90 text-on-surface backdrop-blur-md shadow-sm">
                {equipment.horsepower} HP
              </span>
            )}
          </div>
          {equipment.isForSale && equipment.purchasePrice && (
            <div className="absolute bottom-3 right-3 bg-primary/95 text-on-primary backdrop-blur-sm text-xs font-semibold px-2.5 py-1 rounded-lg shadow-sm">
              Buy: ${Number(equipment.purchasePrice).toLocaleString()}
            </div>
          )}
        </div>

        {/* Card Body */}
        <div className="p-5">
          <div className="flex items-center gap-1 text-xs text-on-surface-variant mb-1.5">
            <span className="material-symbols-outlined text-sm text-primary">location_on</span>
            <span>{equipment.city}, {equipment.state}</span>
            <span className="mx-1.5">•</span>
            <span>{equipment.category}</span>
          </div>

          <Link to={`/equipment/${equipment.id}`}>
            <h3 className="font-headline-sm text-headline-sm text-on-surface font-bold group-hover:text-primary transition-colors line-clamp-1">
              {equipment.title}
            </h3>
          </Link>

          {/* Quick Specs Pill Row */}
          <div className="flex items-center gap-2 mt-3 text-xs text-on-surface-variant">
            <span className="inline-flex items-center gap-1 bg-surface-container-low px-2 py-1 rounded-md">
              <span className="material-symbols-outlined text-xs">timer</span>
              {equipment.engineHours || 0} hrs
            </span>
            {equipment.driveType && equipment.driveType !== 'N/A' && (
              <span className="inline-flex items-center gap-1 bg-surface-container-low px-2 py-1 rounded-md">
                <span className="material-symbols-outlined text-xs">settings</span>
                {equipment.driveType}
              </span>
            )}
            <span className="inline-flex items-center gap-1 bg-surface-container-low px-2 py-1 rounded-md">
              <span className="material-symbols-outlined text-xs text-secondary">verified</span>
              Escrow Insured
            </span>
          </div>
        </div>
      </div>

      {/* Card Footer */}
      <div className="px-5 py-4 border-t border-outline-variant/30 bg-surface-container-lowest/50 flex items-center justify-between gap-3">
        <div>
          <div className="text-[10px] uppercase font-bold text-on-surface-variant tracking-wider">Daily Rate</div>
          <div className="flex items-baseline gap-1">
            <span className="font-metric-val text-xl font-bold text-primary">
              ${Number(equipment.dailyRate).toLocaleString()}
            </span>
            <span className="text-xs text-on-surface-variant">/ day</span>
          </div>
        </div>

        <Link
          to={`/equipment/${equipment.id}`}
          className="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-primary text-on-primary font-label-md text-sm font-semibold hover:bg-primary-container transition-all shadow-sm hover:shadow"
        >
          <span>Rent Now</span>
          <span className="material-symbols-outlined text-sm">arrow_forward</span>
        </Link>
      </div>
    </div>
  );
};

export default EquipmentCard;
