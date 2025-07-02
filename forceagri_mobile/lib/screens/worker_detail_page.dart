// lib/screens/worker_detail_page.dart

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

    // Format the balance
    final balanceText =
        'Balance: N\$${worker.currentBalance.toStringAsFixed(2)}';

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
                  Center(child: ProfileImage(worker: worker, radius: 64)),
                  Center(
                    child: Chip(
                      label: Text(
                        worker.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color:
                              worker.isActive
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor:
                          worker.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      visualDensity: VisualDensity.compact,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color:
                              worker.isActive
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${worker.firstName} ${worker.lastName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Existing fields
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
                  if (worker.paymentGroupIds.isNotEmpty) ...[
                    Text('Payment Groups: ${worker.paymentGroupIds.length}'),
                  ],

                  const SizedBox(height: 8),
                  // ← New balance line
                  Text(
                    balanceText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          worker.currentBalance >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      onTap: () => {},
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
                      onTap: () => {},
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
