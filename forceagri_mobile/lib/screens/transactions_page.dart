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
    final query     = ref.watch(transactionSearchProvider).toLowerCase();

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

    List<TransactionModel> applyDateFilter(List<TransactionModel> list) {
      final s = startDate(), e = endDate();
      return list.where((t) {
        final ts = t.timestamp;
        return !ts.isBefore(s) && !ts.isAfter(e);
      }).toList();
    }

    List<TransactionModel> applySearch(List<TransactionModel> list) {
      if (query.isEmpty) return list;
      final fmtDate = DateFormat('yyyy-MM-dd');
      return list.where((t) {
        final worker = sync.workers.firstWhere((w) => w.id == t.workerIds[0]);
        final operation = sync.operations.firstWhere((o) => o.id == t.operationIds[0]);
        final name = '${worker.firstName} ${worker.lastName}'.toLowerCase();
        final opName = operation.name.toLowerCase();
        final id = t.id.toLowerCase();
        final dateStr = fmtDate.format(t.timestamp).toLowerCase();
        final amtStr = t.amount.abs().toStringAsFixed(2).toLowerCase();
        return name.contains(query) ||
               opName.contains(query) ||
               id.contains(query) ||
               dateStr.contains(query) ||
               amtStr.contains(query);
      }).toList();
    }

    Widget chip(String label, TransactionFilter value) => ChoiceChip(
          label: Text(label),
          selected: filter == value,
          onSelected: (_) =>
              ref.read(transactionFilterProvider.notifier).state = value,
        );

    final fmtDisplayDate = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: txnsAsync.when(
        data: (txns) {
          // apply filters
          var list = applyDateFilter(txns);
          list = applySearch(list);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search transactions',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) =>
                      ref.read(transactionSearchProvider.notifier).state = v,
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    chip('All', TransactionFilter.all),
                    chip('Today', TransactionFilter.today),
                    chip('Yesterday', TransactionFilter.yesterday),
                    chip('This Week', TransactionFilter.thisWeek),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final t = list[i];
                    final worker    = sync.workers.firstWhere((w) => w.id == t.workerIds[0]);
                    final operation = sync.operations.firstWhere((o) => o.id == t.operationIds[0]);
                    final color     = t.amount < 0 ? Colors.red : Colors.green;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(worker.profileImageUrl),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionDetailPage(txn: t),
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
                          Text(fmtDisplayDate.format(t.timestamp)),
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
        error:   (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
