import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/role_config.dart';
import '../services/api_service.dart';
import '../services/dev_auth.dart';
import 'app_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LANDING SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showRoles = false;
  bool _showDevRoles = false;     // ← dev bypass role picker

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      // ── DEV floating badge ──────────────────────────────────────────────
      floatingActionButton: _DevFab(onTap: () => setState(() {
        _showDevRoles = !_showDevRoles;
        _showRoles = false;
      })),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _heroHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.navy2),
                  const SizedBox(width: 4),
                  Text("The Future of Pedagogy",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy2)),
                ]),
                const SizedBox(height: 12),
                Text("AI Powered School ERP\nfor Modern Education",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 30, color: AppColors.text1, height: 1.22)),
                const SizedBox(height: 13),
                Text("An intelligent platform for schools, teachers, students, and parents — with automation, analytics, and personalised learning support.",
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text3, height: 1.7)),
                const SizedBox(height: 22),
                Row(children: [
                  GestureDetector(
                    onTap: () => setState(() { _showRoles = true; _showDevRoles = false; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradA, AppColors.gradC]),
                        borderRadius: BorderRadius.circular(rMd),
                        boxShadow: const [BoxShadow(color: Color(0x4D2D1B8E), blurRadius: 10, offset: Offset(0, 3))],
                      ),
                      child: Text("Login", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border2, width: 1.5),
                      borderRadius: BorderRadius.circular(rMd),
                    ),
                    child: Text("View Features", style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text2)),
                  ),
                ]),
              ]),
            ),

            // ── decorative mockup card ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradA, AppColors.gradB]),
                    borderRadius: BorderRadius.circular(rLg),
                    boxShadow: shadowMd,
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: const BorderRadius.only(topLeft: Radius.circular(rLg), topRight: Radius.circular(rLg))),
                      child: Row(children: [
                        _dot(const Color(0xFFEF4444)), const SizedBox(width: 5),
                        _dot(const Color(0xFFEAB308)), const SizedBox(width: 5),
                        _dot(const Color(0xFF22C55E)), const SizedBox(width: 7),
                        Text("School Management Dashboard", style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.white.withOpacity(0.5))),
                      ]),
                    ),
                    SizedBox(height: 172, child: Row(children: [
                      Container(
                        width: 38, color: Colors.white.withOpacity(0.06), padding: const EdgeInsets.all(6),
                        child: Column(children: List.generate(5, (i) => Container(margin: const EdgeInsets.only(bottom: 5), height: 24, decoration: BoxDecoration(color: i == 0 ? AppColors.gradC : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4))))),
                      ),
                      Expanded(child: Padding(padding: const EdgeInsets.all(9), child: Column(children: [
                        Row(children: [
                          Expanded(flex: 6, child: Container(height: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(3)))),
                          const SizedBox(width: 4),
                          Expanded(flex: 3, child: Container(height: 10, decoration: BoxDecoration(color: AppColors.gradC, borderRadius: BorderRadius.circular(3)))),
                        ]),
                        const SizedBox(height: 6),
                        ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [
                          Expanded(flex: 18, child: Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(width: 4),
                          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: i == 0 ? AppColors.gradC : i == 2 ? const Color(0xFF22C55E) : const Color(0xFFEAB308))),
                          const SizedBox(width: 4),
                          Expanded(flex: 5, child: Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(2)))),
                        ]))),
                        const Spacer(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end,
                            children: [0.55, 0.80, 0.45, 0.95, 0.65, 0.75].map((h) =>
                              Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 40 * h,
                                  decoration: BoxDecoration(color: AppColors.gradC.withOpacity(0.55), borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))))).toList()),
                      ]))),
                    ])),
                  ]),
                ),
                const SizedBox(height: 12),
                Text("AI Insight", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
                const SizedBox(height: 4),
                Text("Student retention is predicted to increase by 12% next quarter based on current engagement metrics.",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.text3, height: 1.55)),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                _pill("AI Analytics"), _pill("Attendance"), _pill("Fee Management"), _pill("Academics"), _pill("Parent Portal"),
              ]),
            ),

            // ── role selector (normal login) ──────────────────────────────
            if (_showRoles) _RoleSelector(onRole: _enterRole),

            // ── dev role selector ─────────────────────────────────────────
            if (_showDevRoles) _DevRoleSelector(onRole: _enterDevRole),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _enterRole(UserRole role) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginFormScreen(role: role)));
  }

  void _enterDevRole(UserRole role) {
    DevAuth.activate();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AppScreen(role: role),
    ));
  }

  Widget _heroHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 16),
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC])),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5)),
              child: Center(child: Text("A", style: GoogleFonts.dmSerifDisplay(fontSize: 18, color: Colors.white)))),
          const SizedBox(width: 9),
          Text("Academic Architect", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
        ]),
        Row(children: [_navLink("Features"), const SizedBox(width: 14), _navLink("Modules"), const SizedBox(width: 14), _navLink("About")]),
      ]),
    );
  }

  Widget _navLink(String label) => Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85)));
  Widget _dot(Color c) => Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  Widget _pill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rFull), boxShadow: shadowSm),
    child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text2)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DEV FLOATING ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _DevFab extends StatelessWidget {
  final VoidCallback onTap;
  const _DevFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(rMd),
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text("DEV LOGIN", style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF00FF88), letterSpacing: 1.0)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEV ROLE SELECTOR — skips API, goes straight to AppScreen
// ─────────────────────────────────────────────────────────────────────────────

