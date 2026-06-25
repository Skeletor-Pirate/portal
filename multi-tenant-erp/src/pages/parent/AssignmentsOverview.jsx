import React, { useState, useMemo } from "react";
import DashboardLayout from "../../components/erp/parent/DashboardLayout";
import { useParent } from "../../context/ParentProvider";

// ─── Skeleton ────────────────────────────────────────────────────────────────
function Skeleton({ className = "" }) {
  return <div className={`animate-pulse bg-gray-200 rounded-md ${className}`} />;
}

function AssignmentsSkeleton() {
  return (
    <DashboardLayout>
      <div className="p-3 sm:p-5 lg:p-8 max-w-7xl mx-auto space-y-4 sm:space-y-6">
        <div className="space-y-2">
          <Skeleton className="w-36 sm:w-48 h-6 sm:h-8" />
          <Skeleton className="w-52 sm:w-80 h-3 sm:h-4" />
        </div>
        <Skeleton className="w-full h-16 sm:h-20 rounded-xl" />
        <div className="grid grid-cols-3 gap-2 sm:gap-4 lg:gap-6">
          {[1, 2, 3].map(i => (
            <div key={i} className="bg-white rounded-xl p-3 sm:p-6 border space-y-2">
              <Skeleton className="w-16 sm:w-24 h-3" />
              <Skeleton className="w-10 sm:w-16 h-6 sm:h-8" />
            </div>
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-6">
          <div className="lg:col-span-2 space-y-3">
            {[1, 2, 3].map(i => <Skeleton key={i} className="w-full h-16 sm:h-20 rounded-xl" />)}
          </div>
          <Skeleton className="h-48 sm:h-64 rounded-xl" />
        </div>
      </div>
    </DashboardLayout>
  );
}

// ─── Subject icons ────────────────────────────────────────────────────────────
const SUBJECT_ICONS = {
  physics:            { icon: "science",     bg: "bg-blue-50",    color: "text-blue-600"   },
  mathematics:        { icon: "calculate",   bg: "bg-purple-50",  color: "text-purple-600" },
  math:               { icon: "calculate",   bg: "bg-purple-50",  color: "text-purple-600" },
  literature:         { icon: "menu_book",   bg: "bg-orange-50",  color: "text-orange-600" },
  english:            { icon: "menu_book",   bg: "bg-orange-50",  color: "text-orange-600" },
  chemistry:          { icon: "experiment",  bg: "bg-green-50",   color: "text-green-600"  },
  biology:            { icon: "biotech",     bg: "bg-emerald-50", color: "text-emerald-600"},
  "computer science": { icon: "code",        bg: "bg-indigo-50",  color: "text-indigo-600" },
  history:            { icon: "history_edu", bg: "bg-amber-50",   color: "text-amber-600"  },
};

function getSubjectMeta(subjectName) {
  const key = (subjectName || "").toLowerCase();
  return SUBJECT_ICONS[key] || { icon: "assignment", bg: "bg-slate-50", color: "text-slate-600" };
}

const STATUS_BADGE = {
  Pending:   "bg-amber-100 text-amber-700",
  Submitted: "bg-purple-100 text-purple-700",
  Graded:    "bg-blue-100 text-blue-700",
};

function formatDueDate(dueDateStr) {
  const due = new Date(dueDateStr);
  const now = new Date();
  const diffMs = due - now;
  const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
  const timeStr = due.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });

  if (diffDays < 0)   return { text: `Overdue — ${due.toLocaleDateString("en-US", { month: "short", day: "numeric" })}`, urgent: true };
  if (diffDays === 0) return { text: `Today, ${timeStr}`, urgent: true };
  if (diffDays === 1) return { text: `Tomorrow, ${timeStr}`, urgent: true };
  return { text: due.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }), urgent: false };
}

