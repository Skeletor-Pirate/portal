import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';
import '../../services/app_store.dart';

class AdminPages extends StatelessWidget {
  final String page;
  const AdminPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':  return const _Dashboard();
      case 'students':   return const _Students();
      case 'teachers':   return const _Teachers();
      case 'users':      return const _Users();
      case 'academic':   return const _Academic();
      case 'grading':    return const _Grading();
      case 'mapping':    return const _Mapping();
      case 'parents':    return const _Parents();
      case 'enrollments':return const _Enrollments();
      case 'assignments':return const _TeacherAssignments();
      default:           return defaultPage(page);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  int _studentCount = 0;
  int _teacherCount = 0;
  int _parentCount  = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
    try {
      final results = await Future.wait([
        ApiService().getMyProfile(),
        ApiService().getStudents(),
        ApiService().getTeachers(),
        ApiService().getParents(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile      = results[0] as ProfileMe;
        _studentCount = (results[1] as PaginatedResult<StudentProfile>).count;
        _teacherCount = (results[2] as PaginatedResult<TeacherProfile>).count;
        _parentCount  = (results[3] as PaginatedResult<ParentProfile>).count;
        _loading      = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final cfg    = kRoles[UserRole.admin]!;
    final store  = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : (_profile?.displayName ?? cfg.name);
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : (_profile?.schoolName ?? 'Your School');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'School Administrator', cfg.idLabel),
      pageTitle('Dashboard', subtitle: '$school · Admin Portal'),
      if (_loading)
        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (!_loading) statGrid([
        StatItem(icon: Icons.school_rounded,     iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: _fmt(_studentCount), label: 'Students',  delta: 0),
        StatItem(icon: Icons.menu_book_rounded,  iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: '$_teacherCount',    label: 'Teachers',  delta: 0),
        StatItem(icon: Icons.group_rounded,      iconBg: AppColors.greenLight, iconColor: AppColors.green, val: _fmt(_parentCount),  label: 'Parents',   delta: 0),
        StatItem(icon: Icons.fact_check_rounded, iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '—',                 label: 'Attendance · Today', delta: null),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.person_add_rounded,     label: 'Add Student',   bg: AppColors.blueLight,  iconColor: AppColors.blue,  onTap: () => showAddStudent(context, onDone: _loadData)),
        ActionItem(icon: Icons.add_card_rounded,       label: 'Add Teacher',   bg: AppColors.tealLight,  iconColor: AppColors.teal,  onTap: () => showAddTeacher(context, onDone: _loadData)),
        ActionItem(icon: Icons.how_to_reg_rounded,     label: 'Add Parent',    bg: AppColors.greenLight, iconColor: AppColors.green, onTap: () => showAddParent(context, onDone: _loadData)),
        ActionItem(icon: Icons.verified_user_rounded,  label: 'Roles',         bg: AppColors.amberLight, iconColor: AppColors.amber, onTap: () => showCreateRole(context, onDone: _loadData)),
        ActionItem(icon: Icons.calendar_month_rounded, label: 'Academic Yr',   bg: AppColors.blueLight,  iconColor: AppColors.blue,  onTap: () => showAddAcademicYear(context, onDone: _loadData)),
        ActionItem(icon: Icons.trending_up_rounded,    label: 'Bulk Promote',  bg: AppColors.tealLight,  iconColor: AppColors.teal,  onTap: () => showBulkPromote(context, onDone: _loadData)),
      ]),
      secLabel('Recent Activity'),
      ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: AppStore.instance.recentActivity,
        builder: (ctx, acts, _) => appCard(Padding(padding: const EdgeInsets.all(16), child: timeline(
          acts.take(6).toList().asMap().entries.map((e) {
            final colors = [AppColors.blue, AppColors.teal, AppColors.green, AppColors.amber, AppColors.navy, AppColors.red];
            return TlItem(title: e.value['title']!, sub: e.value['sub']!, time: e.value['time']!, color: colors[e.key % colors.length]);
          }).toList(),
        ))),
      ),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDENTS — live API with search
// ─────────────────────────────────────────────────────────────────────────────

class _Students extends StatefulWidget {
  const _Students();
  @override
  State<_Students> createState() => _StudentsState();
}

class _StudentsState extends State<_Students> {
  List<StudentProfile> _students = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load({String? search}) async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getStudents(search: search);
      if (mounted) setState(() { _students = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _delete(StudentProfile s) async {
    final ok = await confirmDialog(context,
        title: 'Archive Student',
        body: 'Archive ${s.fullName}? Their records will be preserved.',
        confirm: 'Archive');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteStudent(s.id);
      AppStore.instance.prependActivity('Student Archived', s.fullName);
      showToast(context, '${s.fullName} archived');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Students'),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rLg), boxShadow: shadowSm),
          child: Row(children: [
            const Icon(Icons.search_rounded, size: 16, color: AppColors.text4),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) => _load(search: v.trim()),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
              decoration: InputDecoration(hintText: 'Search by name…', hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            )),
            if (_loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue)),
          ]),
        ),
      ),
      if (_error != null) _apiError(_error!),
      appCard(Column(children: [
        if (_students.isEmpty && !_loading)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No students found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
        ..._students.map((s) {
          final initials = s.fullName.split(' ').where((x) => x.isNotEmpty).map((x) => x[0]).join('');
          return GestureDetector(
            onLongPress: () => _delete(s),
            child: listItem(
              avIcon: Icons.person_rounded, avBg: AppColors.avNavy, avColor: AppColors.navy,
              avInitials: initials, name: s.fullName,
              sub: 'ID: ${s.enrollmentNumber ?? "—"}${s.isArchived ? " · Archived" : ""}',
              badgeText: s.isArchived ? 'Archived' : 'Active',
              badgeBg: s.isArchived ? const Color(0xFFF1F5F9) : AppColors.greenLight,
              badgeColor: s.isArchived ? AppColors.text3 : AppColors.green,
            ),
          );
        }),
      ])),
      if (_students.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
          child: Text('Long-press a student to archive · ${_students.length} shown',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
        ),
      Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Create Student Profile', onTap: () => showAddStudent(context, onDone: _load))),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEACHERS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Teachers extends StatefulWidget {
  const _Teachers();
  @override
  State<_Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<_Teachers> {
  List<TeacherProfile> _teachers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getTeachers();
      if (mounted) setState(() { _teachers = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _delete(TeacherProfile t) async {
    final ok = await confirmDialog(context, title: 'Remove Teacher', body: 'Remove ${t.fullName}? This will delete their profile.', confirm: 'Remove');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteTeacher(t.id);
      AppStore.instance.prependActivity('Teacher Removed', t.fullName);
      showToast(context, '${t.fullName} removed');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Teachers'),
    searchBar(placeholder: 'Search teachers…'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_teachers.isEmpty && !_loading)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No teachers found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._teachers.map((t) {
        final initial = t.fullName.isNotEmpty ? t.fullName[0] : 'T';
        return GestureDetector(
          onLongPress: () => _delete(t),
          child: listItem(
            avIcon: Icons.person_rounded, avBg: AppColors.avTeal, avColor: AppColors.teal,
            avInitials: initial,
            name: t.fullName,
            sub: '${t.qualification ?? "Faculty"} · ID: ${t.employeeId ?? "—"}',
            badgeText: 'Active', badgeBg: AppColors.tealLight, badgeColor: AppColors.teal,
          ),
        );
      }),
    ])),
    if (_teachers.isNotEmpty)
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to remove · ${_teachers.length} shown', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Create Teacher Profile', onTap: () => showAddTeacher(context, onDone: _load))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// PARENTS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Parents extends StatefulWidget {
  const _Parents();
  @override
  State<_Parents> createState() => _ParentsState();
}

class _ParentsState extends State<_Parents> {
  List<ParentProfile> _parents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getParents();
      if (mounted) setState(() { _parents = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Parents'),
    searchBar(placeholder: 'Search parents…'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_parents.isEmpty && !_loading)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No parents found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._parents.map((p) {
        final initials = p.fullName.split(' ').where((x) => x.isNotEmpty).map((x) => x[0]).join('');
        return listItem(
          avIcon: Icons.person_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
          avInitials: initials, name: p.fullName,
          sub: p.occupation != null ? p.occupation! : 'Guardian',
          badgeText: 'Active', badgeBg: AppColors.greenLight, badgeColor: AppColors.green,
        );
      }),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Parent', onTap: () => showAddParent(context, onDone: _load))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// USERS / ROLES & PERMISSIONS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Users extends StatefulWidget {
  const _Users();
  @override
  State<_Users> createState() => _UsersState();
}

class _UsersState extends State<_Users> {
  List<AppRole>            _roles       = [];
  List<UserRoleAssignment> _assignments = [];
  List<TenantUser>         _users       = [];
  List<AppPermission>      _permissions = [];
  bool   _loading = true;
  String? _error;
  int    _tab     = 0; // 0=Roles, 1=Users, 2=Assignments

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final results = await Future.wait([
        ApiService().getRoles(),
        ApiService().getUsers(),
        ApiService().getUserRoles(),
        ApiService().getPermissions(),
      ]);
      if (!mounted) return;
      setState(() {
        _roles       = (results[0] as PaginatedResult<AppRole>).results;
        _users       = (results[1] as PaginatedResult<TenantUser>).results;
        _assignments = (results[2] as PaginatedResult<UserRoleAssignment>).results;
        _permissions = results[3] as List<AppPermission>;
        _loading     = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _deleteRole(AppRole r) async {
    final ok = await confirmDialog(context, title: 'Delete Role', body: 'Delete role "${r.name}"? All user assignments will be removed.', confirm: 'Delete');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteRole(r.id);
      showToast(context, '"${r.name}" deleted');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Future<void> _removeAssignment(UserRoleAssignment a) async {
    final ok = await confirmDialog(context, title: 'Remove Assignment', body: 'Remove role "${a.roleName ?? a.roleId}" from ${a.userEmail ?? a.userId}?', confirm: 'Remove');
    if (!ok || !mounted) return;
    try {
      await ApiService().removeUserRole(a.id);
      showToast(context, 'Role assignment removed');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Roles & Permissions'),
      // ── Tab switcher ──
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Row(children: [
          _tabBtn(0, 'Roles (${_roles.length})'),
          const SizedBox(width: 8),
          _tabBtn(1, 'Users (${_users.length})'),
          const SizedBox(width: 8),
          _tabBtn(2, 'Assignments'),
        ]),
      ),

      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (_error != null) _apiError(_error!),

      // ── ROLES tab ──
      if (_tab == 0 && !_loading) ...[
        appCard(Column(children: [
          if (_roles.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No roles yet. Create one below.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._roles.map((r) => GestureDetector(
            onLongPress: () => _deleteRole(r),
            child: listItem(
              avIcon: Icons.key_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
              name: r.name,
              sub: r.description.isNotEmpty ? r.description : '${r.permissionIds.length} permission(s)',
              badgeText: '${r.permissionIds.length} perms',
              badgeBg: AppColors.amberLight, badgeColor: AppColors.amber,
            ),
          )),
        ])),
        if (_roles.isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to delete · ${_roles.length} roles', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
        Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Create Custom Role', onTap: () => showCreateRole(context, onDone: _load))),

        // Permissions reference
        if (_permissions.isNotEmpty) ...[
          secLabel('Available Permissions (${_permissions.length})'),
          appCard(Column(children: _permissions.map((p) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('${p.module} · ${p.codename}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text3)),
              ])),
            ]),
          )).toList())),
        ],
      ],

      // ── USERS tab ──
      if (_tab == 1 && !_loading) ...[
        appCard(Column(children: [
          if (_users.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No users in this school.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._users.map((u) {
            final initials = u.fullName.split(' ').where((x) => x.isNotEmpty).map((x) => x[0]).join('');
            return listItem(
              avIcon: Icons.person_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
              avInitials: initials.isNotEmpty ? initials : u.email[0].toUpperCase(),
              name: u.fullName.isNotEmpty ? u.fullName : u.email,
              sub: u.email,
              badgeText: u.isStaff ? 'Staff' : 'User',
              badgeBg: u.isStaff ? AppColors.amberLight : AppColors.greenLight,
              badgeColor: u.isStaff ? AppColors.amber : AppColors.green,
            );
          }),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create User', onTap: () => showCreateUser(context, onDone: _load))),

        if (_roles.isNotEmpty) ...[
          secLabel('Assign Role to User'),
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Assign User → Role', onTap: () => showAssignRole(context, users: _users, roles: _roles, onDone: _load))),
        ],
      ],

      // ── ASSIGNMENTS tab ──
      if (_tab == 2 && !_loading) ...[
        appCard(Column(children: [
          if (_assignments.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No role assignments yet.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._assignments.map((a) => GestureDetector(
            onLongPress: () => _removeAssignment(a),
            child: listItem(
              avIcon: Icons.assignment_ind_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
              name: a.userEmail ?? a.userId,
              sub: '→ ${a.roleName ?? a.roleId}',
              badgeText: 'Assigned', badgeBg: AppColors.greenLight, badgeColor: AppColors.green,
            ),
          )),
        ])),
        if (_assignments.isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to remove assignment', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
      ],

      const SizedBox(height: 16),
    ]);
  }

  Widget _tabBtn(int idx, String label) => GestureDetector(
    onTap: () => setState(() => _tab = idx),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _tab == idx ? AppColors.navy : AppColors.surface,
        border: Border.all(color: _tab == idx ? AppColors.navy : AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rMd),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _tab == idx ? Colors.white : AppColors.text3)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ACADEMIC YEARS — live API with class levels, sections & subjects
// ─────────────────────────────────────────────────────────────────────────────

class _Academic extends StatefulWidget {
  const _Academic();
  @override
  State<_Academic> createState() => _AcademicState();
}

class _AcademicState extends State<_Academic> {
  List<AcademicYear> _years    = [];
  List<ClassLevel>   _classes  = [];
  List<Section>      _sections = [];
  List<Subject>      _subjects = [];
  bool   _loading = true;
  String? _error;
  int    _tab     = 0; // 0=Years, 1=Classes, 2=Sections, 3=Subjects

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final results = await Future.wait([
        ApiService().getAcademicYears().catchError((e) => e is ApiException && e.statusCode == 404 ? PaginatedResult<AcademicYear>(count: 0, results: []) : throw e),
        ApiService().getClassLevels().catchError((e) => e is ApiException && e.statusCode == 404 ? PaginatedResult<ClassLevel>(count: 0, results: []) : throw e),
        ApiService().getSections().catchError((e) => e is ApiException && e.statusCode == 404 ? PaginatedResult<Section>(count: 0, results: []) : throw e),
        ApiService().getSubjects().catchError((e) => e is ApiException && e.statusCode == 404 ? PaginatedResult<Subject>(count: 0, results: []) : throw e),
      ]);
      if (!mounted) return;
      setState(() {
        _years    = (results[0] as PaginatedResult<AcademicYear>).results;
        _classes  = (results[1] as PaginatedResult<ClassLevel>).results;
        _sections = (results[2] as PaginatedResult<Section>).results;
        _subjects = (results[3] as PaginatedResult<Subject>).results;
        _loading  = false;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _deleteYear(AcademicYear y) async {
    final ok = await confirmDialog(context, title: 'Delete Academic Year', body: 'Delete "${y.name}"? All enrollments under it will be removed.', confirm: 'Delete');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteAcademicYear(y.id);
      showToast(context, '"${y.name}" deleted');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Future<void> _deleteClass(ClassLevel c) async {
    final ok = await confirmDialog(context, title: 'Delete Class Level', body: 'Delete "${c.name}"?', confirm: 'Delete');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteClassLevel(c.id);
      showToast(context, '"${c.name}" deleted');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Future<void> _deleteSection(Section s) async {
    final ok = await confirmDialog(context, title: 'Delete Section', body: 'Delete "${s.name}"?', confirm: 'Delete');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteSection(s.id);
      showToast(context, '"${s.name}" deleted');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  Future<void> _deleteSubject(Subject s) async {
    final ok = await confirmDialog(context, title: 'Delete Subject', body: 'Delete "${s.name}"?', confirm: 'Delete');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteSubject(s.id);
      showToast(context, '"${s.name}" deleted');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Academic Setup'),
      // Tab row
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Row(children: [
          _tabBtn(0, 'Academic Years'),
          const SizedBox(width: 8),
          _tabBtn(1, 'Class Levels'),
          const SizedBox(width: 8),
          _tabBtn(2, 'Sections'),
          const SizedBox(width: 8),
          _tabBtn(3, 'Subjects'),
        ]),
      ),

      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (_error != null) _apiError(_error!),

      // ── Academic Years ──
      if (_tab == 0 && !_loading) ...[
        appCard(Column(children: [
          if (_years.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No academic years configured.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._years.map((y) => GestureDetector(
            onLongPress: () => _deleteYear(y),
            child: listItem(
              avIcon: Icons.calendar_month_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
              name: y.name,
              sub: '${y.startDate} → ${y.endDate}',
              badgeText: y.isActive ? 'Active' : 'Closed',
              badgeBg: y.isActive ? AppColors.greenLight : const Color(0xFFF1F5F9),
              badgeColor: y.isActive ? AppColors.green : AppColors.text3,
            ),
          )),
        ])),
        if (_years.isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to delete', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
        Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Add Academic Year', onTap: () => showAddAcademicYear(context, onDone: _load))),
      ],

      // ── Class Levels ──
      if (_tab == 1 && !_loading) ...[
        appCard(Column(children: [
          if (_classes.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No class levels configured.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._classes.map((c) => GestureDetector(
            onLongPress: () => _deleteClass(c),
            child: listItem(
              avIcon: Icons.class_rounded, avBg: AppColors.tealLight, avColor: AppColors.teal,
              name: c.name,
              sub: 'Order: ${c.numericOrder}',
              badgeText: 'Level ${c.numericOrder}', badgeBg: AppColors.tealLight, badgeColor: AppColors.teal,
            ),
          )),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Class Level', onTap: () => showAddClassLevel(context, onDone: _load))),
      ],

      // ── Sections ──
      if (_tab == 2 && !_loading) ...[
        appCard(Column(children: [
          if (_sections.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No sections configured.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._sections.map((s) => GestureDetector(
            onLongPress: () => _deleteSection(s),
            child: listItem(
              avIcon: Icons.grid_view_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
              name: '${s.classLevelName ?? "Class"} — ${s.name}',
              sub: 'Section ID: ${s.id.substring(0, 8)}…',
              badgeText: s.name, badgeBg: AppColors.amberLight, badgeColor: AppColors.amber,
            ),
          )),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Section', onTap: () => showAddSection(context, classLevels: _classes, onDone: _load))),
      ],

      // ── Subjects ──
      if (_tab == 3 && !_loading) ...[
        appCard(Column(children: [
          if (_subjects.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No subjects configured.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
          ..._subjects.map((s) => GestureDetector(
            onLongPress: () => _deleteSubject(s),
            child: listItem(
              avIcon: Icons.book_rounded, avBg: AppColors.greenLight, avColor: AppColors.green,
              name: s.name,
              sub: s.code != null ? 'Code: ${s.code}' : 'No code assigned',
              badgeText: s.code ?? '—', badgeBg: AppColors.greenLight, badgeColor: AppColors.green,
            ),
          )),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Subject', onTap: () => showAddSubject(context, onDone: _load))),
      ],

      const SizedBox(height: 16),
    ]);
  }

  Widget _tabBtn(int idx, String label) => GestureDetector(
    onTap: () => setState(() => _tab = idx),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _tab == idx ? AppColors.navy : AppColors.surface,
        border: Border.all(color: _tab == idx ? AppColors.navy : AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(rMd),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: _tab == idx ? Colors.white : AppColors.text3)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PARENT-STUDENT MAPPING — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Mapping extends StatefulWidget {
  const _Mapping();
  @override
  State<_Mapping> createState() => _MappingState();
}

class _MappingState extends State<_Mapping> {
  List<ParentStudentMapping> _mappings = [];
  Map<String, String> _parentNames = {};
  Map<String, String> _studentNames = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final results = await Future.wait([
        ApiService().getParentStudentMappings(),
        ApiService().getParents(),
        ApiService().getStudents(),
      ]);
      if (!mounted) return;
      
      final mappings = (results[0] as PaginatedResult<ParentStudentMapping>).results;
      final parents = (results[1] as PaginatedResult<ParentProfile>).results;
      final students = (results[2] as PaginatedResult<StudentProfile>).results;
      
      final pMap = <String, String>{ for (var p in parents) p.id: p.fullName.isNotEmpty ? p.fullName : ((p.email != null && p.email!.isNotEmpty) ? p.email! : 'Unknown Parent') };
      final sMap = <String, String>{ for (var s in students) s.id: s.fullName };

      setState(() { 
        _mappings = mappings; 
        _parentNames = pMap;
        _studentNames = sMap;
        _loading = false; 
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _delete(ParentStudentMapping m) async {
    final pName = _parentNames[m.parentId] ?? m.parentEmail ?? m.parentId;
    final sName = _studentNames[m.studentId] ?? m.studentName ?? m.studentId;
    final ok = await confirmDialog(context, title: 'Remove Mapping', body: 'Remove the mapping $pName → $sName?', confirm: 'Remove');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteMapping(m.id);
      showToast(context, 'Mapping removed');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Parent–Student Mapping'),
    searchBar(placeholder: 'Search mappings…'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_mappings.isEmpty && !_loading)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No mappings found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._mappings.map((m) {
        final pName = _parentNames[m.parentId] ?? m.parentEmail ?? m.parentId;
        final sName = _studentNames[m.studentId] ?? m.studentName ?? m.studentId;
        final initials = pName.isNotEmpty ? pName[0].toUpperCase() : 'P';
        return GestureDetector(
          onLongPress: () => _delete(m),
          child: listItem(
            avIcon: Icons.family_restroom_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
            avInitials: initials,
            name: pName,
            sub: '→ $sName · ${m.relationship}${m.isPrimaryContact ? " · Primary" : ""}',
            badgeText: 'Linked', badgeBg: AppColors.blueLight, badgeColor: AppColors.blue,
          ),
        );
      }),
    ])),
    if (_mappings.isNotEmpty)
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to remove · ${_mappings.length} mappings', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Add Mapping', onTap: () => showAddMapping(context, onDone: _load))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// ENROLLMENTS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Enrollments extends StatefulWidget {
  const _Enrollments();
  @override
  State<_Enrollments> createState() => _EnrollmentsState();
}

class _EnrollmentsState extends State<_Enrollments> {
  List<Enrollment> _enrollments = [];
  bool _loading = true;
  String? _error;
  String _status = 'current'; // current / historical / all

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getEnrollments(status: _status == 'all' ? null : _status);
      if (mounted) setState(() { _enrollments = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Student Enrollments'),
    ChipRow(chips: const ['Current', 'Historical', 'All'], active: ['current', 'historical', 'all'].indexOf(_status), onChanged: (i) { _status = ['current', 'historical', 'all'][i]; _load(); }),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_enrollments.isEmpty && !_loading)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No enrollments found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._enrollments.map((e) => listItem(
        avIcon: Icons.school_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
        name: e.studentName,
        sub: '${e.className ?? "—"} · ${e.academicYearName ?? "—"} · Roll: ${e.rollNumber ?? "—"}',
        badgeText: e.enrollmentDate ?? '—', badgeBg: AppColors.blueLight, badgeColor: AppColors.blue,
      )),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Enroll Student', onTap: () => showEnrolStudent(context, onDone: _load))),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: _outlineBtn('Bulk Promote Students', onTap: () => showBulkPromote(context, onDone: _load))),
    const SizedBox(height: 16),
  ]);

  Widget _outlineBtn(String label, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.navy, width: 1.5), borderRadius: BorderRadius.circular(rMd)),
      child: Center(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navy))),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TEACHER ASSIGNMENTS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherAssignments extends StatefulWidget {
  const _TeacherAssignments();
  @override
  State<_TeacherAssignments> createState() => _TeacherAssignmentsState();
}

class _TeacherAssignmentsState extends State<_TeacherAssignments> {
  List<TeacherAssignment> _assignments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!TokenStore.hasTokens) { setState(() => _loading = false); return; }
      final res = await ApiService().getTeacherAssignments(status: 'current');
      if (mounted) setState(() { _assignments = res.results; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _delete(TeacherAssignment a) async {
    final ok = await confirmDialog(context, title: 'Remove Assignment', body: 'Remove ${a.teacherName} from ${a.subjectName ?? "subject"} — ${a.className ?? "class"}?', confirm: 'Remove');
    if (!ok || !mounted) return;
    try {
      await ApiService().deleteTeacherAssignment(a.id);
      showToast(context, 'Assignment removed');
      _load();
    } catch (e) {
      showToast(context, e.toString(), color: AppColors.red, icon: Icons.error_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Teacher Assignments'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_assignments.isEmpty && !_loading)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No assignments found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
      ..._assignments.map((a) => GestureDetector(
        onLongPress: () => _delete(a),
        child: listItem(
          avIcon: Icons.menu_book_rounded, avBg: AppColors.tealLight, avColor: AppColors.teal,
          name: a.teacherName,
          sub: '${a.subjectName ?? "—"} · ${a.className ?? "—"} · ${a.academicYearName ?? "—"}',
          badgeText: a.isClassTeacher ? 'Class Teacher' : 'Subject',
          badgeBg: a.isClassTeacher ? AppColors.amberLight : AppColors.tealLight,
          badgeColor: a.isClassTeacher ? AppColors.amber : AppColors.teal,
        ),
      )),
    ])),
    if (_assignments.isNotEmpty)
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Text('Long-press to remove · ${_assignments.length} assignments', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4))),
    Padding(padding: const EdgeInsets.fromLTRB(14, 4, 14, 8), child: navyBtn('+ Assign Teacher', onTap: () => showAddTeacherAssignment(context, onDone: _load))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADING BANDS — static config
// ─────────────────────────────────────────────────────────────────────────────

class _Grading extends StatelessWidget {
  const _Grading();
  @override
  Widget build(BuildContext context) {
    final bands = [
      ('A+', '95–100', 'Outstanding',  AppColors.greenLight, AppColors.green),
      ('A',  '85–94',  'Excellent',    AppColors.greenLight, AppColors.green),
      ('B+', '75–84',  'Very Good',    AppColors.blueLight,  AppColors.blue),
      ('B',  '65–74',  'Good',         AppColors.blueLight,  AppColors.blue),
      ('C',  '50–64',  'Satisfactory', AppColors.amberLight, AppColors.amber),
      ('D',  '35–49',  'Needs Work',   AppColors.amberLight, AppColors.amber),
      ('F',  '0–34',   'Fail',         AppColors.redLight,   AppColors.red),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Grading Bands'),
      appCard(Table(
        columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.8)},
        children: [
          TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: ['Band', 'Range', 'Remark'].map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(h.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
            )).toList(),
          ),
          ...bands.map((b) => TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: [
              Padding(padding: const EdgeInsets.all(10), child: appBadge(b.$1, bg: b.$4, color: b.$5)),
              Padding(padding: const EdgeInsets.all(10), child: Text(b.$2, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text2))),
              Padding(padding: const EdgeInsets.all(10), child: Text(b.$3, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1))),
            ],
          )),
        ],
      )),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Band')),
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED
// ─────────────────────────────────────────────────────────────────────────────

Widget _apiError(String msg) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: const Color(0xFFFCD34D), width: 1.5)),
  child: Row(children: [
    const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.amber),
    const SizedBox(width: 8),
    Expanded(child: Text('API Error · $msg', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.amber))),
  ]),
);

// Fallback teacher data shown when API unavailable
const _fallback = [
  ('Dr. Elena Vance', 'Science Faculty',  AppColors.avTeal,  AppColors.teal),
  ('Mr. James Hoang', 'Mathematics',      AppColors.avBlue,  AppColors.blue),
  ('Ms. Sarah Kim',   'English',          AppColors.avNavy,  AppColors.navy),
  ('Mr. David Osei',  'History',          AppColors.avAmber, AppColors.amber),
];
