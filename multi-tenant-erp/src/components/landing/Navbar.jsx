import { Link } from "react-router-dom";

export default function Navbar() {
  return (
    <nav className="fixed top-0 w-full bg-white/80 backdrop-blur z-50 border-b">
      <div className="max-w-7xl mx-auto flex justify-between items-center lg:px-8 px-4 py-4">
        <h1 className="font-bold lg:text-xl">Academic Architect</h1>

        <div className="hidden md:flex gap-8 text-sm text-gray-600">
          <a href="#features">Features</a>
          <a href="#modules">Modules</a>
          <a href="#about">About</a>
          <a href="#contact">Contact</a>
        </div>

        <div className="flex items-center gap-6">
          <Link
            to="/login"
            className="text-[#2563eb] font-medium text-[15px] h-[42px] flex items-center"
          >
            Login
          </Link>

          <button className="h-[42px] lg:px-6 px-3 bg-[#3563e9] text-white rounded-lg font-medium shadow-sm hover:shadow-md transition">
            Request Demo
          </button>
        </div>
      </div>
    </nav>
  );
}
