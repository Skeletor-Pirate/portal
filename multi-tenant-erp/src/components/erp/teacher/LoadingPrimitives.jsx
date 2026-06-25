import React from 'react';

export const SkeletonBlock = ({ className = '', ...props }) => (
  <div className={`bg-slate-100 dark:bg-slate-800 rounded animate-pulse ${className}`} {...props} />
);

/**
 * RevalidatingBar
 * Shows a thin animated bar at top when background revalidation is happening.
 * Never blocks content. Pass `show={revalidating}`.
 */
export const RevalidatingBar = ({ show }) => (
  <div
    className="fixed top-0 left-0 right-0 z-50 h-[2px] overflow-hidden pointer-events-none"
    style={{ opacity: show ? 1 : 0, transition: 'opacity 0.3s' }}
  >
    <div
      style={{
        height: '100%',
        background: 'linear-gradient(90deg, transparent, var(--color-primary, #1a56db), transparent)',
        backgroundSize: '200% 100%',
        animation: show ? 'revalidate-slide 1.4s linear infinite' : 'none',
      }}
    />
    <style>{`
      @keyframes revalidate-slide {
        0%   { background-position: -100% 0; }
        100% { background-position: 200% 0; }
      }
    `}</style>
  </div>
);

/**
 * SkeletonRow — use inside tables while first-loading
 */
export const SkeletonRow = ({ cols = 4 }) => (
  <tr>
    {Array.from({ length: cols }).map((_, i) => (
      <td key={i} className="px-6 py-4">
        <SkeletonBlock className="h-3" style={{ width: `${60 + (i * 13) % 30}%` }} />
      </td>
    ))}
  </tr>
);

/**
 * SkeletonCard — for card grids
 */
export const SkeletonCard = () => (
  <div className="rounded-2xl border border-outline-variant/10 p-6 space-y-4 animate-pulse bg-surface-container-lowest">
    <div className="flex justify-between">
      <div className="w-12 h-12 rounded-xl bg-slate-100 dark:bg-slate-800" />
      <div className="w-16 h-5 rounded-full bg-slate-100 dark:bg-slate-800" />
    </div>
    <div className="space-y-2 pt-2">
      <div className="h-4 bg-slate-100 dark:bg-slate-800 rounded w-3/4" />
      <div className="h-3 bg-slate-100 dark:bg-slate-800 rounded w-1/2" />
    </div>
    <div className="grid grid-cols-2 gap-3 pt-2">
      <div className="h-14 rounded-md bg-slate-100 dark:bg-slate-800" />
      <div className="h-14 rounded-md bg-slate-100 dark:bg-slate-800" />
    </div>
    <div className="h-10 rounded-md bg-slate-100 dark:bg-slate-800" />
  </div>
);
