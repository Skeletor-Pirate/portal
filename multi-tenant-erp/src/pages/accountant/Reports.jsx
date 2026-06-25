import React from "react";
import AccountantLayout from "../../components/erp/accountant/AccountantLayout";

export default function Reports() {
  return (
    <AccountantLayout title="Financial Reports">
      <div className="p-4 md:p-8">
        <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-lg font-bold">Generated Reports</h2>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition text-sm">
              Generate New Report
            </button>
          </div>
          <p className="text-slate-500 text-sm text-center py-10">No recent reports available.</p>
        </div>
      </div>
    </AccountantLayout>
  );
}
