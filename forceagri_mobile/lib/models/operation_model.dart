import 'package:cloud_firestore/cloud_firestore.dart';

class OperationModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  OperationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OperationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OperationModel(
      id:          doc.id,
      name:        data['name']        as String,
      description: data['description'] as String,
      createdAt:   (data['createdAt']  as Timestamp).toDate(),
      updatedAt:   (data['updatedAt']  as Timestamp).toDate(),
    );
  }
}
