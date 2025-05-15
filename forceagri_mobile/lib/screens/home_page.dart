// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers.dart';
import 'qr_scanner_page.dart';

class HomePage extends ConsumerWidget {
  final User user;
  const HomePage({required this.user, super.key});

  static const _tabs = <Widget>[
    Center(child: Text('🏠 Home Tab')),
    Center(child: Text('⚙️ Settings Tab')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: _tabs[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerPage()),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: currentIndex == 0 ? Theme.of(context).primaryColor : null,
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: currentIndex == 1 ? Theme.of(context).primaryColor : null,
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
            ),
          ],
        ),
      ),
    );
  }
}
