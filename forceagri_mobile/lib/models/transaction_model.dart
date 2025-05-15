import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String description;
  final String operationId;
  final String creatorId;
  final String transactionTypeId;
  final String workerId;
  final String function;
  final List<String> multiWorkerId;

  TransactionModel({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.description,
    required this.operationId,
    required this.creatorId,
    required this.transactionTypeId,
    required this.workerId,
    required this.function,
    required this.multiWorkerId,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id:                 doc.id,
      timestamp:          (data['timestamp']        as Timestamp).toDate(),
      amount:             (data['amount']           as num).toDouble(),
      description:        data['description']       as String,
      operationId:        data['operationId']       as String,
      creatorId:          data['creatorId']         as String,
      transactionTypeId:  data['transactionTypeId'] as String,
      workerId:           data['workerId']          as String,
      function:           data['function']          as String,
      multiWorkerId:      List<String>.from(data['multiWorkerId'] as List),
    );
  }
}
