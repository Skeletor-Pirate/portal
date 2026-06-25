import React, { useState } from 'react';
import Sidebar from "./Sidebar";
import TopAppBar from "./TopAppBar";
import MobileNav from "./MobileNav";
const MainLayout = ({ children, title }) => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  return (
    <div className="bg-surface font-body text-sm text-on-surface antialiased min-h-screen overflow-x-hidden">
      <div className={`fixed inset-y-0 left-0 z-50 transition-all duration-300 ease-in-out ${
        isSidebarOpen
          ? "w-64 translate-x-0 opacity-100"
          : "w-0 -translate-x-full opacity-0 pointer-events-none overflow-hidden"
      }`}>
        <Sidebar />
      </div>

      <main className={`min-h-screen flex flex-col pb-20 md:pb-0 transition-all duration-300 ease-in-out ${
        isSidebarOpen ? "md:ml-64" : "md:ml-0"
      }`}>
        <TopAppBar
          title={title}
          isSidebarOpen={isSidebarOpen}
          onToggleSidebar={() => setIsSidebarOpen((open) => !open)}
        />
        <div className="p-4 md:p-6 max-w-7xl mx-auto w-full flex-grow">
          {children}
        </div>
      </main>
      
      <MobileNav />
    </div>
  );
};

export default MainLayout;
