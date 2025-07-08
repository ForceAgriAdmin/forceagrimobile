// lib/screens/transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../theme.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type_model.dart';
import '../providers.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

class TransactionDetailPage extends ConsumerWidget {
  final TransactionModel txn;
  const TransactionDetailPage({required this.txn, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(firestoreSyncServiceProvider);
    final worker = sync.workers.firstWhere((w) => w.id == txn.workerIds[0]);
    final operation = sync.operations.firstWhere(
      (o) => o.id == txn.operationIds[0],
    );

    final types =
        ref
            .watch(transactionTypesProvider)
            .where((t) => t.name.toLowerCase() != 'settle')
            .toList();
    final txnType = types.firstWhere(
      (t) => t.id == txn.transactionTypeId,
      orElse:
          () => TransactionTypeModel(
            id: txn.transactionTypeId,
            name: '',
            description: '',
            isCredit: false,
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );

    final fmtDate = DateFormat('yyyy-MM-dd HH:mm');
    final amountColor = txn.amount < 0 ? Colors.red : Colors.green;
    final amountText = 'N\$${txn.amount.toStringAsFixed(2)}';

    void viewReceipt() {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          build:
              (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Receipt ID: ${txn.id}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('Worker: ${worker.firstName} ${worker.lastName}'),
                  pw.Text('Operation: ${operation.name}'),
                  pw.Text('Type: ${txnType.name}'),
                  pw.Text('Date: ${fmtDate.format(txn.timestamp)}'),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Amount: $amountText',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: txn.amount < 0 ? PdfColors.red : PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Description: ${txn.description.isNotEmpty ? txn.description : '—'}',
                  ),
                ],
              ),
        ),
      );
      Printing.layoutPdf(onLayout: (_) => doc.save());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile photo & name
            ProfileImage(worker: worker, radius: 64),
            const SizedBox(height: 16),
            Text(
              '${worker.firstName} ${worker.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Transaction details
            _centeredDetail('Transaction ID:', txn.id),
            const SizedBox(height: 8),
            _centeredDetail('Operation:', operation.name),
            const SizedBox(height: 8),
            _centeredDetail('Type:', txnType.name),
            const SizedBox(height: 8),
            _centeredDetail('Date:', fmtDate.format(txn.timestamp)),
            const SizedBox(height: 24),
            // Description
            _centeredDetail(
              'Description:',
              txn.description.isNotEmpty ? txn.description : '—',
            ),
            const SizedBox(height: 32),
            // Amount
            Text(
              amountText,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
            const SizedBox(height: 24),

            // View Receipt button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: GestureDetector(
                onTap: viewReceipt,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'View Receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
