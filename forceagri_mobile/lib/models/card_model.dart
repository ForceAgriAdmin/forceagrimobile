// lib/models/card_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String id;
  final DateTime createdAt;
  final String number;
  final String workerId;
  final bool active;

  CardModel({
    required this.id,
    required this.createdAt,
    required this.number,
    required this.workerId,
    required this.active,
  });

  /// Creates a [CardModel] from a Firestore document snapshot.
  factory CardModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CardModel(
      id:        doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      number:    data['number']     as String,
      workerId:  data['workerId']   as String,
      active:    data['active']     as bool,
    );
  }

  @override
  String toString() {
    return 'CardModel(id: $id, createdAt: $createdAt, '
        'number: $number, workerId: $workerId, active: $active)';
  }
}
