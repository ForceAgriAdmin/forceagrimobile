// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../theme.dart';

/// A simple full-screen splash showing your transparent logo on an off-white background.
/// Wrap Scaffold in Directionality so it can render without a MaterialApp above.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Image.asset(
            'assets/app_logo_transparent.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
