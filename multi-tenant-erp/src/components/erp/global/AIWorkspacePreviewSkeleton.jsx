import React from 'react';

const SkeletonBlock = ({ className = '' }) => (
  <div className={`animate-pulse rounded-md bg-slate-200/80 ${className}`} />
);

const AIWorkspacePreviewSkeleton = () => (
  <div className="space-y-8" aria-label="Generating preview" aria-busy="true">
    <header className="space-y-4 pb-6 border-b border-outline-variant/15">
      <SkeletonBlock className="h-8 w-3/4 mx-auto" />
      <div className="flex justify-center gap-3 flex-wrap">
        <SkeletonBlock className="h-7 w-28 rounded-full" />
        <SkeletonBlock className="h-7 w-24 rounded-full" />
        <SkeletonBlock className="h-7 w-32 rounded-full" />
      </div>
    </header>

    <section className="space-y-4">
      <div className="flex items-center gap-3">
        <SkeletonBlock className="h-8 w-8" />
        <SkeletonBlock className="h-5 w-44" />
      </div>
      <div className="rounded-xl border border-outline-variant/20 bg-surface-container-lowest p-5 space-y-3">
        <SkeletonBlock className="h-4 w-full" />
        <SkeletonBlock className="h-4 w-11/12" />
        <SkeletonBlock className="h-4 w-4/5" />
      </div>
    </section>

    <section className="space-y-4">
      {Array.from({ length: 3 }).map((_, index) => (
        <div key={index} className="rounded-xl border border-outline-variant/20 bg-surface-container-lowest p-5 space-y-4">
          <div className="flex items-center justify-between gap-4">
            <SkeletonBlock className="h-5 w-36" />
            <SkeletonBlock className="h-6 w-20 rounded-full" />
          </div>
          <div className="space-y-2">
            <SkeletonBlock className="h-4 w-full" />
            <SkeletonBlock className="h-4 w-5/6" />
            <SkeletonBlock className="h-4 w-2/3" />
          </div>
        </div>
      ))}
    </section>
  </div>
);

export default AIWorkspacePreviewSkeleton;
