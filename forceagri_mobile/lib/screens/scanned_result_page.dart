// lib/screens/scanned_result_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/screens/transaction_page.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

import '../models/qr_data.dart';
import '../models/card_model.dart';
import '../models/operation_model.dart';
import '../models/farm_model.dart';
import '../providers.dart';

class ScannedResultPage extends ConsumerWidget {
  final QRData qrData;
  final CardModel card;

  const ScannedResultPage({
    required this.qrData,
    required this.card,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(firestoreSyncServiceProvider);
    final worker = sync.workers.firstWhere((w) => w.id == qrData.workerId);
    final operation = sync.operations.firstWhere(
      (o) => o.id == worker.operationId,
      orElse:
          () => OperationModel(
            id: '',
            name: 'Unknown',
            description: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
    final farm = sync.farms.firstWhere(
      (f) => f.id == worker.farmId,
      orElse:
          () => FarmModel(
            id: '',
            name: 'Unknown',
            location: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Worker Details')),
      body: Column(
        children: [
          // Top section
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    Center(child: ProfileImage(worker: worker, radius: 64)),
                    const SizedBox(height: 16),
                    Text(
                      '${worker.firstName} ${worker.lastName}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Employee #: ${worker.employeeNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'ID #:         ${worker.idNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Operation: ${operation.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Farm:       ${farm.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Bottom action panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Transact',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionPage(worker: worker),
                            ),
                          ),
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      context,
                      label: 'Change Operation',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const _ChangeOperationPage(),
                            ),
                          ),
                      minWidth: 140,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Settle',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const _SettlePage(),
                            ),
                          ),
                      minWidth: 120,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    double minWidth = 120,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(minWidth, 40),
        side: BorderSide(color: primary),
        shape: const StadiumBorder(),
        foregroundColor: primary,
      ),
      child: Text(label),
    );
  }
}

class _ChangeOperationPage extends StatelessWidget {
  const _ChangeOperationPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Change Operation')),
    body: const Center(child: Text('Change Operation Page')),
  );
}

class _SettlePage extends StatelessWidget {
  const _SettlePage();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settle')),
    body: const Center(child: Text('Settle Page')),
  );
}
