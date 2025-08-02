import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/widgets/profile_image.dart';

import '../models/worker_model.dart';
import '../models/transaction_type_model.dart';
import '../providers.dart';

class TransactionPage extends ConsumerStatefulWidget {
  final WorkerModel worker;
  const TransactionPage({required this.worker, super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  TransactionTypeModel? _selectedType;
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedType == null || !_formKey.currentState!.validate()) {
      ref
        .read(snackBarServiceProvider)
        .showWarning(
          'Please pick a type and enter a valid amount',
        );
      return;
    }
    final amount = double.parse(_amountCtrl.text);

    ref
        .read(transactionServiceProvider)
        .addTransactionForWorker(
          worker: widget.worker,
          transactionType: _selectedType!,
          amount: amount,
          creatorId: ref.read(authStateProvider).value!.uid,
          description: '',
        )
        .catchError((e) {
          debugPrint('Transaction sync error: $e');
        });

    ref
        .read(snackBarServiceProvider)
        .showSuccess(
          'N\$${amount.toStringAsFixed(2)} ${_selectedType!.name} queued',
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // filter out "settle" from the list
    final allTypes = ref.watch(transactionTypesProvider);
    final types =
        allTypes.where((t) => t.name.toLowerCase() != 'settle').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ProfileImage(worker: widget.worker, radius: 64),
            const SizedBox(height: 16),
            Text(
              '${widget.worker.firstName} ${widget.worker.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),

            if (types.isEmpty) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<TransactionTypeModel>(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Type',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          types.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t.name),
                            );
                          }).toList(),
                      onChanged: (t) => setState(() => _selectedType = t),
                      validator: (v) => v == null ? 'Type required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (N\$)',
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Amount required';
                        }
                        return double.tryParse(v) == null
                            ? 'Invalid number'
                            : null;
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Complete'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
