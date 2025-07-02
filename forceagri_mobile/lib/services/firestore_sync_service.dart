import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../models/worker_model.dart';
import '../models/worker_type_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type_model.dart';
import '../models/operation_model.dart';
import '../models/farm_model.dart';

class FirestoreSyncService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<CardModel>            cards            = [];
  List<WorkerModel>          workers          = [];
  List<WorkerTypeModel>      workerTypes      = [];
  List<TransactionModel>     transactions     = [];
  List<TransactionTypeModel> transactionTypes = [];
  List<OperationModel>       operations       = [];
  List<FarmModel>            farms            = [];

  late StreamSubscription _cardsSub,
      _workersSub,
      _workerTypesSub,
      _transactionsSub,
      _transactionTypesSub,
      _operationsSub,
      _farmsSub;

  FirestoreSyncService() {
    _db.settings = const Settings(persistenceEnabled: true);

    _cardsSub = _db.collection('cards').snapshots().listen((snap) {
      debugPrint('🃏 cards snapshot: ${snap.docs.length}');
      cards = snap.docs.map((d) => CardModel.fromDoc(d)).toList();
      notifyListeners();
    });

    _workersSub = _db.collection('workers').snapshots().listen((snap) async {
      debugPrint('👷 workers snapshot: ${snap.docs.length}');
      workers = snap.docs.map((d) => WorkerModel.fromDoc(d)).toList();
      debugPrint('👷 parsed workers: ${workers.length}');
      await _cacheWorkerImages();
      notifyListeners();
    });

    _workerTypesSub = _db.collection('workerTypes').snapshots().listen((snap) {
      debugPrint('📂 workerTypes snapshot: ${snap.docs.length}');
      workerTypes = snap.docs.map((d) => WorkerTypeModel.fromDoc(d)).toList();
      notifyListeners();
    });

    _transactionsSub = _db.collection('transactions').snapshots().listen((snap) {
      debugPrint('💰 transactions snapshot: ${snap.docs.length}');
      transactions = snap.docs.map((d) => TransactionModel.fromDoc(d)).toList();
      notifyListeners();
    });

    _transactionTypesSub = _db.collection('transactionTypes').snapshots().listen((snap) {
      debugPrint('🏷️ transactionTypes snapshot: ${snap.docs.length}');
      transactionTypes = snap.docs.map((d) => TransactionTypeModel.fromDoc(d)).toList();
      notifyListeners();
    });

    _operationsSub = _db.collection('operations').snapshots().listen((snap) {
      debugPrint('⚙️ operations snapshot: ${snap.docs.length}');
      operations = snap.docs.map((d) => OperationModel.fromDoc(d)).toList();
      notifyListeners();
    });

    _farmsSub = _db.collection('farms').snapshots().listen((snap) {
      debugPrint('🌾 farms snapshot: ${snap.docs.length}');
      farms = snap.docs.map((d) => FarmModel.fromDoc(d)).toList();
      notifyListeners();
    });
  }

  Future<void> _cacheWorkerImages() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheManager = DefaultCacheManager();
    for (final w in workers) {
      final url = w.profileImageUrl;
      if (url.isEmpty) continue;
      final keyTs = 'cachedImageUpdatedAt_${w.id}';
      final localMillis = prefs.getInt(keyTs);
      final localTs = localMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(localMillis)
          : null;
      final remoteTs = w.photoUpdatedAt;
      if (localTs == null || remoteTs.isAfter(localTs)) {
        await cacheManager.removeFile(url);
        try {
          final file = await cacheManager.getSingleFile(url);
          await prefs.setInt(keyTs, remoteTs.millisecondsSinceEpoch);
          debugPrint('✅ Cached image for ${w.id}');
        } catch (e) {
          debugPrint('❌ Failed caching ${w.id}: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _cardsSub.cancel();
    _workersSub.cancel();
    _workerTypesSub.cancel();
    _transactionsSub.cancel();
    _transactionTypesSub.cancel();
    _operationsSub.cancel();
    _farmsSub.cancel();
    super.dispose();
  }
}
