import { Link } from "react-router-dom";

export default function CTASection() {
  return (
    <section className="bg-[#f5f7fb] lg:py-28 py-10">
      <div className="max-w-6xl mx-auto px-6">
        <div className="relative bg-white rounded-[28px] lg:px-16 px-8 lg:py-20 py-10 text-center shadow-[0_10px_30px_rgba(0,0,0,0.04)] overflow-hidden">
          {/* decorative curved corner */}
          <div className="absolute top-0 right-0 lg:w-40 lg:h-40 bg-[#eef2f7] lg:rounded-bl-[150px]"></div>

          <h2 className="lg:text-[38px] text-[32px] leading-[1.2] font-semibold text-[#0b1c30] mb-6 max-w-3xl mx-auto">
            Start using AI Powered Education Platform today
          </h2>

          <p className="text-[#6b7280] text-[16px] mb-10 max-w-xl mx-auto leading-relaxed">
            Join thousands of forward-thinking institutions that are redefining
            the educational landscape with Academic Architect.
          </p>

          <div className="flex justify-center gap-4">
            <Link to="/login">
              <button className="lg:px-8 px-4 py-3 bg-[#2563eb] text-white rounded-xl font-medium shadow-sm hover:bg-[#1f4ed8] transition">
                Login
              </button>
            </Link>

            <button className="lg:px-8 px-3 py-3 bg-[#e9efff] text-[#2563eb] rounded-xl font-medium hover:bg-[#dfe7ff] transition">
              Request Demo
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}