// lib/services/workers_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/worker_model.dart';

class WorkersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(File file) async {
    final path = 'profiles/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addWorker({
    required WorkerModel worker,
    required File profileImage,
  }) async {
    final docRef = _firestore.collection('workers').doc();
    final imageUrl = await uploadProfileImage(profileImage);

    await docRef.set({
      'id': docRef.id,
      'firstName': worker.firstName,
      'lastName': worker.lastName,
      'idNumber': worker.idNumber,
      'operationId': worker.operationId,
      'workerTypeId': worker.workerTypeId,
      'farmId': worker.farmId,
      'employeeNumber': worker.employeeNumber,
      'currentBalance': 0,
      'profileImageUrl': imageUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
