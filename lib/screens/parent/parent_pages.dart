import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class ParentPages extends StatelessWidget {
  final String page;
  const ParentPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':     return const _Dashboard();
      case 'childoverview': return const _ChildOverview();
      case 'grades':        return const _Grades();
      case 'attendance':    return const _Attendance();
      case 'assignments':   return const _Assignments();
      case 'payments':      return const _Payments();
      case 'insights':      return const _Insights();
      default:              return defaultPage(page);
    }
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(kRoles[UserRole.parent]!.avatarAsset, 'Westfield Academy'),
      profileInfo('Alexander Pierce', 'Guardian', 'Guardian ID: #8821'),
      pageTitle('Dashboard'),
      childCard(),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.bar_chart_rounded,    label: "Child Grades",   bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.fact_check_rounded,label: 'Attendance',    bg: AppColors.greenLight, iconColor: AppColors.green),
        ActionItem(icon: Icons.description_rounded,      label: 'Assignments',   bg: AppColors.tealLight,  iconColor: AppColors.teal),
        ActionItem(icon: Icons.credit_card_rounded,    label: 'Pay Fees',      bg: AppColors.redLight,   iconColor: AppColors.red),
        ActionItem(icon: Icons.auto_awesome_rounded,      label: 'AI Insights',   bg: AppColors.amberLight, iconColor: AppColors.amber),
        ActionItem(icon: Icons.chat_rounded, label: 'Message',       bg: AppColors.blueLight,  iconColor: AppColors.blue),
      ]),
      secLabel('Recent Updates'),
      appCard(Padding(padding: const EdgeInsets.all(16), child: timeline([
        TlItem(title: 'Grade Posted',       sub: 'Math Mid-Term: 82/100 · B+',    time: 'Today',      color: AppColors.blue),
        TlItem(title: 'Attendance Alert',   sub: 'Late arrival on Apr 1',          time: '2 days ago', color: AppColors.amber),
        TlItem(title: 'Assignment Graded',  sub: 'History Essay: A · Great work!', time: '3 days ago', color: AppColors.green),
        TlItem(title: 'Fee Due Reminder',   sub: 'Term 2 fee due Apr 15',          time: 'Apr 1',      color: AppColors.red),
      ]))),
      const SizedBox(height: 16),
    ],
  );
}

class _ChildOverview extends StatelessWidget {
  const _ChildOverview();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Child Overview', subtitle: 'Arjun Mehta · Grade 10A'),
      statGrid([
        StatItem(icon: Icons.bar_chart_rounded,     iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '88%', label: 'Avg Grade',     delta: 3),
        StatItem(icon: Icons.fact_check_rounded,iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '91%', label: 'Attendance',    delta: 1),
        StatItem(icon: Icons.description_rounded,       iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '2',   label: 'Pending Tasks', delta: 0),
        StatItem(icon: Icons.emoji_events_rounded,         iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: 'B+',  label: 'GPA Band',      delta: 0),
      ]),
      secLabel('Subject Grades'),
      appCard(GradeBars(items: [
        GradeItem(subject: 'Mathematics', value: 82, color: AppColors.blue),
        GradeItem(subject: 'English',     value: 79, color: AppColors.navy),
        GradeItem(subject: 'Physics',     value: 91, color: AppColors.teal),
        GradeItem(subject: 'Chemistry',   value: 85, color: AppColors.green),
        GradeItem(subject: 'History',     value: 76, color: AppColors.amber),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Grades extends StatelessWidget {
  const _Grades();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Grades & Report Card', subtitle: 'Arjun Mehta'),
      appCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('83.5%', style: GoogleFonts.dmSerifDisplay(fontSize: 26, color: AppColors.text1)),
              Text("Arjun's Average · Term 2", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(gradient: blueGrad(), borderRadius: BorderRadius.circular(rFull)),
              child: Text('B+', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        GradeBars(items: [
          GradeItem(subject: 'Mathematics', value: 82, color: AppColors.blue),
          GradeItem(subject: 'English',     value: 79, color: AppColors.navy),
          GradeItem(subject: 'Physics',     value: 91, color: AppColors.teal),
          GradeItem(subject: 'Chemistry',   value: 85, color: AppColors.green),
          GradeItem(subject: 'History',     value: 76, color: AppColors.amber),
        ]),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Attendance extends StatelessWidget {
  const _Attendance();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Attendance', subtitle: "Arjun's attendance record"),
      appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _attStat('91%', AppColors.green,  'Overall'),
          _attStat('46',  AppColors.blue,   'Present'),
          _attStat('3',   AppColors.red,    'Absent'),
          _attStat('2',   AppColors.amber,  'Late'),
        ]),
        const Divider(height: 28, color: AppColors.border),
        ProgressBar(label: 'Attendance Rate', value: 91, gradient: greenGrad()),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.text4),
          const SizedBox(width: 5),
          Text('Minimum required: 75% · Arjun is on track', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
        ]),
      ]))),
      const SizedBox(height: 16),
    ],
  );
  Widget _attStat(String val, Color color, String label) => Column(children: [
    Text(val, style: GoogleFonts.dmSerifDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.text4)),
  ]);
}

