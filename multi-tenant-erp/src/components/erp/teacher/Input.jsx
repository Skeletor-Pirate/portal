import React from 'react';

const Input = ({ label, icon, className = '', dark = false, ...props }) => {
  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      {label && <label className={`text-xs font-bold uppercase tracking-wider ml-1 ${dark ? 'text-slate-300' : 'text-on-surface-variant dark:text-slate-300'}`}>{label}</label>}
      <div className="relative">
        {icon && (
          <span className={`material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-sm ${dark ? 'text-slate-400' : 'text-outline dark:text-slate-400'}`}>
            {icon}
          </span>
        )}
        <input 
          className={`w-full border border-transparent rounded-xl py-3 ${icon ? 'pl-11' : 'pl-4'} pr-4 text-sm font-medium outline-none transition-all duration-200 ${
            dark 
              ? 'bg-slate-700 text-white placeholder:text-slate-400 hover:bg-slate-600 focus:bg-slate-600 focus:border-blue-400/30 focus:ring-4 focus:ring-blue-400/10' 
              : 'bg-slate-50 dark:bg-slate-700 text-slate-700 dark:text-white placeholder:text-slate-400 dark:placeholder:text-slate-400 hover:bg-slate-100/80 dark:hover:bg-slate-600 focus:bg-white dark:focus:bg-slate-600 focus:border-primary/20 dark:focus:border-blue-400/30 focus:ring-4 focus:ring-primary/5 dark:focus:ring-blue-400/10'
          }`} 
          {...props} 
        />
      </div>
    </div>
  );
};

export default Input;
