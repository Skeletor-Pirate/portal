import React from "react";
import AccountantLayout from "../../components/erp/accountant/AccountantLayout";

export default function ManualPay() {
  return (
    <AccountantLayout title="Manual Payments">
      <div className="p-4 md:p-8">
        <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-lg font-bold">Record Manual Payment</h2>
          </div>
          <p className="text-slate-500 text-sm text-center py-10">Select a student and invoice to record a cash/cheque payment.</p>
        </div>
      </div>
    </AccountantLayout>
  );
}
