import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../widgets/builders.dart';
import '../../widgets/interactive.dart';
import '../page_router.dart';

class TeacherPages extends StatelessWidget {
  final String page;
  const TeacherPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':   return const _Dashboard();
      case 'attendance':  return const _Attendance();
      case 'assignments': return const _Assignments();
      case 'grades':      return const _Grades();
      case 'timetable':   return const _Timetable();
      case 'exams':       return const _Exams();
      case 'analytics':   return const _Analytics();
      default:            return defaultPage(page);
    }
  }
}

// ── Dashboard ──────────────────────────────────────────────────────────────

class _Dashboard extends StatefulWidget {
  const _Dashboard();
  @override
  State<_Dashboard> createState() => _DashboardState();
}
class _DashboardState extends State<_Dashboard> {
  ProfileMe? _profile;
  @override
  void initState() {
    super.initState();
    if (TokenStore.hasTokens) {
      ApiService().getMyProfile().then((p) {
        if (mounted) setState(() => _profile = p);
      }).catchError((_) {});
    }
  }
  @override
  Widget build(BuildContext context) {
    final cfg    = kRoles[UserRole.teacher]!;
    final name   = _profile?.displayName ?? cfg.name;
    final school = _profile?.schoolName  ?? 'Westfield Academy';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'Senior Faculty · Science', cfg.idLabel),
      pageTitle('Dashboard', subtitle: 'AI-Powered Portal'),
      quickStatsBar([
        const QsItem(val: '142', label: 'Students'),
        const QsItem(val: '91%', label: 'Attendance'),
        const QsItem(val: '8',   label: 'Pending'),
        const QsItem(val: '3',   label: 'Classes'),
      ]),
      secLabel("Today's Classes"),
      appCard(ttRows([
        TtItem(time: '08:00–09:30', subject: 'Physics 11-B',  room: 'Lab 2',    status: 'Completed', barColor: AppColors.teal,  badgeBg: AppColors.greenLight,    badgeColor: AppColors.green),
        TtItem(time: '10:15–11:45', subject: 'Science 10-A',  room: 'Room 204', status: 'Active',    barColor: AppColors.blue,  badgeBg: AppColors.blueLight,     badgeColor: AppColors.blue),
        TtItem(time: '13:00–14:30', subject: 'Chemistry 12',  room: 'Lab 3',    status: 'Upcoming',  barColor: AppColors.navy,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      ])),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.fact_check_rounded,  label: 'Attendance',  bg: AppColors.greenLight, iconColor: AppColors.green,
            onTap: () => showToast(context, 'Opening attendance…')),
        ActionItem(icon: Icons.note_add_rounded,    label: 'Assignment',  bg: AppColors.blueLight,  iconColor: AppColors.blue,
            onTap: () => showCreateAssignment(context)),
        ActionItem(icon: Icons.bar_chart_rounded,   label: 'Grades',      bg: AppColors.tealLight,  iconColor: AppColors.teal,
            onTap: () => showToast(context, 'Opening grade book…')),
        ActionItem(icon: Icons.edit_calendar_rounded, label: 'Schedule Exam', bg: AppColors.amberLight, iconColor: AppColors.amber,
            onTap: () => showScheduleExam(context)),
        ActionItem(icon: Icons.trending_up_rounded, label: 'Analytics',   bg: AppColors.blueLight,  iconColor: AppColors.blue,
            onTap: () => showToast(context, 'Opening analytics…')),
        ActionItem(icon: Icons.campaign_rounded,    label: 'Announce',    bg: AppColors.redLight,   iconColor: AppColors.red,
            onTap: () => showAnnounce(context)),
      ]),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Attendance ─────────────────────────────────────────────────────────────

class _Attendance extends StatefulWidget {
  const _Attendance();
  @override
  State<_Attendance> createState() => _AttendanceState();
}
class _AttendanceState extends State<_Attendance> {
  int _classIdx = 0;

