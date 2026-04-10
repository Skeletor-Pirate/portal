import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class AdminPages extends StatelessWidget {
  final String page;
  const AdminPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard': return const _Dashboard();
      case 'students':  return const _Students();
      case 'teachers':  return const _Teachers();
      case 'users':     return const _Users();
      case 'academic':  return const _Academic();
      case 'grading':   return const _Grading();
      case 'mapping':   return const _Mapping();
      case 'parents':   return const _Parents();
      default:          return defaultPage(page);
    }
  }
}

// ── Dashboard ──────────────────────────────────
class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  int _studentCount = 1240;
  int _teacherCount = 84;
  int _parentCount  = 1180;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!TokenStore.hasTokens) return;
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
        final students = results[1] as PaginatedResult<StudentProfile>;
        final teachers = results[2] as PaginatedResult<TeacherProfile>;
        final parents  = results[3] as PaginatedResult<ParentProfile>;
        if (students.count > 0) _studentCount = students.count;
        if (teachers.count > 0) _teacherCount = teachers.count;
        if (parents.count  > 0) _parentCount  = parents.count;
      });
    } catch (_) {}
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final cfg    = kRoles[UserRole.admin]!;
    final name   = _profile?.displayName ?? cfg.name;
    final school = _profile?.schoolName  ?? 'Westfield Academy';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'School Administrator', cfg.idLabel),
      pageTitle('Dashboard', subtitle: '$school · Term 2 · 2024–25'),
      statGrid([
        StatItem(icon: Icons.school_rounded,      iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: _fmt(_studentCount), label: 'Students',   delta: 5),
        StatItem(icon: Icons.menu_book_rounded,   iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: '$_teacherCount',    label: 'Teachers',   delta: 2),
        StatItem(icon: Icons.group_rounded,       iconBg: AppColors.greenLight, iconColor: AppColors.green, val: _fmt(_parentCount),  label: 'Parents',    delta: 0),
        StatItem(icon: Icons.fact_check_rounded,  iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '94%',               label: 'Student Attendance · Today', delta: 1),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.person_add_rounded,     label: 'Add Student',  bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.add_card_rounded,       label: 'Add Teacher',  bg: AppColors.tealLight,  iconColor: AppColors.teal),
        ActionItem(icon: Icons.how_to_reg_rounded,     label: 'Add Parent',   bg: AppColors.greenLight, iconColor: AppColors.green),
        ActionItem(icon: Icons.verified_user_rounded,  label: 'Roles',        bg: AppColors.amberLight, iconColor: AppColors.amber),
        ActionItem(icon: Icons.calendar_month_rounded, label: 'Academic Yr',  bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.star_rounded,           label: 'Grading',      bg: AppColors.redLight,   iconColor: AppColors.red),
      ]),
      secLabel('Recent Activity'),
      appCard(Padding(padding: const EdgeInsets.all(16), child: timeline([
        TlItem(title: 'Student Enrolled',         sub: 'Aisha Okonkwo — Grade 10B',      time: '5m ago',  color: AppColors.blue),
        TlItem(title: 'Teacher Profile Updated',  sub: 'Mr. James Hoang — Math',          time: '22m ago', color: AppColors.teal),
        TlItem(title: 'Academic Year Configured', sub: 'Term 2 activated',                time: '1h ago',  color: AppColors.green),
        TlItem(title: 'Role Permissions Updated', sub: 'Parent role — grades view added', time: '3h ago',  color: AppColors.amber),
      ]))),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Students (live data) ───────────────────────
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

  // Static fallback
  static const _fallback = [
    ('Maya Johnson',    'Grade 10B', '042', '96'),
    ('Arjun Mehta',     'Grade 10A', '018', '88'),
    ('Zara Williams',   'Grade 11C', '067', '92'),
    ('Leo Chen',        'Grade 9A',  '005', '100'),
    ('Sofia Rodriguez', 'Grade 12B', '091', '84'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Students'),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(rLg),
            boxShadow: shadowSm,
          ),
          child: Row(children: [
            const Icon(Icons.search_rounded, size: 16, color: AppColors.text4),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              controller: _searchCtrl,
              onSubmitted: (v) => _load(search: v),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1),
              decoration: InputDecoration(
                hintText: 'Search students...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
                border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
              ),
            )),
            if (_loading)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue)),
          ]),
        ),
      ),
      const ChipRow(chips: ['All', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12']),
      if (_error != null)
        _apiError(_error!),
      appCard(Column(children: [
        if (_students.isNotEmpty)
          ..._students.map((s) {
            final initials = s.fullName.split(' ').map((x) => x.isNotEmpty ? x[0] : '').join('');
            final pctStr = s.attendancePct ?? '—';
            final pct    = int.tryParse(pctStr.replaceAll('%', '')) ?? 0;
            return listItem(
              avIcon: Icons.person_rounded, avBg: AppColors.avNavy, avColor: AppColors.navy,
              avInitials: initials,
              name: s.fullName,
              sub: '${s.gradeClass ?? "—"} · Roll #${s.rollNumber ?? "—"}',
              badgeText: pct > 0 ? '$pctStr%' : '—',
              badgeBg:    pct >= 90 ? AppColors.greenLight : AppColors.amberLight,
              badgeColor: pct >= 90 ? AppColors.green      : AppColors.amber,
            );
          })
        else if (!_loading)
          ..._fallback.map((s) {
            final initials = s.$1.split(' ').map((x) => x[0]).join('');
            final pct = int.parse(s.$4);
            return listItem(
              avIcon: Icons.person_rounded, avBg: AppColors.avNavy, avColor: AppColors.navy,
              avInitials: initials,
              name: s.$1, sub: '${s.$2} · Roll #${s.$3}',
              badgeText: '${s.$4}%',
              badgeBg:    pct >= 90 ? AppColors.greenLight : AppColors.amberLight,
              badgeColor: pct >= 90 ? AppColors.green      : AppColors.amber,
            );
          }),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Student Profile')),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Teachers (live data) ───────────────────────
class _Teachers extends StatefulWidget {
  const _Teachers();
  @override
  State<_Teachers> createState() => _TeachersState();
}

class _TeachersState extends State<_Teachers> {
  List<TeacherProfile> _teachers = [];
  bool _loading = true;
  String? _error;

  static const _fallback = [
    ('Dr. Elena Vance', 'Science',     AppColors.avTeal,  AppColors.teal),
    ('Mr. James Hoang', 'Mathematics', AppColors.avBlue,  AppColors.blue),
    ('Ms. Sarah Kim',   'English',     AppColors.avNavy,  AppColors.navy),
    ('Mr. David Osei',  'History',     AppColors.avAmber, AppColors.amber),
  ];

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

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Teachers'),
    searchBar(placeholder: 'Search teachers...'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_teachers.isNotEmpty)
        ..._teachers.map((t) {
          final initial = t.fullName.isNotEmpty ? t.fullName.split(' ').last[0] : 'T';
          return listItem(
            avIcon: Icons.person_rounded, avBg: AppColors.avTeal, avColor: AppColors.teal,
            avInitials: initial,
            name: t.fullName, sub: t.subject ?? 'Faculty',
            badgeText: (t.subject ?? 'Staff').split(' ').first,
            badgeBg: AppColors.avTeal, badgeColor: AppColors.teal,
          );
        })
      else if (!_loading)
        ..._fallback.map((t) => listItem(
          avIcon: Icons.person_rounded, avBg: t.$3, avColor: t.$4,
          avInitials: t.$1.split(' ').last[0],
          name: t.$1, sub: t.$2,
          badgeText: t.$2.split(' ')[0],
          badgeBg: t.$3, badgeColor: t.$4,
        )),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Teacher Profile')),
    const SizedBox(height: 16),
  ]);
}

// ── Parents (live data) ────────────────────────
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
    searchBar(placeholder: 'Search parents...'),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
    if (_error != null) _apiError(_error!),
    appCard(Column(children: [
      if (_parents.isNotEmpty)
        ..._parents.map((p) {
          final initials = p.fullName.split(' ').map((x) => x.isNotEmpty ? x[0] : '').join('');
          return listItem(
            avIcon: Icons.person_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
            avInitials: initials,
            name: p.fullName,
            sub: p.linkedStudent != null ? 'Parent of ${p.linkedStudent}' : 'Guardian',
            badgeText: 'Active', badgeBg: AppColors.greenLight, badgeColor: AppColors.green,
          );
        })
      else if (!_loading)
        ...[
          ('Priya Mehta',      'Parent of Arjun Mehta'),
          ('John Carter',      'Parent of Ben Carter'),
          ('Alexander Pierce', 'Parent of Alex Rivers'),
          ('Aiko Tanaka',      'Parent of Yuki Tanaka'),
        ].map((p) => listItem(
          avIcon: Icons.person_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
          avInitials: p.$1.split(' ').map((x) => x[0]).join(''),
          name: p.$1, sub: p.$2,
          badgeText: 'Active', badgeBg: AppColors.greenLight, badgeColor: AppColors.green,
        )),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Parent')),
    const SizedBox(height: 16),
  ]);
}

// ── Users / Roles ──────────────────────────────
class _Users extends StatelessWidget {
  const _Users();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Roles & Permissions'),
    appCard(Column(children: [
      ...[
        ('School Admin', 'Full system access',          AppColors.avNavy,  AppColors.navy),
        ('Teacher',      'Classes, grades, attendance', AppColors.avTeal,  AppColors.teal),
        ('Student',      'View own records',            AppColors.avBlue,  AppColors.blue),
        ('Parent',       'View child records',          AppColors.avAmber, AppColors.amber),
        ('Accountant',   'Finance & billing',           AppColors.avRed,   AppColors.red),
      ].map((r) => listItem(
        avIcon: Icons.key_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
        name: r.$1, sub: r.$2,
        badgeText: 'Edit', badgeBg: r.$3, badgeColor: r.$4,
      )),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Custom Role')),
    const SizedBox(height: 16),
  ]);
}

// ── Academic Years ─────────────────────────────
class _Academic extends StatelessWidget {
  const _Academic();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Academic Years'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('2024–2025', style: GoogleFonts.dmSerifDisplay(fontSize: 17, color: AppColors.text1)),
          Text('Current Academic Year', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        ]),
        appBadge('Active', bg: AppColors.greenLight, color: AppColors.green),
      ]),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text('Academic progress — 2024–25', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4, fontWeight: FontWeight.w600)),
      ),
      ProgressBar(label: 'Term 1  Jan–Apr 2024  (Completed)', value: 100, gradient: greenGrad()),
      ProgressBar(label: 'Term 2  May–Aug 2024  (In Progress)', value: 58,  gradient: blueGrad()),
      ProgressBar(label: 'Term 3  Sep–Dec 2024  (Upcoming)',   value: 0,   gradient: amberGrad()),
    ]))),
    secLabel('Past Years'),
    appCard(Column(children: [
      ...['2023–2024', '2022–2023', '2021–2022'].map((y) => listItem(
        avIcon: Icons.calendar_month_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
        name: y, sub: '3 Terms · Completed',
        badgeText: 'Closed',
        badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3,
      )),
    ])),
    const SizedBox(height: 16),
  ]);
}

