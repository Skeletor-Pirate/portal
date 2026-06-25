import React from 'react';

const Select = ({ label, options, className = '', dark = false, ...props }) => {
  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      {label && <label className={`text-xs font-bold uppercase tracking-wider ml-1 ${dark ? 'text-slate-300' : 'text-on-surface-variant dark:text-slate-300'}`}>{label}</label>}
      <div className="relative">
        <select 
          className={`w-full border border-transparent rounded-xl py-3 px-4 text-sm font-medium outline-none transition-all duration-200 appearance-none cursor-pointer ${
            dark
              ? 'bg-slate-700 text-white hover:bg-slate-600 focus:bg-slate-600 focus:border-blue-400/30 focus:ring-4 focus:ring-blue-400/10'
              : 'bg-slate-50 dark:bg-slate-700 text-slate-700 dark:text-white hover:bg-slate-100/80 dark:hover:bg-slate-600 focus:bg-white dark:focus:bg-slate-600 focus:border-primary/20 dark:focus:border-blue-400/30 focus:ring-4 focus:ring-primary/5 dark:focus:ring-blue-400/10'
          }`} 
          {...props}
        >
          {options.map((opt, idx) => (
            <option key={idx} value={opt.value || opt}>{opt.label || opt}</option>
          ))}
        </select>
        <span className={`material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none ${dark ? 'text-slate-400' : 'text-outline dark:text-slate-400'}`}>
          expand_more
        </span>
      </div>
    </div>
  );
};

export default Select;
