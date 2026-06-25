import React, { useState } from "react";
import SchoolLayout from "../../components/erp/school/SchoolLayout";
import { useNavigate } from "react-router-dom";
import api from "../../services/axiosClient";

export default function CreateSubject() {
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setError("Subject name is required.");
      return;
    }
    setError("");
    setLoading(true);
    try {
      await api.post("academics/subjects/", {
        name: name.trim(),
        code: code.trim() || undefined,
      });
      navigate(-1);
    } catch (err) {
      console.error("Error creating subject:", err);
      setError(
        err?.response?.data?.detail ||
          "Failed to create subject. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <SchoolLayout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8 py-4 md:py-6">
        <div className="max-w-2xl mx-auto">
          <div className="bg-surface-container-lowest rounded-lg shadow-sm border border-outline-variant/10 p-6 sm:p-8">
            {/* Header */}
            <div className="flex items-start justify-between mb-6">
              <div className="flex items-center gap-3">
                <span className="material-symbols-outlined text-primary text-2xl">menu_book</span>
                <div>
                  <h2 className="text-xl font-headline font-bold text-on-surface">
                    Define New Subject
                  </h2>
                  <p className="text-sm text-on-surface-variant font-body mt-0.5">
                    Add a new academic subject to the institutional curriculum.
                  </p>
                </div>
              </div>
              <button
                onClick={() => navigate(-1)}
                className="flex items-center gap-1 text-sm text-on-surface-variant hover:text-primary transition-colors font-body border border-outline-variant/30 rounded px-3 py-1.5"
              >
                <span className="material-symbols-outlined text-base">arrow_back</span>
                Go Back
              </button>
            </div>

            {/* Error */}
            {error && (
              <div className="mb-4 px-4 py-3 rounded-lg bg-error/10 border border-error/20 text-error text-sm font-body flex items-center gap-2">
                <span className="material-symbols-outlined text-base">error</span>
                {error}
              </div>
            )}

            {/* Form */}
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* Subject Name */}
              <div>
                <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1.5 font-body">
                  Subject Name <span className="text-error">*</span>
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g., Advanced Mathematics"
                  className="w-full px-4 py-2.5 rounded-lg border border-outline-variant/30 bg-surface-container text-on-surface placeholder:text-outline text-sm font-body focus:outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary transition"
                />
              </div>

              {/* Subject Code */}
              <div>
                <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1.5 font-body">
                  Subject Code{" "}
                  <span className="text-outline font-normal normal-case">(Optional)</span>
                </label>
                <input
                  type="text"
                  value={code}
                  onChange={(e) => setCode(e.target.value)}
                  placeholder="e.g., MATH-401"
                  className="w-full px-4 py-2.5 rounded-lg border border-outline-variant/30 bg-surface-container text-on-surface placeholder:text-outline text-sm font-body focus:outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary transition"
                />
                <p className="text-xs text-on-surface-variant mt-1.5 font-body">
                  A short identifier used for reporting and timetable generation.
                </p>
              </div>

              {/* Actions */}
              <div className="flex justify-end gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => navigate(-1)}
                  className="px-5 py-2 text-sm font-semibold text-on-surface-variant hover:bg-surface-container-high rounded-lg transition font-body"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="flex items-center gap-2 px-5 py-2 bg-primary text-on-primary text-sm font-semibold rounded-lg hover:bg-primary/90 transition font-body disabled:opacity-60"
                >
                  <span className="material-symbols-outlined text-base">save</span>
                  {loading ? "Saving..." : "Save Subject"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </SchoolLayout>
  );
}