  final _classes = const ['Science 10-A', 'Physics 11-B', 'Chemistry 12'];
  final _students = const [
    [('Aisha Okonkwo','01'),('Ben Carter','02'),('Clara Singh','03'),('David Lee','04'),('Eva Martinez','05'),('Felix Brown','06')],
    [('George Patel','01'),('Hannah Kim','02'),('Ivan Nguyen','03'),('Julia Adams','04'),('Kevin Lopez','05')],
    [('Lara Singh','01'),('Meera Osei','02'),('Niko Hassan','03'),('Omar Rivera','04'),('Priya Clarke','05')],
  ];

  late final List<Map<String, String>> _statuses;

  @override
  void initState() {
    super.initState();
    _statuses = List.generate(3, (ci) {
      final m = <String, String>{};
      for (final s in _students[ci]) m[s.$1] = 'present';
      return m;
    });
    _statuses[0]['Ben Carter'] = 'absent';
    _statuses[0]['David Lee']  = 'late';
  }

  @override
  Widget build(BuildContext context) {
    final students = _students[_classIdx];
    final status   = _statuses[_classIdx];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Attendance', subtitle: 'Mark daily attendance · ${_dateStr()}'),
      ChipRow(chips: _classes, active: _classIdx,
          onChanged: (i) => setState(() => _classIdx = i)),
      appCard(Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_classes[_classIdx]} · Today', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
            appBadge('${students.length} Students', bg: AppColors.blueLight, color: AppColors.blue),
          ]),
        ),
        ...students.map((st) {
          final cur = status[st.$1] ?? 'present';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(rMd)),
                child: Center(child: Text(st.$1.split(' ').map((x) => x[0]).join(''),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(st.$1, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('Roll #${st.$2}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
              ])),
              Row(children: [
                _attBtn(cur, 'present', Icons.check_rounded, AppColors.green, AppColors.greenLight, st.$1),
                const SizedBox(width: 5),
                _attBtn(cur, 'late',    Icons.access_time_rounded, AppColors.amber, AppColors.amberLight, st.$1),
                const SizedBox(width: 5),
                _attBtn(cur, 'absent',  Icons.close_rounded, AppColors.red, AppColors.redLight, st.$1),
              ]),
            ]),
          );
        }),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: navyBtn('Save Attendance', onTap: () => showAttendanceSaved(context))),
      const SizedBox(height: 16),
    ]);
  }

  Widget _attBtn(String cur, String val, IconData icon, Color color, Color bg, String name) =>
      GestureDetector(
        onTap: () => setState(() => _statuses[_classIdx][name] = val),
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cur == val ? color : AppColors.border, width: 1.5),
            color: cur == val ? bg : Colors.transparent,
          ),
          child: Center(child: Icon(icon, size: 12, color: cur == val ? color : AppColors.text4)),
        ),
      );

  String _dateStr() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Assignments ────────────────────────────────────────────────────────────

class _Assignments extends StatefulWidget {
  const _Assignments();
  @override
  State<_Assignments> createState() => _AssignmentsState();
}
class _AssignmentsState extends State<_Assignments> {
  final List<Map<String, dynamic>> _assignments = [
    {'sub':'PHYSICS',   'title':'Chapter 5: Forces & Motion', 'due':'Apr 15', 'submitted':22, 'total':28, 'color':AppColors.teal},
    {'sub':'SCIENCE',   'title':'Ecosystem Lab Report',        'due':'Apr 18', 'submitted':0,  'total':28, 'color':AppColors.blue},
    {'sub':'CHEMISTRY', 'title':'Periodic Table — Module 4',   'due':'Apr 16', 'submitted':18, 'total':24, 'color':AppColors.navy},
  ];

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Assignments'),
    const ChipRow(chips: ['All', 'Active', 'Submitted', 'Graded']),
    appCard(Column(children: _assignments.map((a) => Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 3, height: 64,
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
            Text('Due ${a['due']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            const SizedBox(width: 12),
            Text('${a['submitted']}/${a['total']} submitted',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
          ]),
        ])),
        GestureDetector(
          onTap: () => showToast(context, 'Opening submissions for ${a['sub']}…'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(rSm),
            ),
            child: Text('View', style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue)),
          ),
        ),
      ]),
    )).toList())),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: navyBtn('+ Create Assignment', onTap: () => showCreateAssignment(context))),
    const SizedBox(height: 16),
  ]);
}

