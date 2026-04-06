import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../models/role_config.dart';
import '../../widgets/builders.dart';
import '../page_router.dart';

class AccountantPages extends StatelessWidget {
  final String page;
  const AccountantPages({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case 'dashboard':    return _Dashboard();
      case 'invoices':     return _Invoices();
      case 'feestructure': return _FeeStructure();
      case 'reconcile':    return _Reconcile();
      case 'manualpay':    return _ManualPay();
      case 'authorize':    return _Authorize();
      case 'reports':      return _Reports();
      default:             return defaultPage(page);
    }
  }
}

class _Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      heroPortrait(kRoles[UserRole.accountant]!.avatarAsset, 'Westfield Academy'),
      profileInfo('Leon Burke', 'Finance Department', 'Staff ID: #WA-F-007'),
      pageTitle('Dashboard', subtitle: 'Financial overview · Term 2'),
      finBanner('Collected — Term 2', '18.4L', '82% collection · 243 of 298 invoices paid'),
      statGrid([
        const StatItem(icon: '🧾', val: '298', label: 'Total Invoices', delta: 12),
        const StatItem(icon: '✅', val: '243', label: 'Paid',           delta: 18),
        const StatItem(icon: '⏳', val: '41',  label: 'Pending',        delta: -5),
        const StatItem(icon: '❌', val: '14',  label: 'Overdue',        delta: -3),
      ]),
      secLabel('Quick Actions'),
      actionGrid([
        ActionItem(icon: '🧾', label: 'New Invoice',   bg: AppColors.redLight),
        ActionItem(icon: '💰', label: 'Fee Structure',  bg: AppColors.amberLight),
        ActionItem(icon: '🔄', label: 'Reconcile',     bg: AppColors.greenLight),
        ActionItem(icon: '📝', label: 'Manual Pay',    bg: AppColors.blueLight),
        ActionItem(icon: '🔐', label: 'Authorize',     bg: AppColors.tealLight),
        ActionItem(icon: '📈', label: 'Reports',       bg: AppColors.blueLight),
      ]),
      secLabel('Recent Transactions'),
      appCard(invRows([
        InvItem(id: 'INV-089', name: 'Maya Johnson',    type: 'Term 2 Tuition',
            amount: '₹24,500', status: 'Paid',
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-088', name: 'Arjun Mehta',     type: 'Term 2 Tuition',
            amount: '₹24,500', status: 'Pending',
            badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        InvItem(id: 'INV-087', name: 'Leo Chen',        type: 'Activity Fee',
            amount: '₹3,200',  status: 'Paid',
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-086', name: 'Sofia Rodriguez', type: 'Exam Fee',
            amount: '₹1,800',  status: 'Overdue',
            badgeBg: AppColors.redLight, badgeColor: AppColors.red),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _Invoices extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Invoices'),
      searchBar(placeholder: 'Search invoices...'),
      const ChipRow(chips: ['All', 'Paid', 'Pending', 'Overdue']),
      appCard(invRows([
        InvItem(id: 'INV-089', name: 'Maya Johnson',    type: 'Term 2 Tuition · Apr 1',
            amount: '₹24,500', status: 'Paid',
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-088', name: 'Arjun Mehta',     type: 'Term 2 Tuition · Apr 1',
            amount: '₹24,500', status: 'Pending',
            badgeBg: AppColors.amberLight, badgeColor: AppColors.amber),
        InvItem(id: 'INV-087', name: 'Leo Chen',        type: 'Activity Fee · Apr 1',
            amount: '₹3,200',  status: 'Paid',
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
        InvItem(id: 'INV-086', name: 'Sofia Rodriguez', type: 'Exam Fee · Mar 20',
            amount: '₹1,800',  status: 'Overdue',
            badgeBg: AppColors.redLight, badgeColor: AppColors.red),
        InvItem(id: 'INV-085', name: 'Zara Williams',   type: 'Term 2 Tuition · Apr 1',
            amount: '₹24,500', status: 'Paid',
            badgeBg: AppColors.greenLight, badgeColor: AppColors.green),
      ])),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: navyBtn('+ Generate Invoice'),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _FeeStructure extends StatelessWidget {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pageTitle('Fee Structure', subtitle: 'Academic Year 2024–25'),
        appCard(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.8), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border))),
                children: ['Fee Type', 'Gr 9–10', 'Gr 11–12'].map((h) => Padding(
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
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1))),
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text(r.$3, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text1))),
                ],
              )),
              // Total row
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border2, width: 2))),
                children: [
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text('Annual Total', style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text1))),
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text('₹1,08,000', style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
                  Padding(padding: const EdgeInsets.all(10),
                      child: Text('₹1,22,400', style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: outlineBtn('✏️  Edit Fee Structure'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Reconcile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Reconcile Payments', subtitle: 'Match & verify transactions'),
      statGrid([
        const StatItem(icon: '✅', val: '243', label: 'Matched',   delta: 0),
        const StatItem(icon: '⚠️', val: '12',  label: 'Unmatched', delta: 0),
      ]),
      secLabel('Unmatched Payments'),
      appCard(Column(children: [
        ...[
          ('TXN-7821', 'Unknown Sender', '₹24,500', 'Apr 2',  'No invoice ref'),
          ('TXN-7798', 'R. Sharma',      '₹3,200',  'Mar 31', 'Partial match'),
          ('TXN-7765', 'K. Patel',       '₹1,800',  'Mar 28', 'Amount mismatch'),
        ].map((p) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                  color: AppColors.amberLight, borderRadius: BorderRadius.circular(rSm)),
              child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${p.$1} · ${p.$2}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
              Text('${p.$3} · ${p.$4} · ${p.$5}', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.text3)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border2, width: 1.5),
                borderRadius: BorderRadius.circular(rSm),
              ),
              child: Text('Match', style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2)),
            ),
          ]),
        )),
      ])),
      const SizedBox(height: 16),
    ],
  );
}

