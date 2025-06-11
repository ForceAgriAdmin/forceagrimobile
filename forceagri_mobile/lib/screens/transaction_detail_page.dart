// lib/screens/transaction_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              pw.Text('Date: ${fmtDate.format(txn.timestamp)}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'Amount: N\$${txn.amount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  color: txn.amount < 0 ? PdfColors.red : PdfColors.green,
                ),
              ),
            ],
          ),
        ),
      );
      Printing.layoutPdf(onLayout: (_) => doc.save());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(worker.profileImageUrl),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),

            // Worker name
            Text(
              '${worker.firstName} ${worker.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
             Text('ID: : ${txn.id}'),
             const SizedBox(height: 8),
            Text('Operation: ${operation.name}'),
            Text('Date: ${fmtDate.format(txn.timestamp)}'),
            const SizedBox(height: 24),

            // Amount
            Text(
              'N\$${txn.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                color: txn.amount < 0 ? Colors.red : Colors.green,
              ),
            ),
            const Spacer(),

            // View Receipt button
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
