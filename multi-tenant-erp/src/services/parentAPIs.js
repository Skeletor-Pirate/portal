import api from "./axiosClient";

const isNotFoundError = (error) => error?.response?.status === 404;

/**
 * Get all student(s) mapped to the currently logged-in parent.
 * GET /api/v1/profiles/parent-student-mappings/
 */
export const getParentStudentMappings = async () => {
  const response = await api.get(`/profiles/parent-student-mappings/`);
  return response.data.results || [];
};

/**
 * Get a specific student's profile (works for parent token + student_id).
 * GET /api/v1/profiles/students/{student_id}/
 */
export const getStudentProfile = async (studentId) => {
  const response = await api.get(`/profiles/students/${studentId}/`);
  return response.data;
};

/**
 * Bundled dashboard data for one child: attendance + grades + exams.
 */
export const getParentDashboardData = async (studentId) => {
  const [attendanceRes, gradesRes, examsRes] = await Promise.all([
    api.get(`/operations/attendance/?student=${studentId}`),
    api.get(`/operations/grades/?student=${studentId}`),
    api.get(`/operations/exams/?student=${studentId}`),
  ]);
  return {
    attendance: attendanceRes.data,
    grades: gradesRes.data,
    exams: examsRes.data,
  };
};

/**
 * Full attendance record list (results array only) for a given child.
 * GET /api/v1/operations/attendance/?student={student_id}
 */
export const getStudentAttendanceRecords = async (studentId) => {
  const response = await api.get(`/operations/attendance/?student=${studentId}`);
  return response.data.results || [];
};

/**
 * Current enrollment (class/section/roll number) for a given child.
 * GET /api/v1/academics/enrollments/?student={student_id}
 */
export const getStudentEnrollment = async (studentId) => {
  const response = await api.get(`/academics/enrollments/?student=${studentId}`);
  return response.data.results?.length > 0 ? response.data.results[0] : null;
};

/**
 * Academic years + subjects list (shared reference data, not student-specific).
 */
export const getAcademicYear = async () => {
  const [years, subs] = await Promise.all([
    api.get(`/academics/academic-years/`),
    api.get(`/academics/subjects/`),
  ]);
  return {
    years: years.data.results || [],
    subs: subs.data.results || [],
  };
};

/**
 * Grades for a given child, with optional exam/subject filters.
 * GET /api/v1/operations/grades/?student={student_id}&exam={exam_id}&subject={subject_id}
 */
export const getStudentGrades = async (studentId, { examId, subjectId } = {}) => {
  let url = `/operations/grades/?student=${studentId}`;
  if (examId) url += `&exam=${examId}`;
  if (subjectId) url += `&subject=${subjectId}`;
  const response = await api.get(url);
  return response.data.results || [];
};

/**
 * Section lookup by ID — used to resolve class_level for filtering subjects.
 */
export const getSectionById = async (sectionId) => {
  const response = await api.get(`/academics/sections/${sectionId}/`);
  return response.data;
};

/**
 * Assignments for a given child, with submission status baked in
 * (submission_status: "Pending" | "Submitted" | "Graded", plus grade/submitted_at when relevant).
 * GET /api/v1/operations/assignments/for-student/?student={student_id}
 */
export const getAssignmentsForStudent = async (studentId) => {
  try {
    const response = await api.get(`/operations/assignments/for-student/?student=${studentId}`);
    return response.data.results || [];
  } catch (error) {
    if (isNotFoundError(error)) {
      return [];
    }
    throw error;
  }
};