// ── Grades ─────────────────────────────────────────────────────────────────

class _Grades extends StatefulWidget {
  const _Grades();
  @override
  State<_Grades> createState() => _GradesState();
}
class _GradesState extends State<_Grades> {
  int _classIndex = 0;

  static const _classes = [
    ('Science 10-A',  'Mid-Term', [
      ('A. Okonkwo',  '94', 'A+', AppColors.greenLight, AppColors.green),
      ('B. Carter',   '67', 'B',  AppColors.blueLight,  AppColors.blue),
      ('C. Singh',    '88', 'A',  AppColors.greenLight, AppColors.green),
      ('D. Lee',      '45', 'D',  AppColors.amberLight, AppColors.amber),
      ('E. Martinez', '78', 'B+', AppColors.blueLight,  AppColors.blue),
      ('F. Brown',    '91', 'A+', AppColors.greenLight, AppColors.green),
    ]),
    ('Physics 11-B', 'Unit 3 Test', [
      ('G. Patel',    '88', 'A',  AppColors.greenLight, AppColors.green),
      ('H. Kim',      '72', 'B',  AppColors.blueLight,  AppColors.blue),
      ('I. Nguyen',   '55', 'C',  AppColors.amberLight, AppColors.amber),
      ('J. Adams',    '96', 'A+', AppColors.greenLight, AppColors.green),
      ('K. Lopez',    '63', 'B',  AppColors.blueLight,  AppColors.blue),
    ]),
    ('Chemistry 12', 'Practical', [
      ('L. Singh',    '80', 'B+', AppColors.blueLight,  AppColors.blue),
      ('M. Osei',     '91', 'A+', AppColors.greenLight, AppColors.green),
      ('N. Hassan',   '74', 'B',  AppColors.blueLight,  AppColors.blue),
      ('O. Rivera',   '49', 'D',  AppColors.amberLight, AppColors.amber),
      ('P. Clarke',   '85', 'A',  AppColors.greenLight, AppColors.green),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final cls  = _classes[_classIndex];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Record Grades', subtitle: '${cls.$1} · ${cls.$2}'),
      ChipRow(
        chips: _classes.map((c) => c.$1).toList(),
        active: _classIndex,
        onChanged: (i) => setState(() => _classIndex = i),
      ),
      appCard(Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
        children: [
          TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: ['Student', 'Score', 'Grade'].map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(h.toUpperCase(), style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
            )).toList(),
          ),
          ...cls.$3.map((r) => TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: [
              Padding(padding: const EdgeInsets.all(10), child: Text(r.$1,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1))),
              Padding(padding: const EdgeInsets.all(10), child: Text(r.$2,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text1))),
              Padding(padding: const EdgeInsets.all(10), child: appBadge(r.$3, bg: r.$4, color: r.$5)),
            ],
          )),
        ],
      )),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: navyBtn('Publish Grades · ${cls.$1}',
              onTap: () => showPublishGrades(context, cls.$1))),
      const SizedBox(height: 16),
    ]);
  }
}

// ── Timetable ──────────────────────────────────────────────────────────────

class _Timetable extends StatelessWidget {
  const _Timetable();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('My Timetable'),
    const ChipRow(chips: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
    appCard(ttRows([
      TtItem(time: '08:00–09:30', subject: 'Physics 11-B',  room: 'Lab 2',      status: 'Done',     barColor: AppColors.teal,  badgeBg: AppColors.greenLight,    badgeColor: AppColors.green),
      TtItem(time: '10:15–11:45', subject: 'Science 10-A',  room: 'Room 204',   status: 'Active',   barColor: AppColors.blue,  badgeBg: AppColors.blueLight,     badgeColor: AppColors.blue),
      TtItem(time: '13:00–14:30', subject: 'Chemistry 12',  room: 'Lab 3',      status: 'Upcoming', barColor: AppColors.navy,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '15:00–15:45', subject: 'Staff Meeting', room: 'Conference', status: 'Upcoming', barColor: AppColors.amber, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
    ])),
    secLabel('Class Performance · Attendance'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      ProgressBar(label: 'Science 10-A  (Term 2)', value: 94, gradient: greenGrad()),
      ProgressBar(label: 'Physics 11-B  (Term 2)', value: 88, gradient: blueGrad()),
      ProgressBar(label: 'Chemistry 12  (Term 2)', value: 97, gradient: tealGrad()),
    ]))),
    const SizedBox(height: 16),
  ]);
}

