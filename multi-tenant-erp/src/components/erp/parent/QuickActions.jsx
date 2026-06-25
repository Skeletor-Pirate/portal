import React from "react";
import { useNavigate } from "react-router-dom";

const QuickActions = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-slate-100 dark:bg-slate-800 p-8 rounded-xl transition-colors duration-300">
      <h3 className="text-xl font-bold mb-6 text-gray-900 dark:text-white">
        Quick Actions
      </h3>

      <div className="grid grid-cols-2 gap-4">

        {/* Attendance */}
        <button
          onClick={() => navigate("/parent/attendance")}
          className="bg-white dark:bg-slate-700 p-6 rounded-lg hover:shadow-md dark:hover:bg-slate-600 transition group flex flex-col items-center justify-center text-center gap-3"
        >
          <span className="material-symbols-outlined text-3xl text-blue-600 dark:text-blue-300 group-hover:scale-110 transition">
            event_available
          </span>
          <span className="font-semibold text-sm text-gray-900 dark:text-white">
            View Attendance
          </span>
        </button>

        {/* Grades */}
        <button
          onClick={() => navigate("/parent/grades")}
          className="bg-white dark:bg-slate-700 p-6 rounded-lg hover:shadow-md dark:hover:bg-slate-600 transition group flex flex-col items-center justify-center text-center gap-3"
        >
          <span className="material-symbols-outlined text-3xl text-indigo-600 dark:text-indigo-300 group-hover:scale-110 transition">
            analytics
          </span>
          <span className="font-semibold text-sm text-gray-900 dark:text-white">
            View Grades
          </span>
        </button>

        {/* Assignments */}
        <button
          onClick={() => navigate("/parent/assignments")}
          className="bg-white dark:bg-slate-700 p-6 rounded-lg hover:shadow-md dark:hover:bg-slate-600 transition group flex flex-col items-center justify-center text-center gap-3"
        >
          <span className="material-symbols-outlined text-3xl text-purple-600 dark:text-purple-300 group-hover:scale-110 transition">
            edit_document
          </span>
          <span className="font-semibold text-sm text-gray-900 dark:text-white">
            View Assignments
          </span>
        </button>

        {/* AI Insights */}
        <button
          onClick={() => navigate("/parent/insights")}
          className="bg-white dark:bg-slate-700 p-6 rounded-lg hover:shadow-md dark:hover:bg-slate-600 transition group flex flex-col items-center justify-center text-center gap-3"
        >
          <span className="material-symbols-outlined text-3xl text-blue-500 dark:text-blue-300 group-hover:scale-110 transition">
            bolt
          </span>
          <span className="font-semibold text-sm text-gray-900 dark:text-white">
            View AI Insights
          </span>
        </button>

      </div>
    </div>
  );
};

export default QuickActions;