// src/components/erp/parent/PerformanceChart.jsx

import React, { useMemo } from "react";
import { useParent } from "../../../context/ParentProvider";

const MONTH_LABELS = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"];

const PerformanceChart = () => {
  const { dashboard, loading } = useParent();

  const { points, monthLabels, yearLabel, hasData } = useMemo(() => {
    const grades = dashboard?.grades?.results || [];
    const exams  = dashboard?.exams?.results  || [];
    if (!grades.length || !exams.length)
      return { points: [], monthLabels: [], yearLabel: new Date().getFullYear(), hasData: false };

    const examDateByName = {};
    exams.forEach((e) => { if (e.name && e.start_date) examDateByName[e.name] = new Date(e.start_date); });

    const monthBuckets = {};
    grades.forEach((g) => {
      const examDate = examDateByName[g.exam_name];
      if (!examDate) return;
      const key = `${examDate.getFullYear()}-${examDate.getMonth()}`;
      if (!monthBuckets[key]) monthBuckets[key] = { totalObtained: 0, totalMax: 0, year: examDate.getFullYear(), month: examDate.getMonth() };
      monthBuckets[key].totalObtained += parseFloat(g.marks_obtained || 0);
      monthBuckets[key].totalMax      += parseFloat(g.max_marks || 0);
    });

    const sortedKeys = Object.keys(monthBuckets).sort((a, b) => {
      const [ay, am] = a.split("-").map(Number);
      const [by, bm] = b.split("-").map(Number);
      return ay !== by ? ay - by : am - bm;
    });
    const recentKeys = sortedKeys.slice(-6);
    const pts = recentKeys.map((key) => {
      const b = monthBuckets[key];
      return { pct: b.totalMax > 0 ? Math.round((b.totalObtained / b.totalMax) * 100) : 0, month: b.month, year: b.year };
    });
    const labels     = pts.map((p) => MONTH_LABELS[p.month]);
    const latestYear = pts.length > 0 ? pts[pts.length - 1].year : new Date().getFullYear();
    return { points: pts, monthLabels: labels, yearLabel: latestYear, hasData: pts.length > 0 };
  }, [dashboard]);

  const { linePath, areaPath, dotPositions } = useMemo(() => {
    if (!points.length) return { linePath: "", areaPath: "", dotPositions: [] };
    const W = 1000, H = 300, PAD_TOP = 30, PAD_BOTTOM = 30;
    const usableH = H - PAD_TOP - PAD_BOTTOM;
    const n = points.length;
    const stepX = n > 1 ? W / (n - 1) : 0;
    const coords = points.map((p, i) => {
      const x = n > 1 ? i * stepX : W / 2;
      const y = PAD_TOP + (1 - Math.max(0, Math.min(100, p.pct)) / 100) * usableH;
      return { x, y, pct: p.pct };
    });
    let line = `M${coords[0].x},${coords[0].y}`;
    for (let i = 1; i < coords.length; i++) {
      const prev = coords[i - 1], curr = coords[i];
      line += ` Q${(prev.x + curr.x) / 2},${prev.y} ${curr.x},${curr.y}`;
    }
    const area = `${line} L${coords[coords.length - 1].x},${H} L0,${H} Z`;
    return { linePath: line, areaPath: area, dotPositions: coords };
  }, [points]);

  if (loading) {
    return (
      <div className="h-full bg-surface-container-lowest dark:bg-slate-800/60 p-5 rounded-xl border border-outline-variant/5 dark:border-slate-700/40 animate-pulse flex flex-col gap-3">
        <div className="h-5 w-48 bg-surface-container-low dark:bg-slate-700 rounded" />
        <div className="h-4 w-64 bg-surface-container-low dark:bg-slate-700 rounded" />
        <div className="flex-1 bg-surface-container-low dark:bg-slate-700 rounded" />
      </div>
    );
  }

  return (
    /*
      h-full fills the fixed grid row height (380px on lg).
      flex-col lets header stay top, SVG fills middle, labels stay bottom.
    */
    <div className="h-full bg-surface-container-lowest dark:bg-slate-800/60 p-5 rounded-xl border border-outline-variant/5 dark:border-slate-700/40 flex flex-col">

      {/* Header */}
      <div className="flex justify-between items-start mb-3 flex-shrink-0">
        <div>
          <h3 className="text-base sm:text-lg font-bold font-headline text-on-surface dark:text-white mb-0.5">
            Performance Trend
          </h3>
          <p className="text-xs text-on-surface-variant dark:text-slate-400">Average score across all subjects</p>
        </div>
        {hasData && (
          <div className="flex items-center gap-2 flex-shrink-0">
            <span className="w-2.5 h-2.5 rounded-full bg-primary" />
            <span className="text-xs font-medium text-on-surface-variant dark:text-slate-400">{yearLabel}</span>
          </div>
        )}
      </div>

      {!hasData ? (
        <div className="flex-1 flex items-center justify-center text-sm text-on-surface-variant dark:text-slate-400">
          Not enough exam data yet to show a trend.
        </div>
      ) : (
        /* flex-1 + min-h-0: SVG fills all remaining space after header */
        <div className="flex-1 flex flex-col min-h-0">
          <div className="flex-1 w-full min-h-0">
            <svg className="w-full h-full" viewBox="0 0 1000 300" preserveAspectRatio="none">
              <line stroke="#eff4ff" strokeWidth="1" x1="0" x2="1000" y1="50"  y2="50"  />
              <line stroke="#eff4ff" strokeWidth="1" x1="0" x2="1000" y1="125" y2="125" />
              <line stroke="#eff4ff" strokeWidth="1" x1="0" x2="1000" y1="200" y2="200" />
              <line stroke="#eff4ff" strokeWidth="1" x1="0" x2="1000" y1="275" y2="275" />
              <defs>
                <linearGradient id="chartGradient" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%"   stopColor="#2170e4" stopOpacity="0.15" />
                  <stop offset="100%" stopColor="#2170e4" stopOpacity="0"    />
                </linearGradient>
              </defs>
              <path d={areaPath} fill="url(#chartGradient)" />
              <path d={linePath} fill="none" stroke="#0058be" strokeLinecap="round" strokeWidth="4" />
              {dotPositions.map((d, i) => (
                <g key={i}>
                  <circle cx={d.x} cy={d.y} fill="#0058be" r="6" stroke="white" strokeWidth="2">
                    <title>{`${monthLabels[i]}: ${d.pct}%`}</title>
                  </circle>
                </g>
              ))}
            </svg>
          </div>
          {/* Month labels pinned to bottom */}
          <div className="flex justify-between mt-2 px-1 flex-shrink-0">
            {monthLabels.map((label, i) => (
              <span
                key={`${label}-${i}`}
                className={`text-[9px] sm:text-xs font-semibold
                  ${i === monthLabels.length - 1
                    ? "text-primary font-bold underline underline-offset-4"
                    : "text-on-surface-variant dark:text-slate-400"
                  }`}
              >
                {label}
              </span>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default PerformanceChart;