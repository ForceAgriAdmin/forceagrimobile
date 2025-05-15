// lib/screens/scanned_result_page.dart
import 'package:flutter/material.dart';
import '../models/qr_data.dart';
import '../models/card_model.dart';

class ScannedResultPage extends StatelessWidget {
  final QRData qrData;
  final CardModel card;

  const ScannedResultPage({
    required this.qrData,
    required this.card,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card #: ${qrData.card}'),
            Text('Worker ID: ${qrData.workerId}'),
            Text('Farm ID: ${qrData.farmId}'),
            Text('Op ID: ${qrData.operationId}'),
            const Divider(height: 32),
            Text('Card Record:', style: Theme.of(context).textTheme.titleMedium),
            Text('ID:        ${card.id}'),
            Text('Created:   ${card.createdAt}'),
            Text('Active:    ${card.active}'),
          ],
        ),
      ),
    );
  }
}
