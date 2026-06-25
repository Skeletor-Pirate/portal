import api from "./axiosClient";

const isNotFoundError = (error) => error?.response?.status === 404;

export const getStudentProfile = async (studentId) => {
  const response = await api.get(`/profiles/students/${studentId}/`);
  return response.data;
};

export const getStudentDashboardData = async (studentId) => {
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

export const getStudentAttendanceRecords = async (studentId) => {
  const response = await api.get(
    `/operations/attendance/?student=${studentId}`,
  );
  return response.data.results;
};

export const getAcademicYear = async () => {
  const [years, subs] = await Promise.all([
    api.get(`academics/academic-years/`),
    api.get(`academics/subjects/`),
  ]);
  return {
    years: years.data.results,
    subs: subs.data.results,
  };
};

export const getAssignments = async () => {
  try {
    const response = await api.get(`/operations/assignments/`);
    return response.data.results || [];
  } catch (error) {
    if (isNotFoundError(error)) {
      return [];
    }
    throw error;
  }
};

export const getSubmissions = async () => {
  try {
    const response = await api.get(`/operations/submissions/`);
    return response.data.results || [];
  } catch (error) {
    if (isNotFoundError(error)) {
      return [];
    }
    throw error;
  }
};

export const submitAssignment = async (formData) => {
  const response = await api.post(`/operations/submissions/`, formData, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  return response.data;
};

export const getStudentEnrollment = async (studentId) => {
  const response = await api.get(
    `/academics/enrollments/?student=${studentId}`,
  );
  return response.data.results?.length > 0 ? response.data.results[0] : null;
};

export const getStudentParents = async () => {
  const response = await api.get(`/profiles/parent-student-mappings/`);
  return response.data.results;
};

export const getSectionById = async (sectionId) => {
  const response = await api.get(
    `/academics/sections/${sectionId}/`
  );
  return response.data;
};