// lib/models/card_model.dart
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

  @override
  String toString() {
    return 'CardModel(id: $id, createdAt: $createdAt, '
        'number: $number, workerId: $workerId, active: $active)';
  }
}
