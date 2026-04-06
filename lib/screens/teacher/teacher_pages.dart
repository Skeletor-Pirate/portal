import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class TeacherPages extends StatelessWidget {
  final String page;
  const TeacherPages({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':   return _Dashboard();
      case 'attendance':  return _Attendance();
      case 'assignments': return _Assignments();
      case 'grades':      return _Grades();
      case 'timetable':   return _Timetable();
      case 'exams':       return _Exams();
      case 'analytics':   return _Analytics();
      default:            return defaultPage(page);
    }
  }
}

class _Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(kRoles[UserRole.teacher]!.avatarAsset, 'Westfield Academy'),
      profileInfo('Dr. Elena Vance', 'Senior Faculty · Science', 'Faculty ID: #WA-T-042'),
      pageTitle('Academic', subtitle: 'AI-Powered Portal'),
      quickStatsBar([
        const QsItem(val: '142', label: 'Students'),
        const QsItem(val: '91%', label: 'Attendance'),
        const QsItem(val: '8',   label: 'Pending'),
        const QsItem(val: '3',   label: 'Classes'),
      ]),
      secLabel("Today's Classes"),
      appCard(ttRows([
        TtItem(time: '08:00–09:30', subject: 'Physics 11-B', room: 'Lab 2',
            status: 'Completed', barColor: AppColors.teal,
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        TtItem(time: '10:15–11:45', subject: 'Science 10-A', room: 'Room 204',
            status: 'Active', barColor: AppColors.blue,
            badgeBg: AppColors.blueLight, badgeColor: AppColors.blue),
        TtItem(time: '13:00–14:30', subject: 'Chemistry 12', room: 'Lab 3',
            status: 'Upcoming', barColor: AppColors.navy,
            badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      ])),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: '✅', label: 'Mark Attendance', bg: AppColors.greenLight),
        ActionItem(icon: '📋', label: 'New Assignment',  bg: AppColors.blueLight),
        ActionItem(icon: '📊', label: 'Record Grades',   bg: AppColors.tealLight),
        ActionItem(icon: '📝', label: 'Exam Grades',     bg: AppColors.amberLight),
        ActionItem(icon: '📈', label: 'Analytics',       bg: AppColors.blueLight),
        ActionItem(icon: '📢', label: 'Announce',        bg: AppColors.redLight),
      ]),
      const SizedBox(height: 16),
    ],
  );
}

class _Attendance extends StatefulWidget {
  @override
  State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  final Map<String, String> _status = {
    'Aisha Okonkwo': 'present',
    'Ben Carter':    'absent',
    'Clara Singh':   'present',
    'David Lee':     'late',
    'Eva Martinez':  'present',
    'Felix Brown':   'present',
  };

  @override
  Widget build(BuildContext context) {
    final students = [
      ('Aisha Okonkwo', '01'),
      ('Ben Carter',    '02'),
      ('Clara Singh',   '03'),
      ('David Lee',     '04'),
      ('Eva Martinez',  '05'),
      ('Felix Brown',   '06'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pageTitle('Attendance', subtitle: 'Mark daily attendance'),
        const ChipRow(chips: ['Science 10-A', 'Physics 11-B', 'Chemistry 12']),
        appCard(Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Science 10-A · Today',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
              appBadge('28 Students', bg: AppColors.blueLight, color: AppColors.blue),
            ]),
          ),
          ...students.map((st) {
            final cur = _status[st.$1] ?? 'present';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(rSm)),
                  child: Center(child: Text(
                    st.$1.split(' ').map((x) => x[0]).join(''),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(st.$1, style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                  Text('Roll #${st.$2}', style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.text3)),
                ])),
                Row(children: [
                  _attBtn(cur, 'present', '✓', AppColors.green, AppColors.greenLight),
                  const SizedBox(width: 5),
                  _attBtn(cur, 'late',    '~', AppColors.amber, AppColors.amberLight),
                  const SizedBox(width: 5),
                  _attBtn(cur, 'absent',  '✗', AppColors.red,   AppColors.redLight),
                ]),
              ]),
            );
          }),
        ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: navyBtn('💾  Save Attendance'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _attBtn(String cur, String val, String sym, Color color, Color bg) =>
      GestureDetector(
        onTap: () => setState(() => _status.updateAll((k, v) => v)),
        child: Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: cur == val ? color : AppColors.border, width: 1.5),
            color: cur == val ? bg : Colors.transparent,
          ),
          child: Center(
            child: Text(sym,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: cur == val ? color : AppColors.text4)),
          ),
        ),
      );
}

