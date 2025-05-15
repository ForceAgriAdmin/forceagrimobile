// lib/services/transaction_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forceagri_mobile/models/transaction_model.dart';
import '../models/worker_model.dart';
import '../models/transaction_type_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Queues a new transaction; the Cloud Function will update balances server-side.
  Future<void> addTransactionForWorker({
    required WorkerModel worker,
    required TransactionTypeModel transactionType,
    required double amount,
    required String creatorId,
    String description = '',
  }) async {
    final txRef = _db.collection('transactions').doc();

    // Firestore offline persistence will cache this write if offline,
    // and your Cloud Function will pick it up and update balances.
    await txRef.set({
      'timestamp':         FieldValue.serverTimestamp(),
      'amount':            amount,
      'description':       description,
      'operationId':       worker.operationId,
      'creatorId':         creatorId,
      'transactionTypeId': transactionType.id,
      'workerId':          worker.id,
      'function':          'single',
      'multiWorkerId':     <String>[],
    });
  }

  /// Stream all transactions for a given [workerId], newest first.
  Stream<List<TransactionModel>> watchTransactionsForWorker(String workerId) {
    return _db
        .collection('transactions')
        .where('workerId', isEqualTo: workerId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => TransactionModel.fromDoc(doc)).toList());
  }

  /// One-time fetch of transaction types.
  Future<List<TransactionTypeModel>> fetchTransactionTypes() async {
    final snap = await _db.collection('transactionTypes').get();
    return snap.docs
        .map((d) => TransactionTypeModel.fromDoc(d))
        .toList();
  }

  /// Real-time stream of transaction types.
  Stream<List<TransactionTypeModel>> watchTransactionTypes() {
    return _db
        .collection('transactionTypes')
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TransactionTypeModel.fromDoc(d)).toList());
  }
}
