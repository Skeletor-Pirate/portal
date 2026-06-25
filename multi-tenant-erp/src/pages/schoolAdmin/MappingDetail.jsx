import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import SchoolLayout from "../../components/erp/school/SchoolLayout";
import { schoolAdminApi } from "../../services/schoolAdminApi";
import { useTheme } from "../../context/ThemeContext";

export default function MappingDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [mapping, setMapping] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      try {
        const data = await schoolAdminApi.getMappingById(id);
        console.log("Fetched Mapping Data:", data);
        setMapping(data);
      } catch (err) {
        console.error("Failed to load mapping", err);
      } finally {
        setLoading(false);
      }
    };
    loadData();
  }, [id]);

  if (loading) {
    return (
      <SchoolLayout title="Mapping Details">
        <div className="flex items-center justify-center min-h-[50vh] text-primary font-semibold gap-2 font-body">
          <span className="material-symbols-outlined animate-spin text-4xl">progress_activity</span>
        </div>
      </SchoolLayout>
    );
  }

  return (
    <SchoolLayout title="Mapping Details">
      <div className="px-4 sm:px-6 md:px-8 py-6 md:py-8 max-w-4xl mx-auto">
        <button
          onClick={() => navigate(-1)}
          className="mb-6 text-primary font-medium flex items-center gap-1 hover:underline transition-all font-body"
        >
          <span className="material-symbols-outlined text-sm">arrow_back</span>
          Back to Directory
        </button>

        <h1 className="text-3xl font-headline font-extrabold text-on-surface mb-6">
          Connection Details
        </h1>

        {mapping ? (
          <div className="bg-surface-container-lowest p-6 md:p-8 rounded-xl shadow-sm border border-outline-variant/10">
            {/* Header section showing the relationship */}
            <div className="flex flex-col sm:flex-row items-center gap-6 mb-8 border-b border-outline-variant/10 pb-8">
              <div className="flex flex-col items-center text-center">
                <div className="w-14 h-14 mb-2 rounded-full bg-primary/10 text-primary flex items-center justify-center">
                  <span className="material-symbols-outlined text-2xl">escalator_warning</span>
                </div>
                <h3 className="font-headline font-bold text-on-surface">
                  {mapping.parent_name || "Unknown Parent"}
                </h3>
                <span className="text-xs text-on-surface-variant uppercase tracking-wider font-body">
                  Parent/Guardian
                </span>
              </div>

              <div className="flex-1 flex flex-col items-center justify-center w-full sm:w-auto">
                <span className="text-sm font-bold text-primary bg-primary/10 px-3 py-1 rounded-full mb-1 font-body">
                  {mapping.relationship || "Linked"}
                </span>
                <div className="w-full h-px bg-outline-variant/30 relative">
                  <span className="absolute right-0 top-1/2 -translate-y-1/2 material-symbols-outlined text-outline text-sm">
                    arrow_forward
                  </span>
                </div>
              </div>

              <div className="flex flex-col items-center text-center">
                <div className="w-14 h-14 mb-2 rounded-full bg-secondary/10 text-secondary flex items-center justify-center">
                  <span className="material-symbols-outlined text-2xl">school</span>
                </div>
                <h3 className="font-headline font-bold text-on-surface">
                  {mapping.student_name || "Unknown Student"}
                </h3>
                <span className="text-xs text-on-surface-variant uppercase tracking-wider font-body">
                  Student
                </span>
              </div>
            </div>

            {/* Permissions Grid */}
            <h3 className="text-lg font-headline font-bold text-on-surface mb-4">
              Granted Permissions
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-surface-container-high p-4 rounded-lg border border-outline-variant/10 flex items-start gap-3">
                <span
                  className={`material-symbols-outlined ${
                    mapping.is_primary_contact ? "text-success" : "text-outline"
                  }`}
                >
                  {mapping.is_primary_contact ? "check_circle" : "cancel"}
                </span>
                <div>
                  <p className="font-semibold text-on-surface text-sm font-headline">
                    Primary Contact
                  </p>
                  <p className="text-xs text-on-surface-variant mt-1 font-body">
                    Main point of contact for emergencies.
                  </p>
                </div>
              </div>

              <div className="bg-surface-container-high p-4 rounded-lg border border-outline-variant/10 flex items-start gap-3">
                <span
                  className={`material-symbols-outlined ${
                    mapping.can_view_academics ? "text-success" : "text-outline"
                  }`}
                >
                  {mapping.can_view_academics ? "check_circle" : "cancel"}
                </span>
                <div>
                  <p className="font-semibold text-on-surface text-sm font-headline">
                    View Academics
                  </p>
                  <p className="text-xs text-on-surface-variant mt-1 font-body">
                    Access to grades, attendance, and reports.
                  </p>
                </div>
              </div>

              <div className="bg-surface-container-high p-4 rounded-lg border border-outline-variant/10 flex items-start gap-3">
                <span
                  className={`material-symbols-outlined ${
                    mapping.can_pay_fees ? "text-success" : "text-outline"
                  }`}
                >
                  {mapping.can_pay_fees ? "check_circle" : "cancel"}
                </span>
                <div>
                  <p className="font-semibold text-on-surface text-sm font-headline">
                    Pay Fees
                  </p>
                  <p className="text-xs text-on-surface-variant mt-1 font-body">
                    Authorized to view and pay school fees.
                  </p>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="p-6 bg-error/10 text-error rounded-lg border border-error/20 flex items-center gap-3 font-medium font-body">
            <span className="material-symbols-outlined">error</span>
            Mapping data could not be found.
          </div>
        )}
      </div>
    </SchoolLayout>
  );
}