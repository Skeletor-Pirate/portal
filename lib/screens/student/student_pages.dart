import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../services/app_store.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';

class StudentPages extends StatelessWidget {
  final String page;
  const StudentPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':   return const _Dashboard();
      case 'subjects':    return const _Subjects();
      case 'assignments': return const _Assignments();
      case 'grades':      return const _Grades();
      case 'attendance':  return const _Attendance();
      case 'timetable':   return const _Timetable();
      case 'materials':   return const _Materials();
      default:            return defaultPage(page);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  List<Enrollment> _enrollments = [];
  List<StudentGrade> _grades = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    if (!TokenStore.hasTokens || AppStore.instance.isDevMode) {
      setState(() => _loading = false);
      return;
    }
    try {
      final store = AppStore.instance;
      final results = await Future.wait([
        ApiService().getMyProfile(),
        store.studentProfileId != null
            ? ApiService().getEnrollments(status: 'current')
            : Future.value(PaginatedResult<Enrollment>(count: 0, results: [])),
        store.studentProfileId != null
            ? ApiService().getGrades(studentId: store.studentProfileId)
            : Future.value(PaginatedResult<StudentGrade>(count: 0, results: [])),
      ]);
      if (!mounted) return;
      setState(() {
        _profile     = results[0] as ProfileMe;
        _enrollments = (results[1] as PaginatedResult<Enrollment>).results;
        _grades      = (results[2] as PaginatedResult<StudentGrade>).results;
        _loading     = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg   = kRoles[UserRole.student]!;
    final store = AppStore.instance;
    final name   = store.currentUserName.isNotEmpty ? store.currentUserName : cfg.name;
    final school = store.currentSchool.isNotEmpty ? store.currentSchool : 'Westfield Academy';

    // Compute stats from API data
    final enrollmentLabel = _enrollments.isNotEmpty
        ? '${_enrollments.first.className ?? "—"} · $school'
        : 'Student · $school';
    final enrollId = _enrollments.isNotEmpty
        ? 'Roll: ${_enrollments.first.rollNumber ?? "—"}'
        : cfg.idLabel;

    // Compute grade average
    String avgStr = '—';
    String gpaStr = '—';
    if (_grades.isNotEmpty) {
      final total = _grades.fold<double>(0, (s, g) => s + (g.marksObtained ?? 0));
      final maxTotal = _grades.fold<double>(0, (s, g) => s + (g.maxMarks ?? 100));
      final pct = maxTotal > 0 ? (total / maxTotal * 100) : 0.0;
      avgStr = '${pct.toStringAsFixed(0)}%';
      if (pct >= 90) gpaStr = 'A+';
      else if (pct >= 80) gpaStr = 'A';
      else if (pct >= 70) gpaStr = 'B+';
      else if (pct >= 60) gpaStr = 'B';
      else if (pct >= 50) gpaStr = 'C';
      else gpaStr = 'D';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, enrollmentLabel, enrollId),
      pageTitle('Dashboard'),
      if (_loading)
        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (!_loading) quickStatsBar([
        QsItem(val: avgStr, label: 'Average',    valColor: AppColors.green),
        QsItem(val: '${_enrollments.length}', label: 'Enrollments', valColor: AppColors.blue),
        QsItem(val: '${_grades.length}', label: 'Results',    valColor: AppColors.amber),
        QsItem(val: gpaStr,  label: 'GPA',        valColor: AppColors.navy),
      ]),

      if (_grades.isNotEmpty) ...[
        secLabel('Recent Grades'),
        appCard(Column(children: _grades.take(5).map((g) {
          final pct = (g.maxMarks ?? 100) > 0 ? ((g.marksObtained ?? 0) / (g.maxMarks ?? 100) * 100) : 0.0;
          String letter = '—';
          Color color = AppColors.text3;
          if (pct >= 90) { letter = 'A+'; color = AppColors.green; }
          else if (pct >= 80) { letter = 'A'; color = AppColors.green; }
          else if (pct >= 70) { letter = 'B+'; color = AppColors.blue; }
          else if (pct >= 60) { letter = 'B'; color = AppColors.blue; }
          else if (pct >= 50) { letter = 'C'; color = AppColors.amber; }
          else { letter = 'F'; color = AppColors.red; }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(rMd)),
                child: Center(child: Text(letter, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: color))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.subjectName ?? 'Subject', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('${g.examName ?? "Exam"} · ${g.marksObtained?.toStringAsFixed(0) ?? "—"}/${g.maxMarks?.toStringAsFixed(0) ?? "100"}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ])),
              appBadge('${pct.toStringAsFixed(0)}%', bg: color.withOpacity(0.12), color: color),
            ]),
          );
        }).toList())),
      ],

      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.upload_file_rounded,    label: 'Submit Work',  bg: AppColors.blueLight,  iconColor: AppColors.blue,
            onTap: () => showSubmitAssignment(context, 'Assignment')),
        ActionItem(icon: Icons.auto_awesome_rounded,   label: 'Ask AI',       bg: AppColors.amberLight, iconColor: AppColors.amber,
            onTap: () => showAiChat(context)),
        ActionItem(icon: Icons.note_alt_rounded,       label: 'My Notes',     bg: AppColors.amberLight, iconColor: AppColors.amber,
            onTap: () => showQuickNotes(context)),
        ActionItem(icon: Icons.emoji_events_rounded,   label: 'Leaderboard',  bg: AppColors.amberLight, iconColor: AppColors.amber,
            onTap: () => showLeaderboard(context)),
        ActionItem(icon: Icons.bar_chart_rounded,      label: 'My Grades',    bg: AppColors.greenLight, iconColor: AppColors.green,
            onTap: () => showToast(context, 'Opening grades…')),
        ActionItem(icon: Icons.notifications_rounded,  label: 'Alerts',       bg: AppColors.redLight,   iconColor: AppColors.red,
            onTap: () => showNotifications(context)),
      ]),

      // Show due-soon from AppStore (works in both dev and real mode)
      if (AppStore.instance.isDevMode) ...[
        secLabel('Due Soon'),
        appCard(asgnCards([
          AsgItem(sub: 'MATHEMATICS', title: 'Quadratic Equations Set B', due: 'Tomorrow', barColor: AppColors.blue),
          AsgItem(sub: 'PHYSICS',     title: 'Chapter 5 Lab Report',       due: 'Apr 18',   barColor: AppColors.teal),
          AsgItem(sub: 'ENGLISH',     title: 'Essay: The Great Gatsby',    due: 'Apr 20',   barColor: AppColors.navy),
        ])),
      ],
      const SizedBox(height: 16),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBJECTS — live API
