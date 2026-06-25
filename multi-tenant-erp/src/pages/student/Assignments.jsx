

import React, { useState } from "react";
import MainLayout from "../../layouts/MainLayout";
import { useStudent } from "../../context/StudentProvider";
import { submitAssignment } from "../../services/studentAPIs";

export default function Assignments() {
  const {assignments, submissions, academic, dashboard, loading, refreshSubmissions} = useStudent();

  const [selectedSubject, setSelectedSubject] = useState("all");
  const [selectedStatus, setSelectedStatus] = useState("all");
  const [selectedAssignment, setSelectedAssignment] = useState(null); // For modal
  const [file, setFile] = useState(null);
  
  if (loading)
    return (
      <MainLayout>
        <div>Loading Assignments...</div>
      </MainLayout>
    );

   const subs = academic.subs || []
   const exams = dashboard?.exams?.results || [];

  const filteredAssignments = assignments.filter((assign) => {
    const mySubmission = submissions.find((s) => s.assignment === assign.id);

    // Subject Filter Logic
    const matchesSubject =
      selectedSubject === "all" ||
      assign.subject.toString() === selectedSubject;

    // Status Filter Logic
    let matchesStatus = true;
    if (selectedStatus === "pending") matchesStatus = !mySubmission;
    if (selectedStatus === "submitted") matchesStatus = !!mySubmission;
    if (selectedStatus === "graded") matchesStatus = mySubmission?.grade != null;

    return matchesSubject && matchesStatus;
  });

  const pendingTasks = assignments.filter(
    (a) => !submissions.find((s) => s.assignment === a.id),
  ).length;

  const gradedSubmissions = submissions.filter((s) => s.grade != null);
  const avgGradeValue =
    gradedSubmissions.length > 0
      ? gradedSubmissions.reduce(
          (acc, curr) => acc + parseFloat(curr.grade),
          0,
        ) / gradedSubmissions.length
      : 0;

  const getLetterGrade = (grade) => {
    if (grade >= 90) return "A";
    if (grade >= 80) return "B";
    return "C"; //school's logic here
  };
  const averageGradeLetter = getLetterGrade(avgGradeValue);
  const upcomingExam = exams?.length > 0 ? exams[0] : null;
 

  return (
    <MainLayout title="Assignments">
      <div className="p-8 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-10">
          {/* Pending Tasks Card */}
          <div className="bg-surface-container-lowest p-6 rounded-xl ambient-shadow flex flex-col gap-2">
            <span className="text-on-surface-variant text-sm font-medium">
              Pending Tasks
            </span>
            <div className="flex items-baseline gap-2">
              <span className="font-headline text-3xl font-bold text-primary">
                {String(pendingTasks).padStart(2, "0")}
              </span>
              <span className="text-xs text-on-surface-variant">this week</span>
            </div>
          </div>
          {/* Average Grade Card */}
          <div className="bg-surface-container-lowest p-6 rounded-xl ambient-shadow flex flex-col gap-2">
            <span className="text-on-surface-variant text-sm font-medium">
              Average Grade
            </span>
            <div className="flex items-baseline gap-2">
              <span className="font-headline text-3xl font-bold text-secondary">
                {averageGradeLetter}
              </span>
              <span className="text-xs text-on-surface-variant">
                {avgGradeValue.toFixed(1)}%
              </span>
            </div>
          </div>
          {/* Upcoming Exam Card */}
          <div className="col-span-2 bg-primary-container p-6 rounded-xl ambient-shadow primary-gradient text-on-primary flex justify-between items-center relative overflow-hidden">
            <div className="z-10">
              <h3 className="font-headline text-xl font-bold mb-1">
                {upcomingExam ? upcomingExam.name : "No upcoming exams"}
              </h3>
              <p className="text-blue-100 text-sm opacity-90">
                {upcomingExam
                  ? `${new Date(upcomingExam.start_date).toDateString()}`
                  : "Enjoy your free time!"}
              </p>
            </div>
          </div>
        </div>

        <div className="flex flex-col md:flex-row gap-4 mb-8 items-center justify-between">
          <div className="flex flex-1 w-full max-w-md bg-surface-container-low rounded-md px-4 py-2.5 items-center gap-3">
            <span
              className="material-symbols-outlined text-slate-400 text-xl"
              data-icon="search"
            >
              search
            </span>
            <input
              className="bg-transparent border-none focus:ring-0 text-sm w-full placeholder:text-slate-400"
              placeholder="Search assignments..."
              type="text"
            />
          </div>
          <div className="flex items-center gap-3 w-full md:w-auto">
            <select
              value={selectedSubject}
              onChange={(e) => setSelectedSubject(e.target.value)}
              className="bg-surface-container-low border-none rounded-md px-4 py-2.5 text-sm text-on-surface-variant focus:ring-2 focus:ring-surface-tint min-w-[140px]"
            >
              <option value="all">All Subjects</option>
              {subs.map((sub) => (
                <option key={sub.id} value={sub.id}>
                  {sub.name}
                </option>
              ))}
            </select>

            {/* Status Filter */}
            <select
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="bg-surface-container-low border-none rounded-md px-4 py-2.5 text-sm text-on-surface-variant focus:ring-2 focus:ring-surface-tint min-w-[140px]"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="submitted">Submitted</option>
              <option value="graded">Graded</option>
            </select>
            <button className="p-2.5 bg-surface-container-low text-primary rounded-md hover:bg-surface-container-high transition-colors">
              <span className="material-symbols-outlined" data-icon="tune">
                tune
              </span>
            </button>
          </div>
        </div>

        <div className="bg-surface-container-lowest rounded-xl overflow-hidden ambient-shadow">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-surface-container-low text-on-surface-variant">
                <th className="px-6 py-4 font-headline text-sm font-bold uppercase">
                  Assignment Title
                </th>
                <th className="px-6 py-4 font-headline text-sm font-bold uppercase">
                  Subject
                </th>
                <th className="px-6 py-4 font-headline text-sm font-bold uppercase">
                  Due Date
                </th>
                <th className="px-6 py-4 font-headline text-sm font-bold uppercase">
                  Status
                </th>
                <th className="px-6 py-4 font-headline text-sm font-bold uppercase">
                  Grade
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredAssignments.map((assign) => {
                // Use filteredAssignments here
                const mySubmission = submissions.find(
                  (s) => s.assignment === assign.id,
                );
                const subject = subs.find((s) => s.id === assign.subject) || {
                  name: "N/A",
                };

                return (
                  <tr
                    key={assign.id}
                    className="hover:bg-slate-50/50 transition-colors"
                  >
                    <td className="px-6 py-6 font-bold">{assign.title}</td>
                    <td className="px-6 py-6">{subject.name}</td>
                    <td className="px-6 py-6">
                      {new Date(assign.due_date).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-6">
                      {mySubmission ? (
                        <span className="text-emerald-600 font-bold text-xs">
                          Submitted
                        </span>
                      ) : (
                        <button
                          onClick={() => setSelectedAssignment(assign)}
                          className="text-primary font-bold text-xs hover:underline"
                        >
                          Submit Now
                        </button>
                      )}
                    </td>
                    <td className="px-6 py-6 font-bold">
                      {mySubmission?.grade || "—"}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <div className="mt-12 bg-white/40 border border-white p-8 rounded-xl flex items-center gap-8 relative overflow-hidden glass-card">
          <div className="w-20 h-20 rounded-2xl bg-tertiary-fixed flex items-center justify-center text-tertiary shrink-0">
            <span
              className="material-symbols-outlined text-4xl"
              data-icon="psychology"
              style={{ fontVariationSettings: `&apos` }}
            >
              psychology
            </span>
          </div>
          <div>
            <h4 className="font-headline font-bold text-xl text-on-surface mb-2">
              Personalized Recommendation
            </h4>
            <p className="text-on-surface-variant leading-relaxed max-w-2xl">
              I&apos;ve noticed your performance in{" "}
              <span className="font-bold text-primary">Quantum Mechanics</span>{" "}
              has been slightly lower than your semester average. Would you like
              to schedule a 15-minute review session or access supplemental
              materials before your next assignment?
            </p>
            <div className="flex gap-4 mt-6">
              <button className="bg-primary text-white px-6 py-2.5 rounded-md font-bold text-sm shadow-sm hover:opacity-90 transition-opacity">
                Get Help Now
              </button>
              <button className="text-on-surface-variant px-6 py-2.5 rounded-md font-bold text-sm hover:bg-white/50 transition-colors">
                Maybe Later
              </button>
            </div>
          </div>

          <div className="absolute -right-20 -top-20 w-64 h-64 bg-tertiary/5 rounded-full blur-3xl" />
        </div>
      </div>
      {/* Submission Modal */}
      {selectedAssignment && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white p-8 rounded-xl w-full max-w-sm">
            <h3 className="font-bold text-lg mb-4">
              Submit: {selectedAssignment.title}
            </h3>
            <input
              type="file"
              onChange={(e) => setFile(e.target.files[0])}
              className="mb-4 text-sm"
            />
            <div className="flex gap-2">
              <button
                onClick={async () => {
                  const userData = JSON.parse(
                    localStorage.getItem("user_data"),
                  );
                  const formData = new FormData();
                  formData.append("assignment", selectedAssignment.id);
                  formData.append("student", userData.profiles.student.id);
                  formData.append("file", file);
                  await submitAssignment(formData);
                  setSelectedAssignment(null);
                  await refreshSubmissions();
                }}
                className="bg-primary text-white px-4 py-2 rounded-md font-bold text-sm"
              >
                Upload Submission
              </button>
              <button
                onClick={() => setSelectedAssignment(null)}
                className="px-4 py-2 text-sm font-bold"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </MainLayout>
  );
}
