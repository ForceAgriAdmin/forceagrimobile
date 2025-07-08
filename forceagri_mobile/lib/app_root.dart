
// lib/app_root.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'my_app.dart';

/// Entry point wrapper: shows splash for 2 seconds, then MyApp.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: FutureBuilder<void>(
        future: Future.delayed(const Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const MyApp();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
