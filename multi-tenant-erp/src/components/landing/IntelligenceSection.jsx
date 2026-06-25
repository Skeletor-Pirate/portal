export default function IntelligenceSection() {
  return (
    <section className="bg-[#eef2f7] lg:py-28 py-10">
      <div className="max-w-7xl mx-auto px-8">
        {/* heading */}
        <div className="text-center mb-20">
          <h2 className="text-[34px] font-semibold text-[#0b1c30]">
            Intelligence at Every Level
          </h2>

          <p className="text-[#6b7280] mt-4 max-w-2xl mx-auto">
            Our AI-first approach doesn't just store data; it understands it,
            helping your institution reach peak efficiency.
          </p>
        </div>

        <div className="grid grid-cols-3 gap-8">
          {/* ROW 1 */}

          {/* AI Teacher */}
          <div className="lg:col-span-2 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="w-12 h-12 bg-[#e8f0ff] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="22"
                height="22"
                fill="none"
                stroke="#2563eb"
                strokeWidth="2"
              >
                <circle cx="11" cy="11" r="9" />
                <path d="M11 7v4l3 2" />
              </svg>
            </div>

            <h3 className="font-semibold text-[18px] mb-3">
              AI Teacher Assistant
            </h3>

            <p className="text-[#6b7280] mb-6 max-w-lg">
              Generate high-quality lesson plans, interactive quizzes, and
              specialized worksheets automatically. Save hours of prep time
              every week.
            </p>

            <div className="flex gap-3">
              <span className="px-4 py-1 bg-[#e8f0ff] text-[#2563eb] rounded-full text-sm">
                Lesson Gen
              </span>

              <span className="px-4 py-1 bg-[#e8f0ff] text-[#2563eb] rounded-full text-sm">
                Quiz Master
              </span>
            </div>
          </div>

          {/* Student analytics */}
          <div className="lg:col-span-1 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="w-12 h-12 bg-[#f0e8ff] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="22"
                height="22"
                fill="none"
                stroke="#7c3aed"
                strokeWidth="2"
              >
                <path d="M4 14l4-4 4 3 6-6" />
              </svg>
            </div>

            <h3 className="font-semibold text-[18px] mb-3">
              Student Analytics
            </h3>

            <p className="text-[#6b7280]">
              Deep-dive into performance trends and identify hidden weak areas
              before they become obstacles.
            </p>
          </div>

          {/* ROW 2 */}

          {/* Automated assessment */}
          <div className="lg:col-span-1 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="w-12 h-12 bg-[#fff1e6] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="22"
                height="22"
                fill="none"
                stroke="#ea580c"
                strokeWidth="2"
              >
                <path d="M4 6h16M4 12h10M4 18h16" />
              </svg>
            </div>

            <h3 className="font-semibold text-[18px] mb-3">
              Automated Assessment
            </h3>

            <p className="text-[#6b7280]">
              AI evaluates open-ended answers and provides instant, constructive
              feedback to students.
            </p>
          </div>

          {/* center faded text */}
          <div className="lg:col-span-1 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="w-12 h-12 bg-[#eaffe6] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="22"
                height="22"
                viewBox="0 0 512 512"
                fill="rgb(15, 155, 0)"
              >
                <path d="M435.1 161.7a13.9 13.9 0 1 1 19.6-19.7 13.9 13.9 0 1 1 -19.6 19.7zM369.7 97.8c10.4 2.1 20.6 5.2 30.4 9.2 6.8 2.8 10.1 10.8 7.3 17.7-2.8 6.7-10.9 10.1-17.6 7.3-8.3-3.4-16.8-5.8-25.7-7.8-8.6-1.7-17.3-2.5-26-2.5-19.3 0-37.1-10.3-46.7-27-8.7-15.1-20.6-28.9-34.7-39.7-59.1-45.5-143.8-34.3-189.2 25-2.6 3.3-6.5 5.3-10.7 5.3-7.4 0-13.5-6.1-13.5-13.5 0-3.2 1.2-6.3 3.2-8.8 12.9-16.7 28.9-30.7 47.1-41.2 77.4-44.8 176.4-18.2 221.1 59.4 4.3 8.2 13.7 13.3 22.8 13.5 10.8 0 21.6 1 32.2 3.1zM35 270c4.6-8.2 4.6-18.2 0-26.4-21.9-36.5-27.3-82.3-16.3-123.2 1.6-5.9 6.9-10 13-10 8.7 0 15.3 8.7 13 17-9.5 35.4-3.4 71 13.7 102.9 9.3 16.5 9.3 36.7 0 53.1-8.7 15.7-14.8 32.4-17.2 50.3-9.7 73.9 42.3 141.7 116.2 151.4 7.3 1 12.6 7.9 11.6 15.2-1 7.3-7.8 12.6-15.1 11.6-21.1-2.8-41.4-9.7-59.8-20.3-75.6-43.6-104.9-145.8-59.2-221.5zM216.9 509c-7.4 2-15.1-2.4-17.1-9.8s2.5-15 9.9-16.9c8.5-2.2 17.4 4.5 17.4 13.4 0 6.2-4.2 11.6-10.2 13.3zm122.3-91c-9.5 0-18.4 5-23.2 13.2-4.9 9.4-11.7 18.2-18.7 26.2l0 0c-7.1 8-14.8 15.2-23.2 21.7-5.9 4.5-14.4 3.4-19-2.5s-3.4-14.4 2.5-18.9c7-5.4 13.5-11.5 19.4-18.1l0 0c5.9-6.6 11.1-13.8 15.5-21.6 9.7-16.7 27.5-27 46.8-27 17.8 0 35.4-3.5 51.8-10.3 68.3-28.3 101.1-108.3 73.2-176.5-.6-1.6-1-3.3-1-5 0-7.4 6.1-13.5 13.5-13.5 5.4 0 10.3 3.2 12.4 8.2 8.2 19.7 12.4 40.8 12.4 62.1 0 89.5-72.7 162.1-162.4 162.1l0 0zm-13.1-268c3.9-.4 7.9-.6 11.9-.6 59.3 0 108.2 48.7 108.2 107.8S397.3 365 338 365c-4 0-7.9-.2-11.8-.6-22.2-1.7-43.3 10.4-52.9 30.4-17.2 39.1-56.2 64.5-99.1 64.5-59.3 0-108.2-48.7-108.2-107.8 0-23.2 7.5-45.7 21.4-64.3 12.2-18.3 12.1-42.3-.4-60.5-13.6-18.5-20.9-40.8-20.9-63.7 0-59.1 48.8-107.8 108.2-107.8 42.8 0 81.8 25.4 99 64.4 9.6 20 30.7 32.1 52.9 30.4zM106.8 393.4c14.4 25.2 41.1 40.8 69.8 40.8 44.2 0 80.6-36.8 80.6-81.6s-36.4-81.6-80.6-81.6c-14.2 0-28.1 3.8-40.3 10.9-38.3 22.4-51.6 72.7-29.5 111.4zM268 298c14.4 25.2 41.1 40.8 69.8 40.8 44.2 0 80.6-36.8 80.6-81.6s-36.4-81.6-80.6-81.6c-14.2 0-28.1 3.8-40.3 10.9-38.3 22.4-51.6 72.7-29.5 111.4zm-91.2-54.6c44.2 0 80.5-36.8 80.5-81.6s-36.4-81.6-80.6-81.6-80.6 36.8-80.6 81.6c0 44.7 36.4 81.6 80.6 81.6z" />
              </svg>
            </div>

            <h3 className="font-semibold text-lg">Unified ERP Platform</h3>

            <p className="text-[#6b7280] text-sm mt-2 lg:max-w-xs">
              One source of truth for your entire school. Manage students,
              teachers, classes, attendance, and grades within a single, sleek
              interface built for the 21st century.
            </p>
          </div>

          <div></div>

          {/* ROW 3 */}

          {/* speech */}
          <div className="lg:col-span-1 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)]">
            <div className="w-12 h-12 bg-[#e8f0ff] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="22"
                height="22"
                fill="none"
                stroke="#2563eb"
                strokeWidth="2"
              >
                <path d="M4 4h16v12H7l-3 3V4z" />
              </svg>
            </div>

            <h3 className="font-semibold text-[18px] mb-3">
              Speech & Multilingual AI
            </h3>

            <p className="text-[#6b7280]">
              Voice-enabled interaction and seamless multilingual content
              support for diverse learning environments.
            </p>
          </div>

          {/* recommendation */}
          <div className="lg:col-span-2 col-span-3 bg-white rounded-2xl p-10 shadow-[0_2px_12px_rgba(0,0,0,0.04)] relative overflow-hidden">
            <div className="w-12 h-12 bg-[#f0e8ff] rounded-xl flex items-center justify-center mb-6">
              <svg
                width="20"
                height="20"
                fill="none"
                stroke="#7c3aed"
                strokeWidth="2"
              >
                <polygon points="10,2 12,8 18,8 13,12 15,18 10,14 5,18 7,12 2,8 8,8" />
              </svg>
            </div>
            <h3 className="font-semibold text-[18px] mb-3">
              Recommendation Engine
            </h3>

            <p className="text-[#6b7280] max-w-lg">
              Personalized learning suggestions based on individual student
              performance, ensuring no one is left behind.
            </p>

            {/* decorative purple shape */}
          </div>
        </div>
      </div>
    </section>
  );
}
