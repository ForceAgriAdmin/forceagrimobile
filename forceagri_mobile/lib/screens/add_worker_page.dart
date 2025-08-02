// lib/screens/add_worker_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker_model.dart';
import '../providers.dart';
import '../services/workers_service.dart';

class AddWorkerPage extends ConsumerStatefulWidget {
  const AddWorkerPage({super.key});

  @override
  ConsumerState<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends ConsumerState<AddWorkerPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _image;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _idNumberController = TextEditingController();

  String? _selectedOpId;
  String? _selectedWorkerTypeId;

  @override
  Widget build(BuildContext context) {
    final operations = ref.watch(firestoreSyncServiceProvider).operations;
    final types = ref.watch(firestoreSyncServiceProvider).workerTypes;
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Worker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(labelText: 'ID Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedOpId,
                items:
                    operations
                        .map(
                          (op) => DropdownMenuItem(
                            value: op.id,
                            child: Text(op.name),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedOpId = v),
                decoration: const InputDecoration(labelText: 'Operation'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedWorkerTypeId,
                items:
                    types
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.description),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _selectedWorkerTypeId = v),
                decoration: const InputDecoration(labelText: 'Worker Type'),
              ),
              const SizedBox(height: 16),
              _image == null
                  ? ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text(
                      'Upload Profile Picture',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      Image.file(_image!, height: 150),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.edit),
                        label: const Text(
                          'Change Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _submit(user?.uid ?? ''),
                child: const Text(
                  'Add Worker',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit(String farmId) async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ref
        .read(snackBarServiceProvider)
        .showWarning(
          'Complete all fields and upload a photo.',
        );
      return;
    }

    final worker = WorkerModel(
      id: '', // will be generated in service
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      idNumber: _idNumberController.text.trim(),
      operationId: _selectedOpId ?? '',
      workerTypeId: _selectedWorkerTypeId ?? '',
      paymentGroupIds: [],
      farmId: farmId,
      employeeNumber: '',
      currentBalance: 0,
      profileImageUrl: '',
      isActive: true,
      photoUpdatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await WorkersService().addWorker(worker: worker, profileImage: _image!);
      if (mounted) {
        ref
        .read(snackBarServiceProvider)
        .showSuccess(
          'Worker added successfully!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ref
        .read(snackBarServiceProvider)
        .showError(
          'Failed to add worker: $e',
        );
    }
  }
}
