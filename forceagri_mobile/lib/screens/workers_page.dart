import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_model.dart';
import '../models/worker_type_model.dart';
import '../providers.dart';
import 'worker_detail_page.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

// StateProvider for toggling display of inactive workers
final showInactiveProvider = StateProvider<bool>((ref) => false);

class WorkersPage extends ConsumerWidget {
  const WorkersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(firestoreSyncServiceProvider);
    final types = sync.workerTypes;
    final workers = sync.workers;
    final filterId = ref.watch(workerTypeFilterProvider);
    final showInactive = ref.watch(showInactiveProvider);
    final query = ref.watch(workerSearchProvider).toLowerCase();
    // Apply active/inactive and type filters
    var list =
        workers.where((w) {
          if (!showInactive && !w.isActive) return false;
          if (filterId != null && w.workerTypeId != filterId) return false;
          return true;
        }).toList();

    // Apply search filter
    list =
        list.where((w) {
          final name = '${w.firstName} ${w.lastName}'.toLowerCase();
          return name.contains(query) ||
              w.employeeNumber.toLowerCase().contains(query);
        }).toList();

    Widget chip(String label, String? value) => ChoiceChip(
      label: Text(label),
      selected: filterId == value,
      onSelected:
          (_) => ref.read(workerTypeFilterProvider.notifier).state = value,
    );

    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8),
      //       child: Row(
      //         children: [
      //           const Text('Show Inactive'),
      //           Switch(
      //             value: showInactive,
      //             onChanged:
      //                 (val) =>
      //                     ref.read(showInactiveProvider.notifier).state = val,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
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
              onChanged:
                  (v) => ref.read(workerSearchProvider.notifier).state = v,
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
                final isActive = w.isActive;
                final badgeColor =
                    isActive ? Colors.green.shade100 : Colors.red.shade100;
                final badgeTextColor =
                    isActive ? Colors.green.shade800 : Colors.red.shade800;

                return ListTile(
                  leading: ProfileImage(worker: w, radius: 20),
                  title: Text('${w.firstName} ${w.lastName}'),
                  subtitle: Text('Emp#: ${w.employeeNumber}'),
                  trailing: Chip(
                    label: Text(
                      isActive ? 'Active' : 'In-Active',
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: badgeColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    visualDensity: VisualDensity.compact,
                    shape: StadiumBorder(
                      side: BorderSide(color: badgeTextColor),
                    ),
                  ),
                  onTap:
                      () => Navigator.push(
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
