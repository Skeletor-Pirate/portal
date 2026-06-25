import { Link } from "react-router-dom";

export default function Hero() {
  return (
    <section className="pt-[100px] lg:pt-28 lg:pb-24 pb-10 bg-[#f5f7fb] ">
      <div className="max-w-7xl mx-auto px-8 grid lg:grid-cols-2 lg:gap-20 gap-8 items-center">
        {/* LEFT */}
        <div>
          {/* badge */}
          <div className="inline-flex items-center gap-2 bg-[#e9efff] text-[#3563e9] px-4 py-1 lg:py-1.5 rounded-full text-xs font-semibold tracking-wide lg:mb-8 mb-5">
            <span>✦</span>
            THE FUTURE OF PEDAGOGY
          </div>

          {/* heading */}
          <h1 className="lg:text-[72px] text-[34px] leading-[1.05] font-extrabold text-[#0b1c30] tracking-tight">
            AI Powered
            <br />
            School ERP for
            <br />
            <span className="text-[#3563e9]">Modern Education</span>
          </h1>

          {/* description */}
          <p className="text-[#4b5563] lg:text-lg mt-6 max-w-xl leading-relaxed">
            An intelligent platform for schools, teachers, students, and parents
            with automation, analytics, and personalized learning support.
          </p>

          {/* buttons */}
          <div className="flex gap-4 mt-10">
            <Link to="/login">
              <button className="lg:px-8 px-4 lg:py-4 py-3 bg-[#2563eb] text-white rounded-xl">
                Login
              </button>
            </Link>

            <button className="bg-[#e3e9f7] text-[#3563e9] lg:px-8 px-4 py-3 rounded-lg font-semibold">
              View Features
            </button>
          </div>
        </div>

        {/* RIGHT IMAGE */}
        <div className="relative">
          {/* frame */}
          <div className="bg-white rounded-[26px] p-[18px] overflow-hidden">
            <img
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuD0v5yT4zL3gtXuW8rd-v682H_1Qw7G6azvelfkyBmISMIAAOF073133HQ-cUl4KkVO-ckgBPpjPdAcIVIAkQS-UQIq6PDH4p-mX6gxPBY2usGupgvLj48Jfpm5oQP-wPH52N5ZXPE-T7IQgWqP3nxY4pjY8L6fKMvH2JA_MPgvdP5GQGQjsmnhekY8szWIh7BF68Ng5HBEC8M9U0n6l3XpSayo_X9RRWtnMdyp-XrJxAs5ljWLeaOa0YLcdKwKbM3sD87jxAJWVA"
              className="w-full h-full object-cover rounded-[22px] scale-[1.02]"
            />

            {/* insight card */}
            <div className="absolute top-6 right-7 bg-white px-4 py-3 rounded-xl shadow-sm border border-gray-200 w-[230px]">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-[#f59e0b] text-sm">↗</span>

                <span className="text-[14px] font-semibold text-[#0b1c30]">
                  AI Insight
                </span>
              </div>

              <p className="text-[12px] text-gray-500 leading-snug">
                Student retention is predicted to increase by 12% next term
                based on engagement trends.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}