// ─── Main Component ───────────────────────────────────────────────────────────
export default function AssignmentsOverview() {
  const { profile, assignments, loading, error } = useParent();
  const [subjectFilter, setSubjectFilter] = useState("All Subjects");
  const [statusFilter,  setStatusFilter]  = useState("All Status");

  // ── All hooks run unconditionally, on every render, before any early return ──
  const list = assignments || [];

  const subjectOptions = useMemo(
    () => ["All Subjects", ...Array.from(new Set(list.map(a => a.subject_name).filter(Boolean)))],
    [list]
  );

  const total          = list.length;
  const submittedCount = list.filter(a => a.submission_status === "Submitted" || a.submission_status === "Graded").length;
  const pendingCount   = list.filter(a => a.submission_status === "Pending").length;
  const submissionRate = total > 0 ? Math.round((submittedCount / total) * 100) : 0;

  const gradedAssignments = list.filter(a => a.submission_status === "Graded" && a.grade != null);
  const avgGradePct = gradedAssignments.length > 0
    ? Math.round(gradedAssignments.reduce((sum, a) => sum + parseFloat(a.grade), 0) / gradedAssignments.length)
    : null;

  const upcomingPending = useMemo(
    () => [...list].filter(a => a.submission_status === "Pending").sort((a, b) => new Date(a.due_date) - new Date(b.due_date))[0],
    [list]
  );

  const filteredList = useMemo(() => list.filter(a => {
    const matchSubject = subjectFilter === "All Subjects" || a.subject_name === subjectFilter;
    const matchStatus  = statusFilter  === "All Status"   || a.submission_status === statusFilter;
    return matchSubject && matchStatus;
  }), [list, subjectFilter, statusFilter]);

  const sortedList = useMemo(
    () => [...filteredList].sort((a, b) => new Date(a.due_date) - new Date(b.due_date)),
    [filteredList]
  );

  if (loading) return <AssignmentsSkeleton />;

  if (error || !profile) {
    return (
      <DashboardLayout>
        <div className="p-3 sm:p-6 lg:p-8 max-w-7xl mx-auto">
          <div className="bg-red-50 text-red-700 rounded-lg p-4 sm:p-6 text-sm">
            Could not load assignments. {error?.message || "Please try again later."}
          </div>
        </div>
      </DashboardLayout>
    );
  }

  const studentFirstName = profile?.first_name || "your child";

  return (
    <DashboardLayout>
      <div className="p-3 sm:p-5 lg:p-8 max-w-7xl mx-auto space-y-4 sm:space-y-6 lg:space-y-8">

        {/* ── HEADER ── */}
        <div>
          <h1 className="text-xl sm:text-2xl lg:text-3xl font-bold text-gray-900 leading-tight">
            Assignments
          </h1>
          <p className="text-gray-500 mt-1 text-xs sm:text-sm">
            Track, review, and manage {studentFirstName}&apos;s upcoming and completed coursework.
          </p>
        </div>

        {/* ── AI INSIGHT BANNER ── */}
        {upcomingPending ? (
          <div className="bg-gradient-to-r from-blue-700 to-blue-500 rounded-xl p-3 sm:p-5 lg:p-6 shadow-md">
            <div className="flex flex-col xs:flex-row xs:items-center justify-between gap-3">
              <div className="flex items-start gap-2 sm:gap-3 min-w-0">
                <div className="bg-white/20 p-2 sm:p-2.5 rounded-lg flex-shrink-0">
                  <span className="material-symbols-outlined text-white text-base sm:text-xl">psychology</span>
                </div>
                <div className="min-w-0">
                  <p className="text-[10px] sm:text-xs text-blue-100 uppercase tracking-wider">AI Intelligence Insight</p>
                  <p className="text-white font-semibold text-xs sm:text-sm lg:text-base leading-snug mt-0.5 break-words">
                    {upcomingPending.title} ({upcomingPending.subject_name}) is due{" "}
                    {formatDueDate(upcomingPending.due_date).text.toLowerCase()}.
                  </p>
                </div>
              </div>
              <button className="bg-white text-blue-700 px-3 sm:px-4 py-1.5 sm:py-2 rounded-md text-xs sm:text-sm font-semibold hover:bg-blue-50 transition flex-shrink-0 self-start xs:self-auto w-max">
                Review Now
              </button>
            </div>
          </div>
        ) : (
          <div className="bg-gradient-to-r from-emerald-600 to-emerald-400 rounded-xl p-3 sm:p-5 lg:p-6 flex items-center gap-2 sm:gap-3 shadow-md">
            <div className="bg-white/20 p-2 rounded-lg flex-shrink-0">
              <span className="material-symbols-outlined text-white text-base sm:text-xl">check_circle</span>
            </div>
            <p className="text-white font-semibold text-xs sm:text-sm lg:text-base">
              All caught up — no pending assignments right now.
            </p>
          </div>
        )}

        {/* ── METRICS ── */}
        <div className="grid grid-cols-3 gap-2 sm:gap-4 lg:gap-6">
          {/* Total */}
          <div className="bg-white rounded-xl p-3 sm:p-5 lg:p-6 shadow-sm border flex justify-between items-center gap-2 min-w-0">
            <div className="min-w-0">
              <p className="text-gray-500 text-[10px] sm:text-xs lg:text-sm truncate">Total</p>
              <p className="text-lg sm:text-2xl lg:text-3xl font-bold leading-tight">{total}</p>
            </div>
            <div className="bg-gray-100 p-1.5 sm:p-2.5 lg:p-3 rounded-lg flex-shrink-0 hidden xs:flex items-center">
              <span className="material-symbols-outlined text-blue-600 text-sm sm:text-base">analytics</span>
            </div>
          </div>
          {/* Submitted */}
          <div className="bg-white rounded-xl p-3 sm:p-5 lg:p-6 shadow-sm border flex justify-between items-center gap-2 min-w-0">
            <div className="min-w-0">
              <p className="text-gray-500 text-[10px] sm:text-xs lg:text-sm truncate">Submitted</p>
              <p className="text-lg sm:text-2xl lg:text-3xl font-bold text-purple-600 leading-tight">{submittedCount}</p>
            </div>
            <div className="bg-purple-100 p-1.5 sm:p-2.5 lg:p-3 rounded-lg flex-shrink-0 hidden xs:flex items-center">
              <span className="material-symbols-outlined text-purple-600 text-sm sm:text-base">check_circle</span>
            </div>
          </div>
          {/* Pending */}
          <div className="bg-white rounded-xl p-3 sm:p-5 lg:p-6 shadow-sm border flex justify-between items-center gap-2 min-w-0">
            <div className="min-w-0">
              <p className="text-gray-500 text-[10px] sm:text-xs lg:text-sm truncate">Pending</p>
              <p className="text-lg sm:text-2xl lg:text-3xl font-bold text-amber-700 leading-tight">{pendingCount}</p>
            </div>
            <div className="bg-amber-100 p-1.5 sm:p-2.5 lg:p-3 rounded-lg flex-shrink-0 hidden xs:flex items-center">
              <span className="material-symbols-outlined text-amber-700 text-sm sm:text-base">pending_actions</span>
            </div>
          </div>
        </div>

        {/* ── ROADMAP + SIDEBAR ── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-3 sm:gap-5 lg:gap-6">

          {/* ── ASSIGNMENT LIST ── */}
          <div className="lg:col-span-2 space-y-3 sm:space-y-4">

            {/* Filters row */}
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 sm:gap-3">
              <h3 className="text-sm sm:text-base lg:text-lg font-semibold">Assignment Roadmap</h3>
              <div className="flex gap-2 w-full sm:w-auto">
                <select
                  value={subjectFilter}
                  onChange={(e) => setSubjectFilter(e.target.value)}
                  className="border rounded-md px-2 py-1.5 text-xs bg-white flex-1 sm:flex-none min-w-0 sm:min-w-[130px] max-w-[50%] sm:max-w-none truncate"
                >
                  {subjectOptions.map(s => <option key={s}>{s}</option>)}
                </select>
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="border rounded-md px-2 py-1.5 text-xs bg-white flex-1 sm:flex-none"
                >
                  <option>All Status</option>
                  <option>Pending</option>
                  <option>Submitted</option>
                  <option>Graded</option>
                </select>
              </div>
            </div>

            {sortedList.length === 0 && (
              <div className="bg-white rounded-xl p-6 sm:p-8 shadow-sm border text-center text-xs sm:text-sm text-gray-500">
                No assignments match the selected filters.
              </div>
            )}

            {sortedList.map((a) => {
              const meta        = getSubjectMeta(a.subject_name);
              const due         = formatDueDate(a.due_date);
              const isGraded    = a.submission_status === "Graded";
              const isSubmitted = a.submission_status === "Submitted";

              return (
                <div
                  key={a.id}
                  className="bg-white rounded-xl p-3 sm:p-4 lg:p-5 shadow-sm border flex items-center gap-2 sm:gap-3 lg:gap-5 hover:shadow-md transition"
                >
                  {/* Subject icon */}
                  <div className={`${meta.bg} p-2 sm:p-2.5 lg:p-3 rounded-lg flex-shrink-0`}>
                    <span className={`material-symbols-outlined ${meta.color} text-base sm:text-xl`}>{meta.icon}</span>
                  </div>

                  {/* Title block */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[9px] sm:text-[10px] text-gray-400 uppercase truncate">
                      {a.subject_name}{a.section_name ? ` • ${a.section_name}` : ""}
                    </p>
                    <p className="font-semibold text-xs sm:text-sm lg:text-base truncate">{a.title}</p>
                    {a.teacher_name && (
                      <p className="text-[10px] sm:text-xs text-gray-400 mt-0.5 truncate hidden xs:block">
                        Assigned by {a.teacher_name}
                      </p>
                    )}
                  </div>

                  {/* Date / grade */}
                  <div className="text-right flex-shrink-0 hidden sm:block">
                    {isGraded ? (
                      <>
                        <p className="text-[9px] sm:text-xs text-gray-400">Grade</p>
                        <p className="text-blue-600 font-semibold text-xs sm:text-sm">{a.grade}</p>
                      </>
                    ) : isSubmitted ? (
                      <>
                        <p className="text-[9px] sm:text-xs text-gray-400">Submitted</p>
                        <p className="text-gray-700 text-[10px] sm:text-xs font-semibold">
                          {a.submitted_at
                            ? new Date(a.submitted_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
                            : "—"}
                        </p>
                      </>
                    ) : (
                      <>
                        <p className="text-[9px] sm:text-xs text-gray-400">Deadline</p>
                        <p className={`text-[10px] sm:text-xs font-semibold ${due.urgent ? "text-red-500" : "text-gray-700"}`}>
                          {due.text}
                        </p>
                      </>
                    )}
                  </div>

                  {/* Status badge */}
                  <span className={`text-[9px] sm:text-xs px-1.5 sm:px-3 py-0.5 sm:py-1 rounded-full font-semibold flex-shrink-0 ${STATUS_BADGE[a.submission_status] || "bg-slate-100 text-slate-700"} whitespace-nowrap`}>
                    {a.submission_status}
                  </span>

                  <span className="material-symbols-outlined text-gray-300 flex-shrink-0 hidden lg:block">chevron_right</span>
                </div>
              );
            })}
          </div>

          {/* ── SIDEBAR ── */}
          <div className="bg-white rounded-xl p-4 sm:p-5 lg:p-6 shadow-sm border h-fit">
            <h4 className="font-semibold mb-3 sm:mb-4 text-sm lg:text-base">Quick Statistics</h4>

            <div className="mb-4">
              <div className="flex justify-between text-xs sm:text-sm">
                <span className="text-gray-500">Submission Rate</span>
                <span className="font-semibold text-blue-600">{submissionRate}%</span>
              </div>
              <div className="h-2 bg-gray-100 rounded-full mt-2">
                <div className="h-2 bg-blue-600 rounded-full transition-all" style={{ width: `${submissionRate}%` }} />
              </div>
            </div>

            <div className="flex justify-between text-xs sm:text-sm mb-4">
              <span className="text-gray-500">Avg. Grade (Graded)</span>
              <span className="text-purple-600 font-semibold">
                {avgGradePct != null ? `${avgGradePct}%` : "No grades yet"}
              </span>
            </div>

            <div className="border-t pt-3 sm:pt-4">
              <p className="text-[10px] sm:text-xs text-gray-400 uppercase mb-2">Pending Assignments</p>
              {pendingCount === 0 ? (
                <p className="text-xs sm:text-sm text-gray-400">Nothing pending right now.</p>
              ) : (
                list
                  .filter(a => a.submission_status === "Pending")
                  .sort((a, b) => new Date(a.due_date) - new Date(b.due_date))
                  .slice(0, 3)
                  .map(a => (
                    <div key={a.id} className="mb-2">
                      <div className="flex gap-2 items-center text-xs sm:text-sm">
                        <div className="w-1.5 h-1.5 sm:w-2 sm:h-2 bg-red-500 rounded-full flex-shrink-0" />
                        <span className="truncate">{a.title}</span>
                      </div>
                      <p className="text-[10px] sm:text-xs text-gray-400 ml-3 sm:ml-4">
                        {formatDueDate(a.due_date).text}
                      </p>
                    </div>
                  ))
              )}
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}