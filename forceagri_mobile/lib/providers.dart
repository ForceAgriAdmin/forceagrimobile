// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forceagri_mobile/services/connectivity_service.dart';
import 'package:forceagri_mobile/services/snackbar_service.dart';

import 'models/transaction_model.dart';
import 'models/transaction_type_model.dart';
import 'models/worker_type_model.dart';
import 'services/auth_service.dart';
import 'services/card_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/transaction_service.dart';

/// 1️⃣ Core services
final firestoreSyncServiceProvider =
    ChangeNotifierProvider<FirestoreSyncService>((ref) {
  final svc = FirestoreSyncService();
  ref.onDispose(svc.dispose);
  return svc;
});
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);
final transactionServiceProvider =
    Provider<TransactionService>((ref) => TransactionService());
final cardServiceProvider = Provider<CardService>((ref) => CardService());

/// 2️⃣ UI state
final rememberMeProvider     = StateProvider<bool>((ref) => false);
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// 3️⃣ Transaction types (offline‐cached)
/// Pulls from the in‐memory cache populated by FirestoreSyncService
final transactionTypesProvider =
    Provider<List<TransactionTypeModel>>((ref) {
  return ref.watch(firestoreSyncServiceProvider).transactionTypes;
});

final snackBarServiceProvider = Provider(
  (ref) => SnackBarService(rootScaffoldMessengerKey),
);

/// 4️⃣ Transaction filtering & search
enum TransactionFilter { today, yesterday, thisWeek, all }

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => TransactionFilter.today);

/// Holds the current search query for transactions
final transactionSearchProvider = StateProvider<String>((ref) => '');

/// Streams all transactions
final allTransactionsProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  return ref.read(transactionServiceProvider).watchAllTransactions();
});

/// 5️⃣ Worker filtering & search
/// Filter by workerTypeId (null = All)
final workerTypeFilterProvider = StateProvider<String?>((ref) => null);

/// Holds the current search query for workers
final workerSearchProvider = StateProvider<String>((ref) => '');

/// The list of worker types (from sync service)
final workerTypesProvider = Provider<List<WorkerTypeModel>>((ref) {
  return ref.watch(firestoreSyncServiceProvider).workerTypes;
});

/// 6️⃣ Internet‐quality indicator
final connectionQualityProvider =
    StreamProvider<ConnectionQuality>((ref) {
  return connectionQualityStream(
    interval: const Duration(seconds: 10),
    goodThresholdMs: 200,
  );
});