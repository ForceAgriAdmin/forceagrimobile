// lib/screens/workers_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_model.dart';
import '../models/worker_type_model.dart';
import '../providers.dart';
import '../theme.dart';                   // ← for AppColors
import 'worker_detail_page.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

// StateProvider for toggling display of inactive workers
final showInactiveProvider = StateProvider<bool>((ref) => false);

class WorkersPage extends ConsumerWidget {
  const WorkersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync        = ref.watch(firestoreSyncServiceProvider);
    final types       = sync.workerTypes;
    final workers     = sync.workers;
    final filterId    = ref.watch(workerTypeFilterProvider);
    final showInactive= ref.watch(showInactiveProvider);
    final query       = ref.watch(workerSearchProvider).toLowerCase();

    // apply filters...
    var list = workers.where((w) {
      if (!showInactive && !w.isActive) return false;
      if (filterId != null && w.workerTypeId != filterId) return false;
      return true;
    }).toList();

    list = list.where((w) {
      final name = '${w.firstName} ${w.lastName}'.toLowerCase();
      return name.contains(query) ||
             w.employeeNumber.toLowerCase().contains(query);
    }).toList();

    // RESTYLED ChoiceChip
    Widget chip(String label, String? value) {
      final isSelected = filterId == value;
      return ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
          ),
        ),
        selected: isSelected,
        onSelected: (_) =>
          ref.read(workerTypeFilterProvider.notifier).state = value,
        backgroundColor: Colors.white,
        selectedColor: AppColors.fieldFill,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      );
    }

    return Scaffold(
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
              onChanged: (v) =>
                ref.read(workerSearchProvider.notifier).state = v,
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

                // RESTYLED Active/Inactive badge
                final badgeLabel = w.isActive ? 'Active' : 'In-Active';
                return ListTile(
                  leading: ProfileImage(worker: w, radius: 20),
                  title: Text('${w.firstName} ${w.lastName}'),
                  subtitle: Text('Emp#: ${w.employeeNumber}'),
                  trailing: Chip(
                    label: Text(
                      badgeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    backgroundColor: AppColors.fieldFill,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                    shape: const StadiumBorder(
                      side: BorderSide(color: AppColors.primary),
                    ),
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
