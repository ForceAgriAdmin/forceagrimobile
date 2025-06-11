import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final DateTime timestamp;
  final double amount;
  final String description;
  //final String farmId;
  final String creatorId;
  final String transactionTypeId;
  final String function;
  final List<String> workerTypesIds;
  final List<String> operationIds;
  final List<String> workerIds;
  final List<String> paymentGroupIds;

  TransactionModel({
    required this.id,
    required this.timestamp,
    required this.amount,
    required this.description,
    //required this.farmId,
    required this.creatorId,
    required this.transactionTypeId,
    required this.function,
    required this.workerTypesIds,
    required this.operationIds,
    required this.workerIds,
    required this.paymentGroupIds,
  });

  factory TransactionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id:                 doc.id,
      timestamp:          (data['timestamp']        as Timestamp).toDate(),
      amount:             (data['amount']           as num).toDouble(),
      description:        data['description']       as String,
     // farmId:             data['farmId']            as String,
      creatorId:          data['creatorId']         as String,
      transactionTypeId:  data['transactionTypeId'] as String,
      function:           data['function']          as String,
      workerTypesIds:     List<String>.from(data['workerTypesIds'] as List),
      operationIds:       List<String>.from(data['operationIds'] as List),
      workerIds:          List<String>.from(data['workerIds'] as List),
      paymentGroupIds:    List<String>.from(data['paymentGroupIds'] as List),
    );
  }
}
