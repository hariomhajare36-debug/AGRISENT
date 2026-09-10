import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { equipmentService } from '../../services/equipmentService';
import { formatINR } from '../../utils/currency';

export const DealerDashboardPage = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('inventory');
  const [inventory, setInventory] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadFleet = async () => {
      try {
        const data = await equipmentService.getAllEquipment();
        setInventory(data.slice(0, 8));
      } catch (err) {
        console.error('Failed to load dealer inventory:', err);
      } finally {
        setLoading(false);
      }
    };
    loadFleet();
  }, []);

  const sampleLeads = [
    {
      id: 1,
      farmerName: 'Ramesh Patil',
      phone: '+91 98220 12345',
      district: 'Pune (Baramati)',
      machinery: 'Mahindra 575 DI Tractor (45 HP)',
      type: 'Purchase Enquiry',
      budget: '₹ 6,50,000',
      status: 'New Lead',
      date: 'Today, 10:30 AM',
    },
    {
      id: 2,
      farmerName: 'Suresh Deshmukh',
      phone: '+91 98220 54321',
      district: 'Nashik (Niphad)',
      machinery: 'John Deere 5310 4WD (55 HP)',
      type: 'Seasonal Rent (30 Days)',
      budget: '₹ 45,000 / month',
      status: 'Quotation Sent',
      date: 'Yesterday',
    },
    {
      id: 3,
      farmerName: 'Ganesh Shinde',
      phone: '+91 98901 88776',
      district: 'Kolhapur (Karveer)',
      machinery: 'Kubota MU4501 4WD Tractor',
      type: 'Immediate Purchase',
      budget: '₹ 8,20,000',
      status: 'Test Drive Booked',
      date: '2 days ago',
    },
    {
      id: 4,
      farmerName: 'Datta Jadhav',
      phone: '+91 97654 33210',
      district: 'Satara (Phaltan)',
      machinery: 'Shaktiman Rotary Tiller 7ft',
      type: 'Buy / Subsidy Enquiry',
      budget: '₹ 1,15,000',
      status: 'In Discussion',
      date: '3 days ago',
    },
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
      {/* Dealer Welcome Header */}
      <div className="bg-gradient-to-r from-emerald-800 to-emerald-950 rounded-3xl p-8 text-white flex flex-col md:flex-row items-start md:items-center justify-between gap-6 shadow-xl">
        <div className="space-y-2">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 backdrop-blur-md text-emerald-200 text-xs font-bold">
            <span className="material-symbols-outlined text-xs">verified</span>
            Authorized Machinery Dealership
          </div>
          <h1 className="font-headline-lg text-2xl sm:text-3xl font-black tracking-tight">
            {user?.farmName || (user?.fullName ? user.fullName + ' Machinery Hub' : 'Agri-Dealer Machinery Hub')}
          </h1>
          <p className="text-xs text-emerald-100 max-w-xl">
            Manage showroom equipment, process direct farmer inquiries, arrange physical demonstrations, and close sales with AgriRent escrow security.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link
            to="/owner/add-equipment"
            className="px-5 py-3 rounded-2xl bg-white text-emerald-900 font-bold text-xs flex items-center gap-2 hover:bg-emerald-50 transition-all shadow-md"
          >
            <span className="material-symbols-outlined text-sm">add_business</span>
            <span>+ Add Showroom Unit</span>
          </Link>
          <Link
            to="/profile"
            className="px-4 py-3 rounded-2xl bg-white/10 hover:bg-white/20 text-white font-bold text-xs flex items-center gap-2 transition-all border border-white/20"
          >
            <span className="material-symbols-outlined text-sm">settings</span>
            <span>Dealership Settings</span>
          </Link>
        </div>
      </div>

      {/* KPI Metrics */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white rounded-3xl p-6 border border-gray-200 shadow-sm space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wider">Showroom Units</span>
            <span className="w-8 h-8 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center material-symbols-outlined text-lg">
              storefront
            </span>
          </div>
          <p className="text-2xl font-black text-gray-900">24 Units</p>
          <p className="text-[11px] text-emerald-700 font-semibold flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">check_circle</span> 18 Ready for Demo
          </p>
        </div>

        <div className="bg-white rounded-3xl p-6 border border-gray-200 shadow-sm space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wider">Showroom Valuation</span>
            <span className="w-8 h-8 rounded-xl bg-blue-100 text-blue-700 flex items-center justify-center material-symbols-outlined text-lg">
              currency_rupee
            </span>
          </div>
          <p className="text-2xl font-black text-gray-900">₹ 1.84 Cr</p>
          <p className="text-[11px] text-gray-500 font-semibold">Tractors, Harvesters &amp; Implements</p>
        </div>

        <div className="bg-white rounded-3xl p-6 border border-gray-200 shadow-sm space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wider">Farmer Inquiries</span>
            <span className="w-8 h-8 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center material-symbols-outlined text-lg">
              contact_phone
            </span>
          </div>
          <p className="text-2xl font-black text-gray-900">14 Active</p>
          <p className="text-[11px] text-amber-700 font-semibold flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">schedule</span> 4 Pending Follow-up
          </p>
        </div>

        <div className="bg-white rounded-3xl p-6 border border-gray-200 shadow-sm space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wider">Completed Sales</span>
            <span className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center material-symbols-outlined text-lg">
              handshake
            </span>
          </div>
          <p className="text-2xl font-black text-gray-900">₹ 32.5 Lakh</p>
          <p className="text-[11px] text-purple-700 font-semibold">Processed via Escrow this month</p>
        </div>
      </div>

      {/* Main Tabs */}
      <div className="flex border-b border-gray-200 gap-6">
        <button
          type="button"
          onClick={() => setActiveTab('inventory')}
          className={'pb-3 text-xs font-bold transition-all border-b-2 flex items-center gap-2 ' + (
            activeTab === 'inventory'
              ? 'border-emerald-700 text-emerald-800'
              : 'border-transparent text-gray-500 hover:text-gray-900'
          )}
        >
          <span className="material-symbols-outlined text-base">agriculture</span>
          <span>Showroom Inventory ({inventory.length})</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab('leads')}
          className={'pb-3 text-xs font-bold transition-all border-b-2 flex items-center gap-2 ' + (
            activeTab === 'leads'
              ? 'border-emerald-700 text-emerald-800'
              : 'border-transparent text-gray-500 hover:text-gray-900'
          )}
        >
          <span className="material-symbols-outlined text-base">connect_without_contact</span>
          <span>Farmer Inquiries &amp; Leads ({sampleLeads.length})</span>
        </button>
      </div>

      {/* Inventory Tab Content */}
      {activeTab === 'inventory' && (
        <div className="space-y-4">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <h2 className="text-lg font-bold text-gray-900">Listed Showroom Machinery</h2>
            <Link
              to="/owner/add-equipment"
              className="px-4 py-2 rounded-xl bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs flex items-center gap-1.5 shadow-sm"
            >
              <span className="material-symbols-outlined text-sm">add</span>
              <span>Add New Equipment</span>
            </Link>
          </div>

          {loading ? (
            <div className="p-12 text-center text-xs text-gray-500">Loading dealership inventory...</div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {inventory.map((item) => (
                <div key={item.id} className="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition-shadow">
                  <div className="h-40 bg-gray-100 relative">
                    <img
                      src={item.imageUrl || item.image || 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80'}
                      alt={item.name}
                      className="w-full h-full object-cover"
                    />
                    <span className="absolute top-2 right-2 px-2 py-0.5 rounded-full bg-emerald-600 text-white text-[10px] font-bold">
                      {item.listingType === 'BOTH' ? 'Rent & Buy' : item.listingType}
                    </span>
                  </div>
                  <div className="p-4 space-y-2">
                    <h3 className="text-xs font-bold text-gray-900 truncate">{item.name}</h3>
                    <p className="text-[11px] text-gray-500 font-medium">
                      {item.brand} • {item.district || 'Maharashtra'}
                    </p>
                    <div className="pt-2 flex items-center justify-between border-t border-gray-100">
                      <div>
                        <span className="text-[10px] text-gray-400 block uppercase">Price</span>
                        <span className="text-xs font-black text-emerald-800">
                          {item.dailyRate ? formatINR(item.dailyRate) + '/day' : formatINR(item.salePrice || 500000)}
                        </span>
                      </div>
                      <Link
                        to={'/equipment/' + item.id}
                        className="px-2.5 py-1 rounded-lg bg-gray-100 hover:bg-emerald-50 text-gray-700 hover:text-emerald-800 text-[11px] font-bold transition-colors"
                      >
                        View Unit
                      </Link>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Leads Tab Content */}
      {activeTab === 'leads' && (
        <div className="bg-white rounded-3xl border border-gray-200 overflow-hidden shadow-sm">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <div>
              <h2 className="text-sm font-bold text-gray-900">Direct Farmer Inquiries</h2>
              <p className="text-xs text-gray-500">Farmers in Maharashtra requesting price quotes or physical inspections</p>
            </div>
            <span className="text-xs font-bold px-3 py-1 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200">
              4 Active Inquiries
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-gray-50 text-gray-500 uppercase tracking-wider text-[10px] border-b border-gray-100">
                <tr>
                  <th className="px-6 py-3 font-bold">Farmer Name &amp; District</th>
                  <th className="px-6 py-3 font-bold">Equipment Interested</th>
                  <th className="px-6 py-3 font-bold">Deal Type &amp; Budget</th>
                  <th className="px-6 py-3 font-bold">Status</th>
                  <th className="px-6 py-3 font-bold text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {sampleLeads.map((lead) => (
                  <tr key={lead.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="font-bold text-gray-900">{lead.farmerName}</div>
                      <div className="text-[11px] text-gray-500">{lead.district} • {lead.phone}</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-semibold text-gray-800">{lead.machinery}</div>
                      <div className="text-[10px] text-gray-400">{lead.date}</div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="font-bold text-emerald-800">{lead.budget}</div>
                      <div className="text-[10px] text-gray-500">{lead.type}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                        {lead.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right space-x-2">
                      <a
                        href={'https://wa.me/91' + lead.phone.replace(/[^0-9]/g, '').slice(-10) + '?text=' + encodeURIComponent('Namaste ' + lead.farmerName + ', regarding your inquiry for ' + lead.machinery + ' at AgriRent')}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-[11px] transition-colors shadow-sm"
                      >
                        <span className="material-symbols-outlined text-xs">chat</span>
                        WhatsApp
                      </a>
                      <a
                        href={'tel:' + lead.phone}
                        className="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold text-[11px] transition-colors"
                      >
                        <span className="material-symbols-outlined text-xs">call</span>
                        Call
                      </a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
};

export default DealerDashboardPage;