// ─────────────────────────────────────────────────────────────────────────────

class _Subjects extends StatefulWidget {
  const _Subjects();
  @override
  State<_Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<_Subjects> {
  List<Subject> _subjects = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!TokenStore.hasTokens || AppStore.instance.isDevMode) {
      setState(() => _loading = false);
      return;
    }
    try {
      final res = await ApiService().getSubjects();
      if (mounted) setState(() { _subjects = res.results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback for dev mode
    if (AppStore.instance.isDevMode || (!_loading && _subjects.isEmpty && !TokenStore.hasTokens)) {
      return _buildDummy(context);
    }

    final colors = [AppColors.blue, AppColors.teal, AppColors.navy, AppColors.amber, AppColors.green];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('My Subjects'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (!_loading) appCard(Column(children: [
        if (_subjects.isEmpty)
          Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No subjects found.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3)))),
        ..._subjects.asMap().entries.map((entry) {
          final s = entry.value;
          final color = colors[entry.key % colors.length];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(rMd)),
                child: Center(child: Icon(Icons.bookmark_rounded, size: 18, color: color)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text(s.code ?? 'No code', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ])),
            ]),
          );
        }),
      ])),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildDummy(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('My Subjects'),
    appCard(Column(children: [
      ...([
        ('Mathematics', 'Mr. Hoang',  'A',  AppColors.blue),
        ('Physics',     'Dr. Vance',  'A-', AppColors.teal),
        ('English',     'Ms. Kim',    'B+', AppColors.navy),
        ('Chemistry',   'Dr. Vance',  'B+', AppColors.amber),
        ('History',     'Mr. Osei',   'A+', AppColors.green),
      ]).map((s) => GestureDetector(
        onTap: () => showToast(context, 'Opening ${s.$1}…'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: s.$4.withOpacity(0.12), borderRadius: BorderRadius.circular(rMd)),
              child: Center(child: Icon(Icons.bookmark_rounded, size: 18, color: s.$4)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.$1, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              Text(s.$2, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ])),
            appBadge(s.$3, bg: AppColors.avNavy, color: AppColors.navy),
          ]),
        ),
      )),
    ])),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGNMENTS — from AppStore (compatible with both modes)
