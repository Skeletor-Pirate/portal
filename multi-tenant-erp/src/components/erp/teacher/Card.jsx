import React from 'react';

const Card = ({ children, className = '', hoverable = false, ...props }) => {
  // If a bg-* class is supplied via className, skip the default background
  const hasCustomBg = /\bbg-/.test(className);
  const baseBg = hasCustomBg ? '' : 'bg-white/80 dark:bg-slate-900/80';
  // If a border class is supplied via className, skip the default border
  const hasCustomBorder = /\bborder-(?!0)/.test(className);
  const baseBorder = hasCustomBorder ? '' : 'border-slate-100/50 dark:border-slate-800';

  return (
    <article 
      className={`relative backdrop-blur-sm rounded-xl p-5 shadow-sm border flex flex-col transition-all duration-300 ${baseBg} ${baseBorder} ${hoverable ? 'hover:shadow-lg hover:shadow-slate-200/50 dark:hover:shadow-black/50 hover:-translate-y-0.5 hover:border-primary/10 dark:hover:border-primary/30' : ''} ${className}`} 
      {...props}
    >
      {children}
    </article>
  );
};

export default Card;
