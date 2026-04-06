import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/role_config.dart';
import 'app_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showRoles = false;

  @override
  Widget build(BuildContext context) {
    // Light icons on our gradient status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient Hero Header ──────────────────
            _heroHeader(context),

            // ── Hero copy ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('✦ ',
                        style: TextStyle(color: AppColors.navy2, fontSize: 12)),
                    Text('The Future of Pedagogy',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy2)),
                  ]),
                  const SizedBox(height: 12),
                  Text('AI Powered School ERP\nfor Modern Education',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 30,
                          color: AppColors.text1,
                          height: 1.22)),
                  const SizedBox(height: 13),
                  Text(
                    'An intelligent platform for schools, teachers, students, '
                    'and parents — with automation, analytics, and '
                    'personalised learning support.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.text3, height: 1.7),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _showRoles = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.gradA, AppColors.gradC],
                          ),
                          borderRadius: BorderRadius.circular(rMd),
                          boxShadow: [
                            const BoxShadow(
                                color: Color(0x4D2D1B8E),
                                blurRadius: 10,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: Text('Login',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                            color: AppColors.border2, width: 1.5),
                        borderRadius: BorderRadius.circular(rMd),
                      ),
                      child: Text('View Features',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text2)),
                    ),
                  ]),
                ],
              ),
            ),

            // ── Dashboard Preview Card ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.gradA, AppColors.gradB],
                      ),
                      borderRadius: BorderRadius.circular(rLg),
                      boxShadow: shadowMd,
                    ),
                    child: Column(children: [
                      // Mac-style title bar
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(rLg),
                            topRight: Radius.circular(rLg),
                          ),
                        ),
                        child: Row(children: [
                          _dot(const Color(0xFFEF4444)),
                          const SizedBox(width: 5),
                          _dot(const Color(0xFFEAB308)),
                          const SizedBox(width: 5),
                          _dot(const Color(0xFF22C55E)),
                          const SizedBox(width: 7),
                          Text('School Management Dashboard',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.5))),
                        ]),
                      ),
                      SizedBox(
                        height: 172,
                        child: Row(children: [
                          // Sidebar
                          Container(
                            width: 38,
                            color: Colors.white.withOpacity(0.06),
                            padding: const EdgeInsets.all(6),
                            child: Column(
                                children: List.generate(
                                    5,
                                    (i) => Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 5),
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: i == 0
                                                ? AppColors.gradC
                                                : Colors.white
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ))),
                          ),
                          // Body
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(9),
                              child: Column(children: [
                                Row(children: [
                                  Expanded(
                                      flex: 6,
                                      child: Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(3)))),
                                  const SizedBox(width: 4),
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: AppColors.gradC,
                                              borderRadius:
                                                  BorderRadius.circular(3)))),
                                ]),
                                const SizedBox(height: 6),
                                ...List.generate(
                                    4,
                                    (i) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 3),
                                          child: Row(children: [
                                            Expanded(
                                                flex: 18,
                                                child: Container(
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(
                                                                0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    2)))),
                                            const SizedBox(width: 4),
                                            Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: i == 0
                                                      ? AppColors.gradC
                                                      : i == 2
                                                          ? const Color(
                                                              0xFF22C55E)
                                                          : const Color(
                                                              0xFFEAB308),
                                                )),
                                            const SizedBox(width: 4),
                                            Expanded(
                                                flex: 5,
                                                child: Container(
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(
                                                                0.08),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    2)))),
                                          ]),
                                        )),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    0.55,
                                    0.80,
                                    0.45,
                                    0.95,
                                    0.65,
                                    0.75
                                  ]
                                      .map((h) => Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              height: 40 * h,
                                              decoration: BoxDecoration(
                                                color: AppColors.gradC
                                                    .withOpacity(0.55),
                                                borderRadius:
                                                    const BorderRadius
                                                        .vertical(
                                                        top: Radius
                                                            .circular(2)),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ]),
                            ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('✦ AI Insight',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    'Student retention is predicted to increase by 12% next '
                    'quarter based on current engagement metrics.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.text3,
                        height: 1.55),
                  ),
                ],
              ),
            ),

            // ── Feature pills ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                _pill('🤖 AI Analytics'),
                _pill('📋 Attendance'),
                _pill('💳 Fee Management'),
                _pill('📚 Academics'),
                _pill('👨‍👩‍👧 Parent Portal'),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Role selector ────────────────────────
            if (_showRoles)
              _RoleSelector(onRole: _enterRole),

            // Bottom safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _enterRole(UserRole role) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AppScreen(role: role),
    ));
  }

  Widget _heroHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.white.withOpacity(0.25), width: 1.5),
              ),
              child: Center(
                child: Text('A',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 9),
            Text('Academic Architect',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3)),
          ]),
          Row(children: [
            _navLink('Features'),
            const SizedBox(width: 14),
            _navLink('Modules'),
            const SizedBox(width: 14),
            _navLink('About'),
          ]),
        ],
      ),
    );
  }

  Widget _navLink(String label) => Text(label,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.85)));

  Widget _dot(Color c) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _pill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(rFull),
          boxShadow: shadowSm,
        ),
        child: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text2)),
      );
}

// ── ROLE SELECTOR ──────────────────────────────
class _RoleSelector extends StatelessWidget {
  final void Function(UserRole) onRole;
  const _RoleSelector({required this.onRole});

  @override
  Widget build(BuildContext context) {
    final roles = [
      (
        _RoleBtn(
            icon: Icons.home_work_rounded,
            label: 'School Admin',
            bg: const Color(0xFFEBEEFF),
            iconColor: AppColors.blue),
        UserRole.admin
      ),
      (
        _RoleBtn(
            icon: Icons.menu_book_rounded,
            label: 'Teacher',
            bg: AppColors.tealLight,
            iconColor: AppColors.teal),
        UserRole.teacher
      ),
      (
        _RoleBtn(
            icon: Icons.school_rounded,
            label: 'Student',
            bg: AppColors.greenLight,
            iconColor: AppColors.green),
        UserRole.student
      ),
      (
        _RoleBtn(
            icon: Icons.people_rounded,
            label: 'Parent',
            bg: AppColors.amberLight,
            iconColor: AppColors.amber),
        UserRole.parent
      ),
      (
        _RoleBtn(
            icon: Icons.credit_card_rounded,
            label: 'Accountant',
            bg: AppColors.redLight,
            iconColor: AppColors.red),
        UserRole.accountant
      ),
      (
        _RoleBtn(
            icon: Icons.language_rounded,
            label: 'Global Admin',
            bg: const Color(0xFFEDE9FF),
            iconColor: const Color(0xFF5B3FD8)),
        UserRole.global
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(rXl)),
        boxShadow: [
          BoxShadow(
              color: Color(0x142D1B8E),
              blurRadius: 24,
              offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border2,
                borderRadius: BorderRadius.circular(rFull),
              ),
            ),
          ),
          Text('SELECT YOUR PORTAL',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.text4)),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: roles
                .map((r) => GestureDetector(
                      onTap: () => onRole(r.$2),
                      child: r.$1,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, iconColor;
  const _RoleBtn(
      {required this.icon,
      required this.label,
      required this.bg,
      required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(rLg),
          boxShadow: shadowSm,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 9),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
        ]),
      );
}