// ─────────────────────────────────────────────────────────────────────────────

class _Assignments extends StatefulWidget {
  const _Assignments();
  @override
  State<_Assignments> createState() => _AssignmentsState();
}
class _AssignmentsState extends State<_Assignments> {
  Color _col(dynamic c) {
    if (c is Color) return c;
    switch(c.toString()) { case 'teal': return AppColors.teal; case 'navy': return AppColors.navy; case 'amber': return AppColors.amber; case 'green': return AppColors.green; case 'red': return AppColors.red; default: return AppColors.blue; }
  }
  Color _badgeBg(String s) {
    if (s == 'Pending') return AppColors.amberLight;
    if (s.startsWith('Graded')) return AppColors.greenLight;
    return AppColors.blueLight;
  }
  Color _badgeColor(String s) {
    if (s == 'Pending') return AppColors.amber;
    if (s.startsWith('Graded')) return AppColors.green;
    return AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: AppStore.instance.studentAssignments,
      builder: (context, items, _) {
        // If real login and no items, show empty state
        if (items.isEmpty && AppStore.instance.isRealLogin) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            pageTitle('Assignments'),
            appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
              'No assignments yet. Your teachers will post assignments here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3),
            )))),
            const SizedBox(height: 16),
          ]);
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Assignments'),
      Padding(padding: const EdgeInsets.fromLTRB(14,0,14,6),
        child: Text('${items.length} assignments · ${items.where((a)=>a["status"]=="Pending").length} pending',
            style: GoogleFonts.plusJakartaSans(fontSize:12, color: AppColors.text3))),
      const ChipRow(chips: ['All', 'Pending', 'Submitted', 'Graded']),
      appCard(Column(children: items.map((a) => GestureDetector(
        onTap: a['status'] == 'Pending'
            ? () async {
                await showSheet(context, _AssignmentDetailSheet(
                  title: a['title'],
                  subject: a['sub'],
                  due: a['due'],
                  color: _col(a['color']),
                  onSubmit: () {
                    AppStore.instance.submitStudentAssignment(a['title']);
                    Navigator.pop(context);
                    showToast(context, '${a['title']} submitted!');
                  },
                ));
              }
            : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 3, height: 60,
              decoration: BoxDecoration(color: a['color'], borderRadius: BorderRadius.circular(rFull))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a['sub'], style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: a['color'])),
            const SizedBox(height: 3),
            Text(a['title'], style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.text4),
              const SizedBox(width: 4),
              Text('Due ${a['due']}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3)),
            ]),
          ])),
          appBadge(a['status'], bg: _badgeBg(a['status']), color: _badgeColor(a['status'])),
        ]),
      ),
    )).toList())),
    const SizedBox(height: 16),
  ]);
      },
    );
  }
}

class _AssignmentDetailSheet extends StatelessWidget {
  final String title, subject, due;
  final Color  color;
  final VoidCallback onSubmit;
  const _AssignmentDetailSheet({
    required this.title, required this.subject,
    required this.due, required this.color, required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child:
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 4, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rFull))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(subject, style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: color)),
          Text(title, style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: AppColors.text1)),
        ])),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bg,
            borderRadius: BorderRadius.circular(rMd),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Instructions', style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3)),
          const SizedBox(height: 6),
          Text('Complete all problems neatly. Show all working. Submit as PDF or photo. Late submissions will be penalised 10% per day.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text2, height: 1.6)),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.red),
        const SizedBox(width: 6),
        Text('Due: $due', style: GoogleFonts.plusJakartaSans(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red)),
      ]),
      const SizedBox(height: 24),
      navyBtn('Submit Assignment', onTap: onSubmit),
      const SizedBox(height: 10),
      outlineBtn('Ask AI for Help', onTap: () {
        Navigator.pop(context);
        showAiChat(context);
      }),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADES — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Grades extends StatefulWidget {
  const _Grades();
  @override
  State<_Grades> createState() => _GradesState();
}

