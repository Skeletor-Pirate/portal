import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../services/api_service.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class AccountantPages extends StatelessWidget {
  final String page;
  const AccountantPages({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':    return const _Dashboard();
      case 'invoices':     return const _Invoices();
      case 'feestructure': return const _FeeStructure();
      case 'reconcile':    return const _Reconcile();
      case 'manualpay':    return const _ManualPay();
      case 'authorize':    return const _Authorize();
      case 'reports':      return const _Reports();
      default:             return defaultPage(page);
    }
  }
}

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
    final cfg    = kRoles[UserRole.accountant]!;
    final name   = _profile?.displayName ?? cfg.name;
    final school = _profile?.schoolName  ?? 'Westfield Academy';
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(cfg.avatarAsset, school),
      profileInfo(name, 'Finance Department', cfg.idLabel),
      pageTitle('Dashboard', subtitle: 'Financial overview · Term 2'),
      finBanner('Collected — Term 2', '18.4L', '82% collection · 243 of 298 invoices paid'),
      statGrid([
        StatItem(icon: Icons.receipt_long_rounded, iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '298', label: 'Total Invoices', delta: 12),
        StatItem(icon: Icons.task_alt_rounded,     iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '243', label: 'Paid',           delta: 18),
        StatItem(icon: Icons.access_time_rounded,  iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '41',  label: 'Pending',        delta: -5),
        StatItem(icon: Icons.error_outline_rounded,iconBg: AppColors.redLight,   iconColor: AppColors.red,   val: '14',  label: 'Overdue',        delta: -3),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: Icons.note_add_rounded,       label: 'New Invoice',  bg: AppColors.redLight,   iconColor: AppColors.red),
        ActionItem(icon: Icons.currency_rupee_rounded, label: 'Fee Structure',bg: AppColors.amberLight, iconColor: AppColors.amber),
        ActionItem(icon: Icons.sync_rounded,           label: 'Reconcile',    bg: AppColors.greenLight, iconColor: AppColors.green),
        ActionItem(icon: Icons.edit_note_rounded,      label: 'Manual Pay',   bg: AppColors.blueLight,  iconColor: AppColors.blue),
        ActionItem(icon: Icons.lock_open_rounded,      label: 'Authorize',    bg: AppColors.tealLight,  iconColor: AppColors.teal),
        ActionItem(icon: Icons.pie_chart_rounded,      label: 'Reports',      bg: AppColors.blueLight,  iconColor: AppColors.blue),
      ]),
      secLabel('Recent Transactions'),
      appCard(invRows([
        InvItem(id: 'INV-089', name: 'Maya Johnson',    type: 'Term 2 Tuition', amount: '₹24,500', status: 'Paid',    badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-088', name: 'Arjun Mehta',     type: 'Term 2 Tuition', amount: '₹24,500', status: 'Pending', badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        InvItem(id: 'INV-087', name: 'Leo Chen',        type: 'Activity Fee',   amount: '₹3,200',  status: 'Paid',    badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-086', name: 'Sofia Rodriguez', type: 'Exam Fee',       amount: '₹1,800',  status: 'Overdue', badgeBg: AppColors.redLight,   badgeColor: AppColors.red),
      ])),
      const SizedBox(height: 16),
    ],
  );
  }
}

class _Invoices extends StatelessWidget {
  const _Invoices();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Invoices'),
      searchBar(placeholder: 'Search invoices...'),
      const ChipRow(chips: ['All', 'Paid', 'Pending', 'Overdue']),
      appCard(invRows([
        InvItem(id: 'INV-089', name: 'Maya Johnson',    type: 'Term 2 Tuition · Apr 1', amount: '₹24,500', status: 'Paid',    badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-088', name: 'Arjun Mehta',     type: 'Term 2 Tuition · Apr 1', amount: '₹24,500', status: 'Pending', badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        InvItem(id: 'INV-087', name: 'Leo Chen',        type: 'Activity Fee · Apr 1',   amount: '₹3,200',  status: 'Paid',    badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-086', name: 'Sofia Rodriguez', type: 'Exam Fee · Mar 20',      amount: '₹1,800',  status: 'Overdue', badgeBg: AppColors.redLight,   badgeColor: AppColors.red),
        InvItem(id: 'INV-085', name: 'Zara Williams',   type: 'Term 2 Tuition · Apr 1', amount: '₹24,500', status: 'Paid',    badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
      ])),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: navyBtn('+ Generate Invoice')),
      const SizedBox(height: 16),
    ],
  );
}

class _FeeStructure extends StatelessWidget {
  const _FeeStructure();
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Tuition Fee',  '₹24,500', '₹28,000'),
      ('Activity Fee', '₹3,200',  '₹3,200'),
      ('Lab Fee',      '₹1,500',  '₹2,500'),
      ('Exam Fee',     '₹1,800',  '₹2,200'),
      ('Transport',    '₹4,500',  '₹4,500'),
      ('Library',      '₹800',    '₹800'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      pageTitle('Fee Structure', subtitle: 'Academic Year 2024–25'),
      appCard(Table(
        columnWidths: const {0: FlexColumnWidth(1.8), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.2)},
        children: [
          TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: ['Fee Type', 'Gr 9–10', 'Gr 11–12'].map((h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(h.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppColors.text4)),
            )).toList(),
          ),
          ...rows.map((r) => TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            children: [
              Padding(padding: const EdgeInsets.all(10), child: Text(r.$1, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text1))),
              Padding(padding: const EdgeInsets.all(10), child: Text(r.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1))),
              Padding(padding: const EdgeInsets.all(10), child: Text(r.$3, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1))),
            ],
          )),
          TableRow(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border2, width: 2))),
            children: [
              Padding(padding: const EdgeInsets.all(10), child: Text('Annual Total', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text1))),
              Padding(padding: const EdgeInsets.all(10), child: Text('₹1,08,000', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
              Padding(padding: const EdgeInsets.all(10), child: Text('₹1,22,400', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
            ],
          ),
        ],
      )),
      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 8), child: outlineBtn('Edit Fee Structure')),
      const SizedBox(height: 16),
    ]);
  }
}

