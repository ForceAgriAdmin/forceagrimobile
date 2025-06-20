import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_model.dart';
import '../models/worker_type_model.dart';
import '../providers.dart';
import 'worker_detail_page.dart';

// StateProvider for toggling display of inactive workers
final showInactiveProvider = StateProvider<bool>((ref) => false);

class WorkersPage extends ConsumerWidget {
  const WorkersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync       = ref.watch(firestoreSyncServiceProvider);
    final types      = sync.workerTypes;
    final workers    = sync.workers;
    final filterId   = ref.watch(workerTypeFilterProvider);
    final showInactive = ref.watch(showInactiveProvider);
    final query      = ref.watch(workerSearchProvider).toLowerCase();
    // Apply active/inactive and type filters
    var list = workers.where((w) {
      if (!showInactive && !w.isActive) return false;
      if (filterId != null && w.workerTypeId != filterId) return false;
      return true;
    }).toList();

    // Apply search filter
    list = list.where((w) {
      final name = '${w.firstName} ${w.lastName}'.toLowerCase();
      return name.contains(query) || w.employeeNumber.toLowerCase().contains(query);
    }).toList();

    Widget chip(String label, String? value) => ChoiceChip(
          label: Text(label),
          selected: filterId == value,
          onSelected: (_) => ref.read(workerTypeFilterProvider.notifier).state = value,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Text('Show Inactive'),
                Switch(
                  value: showInactive,
                  onChanged: (val) => ref.read(showInactiveProvider.notifier).state = val,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search workers',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(workerSearchProvider.notifier).state = v,
            ),
          ),

          // Type filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 8,
              children: [
                chip('All', null),
                for (final t in types) chip(t.description, t.id),
              ],
            ),
          ),

          // Workers list
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final w = list[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(w.profileImageUrl),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  title: Text('${w.firstName} ${w.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emp#: ${w.employeeNumber}'),
                      Text('Status: ${w.isActive ? 'Active' : 'Inactive'}'),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkerDetailPage(worker: w),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}