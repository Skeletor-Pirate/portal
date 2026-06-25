import React from 'react';

export default function Pagination({ currentPage, totalPages, onPageChange }) {
  return (
    <div className="flex items-center justify-between p-4 bg-white border-t border-gray-100">
      <button 
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        className="px-4 py-2 text-sm font-semibold text-gray-600 hover:text-[#0058be] disabled:opacity-30 disabled:cursor-not-allowed flex items-center gap-1"
      >
        <span className="material-symbols-outlined text-sm">arrow_back</span> Previous
      </button>

      <span className="text-sm text-gray-500 font-medium">
        Page {currentPage} of {totalPages || 1}
      </span>

      <button 
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage >= totalPages}
        className="px-4 py-2 text-sm font-semibold text-gray-600 hover:text-[#0058be] disabled:opacity-30 disabled:cursor-not-allowed flex items-center gap-1"
      >
        Next <span className="material-symbols-outlined text-sm">arrow_forward</span>
      </button>
    </div>
  );
}