class _Reconcile extends StatelessWidget {
  const _Reconcile();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Reconcile Payments', subtitle: 'Match & verify transactions'),
      statGrid([
        StatItem(icon: Icons.task_alt_rounded, iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '243', label: 'Matched',   delta: 0),
        StatItem(icon: Icons.error_outline_rounded, iconBg: AppColors.amberLight, iconColor: AppColors.amber, val: '12',  label: 'Unmatched', delta: 0),
      ]),
      secLabel('Unmatched Payments'),
      appCard(Column(children: [
        ...[
          ('TXN-7821', 'Unknown Sender', '₹24,500', 'Apr 2',  'No invoice ref'),
          ('TXN-7798', 'R. Sharma',      '₹3,200',  'Mar 31', 'Partial match'),
          ('TXN-7765', 'K. Patel',       '₹1,800',  'Mar 28', 'Amount mismatch'),
        ].map((p) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.amberLight, borderRadius: BorderRadius.circular(rMd)),
              child: const Center(child: Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.amber)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.$1} · ${p.$2}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              Text('${p.$3} · ${p.$4} · ${p.$5}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text3)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border2, width: 1.5), borderRadius: BorderRadius.circular(rSm)),
              child: Text('Match', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2)),
            ),
          ]),
        )),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _ManualPay extends StatelessWidget {
  const _ManualPay();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Manual Payment', subtitle: 'Record cash or cheque'),
      appCard(Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        fieldGroup(label: 'Student Name / ID', child: TextField(decoration: fieldDecoration('Search student...'))),
        fieldGroup(label: 'Invoice Number',    child: TextField(decoration: fieldDecoration('INV-XXXX'))),
        fieldGroup(label: 'Amount (₹)',        child: TextField(keyboardType: TextInputType.number, decoration: fieldDecoration('0.00'))),
        fieldGroup(label: 'Payment Method',    child: DropdownButtonFormField<String>(
          decoration: fieldDecoration(''),
          value: 'Cash',
          items: ['Cash', 'Cheque', 'Bank Transfer', 'Demand Draft']
              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
          onChanged: (_) {},
        )),
        fieldGroup(label: 'Reference / Cheque No.', child: TextField(decoration: fieldDecoration('Reference number'))),
        fieldGroup(label: 'Date',  child: TextField(keyboardType: TextInputType.datetime, decoration: fieldDecoration('DD/MM/YYYY'))),
        fieldGroup(label: 'Notes', child: TextField(decoration: fieldDecoration('Optional notes'))),
        navyBtn('Record Payment'),
      ]))),
      const SizedBox(height: 16),
    ],
  );
}

class _Authorize extends StatelessWidget {
  const _Authorize();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Authorize Transactions', subtitle: 'Review pending payments'),
      authCard(const AuthCardItem(name: 'Priya Mehta', desc: 'Term 2 Online Payment', amount: '₹24,500', via: 'Razorpay', id: 'PAY-4421')),
      authCard(const AuthCardItem(name: 'John Carter', desc: 'Activity Fee',           amount: '₹3,200',  via: 'Stripe',   id: 'PAY-4420')),
      authCard(const AuthCardItem(name: 'Aiko Tanaka', desc: 'Exam Fee',               amount: '₹1,800',  via: 'Razorpay', id: 'PAY-4419')),
      const SizedBox(height: 16),
    ],
  );
}

class _Reports extends StatelessWidget {
  const _Reports();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Financial Reports'),
      statGrid([
        StatItem(icon: Icons.currency_rupee_rounded, iconBg: AppColors.greenLight, iconColor: AppColors.green, val: '₹18.4L', label: 'Collected',       delta: 12),
        StatItem(icon: Icons.pie_chart_rounded,    iconBg: AppColors.blueLight,  iconColor: AppColors.blue,  val: '82%',    label: 'Collection Rate', delta: 5),
      ]),
      secLabel('Collection by Grade'),
      appCard(Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        ProgressBar(label: 'Grade 9',  value: 88, gradient: blueGrad()),
        ProgressBar(label: 'Grade 10', value: 94, gradient: greenGrad()),
        ProgressBar(label: 'Grade 11', value: 78, gradient: amberGrad()),
        ProgressBar(label: 'Grade 12', value: 71, gradient: tealGrad()),
      ]))),
      secLabel('Monthly Summary'),
      appCard(Column(children: [
        ...[
          ('January 2025',  '₹6.2L',  '94%'),
          ('February 2025', '₹5.8L',  '88%'),
          ('March 2025',    '₹4.9L',  '74%'),
          ('April 2025',    '₹1.5L',  '23%'),
        ].map((r) {
          final pct = int.parse(r.$3.replaceAll('%', ''));
          return listItem(
            avIcon: Icons.calendar_month_rounded, avBg: AppColors.blueLight, avColor: AppColors.blue,
            name: r.$1, sub: 'Collected: ${r.$2}',
            badgeText: r.$3,
            badgeBg:    pct >= 80 ? AppColors.greenLight : AppColors.amberLight,
            badgeColor: pct >= 80 ? AppColors.green      : AppColors.amber,
          );
        }),
      ])),
      const SizedBox(height: 16),
    ],
  );
}
