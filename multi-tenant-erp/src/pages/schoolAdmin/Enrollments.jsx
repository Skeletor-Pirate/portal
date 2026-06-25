import React from "react";
import SchoolLayout from "../../components/erp/school/SchoolLayout";

export default function Enrollments() {
  return (
    <SchoolLayout title="Enrollments Management">
      <div className="p-4 md:p-8">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 p-8 text-center">
            <span className="material-symbols-outlined text-5xl text-blue-500 mb-4">school</span>
            <h1 className="text-2xl font-bold text-slate-800 dark:text-slate-100 mb-2">Enrollment Campaigns</h1>
            <p className="text-slate-500 dark:text-slate-400">
              Manage new student enrollments, admissions, and waiting lists here.
            </p>
            <button className="mt-6 bg-blue-600 text-white px-6 py-2 rounded-lg font-medium hover:bg-blue-700 transition">
              Create New Campaign
            </button>
          </div>
        </div>
      </div>
    </SchoolLayout>
  );
}
