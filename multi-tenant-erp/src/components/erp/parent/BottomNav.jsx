// src/components/erp/parent/BottomNav.jsx

import React from "react";
import { NavLink } from "react-router-dom";

const BottomNav = () => {
  const linkCls = ({ isActive }) =>
    `flex flex-col items-center justify-center gap-0.5 flex-1 py-2 transition-colors
     ${isActive
       ? "text-blue-700 dark:text-blue-300"
       : "text-slate-400 dark:text-slate-500 hover:text-slate-600 dark:hover:text-slate-300"
     }`;

  return (
    <nav
      className="md:hidden fixed bottom-0 left-0 right-0 h-16
                 bg-white dark:bg-slate-950
                 border-t border-slate-100 dark:border-slate-800
                 flex items-stretch z-40
                 shadow-[0_-2px_12px_rgba(0,0,0,0.06)]"
    >
      <NavLink to="/parent" end className={linkCls}>
        {({ isActive }) => (
          <>
            <span
              className="material-symbols-outlined text-xl leading-none"
              style={isActive ? { fontVariationSettings: "'FILL' 1" } : {}}
            >
              dashboard
            </span>
            <span className="text-[10px] font-semibold leading-none">Home</span>
          </>
        )}
      </NavLink>

      <NavLink to="/parent/child-overview" className={linkCls}>
        {({ isActive }) => (
          <>
            <span
              className="material-symbols-outlined text-xl leading-none"
              style={isActive ? { fontVariationSettings: "'FILL' 1" } : {}}
            >
              child_care
            </span>
            <span className="text-[10px] font-semibold leading-none">Child</span>
          </>
        )}
      </NavLink>

      <NavLink to="/parent/assignments" className={linkCls}>
        {({ isActive }) => (
          <>
            <span
              className="material-symbols-outlined text-xl leading-none"
              style={isActive ? { fontVariationSettings: "'FILL' 1" } : {}}
            >
              assignment
            </span>
            <span className="text-[10px] font-semibold leading-none">Tasks</span>
          </>
        )}
      </NavLink>

      <NavLink to="/parent/grades" className={linkCls}>
        {({ isActive }) => (
          <>
            <span className={`material-symbols-outlined mb-1 transition-transform ${isActive ? 'scale-110 icon-filled text-primary' : 'text-on-surface-variant'}`}>assessment</span>
            <span className="text-[10px] font-medium tracking-wide">Grades</span>
          </>
        )}
      </NavLink>
      <NavLink to="/parent/payments" className={linkCls}>
        {({ isActive }) => (
          <>
            <span className={`material-symbols-outlined mb-1 transition-transform ${isActive ? 'scale-110 icon-filled text-primary' : 'text-on-surface-variant'}`}>payments</span>
            <span className="text-[10px] font-medium tracking-wide">Payments</span>
          </>
        )}
      </NavLink>

      <NavLink to="/parent/settings" className={linkCls}>
        {({ isActive }) => (
          <>
            <span
              className="material-symbols-outlined text-xl leading-none"
              style={isActive ? { fontVariationSettings: "'FILL' 1" } : {}}
            >
              person
            </span>
            <span className="text-[10px] font-semibold leading-none">Profile</span>
          </>
        )}
      </NavLink>
    </nav>
  );
};

export default BottomNav;