enum UserRole { global, admin, teacher, student, parent, accountant }

class RoleConfig {
  final String label;
  final String id;
  final String name;
  final String school;
  final String idLabel;
  final String avatarAsset;
  final List<NavItem> nav;
  final List<NavItem> bottom;

  const RoleConfig({
    required this.label,
    required this.id,
    required this.name,
    required this.school,
    required this.idLabel,
    required this.avatarAsset,
    required this.nav,
    required this.bottom,
  });
}

class NavItem {
  final String id;
  final String label;
  final String iconName;

  const NavItem({required this.id, required this.label, required this.iconName});
}

const Map<UserRole, RoleConfig> kRoles = {
  UserRole.global: RoleConfig(
    label: 'Global Platform Administrator',
    id: 'GA',
    name: 'Jordan Wells',
    school: 'EduCore Platform',
    idLabel: 'Platform ID: #0001',
    avatarAsset: 'assets/avatars/admin.png',
    nav: [
      NavItem(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard'),
      NavItem(id: 'schools', label: 'Schools', iconName: 'schools'),
      NavItem(id: 'domains', label: 'Domains', iconName: 'domains'),
      NavItem(id: 'sysconfig', label: 'System Config', iconName: 'sysconfig'),
      NavItem(id: 'profile', label: 'Profile & Settings', iconName: 'profile'),
    ],
    bottom: [
      NavItem(id: 'dashboard', label: 'Overview', iconName: 'dashboard'),
      NavItem(id: 'schools', label: 'Schools', iconName: 'schools'),
      NavItem(id: 'domains', label: 'Domains', iconName: 'domains'),
      NavItem(id: 'sysconfig', label: 'Config', iconName: 'sysconfig'),
      NavItem(id: 'profile', label: 'Profile', iconName: 'profile'),
    ],
  ),
  UserRole.admin: RoleConfig(
    label: 'School Administrator',
    id: 'SA',
    name: 'Dr. Chris Patel',
    school: 'Westfield Academy',
    idLabel: 'Admin ID: #WA-0012',
    avatarAsset: 'assets/avatars/admin.png',
    nav: [
      NavItem(id: 'dashboard',   label: 'Dashboard',              iconName: 'dashboard'),
      NavItem(id: 'academic',    label: 'Academic Setup',          iconName: 'academic'),
      NavItem(id: 'enrollments', label: 'Enrollments',             iconName: 'enrollments'),
      NavItem(id: 'assignments', label: 'Teacher Assignments',     iconName: 'assignments'),
      NavItem(id: 'users',       label: 'Roles & Permissions',     iconName: 'users'),
      NavItem(id: 'students',    label: 'Students',                iconName: 'students'),
      NavItem(id: 'teachers',    label: 'Teachers',                iconName: 'teachers'),
      NavItem(id: 'parents',     label: 'Parents',                 iconName: 'parents'),
      NavItem(id: 'mapping',     label: 'Parent–Student Mapping',  iconName: 'mapping'),
      NavItem(id: 'grading',     label: 'Grading Bands',           iconName: 'grading'),
      NavItem(id: 'profile',     label: 'Settings',                iconName: 'profile'),
    ],
    bottom: [
      NavItem(id: 'dashboard',   label: 'Dash',      iconName: 'dashboard'),
      NavItem(id: 'students',    label: 'Students',  iconName: 'students'),
      NavItem(id: 'teachers',    label: 'Teachers',  iconName: 'teachers'),
      NavItem(id: 'academic',    label: 'Academic',  iconName: 'academic'),
      NavItem(id: 'profile',     label: 'Profile',   iconName: 'profile'),
    ],
  ),
  UserRole.teacher: RoleConfig(
    label: 'Senior Faculty · Science',
    id: 'TR',
    name: 'Dr. Elena Vance',
    school: 'Westfield Academy',
    idLabel: 'Faculty ID: #WA-T-042',
    avatarAsset: 'assets/avatars/teacher.png',
    nav: [
      NavItem(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard'),
      NavItem(id: 'classes', label: 'My Classes', iconName: 'classes'),
      NavItem(id: 'attendance', label: 'Attendance', iconName: 'attendance'),
      NavItem(id: 'grades', label: 'Grades', iconName: 'grades'),
      NavItem(id: 'aitools', label: 'AI Tools', iconName: 'aitools'),
    ],
    bottom: [
      NavItem(id: 'dashboard', label: 'Dash', iconName: 'dashboard'),
      NavItem(id: 'classes', label: 'Classes', iconName: 'classes'),
      NavItem(id: 'attendance', label: 'Attend', iconName: 'attendance'),
      NavItem(id: 'grades', label: 'Grades', iconName: 'grades'),
      NavItem(id: 'aitools', label: 'AI Tools', iconName: 'aitools'),
    ],
  ),
  UserRole.student: RoleConfig(
    label: 'Grade 11-B',
    id: 'ST',
    name: 'Alex Rivers',
    school: 'Westfield Academy',
    idLabel: 'ID: 20240912',
    avatarAsset: 'assets/avatars/student.png',
    nav: [
      NavItem(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard'),
      NavItem(id: 'subjects', label: 'My Subjects', iconName: 'subjects'),
      NavItem(id: 'materials', label: 'Learning Materials', iconName: 'materials'),
      NavItem(id: 'assignments', label: 'Assignments', iconName: 'assignments'),
      NavItem(id: 'grades', label: 'Grades & Report Card', iconName: 'grades'),
      NavItem(id: 'attendance', label: 'Attendance', iconName: 'attendance'),
      NavItem(id: 'timetable', label: 'Timetable', iconName: 'timetable'),
      NavItem(id: 'profile', label: 'Profile & Settings', iconName: 'profile'),
    ],
    bottom: [
      NavItem(id: 'dashboard', label: 'Dash', iconName: 'dashboard'),
      NavItem(id: 'subjects', label: 'Subjects', iconName: 'subjects'),
      NavItem(id: 'assignments', label: 'Tasks', iconName: 'assignments'),
      NavItem(id: 'grades', label: 'Grades', iconName: 'grades'),
      NavItem(id: 'profile', label: 'Profile', iconName: 'profile'),
    ],
  ),
  UserRole.parent: RoleConfig(
    label: 'Guardian',
    id: 'PR',
    name: 'Alexander Pierce',
    school: 'Westfield Academy',
    idLabel: 'Guardian ID: #8821',
    avatarAsset: 'assets/avatars/parent.png',
    nav: [
      NavItem(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard'),
      NavItem(id: 'childoverview', label: 'Child Overview', iconName: 'childoverview'),
      NavItem(id: 'attendance', label: 'Attendance', iconName: 'attendance'),
      NavItem(id: 'assignments', label: 'Assignments', iconName: 'assignments'),
      NavItem(id: 'grades', label: 'Grades & Report Card', iconName: 'grades'),
      NavItem(id: 'payments', label: 'Payments', iconName: 'payments'),
      NavItem(id: 'insights', label: 'AI Insights', iconName: 'insights'),
      NavItem(id: 'profile', label: 'Settings', iconName: 'profile'),
    ],
    bottom: [
      NavItem(id: 'dashboard', label: 'Dash', iconName: 'dashboard'),
      NavItem(id: 'childoverview', label: 'Child', iconName: 'childoverview'),
      NavItem(id: 'grades', label: 'Grades', iconName: 'grades'),
      NavItem(id: 'payments', label: 'Pay', iconName: 'payments'),
      NavItem(id: 'profile', label: 'Profile', iconName: 'profile'),
    ],
  ),
  UserRole.accountant: RoleConfig(
    label: 'Finance Department',
    id: 'AC',
    name: 'Leon Burke',
    school: 'Westfield Academy',
    idLabel: 'Staff ID: #WA-F-007',
    avatarAsset: 'assets/avatars/accountant.png',
    nav: [
      NavItem(id: 'dashboard', label: 'Dashboard', iconName: 'dashboard'),
      NavItem(id: 'invoices', label: 'Invoices', iconName: 'invoices'),
      NavItem(id: 'feestructure', label: 'Fee Structure', iconName: 'feestructure'),
      NavItem(id: 'reconcile', label: 'Reconcile Payments', iconName: 'reconcile'),
      NavItem(id: 'manualpay', label: 'Manual Payment', iconName: 'manualpay'),
      NavItem(id: 'authorize', label: 'Authorize Transactions', iconName: 'authorize'),
      NavItem(id: 'reports', label: 'Financial Reports', iconName: 'reports'),
      NavItem(id: 'profile', label: 'Settings', iconName: 'profile'),
    ],
    bottom: [
      NavItem(id: 'dashboard', label: 'Dash', iconName: 'dashboard'),
      NavItem(id: 'invoices', label: 'Invoices', iconName: 'invoices'),
      NavItem(id: 'feestructure', label: 'Fees', iconName: 'feestructure'),
      NavItem(id: 'reconcile', label: 'Reconcile', iconName: 'reconcile'),
      NavItem(id: 'profile', label: 'Profile', iconName: 'profile'),
    ],
  ),
};
