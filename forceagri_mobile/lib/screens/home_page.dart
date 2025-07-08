// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forceagri_mobile/theme.dart';

import '../providers.dart';
import '../services/connectivity_service.dart';
import 'qr_scanner_page.dart';
import 'workers_page.dart';
import 'transactions_page.dart';
import 'settings_page.dart';

class HomePage extends ConsumerWidget {
  final User user;
  const HomePage({required this.user, Key? key}) : super(key: key);

  static const _tabs = <Widget>[
    Center(child: Text('Home Tab')),
    WorkersPage(),
    TransactionsPage(),
    SettingsPage(),
  ];

  static const _titles = <String>[
    'Home',
    'Workers',
    'Transactions',
    'Settings',
  ];

  static const _icons = <IconData>[
    Icons.home,
    Icons.group,
    Icons.attach_money,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(bottomNavIndexProvider);
    final connAsync = ref.watch(connectionQualityProvider);

    Widget connectionIndicator() {
      return connAsync.when(
        data: (q) {
          Color c;
          switch (q) {
            case ConnectionQuality.good:
              c = Colors.green;
              break;
            case ConnectionQuality.poor:
              c = Colors.amber;
              break;
            case ConnectionQuality.none:
            default:
              c = Colors.red;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.circle, size: 16, color: c),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.offline_bolt, size: 16, color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[idx]),
        actions: [
          connectionIndicator(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: _tabs[idx],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.fieldFill,  // pale green fill
       foregroundColor: AppColors.primary,     // primary green icon
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerPage()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          children: List.generate(_icons.length, (i) {
            return Expanded(
              child: IconButton(
                icon: Icon(_icons[i]),
                color: idx == i
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                onPressed: () =>
                    ref.read(bottomNavIndexProvider.notifier).state = i,
              ),
            );
          }),
        ),
      ),
    );
  }
}
