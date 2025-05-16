// lib/screens/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers.dart';
import 'transaction_detail_page.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter    = ref.watch(transactionFilterProvider);
    final txnsAsync = ref.watch(allTransactionsProvider);
    final sync      = ref.watch(firestoreSyncServiceProvider);

    DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

    DateTime startDate() {
      final now = DateTime.now();
      switch (filter) {
        case TransactionFilter.today:
          return startOfDay(now);
        case TransactionFilter.yesterday:
          return startOfDay(now.subtract(const Duration(days: 1)));
        case TransactionFilter.thisWeek:
          return startOfDay(now.subtract(Duration(days: now.weekday - 1)));
        case TransactionFilter.all:
          return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    DateTime endDate() =>
        filter == TransactionFilter.yesterday
            ? startOfDay(DateTime.now())
            : DateTime.now();

    List<TransactionModel> applyFilter(List<TransactionModel> list) {
      final s = startDate(), e = endDate();
      return list.where((t) {
        final ts = t.timestamp;
        return !ts.isBefore(s) && !ts.isAfter(e);
      }).toList();
    }

    Widget chip(String label, TransactionFilter value) => ChoiceChip(
          label: Text(label),
          selected: filter == value,
          onSelected: (_) =>
              ref.read(transactionFilterProvider.notifier).state = value,
        );

    final fmtDate = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: txnsAsync.when(
        data: (txns) {
          final list = applyFilter(txns);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    chip('Today', TransactionFilter.today),
                    chip('Yesterday', TransactionFilter.yesterday),
                    chip('This Week', TransactionFilter.thisWeek),
                    chip('All', TransactionFilter.all),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final t = list[i];
                    final worker = sync.workers.firstWhere((w) => w.id == t.workerId);
                    final operation = sync.operations.firstWhere((o) => o.id == t.operationId);
                    final color = t.amount < 0 ? Colors.red : Colors.green;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(worker.profileImageUrl),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionDetailPage(txn: t),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${worker.firstName} ${worker.lastName}'),
                          Text(
                            'N\$${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(color: color),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(operation.name),
                          Text(fmtDate.format(t.timestamp)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
