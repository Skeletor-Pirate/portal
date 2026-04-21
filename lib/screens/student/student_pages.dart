import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
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

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    heroPortrait(kRoles[UserRole.student]!.avatarAsset, 'Westfield Academy'),
    profileInfo('Alex Rivers', 'Grade 11-B · Westfield Academy', 'ID: 20240912'),
    pageTitle('Dashboard'),
    quickStatsBar([
      QsItem(val: '87%', label: 'Average',    valColor: AppColors.green),
      QsItem(val: '96%', label: 'Attendance', valColor: AppColors.blue),
      QsItem(val: '3',   label: 'Pending',    valColor: AppColors.amber),
      QsItem(val: 'A-',  label: 'GPA',        valColor: AppColors.navy),
    ]),
    secLabel("Today's Schedule"),
    appCard(ttRows([
      TtItem(time: '08:00', subject: 'Mathematics',  room: 'Room 204 · Mr. Hoang',  status: 'Done',  barColor: AppColors.blue,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '10:00', subject: 'English Lit.',  room: 'Room 112 · Ms. Kim',    status: 'Done',  barColor: AppColors.teal,  badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      TtItem(time: '13:30', subject: 'Physics Lab',   room: 'Lab 2 · Dr. Vance',     status: 'Next',  barColor: AppColors.navy,  badgeBg: AppColors.blueLight,     badgeColor: AppColors.blue),
      TtItem(time: '15:00', subject: 'History',       room: 'Room 308 · Mr. Osei',   status: 'Later', barColor: AppColors.amber, badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
    ])),
    secLabel('Quick Actions'),
    actionGrid([
      ActionItem(icon: Icons.upload_file_rounded,    label: 'Submit Work',  bg: AppColors.blueLight,  iconColor: AppColors.blue,
          onTap: () => showSubmitAssignment(context, 'Quadratic Equations Set B')),
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
    secLabel('Due Soon'),
    appCard(asgnCards([
      AsgItem(sub: 'MATHEMATICS', title: 'Quadratic Equations Set B', due: 'Tomorrow', barColor: AppColors.blue),
      AsgItem(sub: 'PHYSICS',     title: 'Chapter 5 Lab Report',       due: 'Apr 18',   barColor: AppColors.teal),
      AsgItem(sub: 'ENGLISH',     title: 'Essay: The Great Gatsby',    due: 'Apr 20',   barColor: AppColors.navy),
    ])),
    const SizedBox(height: 16),
  ]);
}

class _Subjects extends StatelessWidget {
  const _Subjects();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

class _Assignments extends StatefulWidget {
  const _Assignments();
  @override
  State<_Assignments> createState() => _AssignmentsState();
}
class _AssignmentsState extends State<_Assignments> {
  final List<Map<String, dynamic>> _items = [
    {'sub':'MATHEMATICS','title':'Quadratic Equations Set B','due':'Tomorrow','color':AppColors.blue,  'status':'Pending'},
    {'sub':'ENGLISH',    'title':'Essay: The Great Gatsby',  'due':'Apr 20',  'color':AppColors.navy,  'status':'Pending'},
    {'sub':'PHYSICS',    'title':'Chapter 4 Problems',       'due':'Mar 30',  'color':AppColors.teal,  'status':'Submitted'},
    {'sub':'HISTORY',    'title':'WWII Analysis Essay',      'due':'Mar 25',  'color':AppColors.green, 'status':'Graded · A'},
    {'sub':'CHEMISTRY',  'title':'Lab Safety Report',        'due':'Apr 22',  'color':AppColors.amber, 'status':'Pending'},
  ];

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
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    pageTitle('Assignments'),
    const ChipRow(chips: ['All', 'Pending', 'Submitted', 'Graded']),
    appCard(Column(children: _items.map((a) => GestureDetector(
      onTap: a['status'] == 'Pending'
          ? () async {
              await showSheet(context, _AssignmentDetailSheet(
                title: a['title'],
                subject: a['sub'],
                due: a['due'],
                color: a['color'],
                onSubmit: () {
                  setState(() => a['status'] = 'Submitted');
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

class _Grades extends StatelessWidget {
  const _Grades();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

class _Attendance extends StatelessWidget {
  const _Attendance();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
