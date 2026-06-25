import React from 'react';

export function Card({ children, className = '', elevated = false }) {
  const baseClasses = "bg-surface-container-lowest rounded-lg p-6";
  const shadowClass = elevated ? "custom-shadow" : "";
  
  return (
    <div className={`${baseClasses} ${shadowClass} ${className}`}>
      {children}
    </div>
  );
}
