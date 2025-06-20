// lib/models/worker_model.dart
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
  final String workerTypeId;
  final List<String> paymentGroupIds;
  final bool isActive;
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
    required this.workerTypeId,
    required this.paymentGroupIds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkerModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WorkerModel(
      id:               doc.id,
      firstName:        data['firstName']      as String? ?? '',
      lastName:         data['lastName']       as String? ?? '',
      idNumber:         data['idNumber']       as String? ?? '',
      employeeNumber:   data['employeeNumber'] as String? ?? '',
      farmId:           data['farmId']         as String? ?? '',
      currentBalance:   (data['currentBalance'] as num?)?.toDouble() ?? 0.0,
      operationId:      data['operationId']    as String? ?? '',
      profileImageUrl:  data['profileImageUrl']as String? ?? '',
      workerTypeId:     data['workerTypeId']   as String? ?? '',
      paymentGroupIds:  data['paymentGroupIds'] != null
        ? List<String>.from(data['paymentGroupIds'] as List<dynamic>)
        : [],
      isActive:         data['isActive']       as bool? ?? true,
      createdAt:        (data['createdAt']     as Timestamp?)?.toDate()
                          ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:        (data['updatedAt']     as Timestamp?)?.toDate()
                          ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName':        firstName,
      'lastName':         lastName,
      'idNumber':         idNumber,
      'employeeNumber':   employeeNumber,
      'farmId':           farmId,
      'currentBalance':   currentBalance,
      'operationId':      operationId,
      'profileImageUrl':  profileImageUrl,
      'workerTypeId':     workerTypeId,
      'paymentGroupIds':  paymentGroupIds,
      'isActive':         isActive,
      'createdAt':        Timestamp.fromDate(createdAt),
      'updatedAt':        Timestamp.fromDate(updatedAt),
    };
  }
}
