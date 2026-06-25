import { useNavigate, useLocation } from "react-router-dom";

export default function SchoolSidebar() {
  const navigate = useNavigate();
  const location = useLocation();
  const currentPath = location.pathname;

  /* reusable menu styling with semantic classes + dark mode */
  const getClass = (route) => `
    flex items-center gap-3 px-4 py-3 mx-2 rounded-lg cursor-pointer transition-all duration-200
    ${currentPath === route
      ? "bg-white text-primary font-semibold shadow-sm dark:bg-surface-container-high dark:text-primary"
      : "text-on-surface-variant hover:bg-surface-container-low dark:text-on-surface-variant dark:hover:bg-surface-container-low"
    }
  `;

  /* sidebar menu config */
  const menu = [
    { name: "Dashboard", icon: "dashboard", path: "/school-admin" },
    { name: "Academic Years", icon: "calendar_today", path: "/school-admin/academic-years" },
    { name: "Roles & Permissions", icon: "security", path: "/school-admin/roles" },
    { name: "Students", icon: "school", path: "/school-admin/students" },
    { name: "Teachers", icon: "person_4", path: "/school-admin/teachers" },
    { name: "Enrollments", icon: "how_to_reg", path: "/school-admin/enrollments" },
    { name: "Parents", icon: "group", path: "/school-admin/parents" },
    { name: "Parent-Student Mapping", icon: "diversity_1", path: "/school-admin/mapping" },
    { name: "Teacher Assignment", icon: "assignment_ind", path: "/school-admin/teacher-assignment" },
    { name: "Settings", icon: "settings", path: "/school-admin/settings" }
  ];

  const handleLogout = () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user_data');
    navigate('/');
  };

  return (
    <aside className="h-screen w-64 fixed left-0 top-0 bg-surface-container-low border-r border-outline-variant/10 flex flex-col py-6">
      {/* logo */}
      <div className="px-6 mb-10">
        <h1 className="text-xl font-headline font-bold text-primary tracking-tight">
          Academic Architect
        </h1>
      </div>

      {/* navigation */}
      <nav className="space-y-1 flex-1">
        {menu.map((item) => (
          <div
            key={item.path}
            onClick={() => navigate(item.path)}
            className={getClass(item.path)}
          >
            <span className="material-symbols-outlined">{item.icon}</span>
            {item.name}
          </div>
        ))}
      </nav>

      {/* Logout */}
      <div className="px-2 pb-2">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-4 py-3 mx-2 rounded-lg cursor-pointer transition-all duration-200 text-error hover:text-error/90 hover:bg-error/10 w-full text-left font-semibold text-sm"
        >
          <span className="material-symbols-outlined">logout</span>
          Log Out
        </button>
      </div>
    </aside>
  );
}