class _GradesState extends State<_Grades> {
  List<StudentGrade> _grades = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final store = AppStore.instance;
    if (!TokenStore.hasTokens || store.isDevMode) {
      setState(() => _loading = false);
      return;
    }
    try {
      final res = await ApiService().getGrades(studentId: store.studentProfileId);
      if (mounted) setState(() { _grades = res.results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dev mode fallback
    if (AppStore.instance.isDevMode || (!_loading && _grades.isEmpty && !TokenStore.hasTokens)) {
      return _buildDummy(context);
    }

    // Calculate overall average from API data
    double totalObt = 0, totalMax = 0;
    for (final g in _grades) {
      totalObt += g.marksObtained ?? 0;
      totalMax += g.maxMarks ?? 100;
    }
    final overallPct = totalMax > 0 ? (totalObt / totalMax * 100) : 0.0;
    String overallGrade = '—';
    if (_grades.isNotEmpty) {
      if (overallPct >= 90) overallGrade = 'A+';
      else if (overallPct >= 80) overallGrade = 'A';
      else if (overallPct >= 70) overallGrade = 'B+';
      else if (overallPct >= 60) overallGrade = 'B';
      else if (overallPct >= 50) overallGrade = 'C';
      else overallGrade = 'D';
    }

    final colors = [AppColors.blue, AppColors.teal, AppColors.navy, AppColors.amber, AppColors.green];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Grades & Report Card'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (!_loading && _grades.isEmpty) appCard(Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(
        'No grades available yet. Results will appear here once published.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3),
      )))),
      if (!_loading && _grades.isNotEmpty) ...[
        appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${overallPct.toStringAsFixed(1)}%', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
                Text('Overall Average · ${_grades.length} results', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rFull)),
                child: Text(overallGrade, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
          GradeBars(items: _grades.take(6).toList().asMap().entries.map((entry) {
            final g = entry.value;
            final pct = (g.maxMarks ?? 100) > 0 ? ((g.marksObtained ?? 0) / (g.maxMarks ?? 100) * 100).clamp(0, 100).toInt() : 0;
            return GradeItem(subject: g.subjectName ?? 'Subject', value: pct, color: colors[entry.key % colors.length]);
          }).toList()),
        ])),
      ],
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildDummy(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Grades & Report Card'),
    appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('87.4%', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
            Text('Overall Average · Term 2', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rFull)),
            child: Text('A−', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
      GradeBars(items: [
        GradeItem(subject: 'Mathematics',   value: 92, color: AppColors.blue),
        GradeItem(subject: 'Physics',       value: 88, color: AppColors.teal),
        GradeItem(subject: 'English',       value: 84, color: AppColors.navy),
        GradeItem(subject: 'Chemistry',     value: 79, color: AppColors.amber),
        GradeItem(subject: 'History',       value: 91, color: AppColors.green),
        GradeItem(subject: 'Computer Sci.', value: 96, color: AppColors.teal),
      ]),
    ])),
    secLabel('Mid-Term Results'),
    examChips([['MATH','94','A+'],['PHY','88','A'],['ENG','81','B+'],['CHEM','76','B+'],['HIST','91','A+'],['CS','97','A+']]),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: outlineBtn('Download Report Card',
            onTap: () => showDownloadMaterial(context, 'Report Card Term 2'))),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTENDANCE — live API when authenticated
// ─────────────────────────────────────────────────────────────────────────────

