export default function Footer() {
  return (
    <footer className="bg-[#eef3ff] lg:py-14 py-6">
      <div className="lg:max-w-7xl mx-auto px-8 flex lg:flex-row flex-col lg:justify-between items-center">
        <div className="flex flex-col items-center">
          <h3 className="font-bold">Academic Architect</h3>

          <p className="text-sm text-gray-500">&copy;2024 Academic Architect</p>
        </div>

        <div className="flex gap-6 lg:pt-0 pt-4 text-sm text-gray-500">
          <span>Privacy Policy</span>
          <span>Terms</span>
          <span>Security</span>
        </div>
      </div>
    </footer>
  );
}
