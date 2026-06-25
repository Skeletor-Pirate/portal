// src/components/erp/parent/StudentHeader.jsx

import React, { useState } from "react";
import { useParent } from "../../../context/ParentProvider";

const StudentHeader = () => {
  const { profile, enrollment, dashboard, loading } = useParent();
  const [downloading, setDownloading] = useState(false);

  const displayName = (() => {
    if (profile?.user?.first_name)
      return `${profile.user.first_name} ${profile.user.last_name || ""}`.trim();
    if (profile?.first_name)
      return `${profile.first_name} ${profile.last_name || ""}`.trim();
    return "Student";
  })();

  const classSection =
    enrollment?.class_level_name && enrollment?.section_name
      ? `${enrollment.class_level_name} – ${enrollment.section_name}`
      : enrollment?.class_name && enrollment?.section_name
      ? `${enrollment.class_name} – ${enrollment.section_name}`
      : enrollment?.class_name || enrollment?.class_level_name || "—";

  const schoolName   = enrollment?.school_name || profile?.school_name || "School";
  const teacherEmail = enrollment?.class_teacher_email || enrollment?.teacher_email || null;

  const getGradeDetails = (obtained, max) => {
    const pct = max > 0 ? (obtained / max) * 100 : 0;
    if (pct >= 90) return { letter: "A+", cls: "grade-Aplus" };
    if (pct >= 80) return { letter: "A",  cls: "grade-A" };
    if (pct >= 70) return { letter: "B+", cls: "grade-Bplus" };
    if (pct >= 60) return { letter: "B",  cls: "grade-B" };
    return               { letter: "C",  cls: "grade-C" };
  };

  const downloadReportCard = () => {
    setDownloading(true);
    const grades = dashboard?.grades?.results || [];
    const exams  = dashboard?.exams?.results  || [];

    const pastExams = exams
      .filter((e) => new Date(e.end_date) < new Date())
      .sort((a, b) => new Date(b.end_date) - new Date(a.end_date));
    const latestExam = pastExams[0] || null;

    const totalMarks = grades.reduce((s, g) => s + parseFloat(g.marks_obtained || 0), 0);
    const totalMax   = grades.reduce((s, g) => s + parseFloat(g.max_marks || 0), 0);
    const overallPct = totalMax > 0 ? ((totalMarks / totalMax) * 100).toFixed(1) : 0;

    const printWindow = window.open("", "_blank");
    const reportHTML = `<!DOCTYPE html><html><head><title>Report Card</title><meta charset="UTF-8">
    <style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:'Segoe UI',sans-serif;padding:40px;color:#333}
    .header{text-align:center;margin-bottom:30px;border-bottom:3px solid #3b82f6;padding-bottom:20px}
    .header h1{font-size:28px;color:#1e293b}.header h2{font-size:20px;color:#64748b;font-weight:normal}
    .info{background:#f8fafc;padding:15px 20px;border-radius:12px;margin-bottom:25px;display:flex;justify-content:space-between;flex-wrap:wrap;gap:10px}
    .info-item{display:flex;gap:8px}.info-label{font-weight:600;color:#64748b;font-size:12px}.info-value{font-weight:700;color:#1e293b;font-size:14px}
    .summary{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-bottom:30px}
    .card{background:linear-gradient(135deg,#3b82f6,#2563eb);color:white;padding:20px;border-radius:16px;text-align:center}
    .card h4{font-size:12px;opacity:.9;margin-bottom:8px}.card .value{font-size:32px;font-weight:bold}
    table{width:100%;border-collapse:collapse;margin-bottom:30px}
    th{background:#f1f5f9;padding:12px;text-align:left;font-size:12px;font-weight:600;color:#475569;border-bottom:2px solid #e2e8f0}
    td{padding:12px;font-size:13px;border-bottom:1px solid #e2e8f0}
    .badge{display:inline-block;padding:4px 12px;border-radius:20px;font-weight:bold;font-size:11px}
    .grade-Aplus{background:#dcfce7;color:#166534}.grade-A{background:#dbeafe;color:#1e40af}
    .grade-Bplus{background:#fef3c7;color:#92400e}.grade-B{background:#ffedd5;color:#9a3412}.grade-C{background:#fee2e2;color:#991b1b}
    .footer{margin-top:30px;padding-top:20px;border-top:1px solid #e2e8f0;text-align:center;font-size:11px;color:#94a3b8}
    </style></head><body>
    <div class="header"><h1>ACADEMIC REPORT CARD</h1><h2>${classSection}</h2><p>Academic Year ${new Date().getFullYear()}</p></div>
    <div class="info">
      <div class="info-item"><span class="info-label">Student:</span><span class="info-value">${displayName}</span></div>
      <div class="info-item"><span class="info-label">Enroll No:</span><span class="info-value">${profile?.enrollment_number || "N/A"}</span></div>
      <div class="info-item"><span class="info-label">Roll No:</span><span class="info-value">${enrollment?.roll_number || "N/A"}</span></div>
      <div class="info-item"><span class="info-label">Date:</span><span class="info-value">${new Date().toLocaleDateString()}</span></div>
    </div>
    <div class="summary">
      <div class="card"><h4>Overall %</h4><div class="value">${overallPct}%</div></div>
      <div class="card" style="background:linear-gradient(135deg,#10b981,#059669)"><h4>Subjects Passed</h4><div class="value">${grades.filter(g=>parseFloat(g.marks_obtained)>=parseFloat(g.max_marks)*0.4).length}</div></div>
      <div class="card" style="background:linear-gradient(135deg,#8b5cf6,#7c3aed)"><h4>Latest Exam</h4><div class="value" style="font-size:16px">${latestExam?.name||"N/A"}</div></div>
    </div>
    <table><thead><tr><th>Subject</th><th>Exam</th><th>Obtained</th><th>Max</th><th>%</th><th>Grade</th><th>Remarks</th></tr></thead>
    <tbody>${grades.map(g=>{
      const obt=parseFloat(g.marks_obtained||0),max=parseFloat(g.max_marks||0);
      const pct=max>0?((obt/max)*100).toFixed(1):"0.0";
      const gd=getGradeDetails(obt,max);
      return `<tr><td><strong>${g.subject_name}</strong></td><td>${g.exam_name}</td><td>${g.marks_obtained}</td><td>${g.max_marks}</td><td><strong>${pct}%</strong></td><td><span class="badge ${gd.cls}">${gd.letter}</span></td><td style="font-style:italic;color:#64748b">${g.remarks||"No remarks"}</td></tr>`;
    }).join("")}</tbody></table>
    <div class="footer"><p>Generated on ${new Date().toLocaleString()} — Academic Architect</p></div>
    <script>window.print();setTimeout(()=>window.close(),500)</script></body></html>`;

    printWindow.document.write(reportHTML);
    printWindow.document.close();
    setTimeout(() => setDownloading(false), 1000);
  };

  if (loading) {
    return (
      <section className="animate-pulse space-y-3">
        <div className="h-8 bg-slate-100 dark:bg-slate-700 rounded w-48" />
        <div className="flex gap-3">
          <div className="h-4 bg-slate-100 dark:bg-slate-700 rounded w-24" />
          <div className="h-4 bg-slate-100 dark:bg-slate-700 rounded w-20" />
        </div>
        <div className="flex gap-3 pt-1">
          <div className="h-10 bg-slate-100 dark:bg-slate-700 rounded w-36" />
          <div className="h-10 bg-slate-100 dark:bg-slate-700 rounded w-36" />
        </div>
      </section>
    );
  }

  return (
    <section className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">

      {/* Left: name + meta */}
      <div className="space-y-1.5 min-w-0">
        <h2 className="text-2xl sm:text-3xl font-extrabold text-on-surface dark:text-white font-headline tracking-tight leading-tight">
          Parent Dashboard
        </h2>

        {/* Chips row — wraps on mobile */}
        <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-on-surface-variant dark:text-slate-300">
          <span className="flex items-center gap-1">
            <span className="material-symbols-outlined text-primary dark:text-blue-300 text-base">person</span>
            <span className="font-semibold text-on-surface dark:text-white">{displayName}</span>
          </span>

          <span className="w-1 h-1 rounded-full bg-slate-300 dark:bg-slate-600" />

          <span className="flex items-center gap-1">
            <span className="material-symbols-outlined text-primary dark:text-blue-300 text-base">school</span>
            <span>{classSection}</span>
          </span>

          <span className="w-1 h-1 rounded-full bg-slate-300 dark:bg-slate-600 hidden sm:block" />

          <span className="text-primary dark:text-blue-300 font-medium hidden sm:inline">{schoolName}</span>
        </div>
      </div>

      {/* Right: action buttons — stack on very small screens */}
      <div className="flex flex-wrap gap-2 sm:gap-3 sm:flex-nowrap sm:justify-end flex-shrink-0">
        <button
          onClick={downloadReportCard}
          disabled={downloading}
          className="flex items-center gap-1.5
                     bg-slate-100 dark:bg-slate-700
                     text-primary dark:text-blue-300
                     px-4 py-2.5 rounded-lg font-semibold text-sm
                     hover:bg-slate-200 dark:hover:bg-slate-600
                     transition-colors active:scale-95 duration-75
                     disabled:opacity-50 whitespace-nowrap"
        >
          <span className="material-symbols-outlined text-base">
            {downloading ? "hourglass_empty" : "picture_as_pdf"}
          </span>
          {downloading ? "Preparing..." : "Download Report"}
        </button>

        {teacherEmail ? (
          <a
            href={`mailto:${teacherEmail}`}
            className="flex items-center gap-1.5
                       bg-blue-600 text-white
                       px-4 py-2.5 rounded-lg font-semibold text-sm
                       hover:bg-blue-700 transition-colors active:scale-95 duration-75
                       whitespace-nowrap"
          >
            <span className="material-symbols-outlined text-base">mail</span>
            Contact Teacher
          </a>
        ) : (
          <button
            disabled
            title="Teacher email not available"
            className="flex items-center gap-1.5
                       bg-blue-600 text-white opacity-60 cursor-not-allowed
                       px-4 py-2.5 rounded-lg font-semibold text-sm whitespace-nowrap"
          >
            <span className="material-symbols-outlined text-base">mail</span>
            Contact Teacher
          </button>
        )}
      </div>
    </section>
  );
};

export default StudentHeader;