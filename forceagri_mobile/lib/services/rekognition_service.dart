import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RekognitionService {
  final _storage = FirebaseStorage.instance;
  final _functions = FirebaseFunctions.instance;

  Future<String> _uploadToStorage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<Map<String, dynamic>> pingWorkerFacialRecognition(File file, String filename) async {
    try {
      final url = await _uploadToStorage(file, 'rekognition/auth/$filename');
      final result = await _functions.httpsCallable('pingWorkerFacialRecognition').call({
        'fileUrl': url,
        'filename': filename,
        'mimeType': 'image/jpeg',
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('no_face_detected')) {
        return {'Message': 'no_face_detected'};
      }
      if (msg.contains('no_match')) {
        return {'Message': 'no_match'};
      }
      return {'Message': 'error', 'error': msg};
    } catch (e) {
      return {'Message': 'error', 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> registerWorkerFacialRecognition(File file, String filename) async {
    try {
      final url = await _uploadToStorage(file, 'rekognition/registered/$filename');
      final result = await _functions.httpsCallable('registerWorkerFacialRecognition').call({
        'fileUrl': url,
        'filename': filename,
        'mimeType': 'image/jpeg',
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      return {'Message': 'error', 'error': e.message ?? 'Unknown Firebase error'};
    } catch (e) {
      return {'Message': 'error', 'error': e.toString()};
    }
  }
}
