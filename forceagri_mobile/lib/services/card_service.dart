import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import '../models/qr_data.dart';

/// Wraps either a valid [CardModel] or an error message.
class ValidationResult {
  final CardModel? card;
  final String? error;
  ValidationResult({this.card, this.error});
  bool get success => card != null;
}

class CardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches the card by number and validates active & workerId.
  /// Returns a [ValidationResult]—no exceptions.
  Future<ValidationResult> validateScan(QRData data) async {
    try {
      // 1️⃣ Query Firestore for a document where 'number' == scanned card
      final query = await _db
          .collection('cards')
          .where('number', isEqualTo: data.card)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return ValidationResult(error: 'Card not found');
      }

      final doc = query.docs.first;
      final card = CardModel(
        id: doc.id,
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
        number: doc['number'] as String,
        workerId: doc['workerId'] as String,
        active: doc['active'] as bool,
      );

      // 2️⃣ Business‐rule checks
      if (!card.active) {
        return ValidationResult(error: 'This card is inactive.');
      }
      if (card.workerId != data.workerId) {
        return ValidationResult(
          error:
              'Worker ID mismatch (expected ${card.workerId}).',
        );
      }

      // 3️⃣ All good
      return ValidationResult(card: card);
    } catch (e) {
      // Network/Firebase errors
      return ValidationResult(error: 'Error fetching card data.');
    }
  }
}
