import React, { useState, useEffect } from "react";
import SchoolLayout from "../../components/erp/school/SchoolLayout";
import { useNavigate } from "react-router-dom";
import api from "../../services/axiosClient";

export default function CreateSection() {
  const navigate = useNavigate();

  const [classLevels, setClassLevels] = useState([]);
  const [classLevelId, setClassLevelId] = useState("");
  const [sectionName, setSectionName] = useState("");
  const [loadingLevels, setLoadingLevels] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchClassLevels = async () => {
      try {
        const res = await api.get("academics/class-levels/");
        const data = res.data.results ?? res.data;
        setClassLevels(Array.isArray(data) ? data : []);
      } catch (err) {
        console.error("Failed to fetch class levels:", err);
        setError("Could not load class levels. Please refresh and try again.");
      } finally {
        setLoadingLevels(false);
      }
    };
    fetchClassLevels();
  }, []);

  const selectedLevel = classLevels.find(
    (cl) => String(cl.id) === String(classLevelId)
  );

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!classLevelId) {
      setError("Please select a parent class level.");
      return;
    }
    if (!sectionName.trim()) {
      setError("Section identifier is required.");
      return;
    }
    setError("");
    setSubmitting(true);
    try {
      await api.post("academics/sections/", {
        class_level: classLevelId,
        name: sectionName.trim(),
      });
      navigate(-1);
    } catch (err) {
      console.error("Error creating section:", err);
      setError(
        err?.response?.data?.detail ||
          "Failed to create section. Please try again."
      );
    } finally {
      setSubmitting(false);
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
                <span className="material-symbols-outlined text-secondary text-2xl">groups</span>
                <div>
                  <h2 className="text-xl font-headline font-bold text-on-surface">
                    Define New Section
                  </h2>
                  <p className="text-sm text-on-surface-variant font-body mt-0.5">
                    Establish a specific classroom division linked to a primary Class Level.
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
              {/* Parent Class Level */}
              <div>
                <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1.5 font-body">
                  Parent Class Level <span className="text-error">*</span>
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-outline text-base pointer-events-none">
                    meeting_room
                  </span>
                  <select
                    value={classLevelId}
                    onChange={(e) => setClassLevelId(e.target.value)}
                    disabled={loadingLevels}
                    className="w-full pl-9 pr-4 py-2.5 rounded-lg border border-outline-variant/30 bg-surface-container text-on-surface text-sm font-body focus:outline-none focus:ring-2 focus:ring-secondary/40 focus:border-secondary transition appearance-none disabled:opacity-60"
                  >
                    <option value="">
                      {loadingLevels ? "Loading..." : "Select Base Class Level..."}
                    </option>
                    {classLevels.map((cl) => (
                      <option key={cl.id} value={cl.id}>
                        {cl.name}
                      </option>
                    ))}
                  </select>
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-outline text-base pointer-events-none">
                    expand_more
                  </span>
                </div>
              </div>

              {/* Section Identifier */}
              <div>
                <label className="block text-xs font-semibold text-on-surface-variant uppercase tracking-wider mb-1.5 font-body">
                  Section Identifier <span className="text-error">*</span>
                </label>
                <input
                  type="text"
                  value={sectionName}
                  onChange={(e) => setSectionName(e.target.value)}
                  placeholder="e.g., Section A, Batch Alpha, Honors"
                  className="w-full px-4 py-2.5 rounded-lg border border-outline-variant/30 bg-surface-container text-on-surface placeholder:text-outline text-sm font-body focus:outline-none focus:ring-2 focus:ring-secondary/40 focus:border-secondary transition"
                />
                <p className="text-xs text-on-surface-variant mt-1.5 font-body">
                  Combined together, this will read as "
                  <span className="font-semibold text-on-surface">
                    {selectedLevel?.name || "[Class Level]"}
                  </span>{" "}
                  -{" "}
                  <span className="font-semibold text-on-surface">
                    {sectionName.trim() || "[Section]"}
                  </span>
                  " in the frontend.
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
                  disabled={submitting || loadingLevels}
                  className="flex items-center gap-2 px-5 py-2 bg-green-600 text-white text-sm font-semibold rounded-lg hover:bg-green-700 transition font-body disabled:opacity-60"
                >
                  <span className="material-symbols-outlined text-base">add_circle</span>
                  {submitting ? "Creating..." : "Create Section"}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </SchoolLayout>
  );
}