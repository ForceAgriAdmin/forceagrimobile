import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String idNumber;
  final String employeeNumber;
  final String farmId;
  final double currentBalance;
  final String operationId;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.employeeNumber,
    required this.farmId,
    required this.currentBalance,
    required this.operationId,
    required this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkerModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerModel(
      id: doc.id,
      firstName:      data['firstName']      as String,
      lastName:       data['lastName']       as String,
      idNumber:       data['idNumber']       as String,
      employeeNumber: data['employeeNumber'] as String,
      farmId:         data['farmId']         as String,
      currentBalance: (data['currentBalance'] as num).toDouble(),
      operationId:    data['operationId']    as String,
      profileImageUrl:data['profileImageUrl']as String,
      createdAt:      (data['createdAt']     as Timestamp).toDate(),
      updatedAt:      (data['updatedAt']     as Timestamp).toDate(),
    );
  }
}
