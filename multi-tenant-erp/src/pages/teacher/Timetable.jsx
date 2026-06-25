import React from 'react';
import MainLayout from "../../components/erp/teacher/MainLayout";
import Card from "../../components/erp/teacher/Card";

export default function Timetable() {
  return (
    <MainLayout title="My Timetable">
      <div className="p-4 md:p-6 space-y-6">
        <header>
          <h1 className="text-2xl font-bold text-slate-800 dark:text-slate-100">Weekly Timetable</h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">View your upcoming classes and schedules</p>
        </header>

        <Card>
          <div className="p-8 text-center text-slate-500">
            <span className="material-symbols-outlined text-4xl mb-4">calendar_month</span>
            <p className="text-lg font-medium text-slate-700 dark:text-slate-200">No schedule available</p>
            <p className="text-sm">Your timetable has not been generated for the current term.</p>
          </div>
        </Card>
      </div>
    </MainLayout>
  );
}