// ── Grading ────────────────────────────────────
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
      pageTitle('Grading Remarks'),
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

// ── Mapping ────────────────────────────────────
class _Mapping extends StatelessWidget {
  const _Mapping();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Parent–Student Mapping'),
    searchBar(placeholder: 'Search...'),
    appCard(Column(children: [
      ...[
        ('Priya Mehta',      'Arjun Mehta',  'Grade 10A'),
        ('John Carter',      'Ben Carter',   'Grade 9B'),
        ('Alexander Pierce', 'Alex Rivers',  'Grade 11B'),
      ].map((m) => listItem(
        avIcon: Icons.share_rounded, avBg: AppColors.amberLight, avColor: AppColors.amber,
        name: m.$1, sub: '→ ${m.$2} · ${m.$3}',
        badgeText: 'Linked', badgeBg: AppColors.blueLight, badgeColor: AppColors.blue,
      )),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Add Mapping')),
    const SizedBox(height: 16),
  ]);
}

// ── Shared error widget ────────────────────────
Widget _apiError(String msg) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  decoration: BoxDecoration(
    color: AppColors.amberLight,
    borderRadius: BorderRadius.circular(rMd),
    border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
  ),
  child: Row(children: [
    const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.amber),
    const SizedBox(width: 8),
    Expanded(child: Text('Showing cached data · $msg',
        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.amber))),
  ]),
);