class _Attendance extends StatefulWidget {
  const _Attendance();
  @override
  State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  int _present = 0, _absent = 0, _late = 0;
  int _total = 0;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final store = AppStore.instance;
    if (!TokenStore.hasTokens || store.isDevMode || store.studentProfileId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final res = await ApiService().getAttendance(studentId: store.studentProfileId);
      final records = res.results;
      int p = 0, a = 0, l = 0;
      for (final r in records) {
        switch (r.status) {
          case 'Present': p++; break;
          case 'Absent': a++; break;
          case 'Late': l++; break;
          default: p++; break;
        }
      }
      if (mounted) setState(() {
        _present = p; _absent = a; _late = l;
        _total = records.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallPct = _total > 0 ? ((_present + _late) / _total * 100).toStringAsFixed(0) : '—';

    // Use API data if available, otherwise show dev dummy
    if (AppStore.instance.isDevMode || _total == 0) {
      return _buildDummy(context);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance'),
      if (_loading) const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator(color: AppColors.blue))),
      if (!_loading) appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _attStat('$overallPct%', AppColors.green, 'Overall'),
          _attStat('$_present',  AppColors.blue,  'Present'),
          _attStat('$_absent',   AppColors.red,   'Absent'),
          _attStat('$_late',     AppColors.amber, 'Late'),
        ]),
      ]))),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildDummy(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Attendance', subtitle: 'April 2025'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _attStat('96%', AppColors.green, 'Overall'),
        _attStat('48',  AppColors.blue,  'Present'),
        _attStat('2',   AppColors.red,   'Absent'),
        _attStat('1',   AppColors.amber, 'Late'),
      ]),
      const Divider(height: 28, color: AppColors.border),
      attendanceGrid(),
    ]))),
    secLabel('Subject Attendance'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      ProgressBar(label: 'Mathematics', value: 95, gradient: blueGrad()),
      ProgressBar(label: 'Physics',     value: 91, gradient: tealGrad()),
      ProgressBar(label: 'English',     value: 88, gradient: greenGrad()),
      ProgressBar(label: 'Chemistry',   value: 87, gradient: amberGrad()),
      ProgressBar(label: 'History',     value: 94, gradient: blueGrad()),
    ]))),
    const SizedBox(height: 16),
  ]);

  Widget _attStat(String val, Color color, String label) => Column(children: [
    Text(val, style: GoogleFonts.dmSerifDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// TIMETABLE — static (no backend endpoint yet)
// ─────────────────────────────────────────────────────────────────────────────

class _Timetable extends StatelessWidget {
  const _Timetable();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Timetable'),
    const ChipRow(chips: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
    appCard(ttRows([
      TtItem(time: '08:00', subject: 'Mathematics',        room: 'Room 204 · Mr. Hoang', status: '—', barColor: AppColors.blue,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '10:00', subject: 'English Literature', room: 'Room 112 · Ms. Kim',    status: '—', barColor: AppColors.navy,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '13:30', subject: 'Physics Lab',        room: 'Lab 2 · Dr. Vance',     status: '—', barColor: AppColors.teal,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '15:00', subject: 'History',            room: 'Room 308 · Mr. Osei',   status: '—', barColor: AppColors.amber, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
    ])),
    const SizedBox(height: 16),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// MATERIALS — static (no backend endpoint yet)
// ─────────────────────────────────────────────────────────────────────────────

class _Materials extends StatelessWidget {
  const _Materials();
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Physics Notes — Chapter 5',  'Dr. Vance · Apr 1',  'PDF',  AppColors.tealLight,  AppColors.teal),
      ('Quadratic Equations Guide',  'Mr. Hoang · Mar 28', 'PDF',  AppColors.blueLight,  AppColors.blue),
      ('The Great Gatsby — Summary', 'Ms. Kim · Mar 25',   'DOC',  AppColors.avNavy,     AppColors.navy),
      ('WWII Timeline',              'Mr. Osei · Mar 20',  'PPTX', AppColors.amberLight, AppColors.amber),
      ('Chemistry Lab Manual',       'Dr. Vance · Mar 15', 'PDF',  AppColors.greenLight, AppColors.green),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Learning Materials'),
      searchBar(placeholder: 'Search materials...'),
      const ChipRow(chips: ['All', 'Physics', 'Math', 'English', 'History']),
      appCard(Column(children: items.map((m) => GestureDetector(
        onTap: () => showDownloadMaterial(context, m.$1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: m.$4, borderRadius: BorderRadius.circular(rMd)),
              child: Center(child: Icon(Icons.description_rounded, size: 18, color: m.$5)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.$1, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              Text(m.$2, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ])),
            const Icon(Icons.download_rounded, size: 16, color: AppColors.text4),
            const SizedBox(width: 6),
            appBadge(m.$3, bg: m.$4, color: m.$5),
          ]),
        ),
      )).toList())),
      const SizedBox(height: 16),
    ]);
  }
}
