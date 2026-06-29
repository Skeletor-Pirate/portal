import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING SCREEN  —  3 beautifully animated intro pages
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _key = 'has_seen_onboarding';

  final _pages = const [
    _OnboardingPage(
      icon: Icons.school_rounded,
      gradient: [AppColors.gradA, AppColors.gradC],
      title: 'Welcome to\nAcademic Architect',
      subtitle: 'The all-in-one intelligent school management platform built for modern education.',
      accent: AppColors.blue,
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      gradient: [AppColors.teal, Color(0xFF06B6D4)],
      title: 'AI-Powered\nInsights & Tools',
      subtitle: 'Generate lesson plans, worksheets, quizzes, and get predictive analytics — all powered by AI.',
      accent: AppColors.teal,
    ),
    _OnboardingPage(
      icon: Icons.people_rounded,
      gradient: [AppColors.green, Color(0xFF22C55E)],
      title: 'Seamless\nCommunication',
      subtitle: 'Connect teachers, students, and parents with real-time updates, assignments, and grade tracking.',
      accent: AppColors.green,
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Page view ─────────────────────────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _buildPage(_pages[i], i),
          ),

          // ── Bottom controls ───────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPad + 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  GestureDetector(
                    onTap: _complete,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text4,
                      ),
                    ),
                  ),

                  // Page dots
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? _pages[_page].accent
                              : AppColors.border2,
                          borderRadius: BorderRadius.circular(rFull),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: _page == _pages.length - 1 ? 22 : 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pages[_page].gradient,
                        ),
                        borderRadius: BorderRadius.circular(rMd),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_page].accent.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _page == _pages.length - 1 ? 'Get Started' : 'Next',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _page == _pages.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.chevron_right_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ── Background gradient orb ───────────────────────────────────────
        Positioned(
          top: topPad + 60,
          left: -40,
          right: -40,
          child: Center(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.accent.withOpacity(0.12),
                    page.accent.withOpacity(0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(32, topPad + 80, 32, 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon container ─────────────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: page.gradient,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: page.accent.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 52, color: Colors.white),
              ),

              const SizedBox(height: 48),

              // ── Title ─────────────────────────────────────────────────
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: AppColors.text1,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 18),

              // ── Subtitle ──────────────────────────────────────────────
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.text3,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 36),

              // ── Feature pills ─────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _featurePills(index).map((label) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: page.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(rFull),
                    border: Border.all(
                      color: page.accent.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: page.accent,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _featurePills(int index) {
    switch (index) {
      case 0:
        return ['Multi-Tenant', 'Role-Based Access', 'Cloud-Powered'];
      case 1:
        return ['Lesson Plans', 'Worksheets', 'Rubrics', 'Smart Analytics'];
      case 2:
        return ['Real-Time Grades', 'Attendance', 'Notifications'];
      default:
        return [];
    }
  }
}

// ── Data class for each page ─────────────────────────────────────────────────

class _OnboardingPage {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final Color accent;

  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}
