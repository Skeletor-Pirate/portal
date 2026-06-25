// src/components/erp/parent/Navbar.jsx

import React from "react";
import { useNavigate, useLocation } from "react-router-dom";

// Route → page name mapping
const PAGE_NAMES = {
  "/parent":                "Dashboard",
  "/parent/child-overview": "Child Overview",
  "/parent/attendance":     "Attendance",
  "/parent/assignments":    "Assignments",
  "/parent/grades":         "Grades & Report",
  "/parent/payments":       "Payments & Fees",
  "/parent/insights":       "AI Insights",
  "/parent/settings":       "Settings",
  "/parent/notifications":  "Notifications",
};

const Navbar = () => {
  const navigate  = useNavigate();
  const location  = useLocation();

  // Match current path — exact first, then prefix
  const pageName =
    PAGE_NAMES[location.pathname] ||
    Object.entries(PAGE_NAMES).find(([key]) =>
      location.pathname.startsWith(key + "/")
    )?.[1] ||
    "Parent Portal";

  // Tell the Sidebar to open its mobile drawer.
  // This is the ONLY hamburger on mobile — the Sidebar's own internal
  // hamburger is hidden on mobile (it only shows a close/X there), so
  // there's never two toggle buttons fighting for the same corner.
  const openSidebar = () => {
    window.dispatchEvent(new CustomEvent("parent-sidebar-open"));
  };

  return (
    <header
      className="w-full sticky top-0 z-30
                 bg-white/80 dark:bg-slate-900/80
                 backdrop-blur-xl
                 border-b border-slate-200 dark:border-slate-700/50
                 flex justify-between items-center px-4 sm:px-6 h-16
                 transition-colors duration-300"
    >
      {/* Left: mobile hamburger + page title */}
      <div className="flex items-center gap-3 min-w-0">
        <button
          onClick={openSidebar}
          className="md:hidden w-9 h-9 -ml-1 flex items-center justify-center rounded-lg
                     text-blue-700 dark:text-blue-300
                     hover:bg-blue-50 dark:hover:bg-slate-800 transition-colors flex-shrink-0"
          aria-label="Open menu"
        >
          <span className="material-symbols-outlined text-2xl">menu</span>
        </button>

        <h1 className="font-bold tracking-tight text-blue-800 dark:text-blue-300 font-headline truncate
                       text-base md:text-xl">
          {/* Mobile: page name */}
          <span className="md:hidden">{pageName}</span>
          {/* Desktop: brand name */}
          <span className="hidden md:inline">The Academic Architect</span>
        </h1>
      </div>

      {/* Right */}
      <div className="flex items-center gap-3 sm:gap-6 flex-shrink-0">
        {/* Name + divider — desktop only */}
        <div className="hidden md:flex items-center gap-4">
          <span className="text-sm font-medium text-blue-700 dark:text-blue-400">
            Alexander Pierce
          </span>
          <div className="h-8 w-px bg-slate-200 dark:bg-slate-700" />
        </div>

        <span className="material-symbols-outlined text-blue-700 dark:text-blue-400 cursor-pointer text-xl">
          search
        </span>

        <button
          onClick={() => navigate("/parent/notifications")}
          className="relative text-slate-600 dark:text-slate-300
                     hover:text-blue-600 dark:hover:text-blue-300 transition-colors"
        >
          <span className="material-symbols-outlined text-xl">notifications</span>
        </button>
      </div>
    </header>
  );
};

export default Navbar;