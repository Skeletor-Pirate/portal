import React, { createContext, useContext, useState, useEffect } from "react";
import {
  getStudentProfile,
  getStudentDashboardData,
  getStudentEnrollment,
  getStudentParents,
  getAcademicYear,
  getAssignments,
  getSubmissions,
  getStudentAttendanceRecords,
} from "../services/studentAPIs";

const StudentContext = createContext();

export const StudentProvider = ({ children }) => {
  const [contextData, setContextData] = useState({
    profile: null,
    dashboard: null,
    enrollment: null,
    parents: [],
    academic: { years: [], subs: [] },
    assignments: [],
    submissions: [],
    attendanceRecords: [],
  });
  const [loading, setLoading] = useState(true);

  // A method to refresh specific data (like submissions after upload)
  const refreshSubmissions = async () => {
    const subs = await getSubmissions();
    setContextData((prev) => ({ ...prev, submissions: subs }));
  };

  useEffect(() => {
    const loadAllData = async () => {
      try {
        const userData = JSON.parse(localStorage.getItem("user_data"));
        const studentId = userData?.profiles?.student?.id;

        if (!studentId) throw new Error("No student ID found.");

        const [
          profile,
          dashboard,
          enrollment,
          parentsData,
          academic,
          assignments,
          submissions,
          attendanceRecords,
        ] = await Promise.all([
          getStudentProfile(studentId),
          getStudentDashboardData(studentId),
          getStudentEnrollment(studentId),
          getStudentParents(),
          getAcademicYear(),
          getAssignments(),
          getSubmissions(),
          getStudentAttendanceRecords(studentId),
        ]);

        setContextData({
          profile,
          dashboard,
          enrollment,
          parents: parentsData.filter((p) => p.student === studentId),
          academic,
          assignments,
          submissions,
          attendanceRecords,
        });
      } catch (err) {
        console.error("Failed to load global student data", err);
      } finally {
        setLoading(false);
      }
    };
    loadAllData();
  }, []);

  return (
    <StudentContext.Provider
      value={{ ...contextData, loading, refreshSubmissions }}
    >
      {children}
    </StudentContext.Provider>
  );
};

export const useStudent = () => useContext(StudentContext);
