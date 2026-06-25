import React from "react";
import AccountantLayout from "../../components/erp/accountant/AccountantLayout";

export default function Dashboard() {
  return (
    <AccountantLayout title="Accountant Dashboard">
      <div className="p-4 md:p-8 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
            <h3 className="text-sm font-semibold text-slate-500 mb-1">Total Revenue (MTD)</h3>
            <p className="text-3xl font-bold text-slate-800 dark:text-slate-100">$45,200</p>
          </div>
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
            <h3 className="text-sm font-semibold text-slate-500 mb-1">Pending Invoices</h3>
            <p className="text-3xl font-bold text-amber-500">12</p>
          </div>
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
            <h3 className="text-sm font-semibold text-slate-500 mb-1">Overdue Payments</h3>
            <p className="text-3xl font-bold text-red-500">3</p>
          </div>
        </div>
        
        <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
          <h2 className="text-lg font-bold mb-4">Recent Transactions</h2>
          <p className="text-slate-500 text-sm">No recent transactions to display.</p>
        </div>
      </div>
    </AccountantLayout>
  );
}