class _Assignments extends StatelessWidget {
  const _Assignments();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Assignments', subtitle: "Arjun's tasks"),
      const ChipRow(chips: ['All', 'Pending', 'Submitted', 'Graded']),
      appCard(asgnCards([
        AsgItem(sub: 'MATHEMATICS', title: 'Quadratic Equations Set B', due: 'Tomorrow', barColor: AppColors.blue,  badge: 'Pending',    badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        AsgItem(sub: 'PHYSICS',     title: 'Chapter 4 Problems',        due: 'Mar 30',   barColor: AppColors.teal,  badge: 'Submitted',  badgeBg: AppColors.blueLight,  badgeColor: AppColors.blue),
        AsgItem(sub: 'HISTORY',     title: 'WWII Analysis Essay',       due: 'Mar 25',   barColor: AppColors.green, badge: 'Graded · A', badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Payments extends StatelessWidget {
  const _Payments();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      finBanner('Fee Due — Term 2', '24,500', 'Due April 15, 2025 · Arjun Mehta'),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: navyBtn('Pay Now Online')),
      secLabel('Payment History'),
      appCard(invRows([
        InvItem(id: 'INV-089', name: 'Term 2 Tuition',  type: 'Apr 2025', amount: '₹24,500', status: 'Due',  badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        InvItem(id: 'INV-075', name: 'Term 1 Tuition',  type: 'Nov 2024', amount: '₹24,500', status: 'Paid', badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-062', name: 'Activity Fee',    type: 'Nov 2024', amount: '₹3,200',  status: 'Paid', badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-051', name: 'Examination Fee', type: 'Mar 2025', amount: '₹1,800',  status: 'Paid', badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Insights extends StatelessWidget {
  const _Insights();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('AI Insights', subtitle: 'Personalized recommendations for Arjun'),
      appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        _insight(AppColors.blue,  Icons.trending_up_rounded,    'Performance Trend',  "Arjun's Physics scores improved 8% over the last 3 tests. Consistent practice is paying off."),
        const SizedBox(height: 14),
        _insight(AppColors.amber, Icons.warning_amber_rounded, 'Attendance Warning', '3 absences this month. Ensure regular attendance to maintain the 75% minimum threshold.'),
        const SizedBox(height: 14),
        _insight(AppColors.green, Icons.trending_up_rounded,    'Predicted Grade',    'Based on current performance, final grade predicted at B+ to A− range for Term 2.'),
      ]))),
      const SizedBox(height: 16),
    ],
  );
  Widget _insight(Color color, IconData icon, String title, String body) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 3, height: 60, color: color, decoration: BoxDecoration(borderRadius: BorderRadius.circular(rFull))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
        ]),
        const SizedBox(height: 3),
        Text(body, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.5)),
      ])),
    ],
  );
}
