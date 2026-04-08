import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/role_config.dart';
import '../widgets/nav_icons.dart';
import 'page_router.dart';
import '../services/dev_auth.dart';

class AppScreen extends StatefulWidget {
  final UserRole role;
  const AppScreen({super.key, required this.role});
  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  String _currentPage = 'dashboard';
  bool _drawerOpen = false;
  bool _notifOpen = false;

  RoleConfig get cfg => kRoles[widget.role]!;

  @override
  Widget build(BuildContext context) {
    // Make status bar icons light (white) to match our dark header
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: AppColors.bg,
      // Extend body behind status bar and nav bar so we control insets
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(children: [
        // Main content column — fills the entire screen
        Column(children: [
          _topBar(context),
          if (DevAuth.isActive) _devBanner(),
          Expanded(
            child: SingleChildScrollView(
              // Add bottom padding so content is not hidden behind bottom nav
              padding: EdgeInsets.only(
                bottom: _bottomNavHeight(context),
              ),
              child: PageRouter(role: widget.role, page: _currentPage),
            ),
          ),
        ]),

        // Bottom nav anchored to bottom, respects system nav bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _bottomNav(context),
        ),

        // Drawer scrim
        if (_drawerOpen)
          GestureDetector(
            onTap: () => setState(() => _drawerOpen = false),
            child: Container(color: Colors.black.withOpacity(0.38)),
          ),

        // Side drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: _drawerOpen ? 0 : -290,
          top: 0,
          bottom: 0,
          child: _drawer(context),
        ),

        // Notification panel
        if (_notifOpen)
          Positioned(
            top: _topBarHeight(context) + 8,
            right: 12,
            child: _notifPanel(),
          ),
      ]),
    );
  }

  // ── Helpers ──────────────────────────────────

  double _topBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top + 56;

  double _bottomNavHeight(BuildContext context) =>
      60 + MediaQuery.of(context).padding.bottom;

  // ── Top Bar ──────────────────────────────────

  Widget _topBar(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(14, topPad + 10, 14, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradA, AppColors.gradB],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x332D1B8E), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        // Hamburger
        GestureDetector(
          onTap: () => setState(() {
            _drawerOpen = !_drawerOpen;
            _notifOpen = false;
          }),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _bar(), _bar(), _bar(),
            ]),
          ),
        ),
        const SizedBox(width: 12),
        // Logo + title
        Expanded(
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('A',
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 15, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
            Text('Academic Architect',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3)),
          ]),
        ),
        // Notification bell
        GestureDetector(
          onTap: () => setState(() {
            _notifOpen = !_notifOpen;
            _drawerOpen = false;
          }),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(rMd),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Stack(children: [
              const Center(
                child: Icon(Icons.notifications_outlined,
                    size: 18, color: Colors.white),
              ),
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D6D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _bar() => Container(
        height: 1.5,
        width: 16,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 2),
      );

  // ── Drawer ───────────────────────────────────

  Widget _drawer(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      width: 286,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Color(0x262D1B8E), blurRadius: 32, offset: Offset(4, 0)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Drawer header with gradient
        Container(
          padding: EdgeInsets.fromLTRB(18, topPad + 22, 18, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.gradA, AppColors.gradB, AppColors.gradC],
            ),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 2.5),
              ),
              child: ClipOval(
                child: Image.asset(cfg.avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                          color: AppColors.navy2,
                          child: Center(
                              child: Text(cfg.id,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white))),
                        )),
              ),
            ),
            const SizedBox(width: 13),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cfg.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text(cfg.label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.white.withOpacity(0.65))),
            ]),
          ]),
        ),

        Divider(height: 1, color: AppColors.border),

        // Nav items
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                  child: Text('NAVIGATION',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.text4)),
                ),
                ...cfg.nav.map((item) => GestureDetector(
                      onTap: () => setState(() {
                        _currentPage = item.id;
                        _drawerOpen = false;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _currentPage == item.id
                              ? AppColors.blueLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(rMd),
                        ),
                        child: Row(children: [
                          Icon(navIcon(item.iconName),
                              size: 16,
                              color: _currentPage == item.id
                                  ? AppColors.blue
                                  : AppColors.text2),
                          const SizedBox(width: 11),
                          Text(item.label,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: _currentPage == item.id
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _currentPage == item.id
                                      ? AppColors.blue
                                      : AppColors.text2)),
                        ]),
                      ),
                    )),
              ],
            ),
          ),
        ),

        Divider(height: 1, color: AppColors.border),

        // Logout
        Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10 + bottomPad),
          child: GestureDetector(
            onTap: () { DevAuth.deactivate(); Navigator.of(context).pop(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border2, width: 1.5),
                borderRadius: BorderRadius.circular(rSm),
              ),
              child: Row(children: [
                const Icon(Icons.logout_rounded, size: 14, color: AppColors.text3),
                const SizedBox(width: 8),
                Text('Switch Role / Logout',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text3)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Notification Panel ────────────────────────

  Widget _notifPanel() => Container(
        width: 300,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(rLg),
          boxShadow: shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text1)),
                    GestureDetector(
                      onTap: () => setState(() => _notifOpen = false),
                      child: const Icon(Icons.close, size: 16, color: AppColors.text3),
                    ),
                  ]),
            ),
            Divider(height: 1, color: AppColors.border),
            ..._notifItems(),
          ],
        ),
      );

  List<Widget> _notifItems() => [
        _ni(true, AppColors.blue, 'Assignment Submitted',
            '3 students submitted Math #4', '2m ago'),
        _ni(true, const Color(0xFF16A34A), 'Payment Received',
            'INV-089 paid — ₹24,500', '14m ago'),
        _ni(false, const Color(0xFFD97706), 'Attendance Alert',
            'Grade 9B below 75% threshold', '1h ago'),
        _ni(false, AppColors.navy, 'Exam Results',
            'Mid-term results for Grade 10', '3h ago'),
      ];

  Widget _ni(bool unread, Color dotColor, String title, String sub,
          String time) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        color: unread ? AppColors.blueLight : Colors.transparent,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text1)),
            Text(sub,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.text3)),
            Text(time,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10, color: AppColors.text4)),
          ]),
        ]),
      );

  // ── Bottom Nav ────────────────────────────────

  Widget _bottomNav(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final items = cfg.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(4, 8, 4, 8 + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          const BoxShadow(
              color: Color(0x142D1B8E),
              blurRadius: 16,
              offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final active = _currentPage == item.id;
          return GestureDetector(
            onTap: () => setState(() {
              _currentPage = item.id;
              _drawerOpen = false;
              _notifOpen = false;
            }),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 30,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [AppColors.navy, AppColors.navy2])
                      : null,
                  color: active ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(rFull),
                ),
                child: Center(
                  child: Icon(navIcon(item.iconName),
                      size: 16,
                      color: active ? Colors.white : AppColors.text4),
                ),
              ),
              const SizedBox(height: 4),
              Text(item.label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.navy : AppColors.text4)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ── DEV MODE BANNER ────────────────────────────────────────────────────────
  Widget _devBanner() => GestureDetector(
        onTap: () { DevAuth.deactivate(); Navigator.of(context).pop(); },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
          child: Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('DEV MODE  —  Dummy data  —  Tap to exit',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF00FF88), letterSpacing: 0.5, fontFamily: 'sans-serif')),
            const Spacer(),
            const Icon(Icons.close_rounded, size: 12, color: Color(0xFF00FF88)),
          ]),
        ),
      );

}
