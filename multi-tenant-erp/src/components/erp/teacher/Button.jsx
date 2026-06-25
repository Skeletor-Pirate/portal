import React from 'react';

const Button = ({ children, variant = 'primary', className = '', ...props }) => {
  const baseClasses = 'px-6 py-3 rounded-md text-sm font-semibold transition-all duration-200 shadow-sm flex items-center justify-center gap-2';
  
  const variants = {
    primary: 'bg-gradient-to-br from-primary to-primary-container text-white shadow-md hover:shadow-lg hover:shadow-primary/20 hover:scale-[1.02] active:scale-[0.98] focus:ring-2 focus:ring-primary/20 focus:outline-none',
    secondary: 'bg-surface-container-high text-primary hover:bg-surface-variant hover:scale-[1.02] active:scale-[0.98] focus:ring-2 focus:ring-primary/10 focus:outline-none',
    tertiary: 'text-primary hover:bg-primary/10 active:bg-primary/20 hover:scale-[1.05] active:scale-[0.95]',
    danger: 'bg-red-50 text-red-600 hover:bg-red-100 hover:text-red-700 active:scale-[0.98] focus:ring-2 focus:ring-red-200 focus:outline-none dark:bg-red-950/30 dark:text-red-400 dark:hover:bg-red-900/40',
  };

  return (
    <button className={`${baseClasses} ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
};

export default Button;
