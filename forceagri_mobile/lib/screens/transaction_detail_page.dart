// lib/screens/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/models/transaction_type_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers.dart';

class TransactionDetailPage extends ConsumerWidget {
  final TransactionModel txn;
  const TransactionDetailPage({required this.txn, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync      = ref.watch(firestoreSyncServiceProvider);
    final worker    = sync.workers.firstWhere((w) => w.id == txn.workerIds[0]);
    final operation = sync.operations.firstWhere((o) => o.id == txn.operationIds[0]);
    final types     = ref.watch(transactionTypesProvider)
      .where((t) => t.name.toLowerCase() != 'settle')
      .toList();
    final txnType   = types.firstWhere((t) => t.id == txn.transactionTypeId,
      orElse: () => TransactionTypeModel(
        id: txn.transactionTypeId,
        name: '',
        description: '',
        isCredit: false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      )
    );
    final fmtDate   = DateFormat('yyyy-MM-dd HH:mm');

    void viewReceipt() {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          build: (c) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Receipt ID: ${txn.id}'),
              pw.SizedBox(height: 12),
              pw.Text('Worker: ${worker.firstName} ${worker.lastName}'),
              pw.Text('Operation: ${operation.name}'),
              pw.Text('Type: ${txnType.name}'),
              pw.Text('Date: ${fmtDate.format(txn.timestamp)}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'Amount: N\\${txn.amount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  color: txn.amount < 0 ? PdfColors.red : PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Description: ${txn.description}'),
            ],
          ),
        ),
      );
      Printing.layoutPdf(onLayout: (_) => doc.save());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(worker.profileImageUrl),
                backgroundColor: Colors.grey.shade200,
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

            Text('Transaction ID: ${txn.id}'),
            const SizedBox(height: 8),
            Text('Operation: ${operation.name}'),
            const SizedBox(height: 8),
            Text('Type: ${txnType.name}'),
            const SizedBox(height: 8),
            Text('Date: ${fmtDate.format(txn.timestamp)}'),
            const SizedBox(height: 24),

            Text(
              'Amount: N\\${txn.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                color: txn.amount < 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            Text('Description:'),
            Text(txn.description.isNotEmpty ? txn.description : '—'),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewReceipt,
                child: const Text('View Receipt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
