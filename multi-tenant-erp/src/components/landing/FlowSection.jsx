export default function FlowSection() {
  return (
    <section className="bg-[#071c2f] text-white lg:py-24 py-10">
      <div className="max-w-7xl mx-auto px-8">
        <h2 className="text-center text-[30px] font-bold mb-20">
          Seamless Integration Flow
        </h2>

        <div className="relative">
          {/* connecting line */}
          <div className="hidden lg:block absolute top-5 left-0 w-full h-[1px] bg-white/20"></div>

          <div className="grid md:grid-cols-4 gap-16 relative">
            {[
              {
                title: "Login securely",
                desc: "Enterprise-grade SSO and multi-factor authentication for total data peace of mind.",
              },

              {
                title: "Role detection",
                desc: "Our system instantly identifies your role and configures your workspace environment.",
              },

              {
                title: "Personalized dashboard",
                desc: "Widgets, news, and tasks curated specifically for your daily requirements.",
              },

              {
                title: "AI tools access",
                desc: "One-click access to lesson generation, predictive analytics, and multilingual tools.",
              },
            ].map((item, i) => (
              <div key={i} className="relative">
                {/* number circle */}
                <div className="w-11 h-11 border border-white/40 rounded-full flex items-center justify-center mb-6 text-sm font-medium bg-[#071c2f] relative z-10">
                  {i + 1}
                </div>

                <h4 className="text-[18px] font-semibold mb-3">{item.title}</h4>

                <p className="text-white/70 text-[14px] leading-relaxed max-w-[260px]">
                  {item.desc}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
