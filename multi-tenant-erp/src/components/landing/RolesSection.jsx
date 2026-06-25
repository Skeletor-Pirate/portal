export default function RolesSection() {
  return (
    <section className="bg-[#f5f7fb] lg:py-24 py-10">
      <div className="max-w-7xl mx-auto px-8 grid md:grid-cols-2 lg:grid-cols-4 gap-8">
        {/* School Admin */}
        <div className="bg-white rounded-2xl p-8 shadow-[0_2px_10px_rgba(0,0,0,0.04)]">
          <div className="w-12 h-12 bg-[#eaf1ff] rounded-xl flex items-center justify-center mb-6">
            <svg
              width="24"
              height="24"
              fill="none"
              stroke="#2563eb"
              strokeWidth="2"
            >
              <path d="M12 2l7 4v6c0 5-3.5 9-7 10-3.5-1-7-5-7-10V6l7-4z" />
              <circle cx="12" cy="11" r="2" />
            </svg>
          </div>

          <h3 className="text-[18px] font-semibold text-[#0b1c30] mb-2">
            School Admin
          </h3>

          <p className="text-[#6b7280] text-[14px] leading-relaxed">
            Oversee institutional growth with high-level data dashboards and
            financial automation.
          </p>
        </div>

        {/* Teacher */}
        <div className="bg-white rounded-2xl p-8 shadow-[0_2px_10px_rgba(0,0,0,0.04)]">
          <div className="w-12 h-12 bg-[#eaf1ff] rounded-xl flex items-center justify-center mb-6">
            <svg
              width="24"
              height="24"
              fill="none"
              stroke="#2563eb"
              strokeWidth="2"
            >
              <path d="M12 3L2 9l10 6 10-6-10-6z" />
              <path d="M2 9v6l10 6 10-6V9" />
            </svg>
          </div>

          <h3 className="text-[18px] font-semibold text-[#0b1c30] mb-2">
            Teacher
          </h3>

          <p className="text-[#6b7280] text-[14px] leading-relaxed">
            Focus on teaching, not paperwork. Let AI handle lesson plans and
            grading logistics.
          </p>
        </div>

        {/* Student */}
        <div className="bg-white rounded-2xl p-8 shadow-[0_2px_10px_rgba(0,0,0,0.04)]">
          <div className="w-12 h-12 bg-[#eaf1ff] rounded-xl flex items-center justify-center mb-6">
            <svg
              width="24"
              height="24"
              fill="none"
              stroke="#2563eb"
              strokeWidth="2"
            >
              <circle cx="12" cy="7" r="4" />
              <path d="M5.5 21a6.5 6.5 0 0113 0" />
            </svg>
          </div>

          <h3 className="text-[18px] font-semibold text-[#0b1c30] mb-2">
            Student
          </h3>

          <p className="text-[#6b7280] text-[14px] leading-relaxed">
            Experience a personalized learning path with 24/7 AI tutor support
            and clear goals.
          </p>
        </div>

        {/* Parent */}
        <div className="bg-white rounded-2xl p-8 shadow-[0_2px_10px_rgba(0,0,0,0.04)]">
          <div className="w-12 h-12 bg-[#eaf1ff] rounded-xl flex items-center justify-center mb-6">
            <svg
              width="24"
              height="24"
              fill="none"
              stroke="#2563eb"
              strokeWidth="2"
            >
              <circle cx="9" cy="7" r="4" />
              <circle cx="17" cy="7" r="4" />
              <path d="M2 21a7 7 0 0114 0" />
              <path d="M10 21a7 7 0 0114 0" />
            </svg>
          </div>

          <h3 className="text-[18px] font-semibold text-[#0b1c30] mb-2">
            Parent
          </h3>

          <p className="text-[#6b7280] text-[14px] leading-relaxed">
            Stay connected to your child's progress with real-time updates and
            simplified communication.
          </p>
        </div>
      </div>
    </section>
  );
}
