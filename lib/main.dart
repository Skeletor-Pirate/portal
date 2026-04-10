import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

void main() {
  // Ensure Flutter framework is ready before calling platform-specific code
  WidgetsFlutterBinding.ensureInitialized();
  
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
      
      // Starting with the LoginScreen which now contains the Register toggle
      home: const LoginScreen(),
      
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