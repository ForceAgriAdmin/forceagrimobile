import 'package:cloud_firestore/cloud_firestore.dart';

class FarmModel {
  final String id;
  final String name;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;

  FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FarmModel(
      id:        doc.id,
      name:      data['name']      as String,
      location:  data['location']  as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
