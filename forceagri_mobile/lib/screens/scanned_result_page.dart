import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';
import '../models/qr_data.dart';
import '../models/card_model.dart';
import '../models/worker_model.dart';
import '../models/operation_model.dart';
import '../models/farm_model.dart';
import '../models/worker_type_model.dart';
import '../providers.dart';
import 'transaction_page.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

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

    // look up related models
    final operation = sync.operations.firstWhere(
      (o) => o.id == worker.operationId,
      orElse: () => OperationModel(
        id: '', name: 'Unknown', description: '',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );
    final farm = sync.farms.firstWhere(
      (f) => f.id == worker.farmId,
      orElse: () => FarmModel(
        id: '', name: 'Unknown', location: '',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );
    final workerType = sync.workerTypes.firstWhere(
      (t) => t.id == worker.workerTypeId,
      orElse: () => WorkerTypeModel(id: '', description: 'Unknown'),
    );

    // balance formatting
    final balanceColor = worker.currentBalance >= 0
        ? Colors.green.shade700
        : Colors.red.shade700;
    final balanceText = 'N\$${worker.currentBalance.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Scanned Worker Details')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1) Profile & status pill
            ProfileImage(worker: worker, radius: 64),
            const SizedBox(height: 16),
            Chip(
              label: Text(
                worker.isActive ? 'Active' : 'In-Active',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.fieldFill,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // 2) Name
            Text(
              '${worker.firstName} ${worker.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // 3) Balance under name
            Text(
              balanceText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                    color: balanceColor,
                  ),
            ),
            const SizedBox(height: 32),

            // 4) Action cards
            Row(
              children: [
                _buildActionCard(
                  context,
                  label: 'Transact',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionPage(worker: worker),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionCard(
                  context,
                  label: 'Change\nOperation',
                  onTap: () {/* TODO */},
                ),
                const SizedBox(width: 12),
                _buildActionCard(
                  context,
                  label: 'Settle',
                  onTap: () {/* TODO */},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 5) Center-aligned details
            _centeredDetail('Employee #:', worker.employeeNumber),
            const SizedBox(height: 8),
            _centeredDetail('ID #:', worker.idNumber),
            const SizedBox(height: 8),
            _centeredDetail('Type:', workerType.description),
            const SizedBox(height: 8),
            _centeredDetail('Operation:', operation.name),
            const SizedBox(height: 8),
            _centeredDetail('Farm:', farm.name),
            if (worker.paymentGroupIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              _centeredDetail(
                'Pay Groups:',
                '${worker.paymentGroupIds.length}',
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// A RichText widget with a bold label and normal-weight value, centered.
  Widget _centeredDetail(String label, String value) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  /// The green action cards under the name.
  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
