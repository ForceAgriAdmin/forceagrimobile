import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

import '../models/worker_model.dart';
import '../models/operation_model.dart';
import '../models/farm_model.dart';
import '../models/worker_type_model.dart';
import '../providers.dart';
import 'transaction_page.dart';

class WorkerDetailPage extends ConsumerWidget {
  final WorkerModel worker;
  const WorkerDetailPage({required this.worker, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(firestoreSyncServiceProvider);

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

    final workerType = sync.workerTypes.firstWhere(
      (t) => t.id == worker.workerTypeId,
      orElse: () => WorkerTypeModel(id: '', description: 'Unknown'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Details')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Center(
                      child: ProfileImage(worker: worker, radius: 64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${worker.firstName} ${worker.lastName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Employee #: ${worker.employeeNumber}'),
                  const SizedBox(height: 8),
                  Text('ID #:           ${worker.idNumber}'),
                  const SizedBox(height: 8),
                  Text('Type:          ${workerType.description}'),
                  const SizedBox(height: 8),
                  Text('Operation:     ${operation.name}'),
                  const SizedBox(height: 8),
                  Text('Farm:          ${farm.name}'),
                  const SizedBox(height: 8),
                  Text(
                    'Status:        ${worker.isActive ? 'Active' : 'Inactive'}',
                  ),
                  if (worker.paymentGroupIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Payment Groups: ${worker.paymentGroupIds.length}'),
                  ],
                ],
              ),
            ),
          ),

          const Divider(height: 1),

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
