import React from "react";
import AccountantLayout from "../../components/erp/accountant/AccountantLayout";

export default function Reconcile() {
  return (
    <AccountantLayout title="Reconciliation">
      <div className="p-4 md:p-8">
        <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-lg font-bold">Bank Reconciliation</h2>
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-blue-700 transition text-sm">
              Upload Statement
            </button>
          </div>
          <p className="text-slate-500 text-sm text-center py-10">Upload a bank statement to begin reconciliation.</p>
        </div>
      </div>
    </AccountantLayout>
  );
}
