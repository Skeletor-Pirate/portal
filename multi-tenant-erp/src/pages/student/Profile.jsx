import React from "react";
import MainLayout from "../../layouts/MainLayout";
import { useStudent } from "../../context/StudentProvider";
import { calculateAttendance } from "../../utils/calculations";

function Skeleton({ className = "" }) {
  return <div className={`animate-pulse bg-gray-200 rounded-md ${className}`} />;
}

function ProfileSkeleton() {
  return (
    <MainLayout title="Student Profile">
      <div className="max-w-5xl mx-auto p-4 sm:p-6 md:p-8">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6 mb-8 md:mb-12">
          {/* Left Card Skeleton */}
          <div className="md:col-span-8 bg-white rounded-xl p-5 sm:p-6 md:p-8 flex flex-col md:flex-row items-center md:items-start gap-6 md:gap-8 shadow-sm">
            <div className="relative group">
              <Skeleton className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 rounded-2xl" />
            </div>
            <div className="flex-1 text-center md:text-left w-full">
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-4">
                <Skeleton className="w-64 h-10 mx-auto md:mx-0" />
                <Skeleton className="w-32 h-7 rounded-full mx-auto md:mx-0" />
              </div>
              <Skeleton className="w-48 h-6 mb-6 mx-auto md:mx-0" />
              <div className="flex flex-wrap justify-center md:justify-start gap-3">
                <Skeleton className="w-36 h-12 rounded-xl" />
              </div>
            </div>
          </div>
          <div className="md:col-span-4 grid grid-cols-1 gap-6">
            {[1, 2].map(i => (
              <div key={i} className="bg-white rounded-xl p-6 flex items-center justify-between shadow-sm">
                <div>
                  <Skeleton className="w-20 h-3 mb-2" />
                  <Skeleton className="w-16 h-9" />
                </div>
                <Skeleton className="w-12 h-12 rounded-lg" />
              </div>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8">
          {/* Academic Information Skeleton */}
          <section className="space-y-6">
            <div className="flex items-center gap-3 px-2">
              <Skeleton className="w-6 h-6 rounded-full" />
              <Skeleton className="w-48 h-7" />
            </div>
            <div className="bg-white rounded-xl overflow-hidden shadow-sm">
              <div className="p-6 space-y-6">
                <div className="flex justify-between items-start">
                  <div>
                    <Skeleton className="w-24 h-3 mb-2" />
                    <Skeleton className="w-40 h-5" />
                  </div>
                </div>

                <div className="flex justify-between items-start">
                  <div>
                    <Skeleton className="w-32 h-3 mb-2" />
                    <Skeleton className="w-48 h-7" />
                  </div>
                </div>

                <div className="flex justify-between items-start">
                  <div>
                    <Skeleton className="w-24 h-3 mb-2" />
                    <Skeleton className="w-32 h-5" />
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Personal Contact Skeleton */}
          <section className="space-y-6">
            <div className="flex items-center gap-3 px-2">
              <Skeleton className="w-6 h-6 rounded-full" />
              <Skeleton className="w-40 h-7" />
            </div>
            <div className="bg-white rounded-xl overflow-hidden shadow-sm">
              <div className="p-6 space-y-6">
                <div className="flex items-center gap-4">
                  <Skeleton className="w-10 h-10 rounded-full shrink-0" />
                  <div className="flex-1">
                    <Skeleton className="w-24 h-3 mb-2" />
                    <Skeleton className="w-48 h-5" />
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <Skeleton className="w-10 h-10 rounded-full shrink-0" />
                  <div className="flex-1">
                    <Skeleton className="w-24 h-3 mb-2" />
                    <Skeleton className="w-56 h-5" />
                  </div>
                </div>

                <div className="flex items-center gap-4">
                  <Skeleton className="w-10 h-10 rounded-full shrink-0" />
                  <div className="flex-1">
                    <Skeleton className="w-32 h-3 mb-2" />
                    <Skeleton className="w-48 h-5" />
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>
    </MainLayout>
  );
}

export default function Profile() {
  const {
    profile: student,
    dashboard: studentData,
    enrollment: enroll,
    parents,
    loading,
  } = useStudent();

  if (loading) return <ProfileSkeleton />;

  if (!student)
    return (
      <MainLayout title="Student Profile">
        <div className="p-4 sm:p-6 md:p-8">No profile data found.</div>
      </MainLayout>
    );

  const attendance     = studentData?.attendance?.results || [];
  const attendanceRate = calculateAttendance(attendance);
  const grades         = studentData?.grades?.results || [];

  // ── Overall Percentage ──
  const totalMarks = grades.reduce((sum, g) => sum + parseFloat(g.marks_obtained || 0), 0);
  const totalMax   = grades.reduce((sum, g) => sum + parseFloat(g.max_marks || 1), 0);
  const percentage = totalMax > 0 ? ((totalMarks / totalMax) * 100).toFixed(1) : "0.0";

  return (
    <MainLayout title="Student Profile">
      <div className="max-w-5xl mx-auto p-4 sm:p-6 md:p-8">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6 mb-8 md:mb-12">
          {/* Left Card - Profile Info */}
          <div className="md:col-span-8 bg-surface-container-lowest rounded-xl p-5 sm:p-6 md:p-8 flex flex-col lg:flex-row items-center lg:items-start gap-6 lg:gap-8 shadow-sm overflow-hidden">
            <div className="relative group flex-shrink-0 mx-auto lg:mx-0">
              <div className="w-32 h-32 sm:w-40 sm:h-40 md:w-48 md:h-48 rounded-2xl bg-blue-100 flex items-center justify-center text-blue-50 shadow-xl overflow-hidden">
                {student.profile_picture ? (
                  <img src={student.profile_picture} alt="Profile" className="w-full h-full object-cover" />
                ) : (
                  <span className="material-symbols-outlined text-5xl sm:text-6xl">
                    person
                  </span>
                )}
              </div>
              <button className="absolute -bottom-3 -right-3 bg-primary-container text-white p-2.5 sm:p-3 rounded-full shadow-lg hover:scale-110 transition-transform">
                <span
                  className="material-symbols-outlined text-base sm:text-lg"
                  data-icon="photo_icon"
                >
                  photo_camera
                </span>
              </button>
            </div>
            <div className="flex-1 w-full min-w-0 flex flex-col items-center lg:items-start">

  <h1 className="text-2xl sm:text-3xl md:text-4xl font-extrabold font-headline text-on-surface text-center lg:text-left break-words leading-tight">
    {student.first_name} {student?.last_name}
  </h1>

  <span
    className={`mt-3 inline-flex items-center justify-center px-4 py-1.5 text-xs font-bold rounded-full whitespace-nowrap ${
      student.is_archived
        ? "bg-red-100 text-red-700"
        : "bg-surface-container-highest text-primary"
    }`}
  >
    {student?.is_archived ? "ARCHIVED" : "ACTIVE STUDENT"}
  </span>

  <p className="text-on-surface-variant font-medium text-base sm:text-lg mb-4 sm:mb-6 mt-4 text-center lg:text-left">
    Enrolled via {enroll ? enroll.academic_year_name : "N/A"}
  </p>

  <div className="flex flex-wrap justify-center lg:justify-start gap-3">
    <button className="bg-primary text-white px-6 sm:px-8 py-3 rounded-xl font-bold flex items-center gap-2 shadow-sm hover:opacity-90 transition-all">
      <span className="material-symbols-outlined">
        edit
      </span>
      Edit Profile
    </button>
  </div>

</div>
</div>
          

          {/* Right Stats Cards */}
          <div className="md:col-span-4 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-1 gap-6">
            <div className="bg-surface-container-lowest rounded-xl p-6 flex items-center justify-between shadow-sm">
              <div>
                <p className="text-xs font-bold text-on-surface-variant uppercase tracking-widest mb-1">
                  Overall Score
                </p>
                <p className="text-3xl font-black text-on-surface font-headline">
                  {percentage}<span className="text-lg font-semibold">%</span>
                </p>
              </div>

              <div className="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center text-primary flex-shrink-0">
                <span
                  className="material-symbols-outlined text-3xl"
                  data-icon="grade"
                >
                  grade
                </span>
              </div>
            </div>

            {/* Attendance */}
            <div className="bg-surface-container-lowest rounded-xl p-6 flex items-center justify-between shadow-sm">
              <div>
                <p className="text-xs font-bold text-on-surface-variant uppercase tracking-widest mb-1">
                  Attendance
                </p>
                <p className="text-3xl font-black text-on-surface font-headline">
                  {attendanceRate}<span className="text-lg font-semibold">%</span>
                </p>
              </div>

              <div className="w-12 h-12 rounded-lg bg-blue-50 flex items-center justify-center text-primary flex-shrink-0">
                <span
                  className="material-symbols-outlined text-3xl"
                  data-icon="event_available"
                >
                  event_available
                </span>
              </div>
            </div>

          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8">
          {/* Academic Information Section */}
          <section className="space-y-6">
            <div className="flex items-center gap-3 px-2">
              <span
                className="material-symbols-outlined text-primary"
                data-icon="school"
              >
                school
              </span>
              <h2 className="text-lg sm:text-xl font-bold font-headline">
                Academic Information
              </h2>
            </div>
            <div className="bg-surface-container-lowest rounded-xl overflow-hidden shadow-sm">
              <div className="p-4 sm:p-6 space-y-6">
                <div className="flex justify-between items-start">
                  <div>
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Class / Grade
                    </label>
                    <p className="text-on-surface font-semibold text-base sm:text-lg mt-1">
                      {enroll
                        ? `${enroll.class_level_name} - ${enroll.section_name}`
                        : "Not Assigned"}
                    </p>
                  </div>
                </div>

                <div className="flex justify-between items-start">
                  <div>
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Enrollment Number
                    </label>
                    <p className="text-on-surface font-semibold text-base sm:text-lg mt-1 break-all">
                      {student.enrollment_number}
                    </p>
                  </div>
                </div>

                <div className="flex justify-between items-start">
                  <div>
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Roll Number
                    </label>
                    <p className="text-on-surface font-semibold text-base sm:text-lg mt-1">
                      {enroll?.roll_number || "Unassigned"}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Personal Contact */}
          <section className="space-y-6">
            <div className="flex items-center gap-3 px-2">
              <span
                className="material-symbols-outlined text-primary"
                data-icon="contact_page"
              >
                contact_page
              </span>
              <h2 className="text-lg sm:text-xl font-bold font-headline">
                Personal Contact
              </h2>
            </div>
            <div className="bg-surface-container-lowest rounded-xl overflow-hidden shadow-sm">
              <div className="p-4 sm:p-6 space-y-6">
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-surface-container-low flex items-center justify-center flex-shrink-0">
                    <span
                      className="material-symbols-outlined text-primary"
                      data-icon="mail"
                    >
                      mail
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Email Address
                    </label>
                    <p className="text-on-surface font-semibold break-all">
                      {student.email}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-surface-container-low flex items-center justify-center flex-shrink-0">
                    <span
                      className="material-symbols-outlined text-primary"
                      data-icon="call"
                    >
                      call
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Residence
                    </label>
                    <p className="text-on-surface font-semibold break-words">
                      {student.address || "Not provided"}
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-surface-container-low flex items-center justify-center flex-shrink-0">
                    <span
                      className="material-symbols-outlined text-primary"
                      data-icon="emergency_share"
                    >
                      emergency_share
                    </span>
                  </div>
                  <div className="flex-1 min-w-0">
                    <label className="text-xs font-bold text-slate-400 uppercase tracking-widest">
                      Emergency Contact
                    </label>
                    <p className="text-on-surface font-semibold break-words">
                      {parents.length > 0
                        ? `${parents[0].parent_name} (${parents[0].relationship})`
                        : "No Contact Registered"}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>

        </div>
      </div>
    </MainLayout>
  );
}