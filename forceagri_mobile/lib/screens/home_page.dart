import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers.dart';
import 'qr_scanner_page.dart';
import 'workers_page.dart';
import 'transactions_page.dart';
import 'settings_page.dart';

class HomePage extends ConsumerWidget {
  final User user;
  const HomePage({required this.user, super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[idx]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: _tabs[idx],
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
          children: List.generate(_icons.length, (i) {
            return Expanded(
              child: IconButton(
                icon: Icon(_icons[i]),
                color: idx == i ? Theme.of(context).primaryColor : Colors.grey,
                onPressed:
                    () => ref.read(bottomNavIndexProvider.notifier).state = i,
              ),
            );
          }),
        ),
      ),
    );
  }
}
