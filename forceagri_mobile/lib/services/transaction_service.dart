import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forceagri_mobile/models/transaction_model.dart';
import '../models/worker_model.dart';
import '../models/transaction_type_model.dart';

class TransactionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Queues a new transaction; your Cloud Function will pick it up and update balances.
  Future<void> addTransactionForWorker({
    required WorkerModel worker,
    required TransactionTypeModel transactionType,
    required double amount,
    required String creatorId,
    String description = '',
  }) async {
    final txRef = _db.collection('transactions').doc();

    await txRef.set({
      'timestamp':            FieldValue.serverTimestamp(),
      'amount':               amount,
      'description':          description,
      'farmId':               worker.farmId,
      'creatorId':            creatorId,
      'transactionTypeId':    transactionType.id,
      'function':             'single',
      'workerIds':            [worker.id],
      'operationIds':         [worker.operationId],
      'workerTypesIds':       [worker.workerTypeId],
      'paymentGroupIds':      worker.paymentGroupIds ?? [],
      'isSettleTransaction':  false,
    });
  }

  /// Stream all transactions for a given [workerId], newest first.
  Stream<List<TransactionModel>> watchTransactionsForWorker(String workerId) {
    return _db
      .collection('transactions')
      .where('workerIds', arrayContains: workerId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((doc) => TransactionModel.fromDoc(doc))
        .toList()
      );
  }

  /// One-time fetch of transaction types (you may filter here too if you like).
  Future<List<TransactionTypeModel>> fetchTransactionTypes() async {
    final snap = await _db.collection('transactionTypes').get();
    return snap.docs
      .map((d) => TransactionTypeModel.fromDoc(d))
      .where((t) => t.name.toLowerCase() != 'settle')
      .toList();
  }

  /// Real-time stream of transaction types.
  Stream<List<TransactionTypeModel>> watchTransactionTypes() {
    return _db
      .collection('transactionTypes')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => TransactionTypeModel.fromDoc(d))
        .where((t) => t.name.toLowerCase() != 'settle')
        .toList()
      );
  }

    Stream<List<TransactionModel>> watchAllTransactions() {
    return _db
      .collection('transactions')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) =>
        snap.docs.map((doc) => TransactionModel.fromDoc(doc)).toList()
      );
  }
}
