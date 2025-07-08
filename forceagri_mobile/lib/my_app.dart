import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/services/snackbar_service.dart';
import 'package:forceagri_mobile/theme.dart';
import 'providers.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    ref.read(firestoreSyncServiceProvider);

    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'ForceAgri',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: authState.when(
        data: (user) => user != null
            ? HomePage(user: user)
            : const LoginPage(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const Scaffold(
          body: Center(child: Text('Auth error')),
        ),
      ),
    );
  }
}
