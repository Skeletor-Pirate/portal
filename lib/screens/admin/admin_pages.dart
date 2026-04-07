import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
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

class _Dashboard extends StatelessWidget {
  const _Dashboard();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(kRoles[UserRole.admin]!.avatarAsset, 'Westfield Academy'),
      profileInfo('Dr. Chris Patel', 'School Administrator', 'Admin ID: #WA-0012'),
      pageTitle('Dashboard', subtitle: 'Westfield Academy · Term 2 · 2024–25'),
      statGrid([
        StatItem(icon: Icons.school_rounded, iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '1,240', label: 'Students',   delta: 5),
        StatItem(icon: Icons.menu_book_rounded,      iconBg: AppColors.tealLight,  iconColor: AppColors.teal,  val: '84',    label: 'Teachers',   delta: 2),
        StatItem(icon: Icons.group_rounded,         iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '1,180', label: 'Parents',    delta: 0),
        StatItem(icon: Icons.fact_check_rounded,iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '94%',   label: 'Attendance', delta: 1),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.person_add_rounded,    label: 'Add Student',   bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.add_card_rounded,     label: 'Add Teacher',   bg: AppColors.tealLight,  iconColor: AppColors.teal),
        ActionItem(icon: Icons.how_to_reg_rounded,    label: 'Add Parent',    bg: AppColors.greenLight, iconColor: AppColors.green),
        ActionItem(icon: Icons.verified_user_rounded,  label: 'Roles',         bg: AppColors.amberLight, iconColor: AppColors.amber),
        ActionItem(icon: Icons.calendar_month_rounded, label: 'Academic Yr',   bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.star_rounded,         label: 'Grading',       bg: AppColors.redLight,   iconColor: AppColors.red),
      ]),
      secLabel('Recent Activity'),
      appCard(Padding(padding: const EdgeInsets.all(16), child: timeline([
        TlItem(title: 'Student Enrolled',         sub: 'Aisha Okonkwo — Grade 10B',      time: '5m ago',  color: AppColors.blue),
        TlItem(title: 'Teacher Profile Updated',  sub: 'Mr. James Hoang — Math',          time: '22m ago', color: AppColors.teal),
        TlItem(title: 'Academic Year Configured', sub: 'Term 2 activated',                time: '1h ago',  color: AppColors.green),
        TlItem(title: 'Role Permissions Updated', sub: 'Parent role — grades view added', time: '3h ago',  color: AppColors.amber),
      ]))),
      const SizedBox(height: 16),
    ],
  );
}

class _Students extends StatelessWidget {
  const _Students();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Students'),
      searchBar(placeholder: 'Search students...'),
      const ChipRow(chips: ['All', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12']),
      appCard(Column(children: [
        ...[
          ('Maya Johnson',    'Grade 10B', '#042', '96%'),
          ('Arjun Mehta',     'Grade 10A', '#018', '88%'),
          ('Zara Williams',   'Grade 11C', '#067', '92%'),
          ('Leo Chen',        'Grade 9A',  '#005', '100%'),
          ('Sofia Rodriguez', 'Grade 12B', '#091', '84%'),
        ].map((s) {
          final initials = s.$1.split(' ').map((x) => x[0]).join('');
          final pct = int.parse(s.$4.replaceAll('%', ''));
          return listItem(
            avIcon: Icons.person_rounded, avBg: AppColors.avNavy, avColor: AppColors.navy,
            avInitials: initials,
            name: s.$1, sub: '${s.$2} · Roll ${s.$3}',
            badgeText: s.$4,
            badgeBg:    pct >= 90 ? AppColors.greenLight : AppColors.amberLight,
            badgeColor: pct >= 90 ? AppColors.green      : AppColors.amber,
          );
        }),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Student Profile')),
      const SizedBox(height: 16),
    ],
  );
}

class _Teachers extends StatelessWidget {
  const _Teachers();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Teachers'),
      searchBar(placeholder: 'Search teachers...'),
      appCard(Column(children: [
        ...[
          ('Dr. Elena Vance', 'Science',     AppColors.avTeal,  AppColors.teal),
          ('Mr. James Hoang', 'Mathematics', AppColors.avBlue,  AppColors.blue),
          ('Ms. Sarah Kim',   'English',     AppColors.avNavy,  AppColors.navy),
          ('Mr. David Osei',  'History',     AppColors.avAmber, AppColors.amber),
        ].map((t) => listItem(
          avIcon: Icons.person_rounded, avBg: t.$3, avColor: t.$4,
          avInitials: t.$1.split(' ').last[0],
          name: t.$1, sub: t.$2,
          badgeText: t.$2.split(' ')[0],
          badgeBg: t.$3, badgeColor: t.$4,
        )),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Create Teacher Profile')),
      const SizedBox(height: 16),
    ],
  );
}

class _Users extends StatelessWidget {
  const _Users();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
    ],
  );
}

class _Academic extends StatelessWidget {
  const _Academic();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
        ProgressBar(label: 'Term 1', value: 100, gradient: greenGrad()),
        ProgressBar(label: 'Term 2', value: 58,  gradient: blueGrad()),
        ProgressBar(label: 'Term 3', value: 0,   gradient: amberGrad()),
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
    ],
  );
}

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
              child: Text(h.toUpperCase(), style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
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

class _Mapping extends StatelessWidget {
  const _Mapping();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
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
    ],
  );
}

class _Parents extends StatelessWidget {
  const _Parents();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Parents'),
      searchBar(placeholder: 'Search parents...'),
      appCard(Column(children: [
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
    ],
  );
}
