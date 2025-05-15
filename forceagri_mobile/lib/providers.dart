// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/auth_service.dart';
import 'services/card_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/transaction_service.dart';
import 'models/transaction_type_model.dart';

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
final rememberMeProvider = StateProvider<bool>((ref) => false);
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// 3️⃣ Transaction types (offline‐cached)
/// Pulls from the in‐memory cache populated by FirestoreSyncService
final transactionTypesProvider =
    Provider<List<TransactionTypeModel>>((ref) {
  return ref.watch(firestoreSyncServiceProvider).transactionTypes;
});
