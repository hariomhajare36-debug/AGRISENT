export const EQUIPMENT_CATEGORIES = [
  { id: 'all', label: 'All Equipment', icon: 'agriculture' },
  { id: 'TRACTORS', label: 'Tractors', icon: 'agriculture', count: 842 },
  { id: 'HARVESTERS', label: 'Harvesters & Combines', icon: 'grain', count: 312 },
  { id: 'TILLAGE', label: 'Cultivators & Tillage', icon: 'landslide', count: 245 },
  { id: 'SEEDERS', label: 'Seeders & Planters', icon: 'grass', count: 189 },
  { id: 'SPRAYERS', label: 'Sprayers & Applicators', icon: 'water_drop', count: 120 },
  { id: 'HAY_FORAGE', label: 'Hay & Forage Equipment', icon: 'inventory_2', count: 134 }
];

export const HORSEPOWER_CLASSES = [
  { value: 'all', label: 'All Power Classes' },
  { value: 'hp-under-100', label: '< 100 HP (Utility)' },
  { value: 'hp-100-250', label: '150 - 250 HP (Row Crop)' },
  { value: 'hp-250-400', label: '250 - 400 HP (Heavy Duty)' },
  { value: 'hp-400-plus', label: '400+ HP (Articulated 4WD)' }
];

export const STATUS_COLORS = {
  AVAILABLE: { bg: 'bg-emerald-50 text-emerald-700 border-emerald-200', dot: 'bg-emerald-500', label: 'Available Now' },
  RENTED: { bg: 'bg-blue-50 text-blue-700 border-blue-200', dot: 'bg-blue-500', label: 'Active in Field' },
  MAINTENANCE: { bg: 'bg-amber-50 text-amber-700 border-amber-200', dot: 'bg-amber-500', label: 'Maintenance' },
  IN_TRANSIT: { bg: 'bg-purple-50 text-purple-700 border-purple-200', dot: 'bg-purple-500', label: 'In Transit' },
  PENDING_APPROVAL: { bg: 'bg-orange-50 text-orange-700 border-orange-200', dot: 'bg-orange-500', label: 'Pending Audit' },
  REJECTED: { bg: 'bg-red-50 text-red-700 border-red-200', dot: 'bg-red-500', label: 'Rejected' },
};
