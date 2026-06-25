import React, { createContext, useContext, useState, useEffect, useCallback } from "react";
import {
  getParentStudentMappings,
  getStudentProfile,
  getParentDashboardData,
  getStudentEnrollment,
  getAcademicYear,
  getStudentAttendanceRecords,
  getStudentGrades,
  getAssignmentsForStudent,
} from "../services/parentAPIs";

const ParentContext = createContext();

export const ParentProvider = ({ children }) => {
  const [contextData, setContextData] = useState({
    mapping: null,
    student: null,
    profile: null,
    dashboard: null,          // { attendance, grades, exams }
    enrollment: null,
    academic: { years: [], subs: [] },
    attendanceRecords: [],
    grades: [],                // flat grades array for GradesAssessmentHub
    assignments: [],           // assignments + submission status for AssignmentsOverview
    children: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const loadForStudent = useCallback(async (studentId, mappingRecord) => {
    try {
      const [profile, dashboard, enrollment, academic, attendanceRecords, grades, assignments] =
        await Promise.all([
          getStudentProfile(studentId),
          getParentDashboardData(studentId),
          getStudentEnrollment(studentId),
          getAcademicYear(),
          getStudentAttendanceRecords(studentId),
          getStudentGrades(studentId),
          getAssignmentsForStudent(studentId),
        ]);

      setContextData((prev) => ({
        ...prev,
        mapping: mappingRecord,
        student: studentId,
        profile,
        dashboard,
        enrollment,
        academic,
        attendanceRecords,
        grades,
        assignments,
      }));
    } catch (err) {
      console.error("Failed to load student data for parent", err);
      setError(err);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      try {
        const mappings = await getParentStudentMappings();

        if (!mappings || mappings.length === 0) {
          throw new Error("No children mapped to this parent account.");
        }

        setContextData((prev) => ({ ...prev, children: mappings }));

        const primary = mappings.find((m) => m.is_primary_contact) || mappings[0];
        await loadForStudent(primary.student, primary);
      } catch (err) {
        console.error("Failed to load parent-student mapping", err);
        setError(err);
      } finally {
        setLoading(false);
      }
    };
    init();
  }, [loadForStudent]);

  const switchChild = useCallback(
    async (studentId) => {
      setLoading(true);
      const mappingRecord =
        contextData.children.find((m) => m.student === studentId) || null;
      await loadForStudent(studentId, mappingRecord);
      setLoading(false);
    },
    [contextData.children, loadForStudent]
  );

  // Refresh grades with optional filters (e.g. after tab switch)
  const refreshGrades = useCallback(
    async (filters = {}) => {
      if (!contextData.student) return;
      const grades = await getStudentGrades(contextData.student, filters);
      setContextData((prev) => ({ ...prev, grades }));
    },
    [contextData.student]
  );

  // Refresh assignments (e.g. after a child switch or manual reload)
  const refreshAssignments = useCallback(async () => {
    if (!contextData.student) return;
    const assignments = await getAssignmentsForStudent(contextData.student);
    setContextData((prev) => ({ ...prev, assignments }));
  }, [contextData.student]);

  return (
    <ParentContext.Provider
      value={{ ...contextData, loading, error, switchChild, refreshGrades, refreshAssignments }}
    >
      {children}
    </ParentContext.Provider>
  );
};

export const useParent = () => useContext(ParentContext);