class _DevRoleSelector extends StatelessWidget {
  final void Function(UserRole) onRole;
  const _DevRoleSelector({required this.onRole});

  @override
  Widget build(BuildContext context) {
    final roles = [
      (_DevRoleCard(icon: Icons.home_work_rounded,    label: "School Admin",  name: "Priya Sharma", bg: const Color(0xFFEBEEFF), iconColor: AppColors.blue),      UserRole.admin),
      (_DevRoleCard(icon: Icons.menu_book_rounded,    label: "Teacher",       name: "Mr. Hoang",    bg: AppColors.tealLight,    iconColor: AppColors.teal),        UserRole.teacher),
      (_DevRoleCard(icon: Icons.school_rounded,       label: "Student",       name: "Alex Rivers",  bg: AppColors.greenLight,   iconColor: AppColors.green),       UserRole.student),
      (_DevRoleCard(icon: Icons.people_rounded,       label: "Parent",        name: "Raj Mehta",    bg: AppColors.amberLight,   iconColor: AppColors.amber),       UserRole.parent),
      (_DevRoleCard(icon: Icons.credit_card_rounded,  label: "Accountant",    name: "Sarah Chen",   bg: AppColors.redLight,     iconColor: AppColors.red),         UserRole.accountant),
      (_DevRoleCard(icon: Icons.language_rounded,     label: "Global Admin",  name: "Jordan Wells", bg: const Color(0xFFEDE9FF),iconColor: const Color(0xFF5B3FD8)), UserRole.global),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(rXl),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ─────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(rXl)),
            border: Border(bottom: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.15))),
          ),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text("DEV MODE — Pick a role to preview",
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF00FF88), letterSpacing: 0.5)),
            const Spacer(),
            Text("No API calls", style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.white.withOpacity(0.3))),
          ]),
        ),

        // ── Disclaimer ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            "Uses dummy data only. Backend is bypassed. Remove DevAuth before release.",
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withOpacity(0.35), height: 1.5),
          ),
        ),

        // ── Role grid ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.88,
            children: roles.map((r) => GestureDetector(onTap: () => onRole(r.$2), child: r.$1)).toList(),
          ),
        ),
      ]),
    );
  }
}

class _DevRoleCard extends StatelessWidget {
  final IconData icon;
  final String label, name;
  final Color bg, iconColor;
  const _DevRoleCard({required this.icon, required this.label, required this.name, required this.bg, required this.iconColor});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(rLg),
      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 40, height: 40,
          decoration: BoxDecoration(color: bg.withOpacity(0.85), borderRadius: BorderRadius.circular(rMd)),
          child: Icon(icon, size: 21, color: iconColor)),
      const SizedBox(height: 7),
      Text(label, textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9))),
      const SizedBox(height: 2),
      Text(name, textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.white.withOpacity(0.4))),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NORMAL ROLE SELECTOR (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  final void Function(UserRole) onRole;
  const _RoleSelector({required this.onRole});
  @override
  Widget build(BuildContext context) {
    final roles = [
      (_RoleBtn(icon: Icons.home_work_rounded,   label: "School Admin", bg: const Color(0xFFEBEEFF), iconColor: AppColors.blue),      UserRole.admin),
      (_RoleBtn(icon: Icons.menu_book_rounded,   label: "Teacher",      bg: AppColors.tealLight,    iconColor: AppColors.teal),        UserRole.teacher),
      (_RoleBtn(icon: Icons.school_rounded,      label: "Student",      bg: AppColors.greenLight,   iconColor: AppColors.green),       UserRole.student),
      (_RoleBtn(icon: Icons.people_rounded,      label: "Parent",       bg: AppColors.amberLight,   iconColor: AppColors.amber),       UserRole.parent),
      (_RoleBtn(icon: Icons.credit_card_rounded, label: "Accountant",   bg: AppColors.redLight,     iconColor: AppColors.red),         UserRole.accountant),
      (_RoleBtn(icon: Icons.language_rounded,    label: "Global Admin", bg: const Color(0xFFEDE9FF),iconColor: const Color(0xFF5B3FD8)), UserRole.global),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(rXl)),
        boxShadow: [BoxShadow(color: Color(0x142D1B8E), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(rFull)))),
        Text("SELECT YOUR PORTAL", style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.text4)),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: roles.map((r) => GestureDetector(onTap: () => onRole(r.$2), child: r.$1)).toList(),
        ),
      ]),
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, iconColor;
  const _RoleBtn({required this.icon, required this.label, required this.bg, required this.iconColor});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.5), borderRadius: BorderRadius.circular(rLg), boxShadow: shadowSm),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: AppColors.border, width: 1.5)), child: Icon(icon, size: 22, color: iconColor)),
      const SizedBox(height: 9),
      Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.text2)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN FORM SCREEN (real API — unchanged except dev banner addition)
