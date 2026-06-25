// src/components/erp/parent/AIInsights.jsx  (also used as AllInsights)

import React from "react";

const AIInsights = () => {
  return (
    <div className="h-full bg-surface-container-lowest dark:bg-slate-800/60
                    p-5 rounded-xl
                    border-2 border-primary/5 dark:border-slate-700/40
                    relative flex flex-col gap-4">

      {/* Background icon */}
      <div className="absolute top-0 right-0 p-3 opacity-10 pointer-events-none">
        <span
          className="material-symbols-outlined text-6xl text-primary"
          style={{ fontVariationSettings: "'FILL' 1" }}
        >
          psychology
        </span>
      </div>

      {/* Header */}
      <div className="flex items-center gap-3 flex-shrink-0">
        <div className="p-2 bg-tertiary-fixed dark:bg-purple-900/30 rounded-lg flex-shrink-0">
          <span
            className="material-symbols-outlined text-tertiary dark:text-purple-400"
            style={{ fontVariationSettings: "'FILL' 1" }}
          >
            auto_awesome
          </span>
        </div>
        <h3 className="text-base sm:text-lg font-bold font-headline text-on-surface dark:text-white">
          AI Insight Alert
        </h3>
      </div>

      {/* Quote */}
      <div className="bg-tertiary/5 dark:bg-purple-900/20 p-3 rounded-xl border-l-4 border-tertiary dark:border-purple-500 flex-shrink-0">
        <p className="text-on-surface dark:text-slate-200 font-medium leading-relaxed text-sm">
          "Your child shows significant improvement in{" "}
          <span className="text-tertiary dark:text-purple-300 font-bold">Mathematics</span>.
          Alex has improved their average from B to A- over the last month."
        </p>
      </div>

      {/* Checklist — flex-1 fills space between quote and button */}
      <ul className="flex-1 space-y-2 text-sm text-on-surface-variant dark:text-slate-400">
        <li className="flex items-start gap-2">
          <span className="material-symbols-outlined text-tertiary dark:text-purple-400 text-base mt-0.5 flex-shrink-0">
            check_circle
          </span>
          <span>Completed 100% of Algebra modules</span>
        </li>
        <li className="flex items-start gap-2">
          <span className="material-symbols-outlined text-tertiary dark:text-purple-400 text-base mt-0.5 flex-shrink-0">
            check_circle
          </span>
          <span>High engagement during Calculus labs</span>
        </li>
      </ul>

      {/* Button — always pinned to bottom */}
      <button className="w-full py-2.5 rounded-xl font-bold text-sm flex-shrink-0
                         bg-surface-container-high dark:bg-slate-700
                         text-primary dark:text-blue-300
                         hover:bg-primary hover:text-white
                         dark:hover:bg-blue-600 dark:hover:text-white
                         transition-all">
        View Detailed Insights
      </button>
    </div>
  );
};

export default AIInsights;