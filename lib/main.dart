import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/app_screen.dart';
import 'services/config_service.dart';
import 'services/api_service.dart';
import 'services/app_store.dart';
import 'models/role_config.dart';

void main() async {
  // Ensure Flutter framework is ready before calling platform-specific code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dynamic server configuration
  await ConfigService.init();

  // Load persisted auth tokens
  await TokenStore.init();

  // Force portrait mode for a consistent ERP dashboard experience
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Enable Edge-to-Edge mode to allow our custom gradients to bleed into status/nav bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const AcademicArchitectApp());
}

class AcademicArchitectApp extends StatelessWidget {
  const AcademicArchitectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Architect',
      debugShowCheckedModeBanner: false,

      // Using the centralized theme defined in theme.dart
      theme: AppTheme.theme,

      // Start with the splash/router that checks onboarding + session
      home: const _AppRouter(),

      // Standardizing transition animations across the platform
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: child!,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROUTER — determines initial route based on onboarding + session state
// ─────────────────────────────────────────────────────────────────────────────

class _AppRouter extends StatefulWidget {
  const _AppRouter();
  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool _loading = true;
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      // 1. First launch? → Onboarding
      if (!hasSeenOnboarding) {
        setState(() {
          _destination = const OnboardingScreen();
          _loading = false;
        });
        return;
      }

      // 2. Do we have stored tokens? → Try to restore session
      if (TokenStore.hasTokens) {
        try {
          await AppStore.instance.initSession();

          // Auto-detect role
          UserRole detectedRole = UserRole.admin;
          final ctx = AppStore.instance.profileContext;
          if (ctx != null) {
            final backendRoles =
                ctx.roles.map((r) => r.toLowerCase()).toList();
            final isSuperuser = ctx.isSuperuser;

            if (isSuperuser) {
              detectedRole = UserRole.global;
            } else if (backendRoles.any((r) => r.contains('admin'))) {
              detectedRole = UserRole.admin;
            } else if (backendRoles.any((r) => r.contains('teacher')) ||
                ctx.profiles.teacher.exists) {
              detectedRole = UserRole.teacher;
            } else if (backendRoles.any((r) => r.contains('student')) ||
                ctx.profiles.student.exists) {
              detectedRole = UserRole.student;
            } else if (backendRoles.any((r) => r.contains('parent')) ||
                ctx.profiles.parent.exists) {
              detectedRole = UserRole.parent;
            } else if (backendRoles.any(
                (r) => r.contains('accountant') || r.contains('finance'))) {
              detectedRole = UserRole.accountant;
            }
          }

          setState(() {
            _destination = AppScreen(role: detectedRole);
            _loading = false;
          });
          return;
        } catch (_) {
          // Token expired or invalid — fall through to login
          await TokenStore.clear();
        }
      }

      // 3. Default → Login
      setState(() {
        _destination = const LoginScreen();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _destination = const LoginScreen();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Splash screen while resolving
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradA, AppColors.gradC],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('A',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _destination!;
  }
}