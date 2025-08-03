import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forceagri_mobile/models/worker_model.dart';
import 'package:forceagri_mobile/screens/worker_detail_page.dart';
import 'package:forceagri_mobile/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/qr_data.dart';
import '../providers.dart';
import 'scanned_result_page.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  final bool scanFaceOnlyMode;
  const QRScannerPage({super.key, this.scanFaceOnlyMode = false});

  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage>
    with TickerProviderStateMixin {
  final controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  bool _isScanningFace = false;

  File? _faceImage;
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;

  late final TabController _tabController;
  late final AnimationController _scanAnimController;
  late final Animation<double> _scanLinePosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.scanFaceOnlyMode ? 1 : 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 || widget.scanFaceOnlyMode) {
        _faceImage = null;
        _initCamera();
      } else {
        _cameraController?.dispose();
        _cameraController = null;
        setState(() {});
      }
    });

    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scanLinePosition = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );

    if (widget.scanFaceOnlyMode) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _cameraController?.dispose();
    _tabController.dispose();
    _scanAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String raw) async {
    final data = parseQRData(raw);
    if (data == null) {
      _showError('Invalid Card');
      return;
    }
    final result = await ref.read(cardServiceProvider).validateScan(data);

    if (!result.success) {
      _showError(result.error!);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScannedResultPage(qrData: data, card: result.card!),
      ),
    );
  }

  void _showError(String message) {
    ref.read(snackBarServiceProvider).showError(message);
    _isScanning = true;
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final back = _cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _cameraController = CameraController(back, ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _takeFacePicture() async {
    final image = await _cameraController!.takePicture();
    if (!mounted) return;
    setState(() {
      _faceImage = File(image.path);
    });
    ref.read(snackBarServiceProvider).showSuccess("Face captured.");
  }

  Future<void> _pingRekognition() async {
    setState(() => _isScanningFace = true);
    _scanAnimController.repeat(reverse: true);

    try {
      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await ref
          .read(rekognitionServiceProvider)
          .pingWorkerFacialRecognition(_faceImage!, filename);

      final message = result['Message']?.toString().toLowerCase();
      final workerId = result['workerId'] ?? '';

      if (message == 'success' && workerId.isNotEmpty) {
        ref
            .read(snackBarServiceProvider)
            .showWarning('Face matched to a worker.');

        await Future.delayed(const Duration(seconds: 1));

        final worker = ref
            .read(firestoreSyncServiceProvider)
            .workers
            .firstWhere((w) => w.id == workerId);

        if (worker.id.isNotEmpty && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WorkerDetailPage(worker: worker)),
          );
        } else {
          ref
              .read(snackBarServiceProvider)
              .showError('Worker record not found locally.');
        }
      } else if (message == 'no_match') {
        ref
            .read(snackBarServiceProvider)
            .showSuccess('This worker\'s face has not been detected.');

        if (widget.scanFaceOnlyMode) {
          Navigator.pop(context, _faceImage);
        }
      } else if (message == 'no_face_detected') {
        ref
            .read(snackBarServiceProvider)
            .showError('No face detected in the image.');

        if (widget.scanFaceOnlyMode) {
          Navigator.pop(context);
        }
      } else {
        ref
            .read(snackBarServiceProvider)
            .showError('Rekognition Failed! Please make sure you are scanning a face');

        if (widget.scanFaceOnlyMode) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ref
          .read(snackBarServiceProvider)
          .showError('Scan failed: ${e.toString()}');

      if (widget.scanFaceOnlyMode) {
        Navigator.pop(context);
      }
    } finally {
      _scanAnimController.stop();
      setState(() => _isScanningFace = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan'),
        backgroundColor: AppColors.primary,
        bottom: widget.scanFaceOnlyMode
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Scan Card'),
                  Tab(text: 'Scan Face'),
                ],
              ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: widget.scanFaceOnlyMode ? const NeverScrollableScrollPhysics() : null,
        children: widget.scanFaceOnlyMode
            ? [_buildFaceTab()]
            : [_buildCardTab(), _buildFaceTab()],
      ),
    );
  }

  Widget _buildCardTab() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (!_isScanning) return;
                    _isScanning = false;
                    final raw = capture.barcodes.first.rawValue ?? '';
                    _handleScan(raw);
                  },
                ),
              ),
              _buildScanBox(aspectRatio: 3 / 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaceTab() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_faceImage != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(_faceImage!, height: 300),
                        if (_isScanningFace)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _scanLinePosition,
                              builder: (_, __) {
                                return Align(
                                  alignment: Alignment(0, _scanLinePosition.value * 2 - 1),
                                  child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.greenAccent.withOpacity(0.4),
                                          Colors.greenAccent.withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.4, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isScanningFace)
                      ElevatedButton.icon(
                        label: const Text(
                          'Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: _pingRekognition,
                        icon: const Icon(Icons.search),
                      ),
                  ],
                )
              else if (_cameraController != null && _cameraController!.value.isInitialized)
                SizedBox.expand(child: CameraPreview(_cameraController!))
              else
                const Center(child: CircularProgressIndicator()),

              if (_faceImage == null) _buildScanBox(aspectRatio: 3 / 4),
              if (_faceImage == null)
                Positioned(
                  bottom: 32,
                  child: FloatingActionButton(
                    onPressed: _takeFacePicture,
                    backgroundColor: AppColors.fieldFill,
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanBox({required double aspectRatio}) {
    final width = MediaQuery.of(context).size.width * 0.7;
    final height = width / aspectRatio;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  QRData? parseQRData(String raw) {
    const keyCard = 'card:';
    const keyWork = 'workerId:';
    const keyFarm = 'farmId:';
    const keyOp = 'operationId:';

    final iCard = raw.indexOf(keyCard);
    final iWork = raw.indexOf(keyWork);
    final iFarm = raw.indexOf(keyFarm);
    final iOp = raw.indexOf(keyOp);

    if ([iCard, iWork, iFarm, iOp].any((i) => i < 0) ||
        !(iCard < iWork && iWork < iFarm && iFarm < iOp)) {
      return null;
    }

    String slice(int start, int end) => raw.substring(start, end).trim();

    final cardValue = slice(iCard + keyCard.length, iWork);
    final workValue = slice(iWork + keyWork.length, iFarm);
    final farmValue = slice(iFarm + keyFarm.length, iOp);
    final opValue = slice(iOp + keyOp.length, raw.length);

    if (!RegExp(r'^\d{20}\$').hasMatch(cardValue)) return null;
    if ([workValue, farmValue, opValue].any((s) => s.isEmpty)) return null;

    return QRData(
      card: cardValue,
      workerId: workValue,
      farmId: farmValue,
      operationId: opValue,
    );
  }
}
