import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/role_config.dart';
import '../services/api_service.dart';
import '../services/config_service.dart';
import '../services/app_store.dart';
import 'app_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UNIFIED LOGIN SCREEN  —  single screen with email + password
// ─────────────────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(
          () => _error = 'Please enter your email address and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService().login(email, password);
      await AppStore.instance.initSession();
      if (!mounted) return;

      // Auto-detect user role from backend
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

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AppScreen(role: detectedRole)));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error =
          'Could not reach the server at ${ConfigService.serverUrl}. Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registration'),
        content: const Text('Registration is currently handled by the school administration. Please contact your administrator.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _header(topPad),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null) _errorBanner(),

                    const SizedBox(height: 10),

                    // ── Main unified login form ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(rXl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.navy.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _inputField('Email or Username', _emailCtrl,
                              Icons.email_outlined,
                              isEmail: true),
                          const SizedBox(height: 16),
                          _inputField(
                              'Password', _passwordCtrl, Icons.lock_outline,
                              isPassword: true),
                          const SizedBox(height: 24),
                          _loginButton(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Bottom links ───────────────────────────────────────
                    GestureDetector(
                      onTap: _showRegisterDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(
                              color: AppColors.border2, width: 1.5),
                          borderRadius: BorderRadius.circular(rMd),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_add_rounded,
                                  size: 16, color: AppColors.navy),
                              const SizedBox(width: 8),
                              Text('Register New Account',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navy)),
                            ]),
                      ),
                    ),

                    const SizedBox(height: 14),

                  ],
                ),
              ),

              // ── Footer ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(bottom: bottomPad + 20),
                child: Column(
                  children: [
                    Text('Secure Cloud Login',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text4)),
                    const SizedBox(height: 4),
                    Text('v2.0.4 • Academic Architect',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10, color: AppColors.slateLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header widget ─────────────────────────────────────────────────────────

  Widget _header(double topPad) => Container(
        padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
                color: AppColors.navy.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.gradA, AppColors.gradC]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text('Academic Architect',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24, color: AppColors.text1)),
            const SizedBox(height: 4),
            Text('Intelligent Portal',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text3,
                    letterSpacing: 0.5)),
          ],
        ),
      );

  // ── Form Components ───────────────────────────────────────────────────────

  Widget _errorBanner() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.redLight,
          borderRadius: BorderRadius.circular(rMd),
          border: Border.all(color: AppColors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(_error!,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.red))),
          ],
        ),
      );

  Widget _inputField(
      String label, TextEditingController ctrl, IconData icon,
      {bool isPassword = false, bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text2)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(rMd),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: isPassword && _obscure,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppColors.text1),
            decoration: InputDecoration(
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle:
                  GoogleFonts.plusJakartaSans(color: AppColors.text4),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, size: 18, color: AppColors.text4),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.text4),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() => GestureDetector(
        onTap: _loading ? null : _login,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.gradA, AppColors.gradC]),
            borderRadius: BorderRadius.circular(rMd),
            boxShadow: [
              BoxShadow(
                  color: AppColors.blue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Sign In',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      );
}
