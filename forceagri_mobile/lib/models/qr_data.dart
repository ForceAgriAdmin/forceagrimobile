class QRData {
  final String card;
  final String workerId;
  final String farmId;
  final String operationId;

  QRData({
    required this.card,
    required this.workerId,
    required this.farmId,
    required this.operationId,
  });

  @override
  String toString() =>
      'QRData(card: $card, workerId: $workerId, farmId: $farmId, operationId: $operationId)';
}