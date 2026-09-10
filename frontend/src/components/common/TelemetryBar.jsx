import React from 'react';

export const TelemetryBar = ({ telemetry, compact = false }) => {
  if (!telemetry) return null;

  if (compact) {
    return (
      <div className="flex items-center gap-3 text-xs text-on-surface-variant bg-surface-container-low px-2.5 py-1.5 rounded-lg border border-outline-variant/30">
        <span className="flex items-center gap-1">
          <span className="material-symbols-outlined text-sm text-primary">timer</span>
          {telemetry.engineHours} hrs
        </span>
        <span className="flex items-center gap-1">
          <span className="material-symbols-outlined text-sm text-secondary">local_gas_station</span>
          {telemetry.fuelLevelPercent}% Fuel
        </span>
        <span className="flex items-center gap-1">
          <span className="material-symbols-outlined text-sm text-primary">satellite_alt</span>
          GPS Active
        </span>
      </div>
    );
  }

  return (
    <div className="bg-surface-container-lowest border border-outline-variant/50 rounded-xl p-4 shadow-sm">
      <div className="flex items-center justify-between mb-3 border-b border-outline-variant/30 pb-2">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-secondary text-lg">sensors</span>
          <span className="font-label-md text-label-md text-on-surface font-semibold">Live Telemetry & Diagnostics</span>
        </div>
        <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
          Connected
        </span>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="bg-surface-container-low p-2.5 rounded-lg">
          <span className="block text-xs text-on-surface-variant">Meter Hours</span>
          <span className="font-metric-val text-metric-val text-on-surface">{telemetry.engineHours || 0} hrs</span>
        </div>
        <div className="bg-surface-container-low p-2.5 rounded-lg">
          <span className="block text-xs text-on-surface-variant">Diesel Fuel Level</span>
          <div className="flex items-center gap-2 mt-0.5">
            <span className="font-metric-val text-metric-val text-on-surface">{telemetry.fuelLevelPercent || 100}%</span>
            <div className="flex-1 h-2 bg-surface-container-highest rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full ${
                  (telemetry.fuelLevelPercent || 100) < 25 ? 'bg-error' : 'bg-secondary'
                }`}
                style={{ width: `${telemetry.fuelLevelPercent || 100}%` }}
              ></div>
            </div>
          </div>
        </div>
        <div className="bg-surface-container-low p-2.5 rounded-lg">
          <span className="block text-xs text-on-surface-variant">DEF Fluid</span>
          <div className="flex items-center gap-2 mt-0.5">
            <span className="font-metric-val text-metric-val text-on-surface">{telemetry.defFluidPercent || 100}%</span>
            <div className="flex-1 h-2 bg-surface-container-highest rounded-full overflow-hidden">
              <div
                className="h-full bg-sky-500 rounded-full"
                style={{ width: `${telemetry.defFluidPercent || 100}%` }}
              ></div>
            </div>
          </div>
        </div>
        <div className="bg-surface-container-low p-2.5 rounded-lg">
          <span className="block text-xs text-on-surface-variant">Next Scheduled Service</span>
          <span className="font-label-md text-label-md text-on-surface">
            {telemetry.nextServiceHours ? `in ${telemetry.nextServiceHours - (telemetry.engineHours || 0)} hrs` : '150 hrs'}
          </span>
        </div>
      </div>
    </div>
  );
};

export default TelemetryBar;
