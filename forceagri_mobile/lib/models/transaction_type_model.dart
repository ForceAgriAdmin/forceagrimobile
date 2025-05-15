// lib/models/transaction_type_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionTypeModel {
  final String id;
  final String name;
  final String description;
  final bool isCredit;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isCredit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionTypeModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    // Safely parse server timestamps, fallback to epoch
    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;

    return TransactionTypeModel(
      id:          doc.id,
      name:        data['name']        as String,
      description: data['description'] as String,
      isCredit:    data['isCredit']    as bool,
      createdAt:   createdTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:   updatedTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
