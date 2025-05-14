// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateProvider  = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);
final rememberMeProvider = StateProvider<bool>((ref) => false);