// ── Exams ──────────────────────────────────────────────────────────────────

class _Exams extends StatelessWidget {
  const _Exams();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Exams', subtitle: 'Upcoming & recent examinations'),
    const ChipRow(chips: ['All', 'Upcoming', 'Completed']),
    appCard(Column(children: [
      ...([
        ('PHYSICS',   'Mid-Term Examination', 'Apr 22 · 10:00 AM', 'Lab 2',    'Upcoming'),
        ('SCIENCE',   'Unit 3 Test',           'Apr 18 · 09:00 AM', 'Room 204', 'Upcoming'),
        ('CHEMISTRY', 'Practical Assessment',  'Mar 28',             'Lab 3',    'Completed'),
      ]).map((e) {
        final upcoming = e.$5 == 'Upcoming';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd)),
              child: const Center(child: Icon(Icons.edit_rounded, size: 18, color: AppColors.blue)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.$1, style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.blue)),
              Text(e.$2, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              Text('${e.$3} · ${e.$4}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3)),
            ])),
            appBadge(e.$5,
              bg: upcoming ? AppColors.amberLight : AppColors.greenLight,
              color: upcoming ? AppColors.amber : AppColors.green),
          ]),
        );
      }),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: navyBtn('+ Schedule Exam', onTap: () => showScheduleExam(context))),
    const SizedBox(height: 16),
  ]);
}

// ── Analytics ──────────────────────────────────────────────────────────────

class _Analytics extends StatelessWidget {
  const _Analytics();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Student Analytics', subtitle: 'All classes · Term 2 · 2024–25'),
    statGrid([
      StatItem(icon: Icons.bar_chart_rounded,     iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '78%', label: 'Combined Avg',  delta: 3),
      StatItem(icon: Icons.emoji_events_rounded,  iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '6',   label: 'Top Scorers',   delta: 0),
      StatItem(icon: Icons.warning_amber_rounded, iconBg: AppColors.redLight,   iconColor: AppColors.red,   val: '4',   label: 'At Risk',        delta: -2),
      StatItem(icon: Icons.fact_check_rounded,    iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '91%', label: 'Avg Attendance', delta: 1),
    ]),
    secLabel('Subject Averages · Mid-Term'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      ProgressBar(label: 'Physics 11-B',  value: 82, gradient: tealGrad()),
      ProgressBar(label: 'Science 10-A',  value: 75, gradient: blueGrad()),
      ProgressBar(label: 'Chemistry 12',  value: 68, gradient: amberGrad()),
    ]))),
    secLabel('AI Insights'),
    appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
      _insight(AppColors.blue,  Icons.trending_up_rounded,    'Grade Trend',       'Class average increased 5% over the past 3 weeks.'),
      const SizedBox(height: 14),
      _insight(AppColors.amber, Icons.warning_amber_rounded,  'At-Risk Students',  '4 students scoring below 50%. Early intervention recommended.'),
      const SizedBox(height: 14),
      _insight(AppColors.green, Icons.task_alt_rounded,       'Attendance Impact', 'Students >90% attendance score 18% higher on average.'),
    ]))),
    const SizedBox(height: 16),
  ]);

  Widget _insight(Color color, IconData icon, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 3, height: 52, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(rFull))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(title, style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
        ]),
        const SizedBox(height: 3),
        Text(body, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, color: AppColors.text3, height: 1.5)),
      ])),
    ],
  );
}
