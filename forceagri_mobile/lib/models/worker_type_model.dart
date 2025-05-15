import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerTypeModel {
  final String id;
  final String description;

  WorkerTypeModel({ required this.id, required this.description });

  factory WorkerTypeModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerTypeModel(
      id:          doc.id,
      description: data['description'] as String,
    );
  }
}
