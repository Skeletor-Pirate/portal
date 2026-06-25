import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import SchoolLayout from "../../components/erp/school/SchoolLayout";
import { schoolAdminApi } from "../../services/schoolAdminApi";
import { useTheme } from "../../context/ThemeContext";

export default function EditTeacherAssignment() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [isClassTeacher, setIsClassTeacher] = useState(false);
  const [displayData, setDisplayData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      try {
        const data = await schoolAdminApi.getTeacherAssignmentById(id);
        setDisplayData(data);
        setIsClassTeacher(data.is_class_teacher || false);
      } catch (err) {
        console.error("Error loading assignment:", err);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [id]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await schoolAdminApi.updateTeacherAssignment(id, {
        is_class_teacher: isClassTeacher,
      });
      alert("Updated successfully!");
      navigate("/school-admin/teacher-assignment");
    } catch (err) {
      console.error("Error updating assignment:", err);
      alert("Failed to update.");
    }
  };

  if (loading) {
    return (
      <SchoolLayout title="Edit Assignment">
        <div className="flex items-center justify-center min-h-[50vh] text-primary font-semibold gap-2 font-body">
          <span className="material-symbols-outlined animate-spin text-4xl">progress_activity</span>
        </div>
      </SchoolLayout>
    );
  }

  return (
    <SchoolLayout title="Edit Assignment">
      <div className="px-4 sm:px-6 md:px-8 py-6 md:py-8 max-w-lg mx-auto">
        <div className="bg-surface-container-lowest p-6 md:p-8 rounded-xl shadow-sm border border-outline-variant/10">
          <button
            onClick={() => navigate(-1)}
            className="mb-6 text-primary font-medium flex items-center gap-1 hover:underline transition-all font-body"
          >
            <span className="material-symbols-outlined text-sm">arrow_back</span>
            Back
          </button>

          <h1 className="text-2xl font-headline font-extrabold text-on-surface mb-6">
            Edit Assignment
          </h1>

          {displayData && (
            <div className="mb-8 p-5 bg-surface-container-high rounded-lg border border-outline-variant/10">
              <p className="font-headline font-bold text-on-surface text-lg mb-1">
                {displayData.teacher_name}
              </p>
              <div className="flex flex-col gap-1 text-sm text-on-surface-variant font-body">
                <p>
                  <strong className="text-on-surface">Subject:</strong> {displayData.subject_name}
                </p>
                <p>
                  <strong className="text-on-surface">Class/Section:</strong> {displayData.class_level_name} - {displayData.section_name}
                </p>
                <p>
                  <strong className="text-on-surface">Academic Year:</strong> {displayData.academic_year_name}
                </p>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="mb-8">
              <label className="flex items-center justify-between p-4 bg-tertiary/10 border border-tertiary/20 rounded-lg cursor-pointer hover:bg-tertiary/20 transition-colors">
                <div>
                  <span className="font-bold text-tertiary font-body">
                    Assign as Class Teacher
                  </span>
                </div>
                <input
                  type="checkbox"
                  checked={isClassTeacher}
                  onChange={() => setIsClassTeacher(!isClassTeacher)}
                  className="w-5 h-5 rounded text-tertiary focus:ring-tertiary/50 border-outline-variant/20"
                />
              </label>
            </div>

            <div className="flex flex-wrap gap-3">
              <button
                type="submit"
                className="bg-primary hover:bg-primary/90 text-white px-6 py-2.5 rounded-lg font-medium transition-colors font-body"
              >
                Save Changes
              </button>
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="bg-surface-container-high hover:bg-surface-container-high/70 text-on-surface-variant px-6 py-2.5 rounded-lg font-medium transition-colors font-body"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </SchoolLayout>
  );
}