class _ManualPay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Manual Payment', subtitle: 'Record cash or cheque'),
      appCard(
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            fieldGroup(
              label: 'Student Name / ID',
              child: TextField(decoration: fieldDecoration('Search student...')),
            ),
            fieldGroup(
              label: 'Invoice Number',
              child: TextField(decoration: fieldDecoration('INV-XXXX')),
            ),
            fieldGroup(
              label: 'Amount (₹)',
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: fieldDecoration('0.00'),
              ),
            ),
            fieldGroup(
              label: 'Payment Method',
              child: DropdownButtonFormField<String>(
                decoration: fieldDecoration(''),
                value: 'Cash',
                items: ['Cash', 'Cheque', 'Bank Transfer', 'Demand Draft']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text1))))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
            fieldGroup(
              label: 'Reference / Cheque No.',
              child: TextField(decoration: fieldDecoration('Reference number')),
            ),
            fieldGroup(
              label: 'Date',
              child: TextField(
                decoration: fieldDecoration('DD/MM/YYYY'),
                keyboardType: TextInputType.datetime,
              ),
            ),
            fieldGroup(
              label: 'Notes',
              child: TextField(decoration: fieldDecoration('Optional notes')),
            ),
            navyBtn('💾  Record Payment'),
          ]),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

class _Authorize extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final txns = [
      AuthCardItem(name: 'Priya Mehta',  desc: 'Term 2 Online Payment', amount: '₹24,500', via: 'Razorpay', id: 'PAY-4421'),
      AuthCardItem(name: 'John Carter',  desc: 'Activity Fee',           amount: '₹3,200',  via: 'Stripe',   id: 'PAY-4420'),
      AuthCardItem(name: 'Aiko Tanaka',  desc: 'Exam Fee',               amount: '₹1,800',  via: 'Razorpay', id: 'PAY-4419'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pageTitle('Authorize Transactions', subtitle: 'Review pending payments'),
        ...txns.map((t) => authCard(t)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Reports extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      pageTitle('Financial Reports'),
      statGrid([
        const StatItem(icon: '💰', val: '₹18.4L', label: 'Collected',       delta: 12),
        const StatItem(icon: '📊', val: '82%',    label: 'Collection Rate', delta: 5),
      ]),
      secLabel('Collection by Grade'),
      appCard(
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            ProgressBar(label: 'Grade 9',  value: 88, gradient: blueGrad()),
            ProgressBar(label: 'Grade 10', value: 94, gradient: greenGrad()),
            ProgressBar(label: 'Grade 11', value: 78, gradient: amberGrad()),
            ProgressBar(label: 'Grade 12', value: 71, gradient: tealGrad()),
          ]),
        ),
      ),
      secLabel('Monthly Summary'),
      appCard(Column(children: [
        ...[
          ('January 2025',  '₹6.2L',  '94%'),
          ('February 2025', '₹5.8L',  '88%'),
          ('March 2025',    '₹4.9L',  '74%'),
          ('April 2025',    '₹1.5L',  '23%'),
        ].map((r) => listItem(
          av: '📅', avBg: AppColors.blueLight, avColor: AppColors.blue,
          name: r.$1, sub: 'Collected: ${r.$2}',
          badgeText: r.$3,
          badgeBg: int.parse(r.$3.replaceAll('%','')) >= 80
              ? AppColors.greenLight : AppColors.amberLight,
          badgeColor: int.parse(r.$3.replaceAll('%','')) >= 80
              ? AppColors.green : AppColors.amber,
        )),
      ])),
      const SizedBox(height: 16),
    ],
  );
}