// ─────────────────────────────────────────────────────────────────────────────

class LoginFormScreen extends StatefulWidget {
  final UserRole role;
  const LoginFormScreen({super.key, required this.role});
  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  RoleConfig get _cfg => kRoles[widget.role]!;

  @override
  void dispose() { _usernameCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = "Please enter your username and password.");
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().login(username, password);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppScreen(role: widget.role)));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Could not reach the server. Check your connection.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Dev bypass directly from the login form — no credentials needed
  void _devBypass() {
    DevAuth.activate();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppScreen(role: widget.role)));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        // ── Top bar ────────────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 18),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gradA, AppColors.gradB])),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(rMd), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)), child: const Icon(Icons.arrow_back_rounded, size: 16, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Sign In", style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: Colors.white)),
              Text(_cfg.label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withOpacity(0.65))),
            ])),
            // ── DEV shortcut on top bar ────────────────────────────────────
            GestureDetector(
              onTap: _devBypass,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(rSm),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.6), width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text("DEV", style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF00FF88), letterSpacing: 1.0)),
                ]),
              ),
            ),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 20 + bottomPad),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Role badge ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: AppColors.border, width: 1.5)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified_rounded, size: 14, color: AppColors.blue), const SizedBox(width: 6),
                Text("Logging in as: ${_cfg.label}", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.blue)),
              ]),
            ),

            const SizedBox(height: 28),

            // ── Username ───────────────────────────────────────────────────
            Text("Username", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
            const SizedBox(height: 6),
            TextField(controller: _usernameCtrl, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.text1), decoration: _inputDec("Enter your username", Icons.person_outline_rounded)),

            const SizedBox(height: 16),

            // ── Password ───────────────────────────────────────────────────
            Text("Password", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordCtrl, obscureText: _obscure, textInputAction: TextInputAction.done, onSubmitted: (_) => _login(),
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.text1),
              decoration: _inputDec("Enter your password", Icons.lock_outline_rounded).copyWith(
                suffixIcon: GestureDetector(onTap: () => setState(() => _obscure = !_obscure), child: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.text4)),
              ),
            ),

            // ── Error ──────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(rMd), border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5)),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.red), const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.red, fontWeight: FontWeight.w500))),
                ]),
              ),
            ],

            const SizedBox(height: 28),

            // ── Sign In button (real API) ───────────────────────────────────
            GestureDetector(
              onTap: _loading ? null : _login,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.gradA, AppColors.gradC], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(rMd), boxShadow: shadowMd),
                child: Center(child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text("Sign In", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
            ),

            const SizedBox(height: 12),

            // ── Dev bypass button ─────────────────────────────────────────
            GestureDetector(
              onTap: _devBypass,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(rMd),
                  border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4), width: 1.5),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text("Dev Login — Skip API, use dummy data",
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00FF88))),
                ]),
              ),
            ),

            const SizedBox(height: 16),
            Center(child: Text("Use credentials provided by your school administrator.", textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.text4, height: 1.5))),
          ]),
        )),
      ]),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.text4),
    prefixIcon: Icon(icon, size: 18, color: AppColors.text4),
    filled: true, fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd), borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(rMd), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
  );
}
