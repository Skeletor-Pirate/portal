// src/pages/erp/parent/ParentDashboard.jsx

import DashboardLayout from "../../components/erp/parent/DashboardLayout";
import StudentHeader from "../../components/erp/parent/StudentHeader";
import SummaryCards from "../../components/erp/parent/SummaryCards";
import PerformanceChart from "../../components/erp/parent/PerformanceChart";
import AllInsights from "../../components/erp/parent/AllInsights";

const ParentDashboard = () => {
  return (
    <DashboardLayout>
      <div className="max-w-7xl mx-auto px-3 sm:px-5 lg:px-8 py-4 sm:py-6 lg:py-8 space-y-4 sm:space-y-6 lg:space-y-8">

        <StudentHeader />
        <SummaryCards />

        {/*
          grid-rows-[380px] fixes the row height at 380px for ALL viewport
          widths — sidebar open or closed, narrow or wide.
          Both children use h-full so they fill this exact height.
          Result: perfectly equal cards at all times.
        */}
        <section className="grid grid-cols-1 lg:grid-cols-3 lg:grid-rows-[380px] gap-4 sm:gap-6 lg:gap-8">
          <div className="lg:col-span-2 min-w-0 lg:h-full">
            <PerformanceChart />
          </div>
          <div className="min-w-0 lg:h-full">
            <AllInsights />
          </div>
        </section>

      </div>
    </DashboardLayout>
  );
};

export default ParentDashboard;