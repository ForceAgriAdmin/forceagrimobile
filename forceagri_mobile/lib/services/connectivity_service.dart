import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

enum ConnectionQuality { good, poor, none }

Stream<ConnectionQuality> connectionQualityStream({
  Duration interval = const Duration(seconds: 10),
  int goodThresholdMs = 200,
}) async* {
  final connectivity = Connectivity();
  final client = http.Client();

  Future<ConnectionQuality> checkOnce() async {
    final status = await connectivity.checkConnectivity();
    if (status == ConnectivityResult.none) {
      return ConnectionQuality.none;
    }
    final stopwatch = Stopwatch()..start();
    try {
      final resp = await client
          .head(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();
      if (resp.statusCode == 204) {
        return stopwatch.elapsedMilliseconds < goodThresholdMs
            ? ConnectionQuality.good
            : ConnectionQuality.poor;
      }
      return ConnectionQuality.poor;
    } catch (_) {
      return ConnectionQuality.none;
    }
  }

  // first immediate
  yield await checkOnce();

  // then periodic
  await for (final _ in Stream.periodic(interval)) {
    yield await checkOnce();
  }
}