class _Assignments extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Assignments'),
      const ChipRow(chips: ['All', 'Active', 'Submitted', 'Graded']),
      appCard(asgnCards([
        AsgItem(sub: 'PHYSICS',   title: 'Chapter 5: Forces & Motion',  due: 'Due Apr 5',
            barColor: AppColors.teal,  badge: '22/28 submitted',
            badgeBg: AppColors.blueLight, badgeColor: AppColors.blue),
        AsgItem(sub: 'SCIENCE',   title: 'Ecosystem Lab Report',         due: 'Due Apr 10',
            barColor: AppColors.blue,  badge: '0/28 submitted',
            badgeBg: AppColors.blueLight, badgeColor: AppColors.blue),
        AsgItem(sub: 'CHEMISTRY', title: 'Periodic Table — Module 4',    due: 'Due Apr 8',
            barColor: AppColors.navy,  badge: '18/24 submitted',
            badgeBg: AppColors.blueLight, badgeColor: AppColors.blue),
      ])),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: navyBtn('+ Create Assignment'),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _Grades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('A. Okonkwo', '94', 'A+', AppColors.greenLight,  AppColors.green),
      ('B. Carter',  '67', 'B',  AppColors.blueLight,   AppColors.blue),
      ('C. Singh',   '88', 'A',  AppColors.greenLight,  AppColors.green),
      ('D. Lee',     '45', 'D',  AppColors.amberLight,  AppColors.amber),
      ('E. Martinez','78', 'B+', AppColors.blueLight,   AppColors.blue),
      ('F. Brown',   '91', 'A+', AppColors.greenLight,  AppColors.green),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pageTitle('Record Grades', subtitle: 'Science 10-A · Mid-Term'),
        appCard(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border))),
                children: ['Student', 'Score', 'Grade'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(h.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          letterSpacing: 1.5, color: AppColors.text4)),
                )).toList(),
              ),
              ...rows.map((r) => TableRow(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border))),
                children: [
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text(r.$1, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: AppColors.text1))),
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text(r.$2, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text1))),
                  Padding(padding: const EdgeInsets.all(10),
                      child: appBadge(r.$3, bg: r.$4, color: r.$5)),
                ],
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: navyBtn('💾  Publish Grades'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Timetable extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('My Timetable'),
      const ChipRow(chips: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      appCard(ttRows([
        TtItem(time: '08:00–09:30', subject: 'Physics 11-B',    room: 'Lab 2',
            status: 'Done',     barColor: AppColors.teal,
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        TtItem(time: '10:15–11:45', subject: 'Science 10-A',    room: 'Room 204',
            status: 'Active',   barColor: AppColors.blue,
            badgeBg: AppColors.blueLight, badgeColor: AppColors.blue),
        TtItem(time: '13:00–14:30', subject: 'Chemistry 12',    room: 'Lab 3',
            status: 'Upcoming', barColor: AppColors.navy,
            badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
        TtItem(time: '15:00–15:45', subject: 'Staff Meeting',   room: 'Conference',
            status: 'Upcoming', barColor: AppColors.amber,
            badgeBg: const Color(0xFFF1F5F9), badgeColor: AppColors.text3),
      ])),
      secLabel('Class Performance'),
      appCard(
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            ProgressBar(label: 'Science 10-A Attendance',  value: 94, gradient: greenGrad()),
            ProgressBar(label: 'Physics 11-B Attendance',  value: 88, gradient: blueGrad()),
            ProgressBar(label: 'Chemistry 12 Attendance',  value: 97, gradient: tealGrad()),
          ]),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _Exams extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Exams', subtitle: 'Upcoming & recent examinations'),
      const ChipRow(chips: ['All', 'Upcoming', 'Completed']),
      appCard(Column(children: [
        ...[
          ('PHYSICS',   'Mid-Term Examination',     'Apr 12, 2025 · 10:00 AM', 'Lab 2',    'Upcoming'),
          ('SCIENCE',   'Unit 3 Test',              'Apr 8,  2025 · 09:00 AM', 'Room 204', 'Upcoming'),
          ('CHEMISTRY', 'Practical Assessment',     'Mar 28, 2025',            'Lab 3',    'Completed'),
        ].map((e) {
          final upcoming = e.$5 == 'Upcoming';
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(rSm)),
                child: const Center(child: Text('📝', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.$1, style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 1.0, color: AppColors.blue)),
                Text(e.$2, style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
                Text('${e.$3} · ${e.$4}', style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.text3)),
              ])),
              appBadge(e.$5,
                  bg:    upcoming ? AppColors.amberLight : AppColors.greenLight,
                  color: upcoming ? AppColors.amber      : AppColors.green),
            ]),
          );
        }),
      ])),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: navyBtn('+ Schedule Exam'),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _Analytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Student Analytics', subtitle: 'Class performance insights'),
      statGrid([
        const StatItem(icon: '📊', val: '78%', label: 'Class Avg',   delta: 3),
        const StatItem(icon: '🏆', val: '6',   label: 'Top Scorers', delta: 0),
        const StatItem(icon: '⚠️', val: '4',   label: 'At Risk',     delta: -2),
        const StatItem(icon: '📈', val: '91%', label: 'Attendance',  delta: 1),
      ]),
      secLabel('Subject Averages'),
      appCard(
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            ProgressBar(label: 'Physics',   value: 82, gradient: tealGrad()),
            ProgressBar(label: 'Science',   value: 75, gradient: blueGrad()),
            ProgressBar(label: 'Chemistry', value: 68, gradient: amberGrad()),
          ]),
        ),
      ),
      secLabel('✦ AI Insight'),
      appCard(
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            _insightRow(AppColors.blue, '📈 Grade Trend',
                'Class average increased 5% over the past 3 weeks. Physics scores show the most improvement.'),
            const SizedBox(height: 14),
            _insightRow(AppColors.amber, '⚠️ At-Risk Students',
                '4 students are scoring below 50%. Early intervention recommended for David Lee and 3 others.'),
            const SizedBox(height: 14),
            _insightRow(AppColors.green, '✅ Attendance Impact',
                'Students with >90% attendance score 18% higher on average than those below 75%.'),
          ]),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _insightRow(Color color, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 3, height: 50, color: color,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(rFull))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
        const SizedBox(height: 4),
        Text(body, style: GoogleFonts.plusJakartaSans(
            fontSize: 12, color: AppColors.text3, height: 1.5)),
      ])),
    ],
  );
}
