export const EQUIPMENT_CATEGORIES = [
  { 
    id: 'all', 
    label: 'All Machinery', 
    icon: 'agriculture',
    image: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80',
    count: 129 
  },
  { 
    id: 'TRACTORS', 
    label: 'Tractors', 
    icon: 'agriculture', 
    image: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=800&q=80',
    description: 'Mahindra, Swaraj, Sonalika, John Deere, Massey, Kubota & more',
    count: 45 
  },
  { 
    id: 'HARVESTERS', 
    label: 'Combine Harvesters', 
    icon: 'grain', 
    image: 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=800&q=80',
    description: 'Self-propelled paddy, wheat & multi-crop combine harvesters',
    count: 10 
  },
  { 
    id: 'ROTAVATORS', 
    label: 'Rotavators & Rotary Tillers', 
    icon: 'landslide', 
    image: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=800&q=80',
    description: 'Shaktiman, Maschio Gaspardo, Fieldking & Lemken rotavators',
    count: 8 
  },
  { 
    id: 'CULTIVATORS', 
    label: 'Cultivators', 
    icon: 'handyman', 
    image: 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=800&q=80',
    description: '9-tyne, 11-tyne spring loaded & rigid field cultivators',
    count: 8 
  },
  { 
    id: 'SEEDERS', 
    label: 'Seeders & Planters', 
    icon: 'grass', 
    image: 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=800&q=80',
    description: 'Automatic multi-crop seed drills, pneumatic planters & super seeders',
    count: 9 
  },
  { 
    id: 'PLOUGHS', 
    label: 'Ploughs & Chiselers', 
    icon: 'carpenter', 
    image: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=800&q=80',
    description: 'Reversible MB ploughs, disc ploughs & heavy subsoilers',
    count: 8 
  },
  { 
    id: 'THRESHERS', 
    label: 'Multi-Crop Threshers', 
    icon: 'alt_route', 
    image: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
    description: 'High capacity wheat, soybean, maize & chickpea threshers',
    count: 8 
  },
  { 
    id: 'SPRAYERS', 
    label: 'Agricultural Sprayers', 
    icon: 'water_drop', 
    image: 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=800&q=80',
    description: 'Tractor-mounted boom sprayers, mist blowers & orchard sprayers',
    count: 8 
  },
  { 
    id: 'TRAILERS', 
    label: 'Tipping Trailers & Trolleys', 
    icon: 'local_shipping', 
    image: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
    description: 'Heavy duty hydraulic tipping trailers (3 to 10 Tonnes)',
    count: 8 
  },
  { 
    id: 'POWER_TILLERS', 
    label: 'Power Tillers', 
    icon: 'precision_manufacturing', 
    image: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=800&q=80',
    description: 'VST Shakti & Kamco 12-16 HP diesel walking power tillers',
    count: 6 
  },
  { 
    id: 'MINI_TRACTORS', 
    label: 'Mini & Orchard Tractors', 
    icon: 'agriculture', 
    image: 'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=800&q=80',
    description: 'Compact 4WD orchard, vineyard & small holding tractors (18-28 HP)',
    count: 5 
  },
  { 
    id: 'OTHER_EQUIPMENT', 
    label: 'Other Farm Equipment', 
    icon: 'construction', 
    image: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=800&q=80',
    description: 'Laser land levellers, post hole diggers, balers & loaders',
    count: 5 
  }
];

export const INDIAN_BRANDS = [
  { id: 'all', label: 'All Brands' },
  { id: 'Mahindra', label: 'Mahindra & Mahindra' },
  { id: 'Swaraj', label: 'Swaraj Tractors' },
  { id: 'Sonalika', label: 'Sonalika Tractors' },
  { id: 'John Deere', label: 'John Deere India' },
  { id: 'Massey Ferguson', label: 'Massey Ferguson (TAFE)' },
  { id: 'New Holland', label: 'New Holland Agriculture' },
  { id: 'Kubota', label: 'Kubota Agricultural Machinery' },
  { id: 'Eicher', label: 'Eicher Tractors' },
  { id: 'Powertrac', label: 'Powertrac (Escorts)' },
  { id: 'Farmtrac', label: 'Farmtrac (Escorts)' },
  { id: 'VST', label: 'VST Tillers Tractors' },
  { id: 'Deutz-Fahr', label: 'Deutz-Fahr' },
  { id: 'Shaktiman', label: 'Shaktiman Agro' },
  { id: 'Fieldking', label: 'Fieldking' },
  { id: 'Lemken', label: 'Lemken India' },
  { id: 'Maschio Gaspardo', label: 'Maschio Gaspardo' }
];

export const MAHARASHTRA_DISTRICTS = [
  { id: 'all', label: 'All Maharashtra' },
  { id: 'Nagpur', label: 'Nagpur (Vidarbha Hub)' },
  { id: 'Pune', label: 'Pune (Western Maharashtra)' },
  { id: 'Nashik', label: 'Nashik (Khandesh & Wine Belt)' },
  { id: 'Kolhapur', label: 'Kolhapur (Sugarcane Belt)' },
  { id: 'Chhatrapati Sambhajinagar', label: 'Chhatrapati Sambhajinagar (Marathwada Hub)' },
  { id: 'Amravati', label: 'Amravati (Cotton & Soybean Belt)' },
  { id: 'Ahmednagar', label: 'Ahmednagar (Agri Logistics Hub)' },
  { id: 'Sangli', label: 'Sangli (Turmeric & Grapes)' },
  { id: 'Satara', label: 'Satara' },
  { id: 'Akola', label: 'Akola' },
  { id: 'Jalgaon', label: 'Jalgaon (Banana City)' },
  { id: 'Nanded', label: 'Nanded' }
];

export const HORSEPOWER_CLASSES = [
  { value: 'all', label: 'All Power Classes' },
  { value: 'hp-under-30', label: '< 30 HP (Mini & Orchard)' },
  { value: 'hp-30-45', label: '30 - 45 HP (Light Utility)' },
  { value: 'hp-45-60', label: '45 - 60 HP (Standard Farmland)' },
  { value: 'hp-60-75', label: '60 - 75 HP (Heavy Duty Farming)' },
  { value: 'hp-75-plus', label: '75+ HP (Commercial & Heavy Duty)' }
];

export const STATUS_COLORS = {
  AVAILABLE: { bg: 'bg-emerald-50 text-emerald-700 border-emerald-200', dot: 'bg-emerald-500', label: 'Available Now' },
  RENTED: { bg: 'bg-blue-50 text-blue-700 border-blue-200', dot: 'bg-blue-500', label: 'Active in Field' },
  MAINTENANCE: { bg: 'bg-amber-50 text-amber-700 border-amber-200', dot: 'bg-amber-500', label: 'Maintenance' },
  IN_TRANSIT: { bg: 'bg-purple-50 text-purple-700 border-purple-200', dot: 'bg-purple-500', label: 'In Transit' },
  PENDING_APPROVAL: { bg: 'bg-orange-50 text-orange-700 border-orange-200', dot: 'bg-orange-500', label: 'Pending Audit' },
  REJECTED: { bg: 'bg-red-50 text-red-700 border-red-200', dot: 'bg-red-500', label: 'Rejected' },
};
