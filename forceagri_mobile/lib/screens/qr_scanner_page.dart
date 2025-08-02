import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_data.dart';
import '../providers.dart';
import 'scanned_result_page.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  const QRScannerPage({super.key});
  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  final controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String raw) async {
    final data = parseQRData(raw);
    if (data == null) {
      _showError('Invalid Card');
      return;
    }
    final result =
        await ref.read(cardServiceProvider).validateScan(data);

    if (!result.success) {
      _showError(result.error!);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScannedResultPage(
          qrData: data,
          card: result.card!,
        ),
      ),
    );
  }

  void _showError(String message) {
    ref
        .read(snackBarServiceProvider)
        .showError(
          message,
        );
    _isScanning = true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.8;
    final h = w * 0.6;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Card')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (!_isScanning) return;
              _isScanning = false;
              final raw = capture.barcodes.first.rawValue ?? '';
              _handleScan(raw);
            },
          ),
          Container(color: Colors.black.withValues(alpha: 0.5)),
          Center(
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

   QRData? parseQRData(String raw) {
  const keyCard   = 'card:';
  const keyWork   = 'workerId:';
  const keyFarm   = 'farmId:';
  const keyOp     = 'operationId:';

  final iCard   = raw.indexOf(keyCard);
  final iWork   = raw.indexOf(keyWork);
  final iFarm   = raw.indexOf(keyFarm);
  final iOp     = raw.indexOf(keyOp);

  if ([iCard, iWork, iFarm, iOp].any((i) => i < 0) ||
      !(iCard < iWork && iWork < iFarm && iFarm < iOp)) {
    return null;
  }

  String slice(int start, int end) =>
      raw.substring(start, end).trim();

  final cardValue = slice(iCard + keyCard.length, iWork);
  final workValue = slice(iWork + keyWork.length, iFarm);
  final farmValue = slice(iFarm + keyFarm.length, iOp);
  final opValue   = slice(iOp   + keyOp.length, raw.length);

  if (!RegExp(r'^\d{20}$').hasMatch(cardValue)) {
    return null;
  }
  
  if ([workValue, farmValue, opValue].any((s) => s.isEmpty)) {
    return null;
  }

  return QRData(
    card:        cardValue,
    workerId:    workValue,
    farmId:      farmValue,
    operationId: opValue,
  );
}
}
