// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      final expiry = DateTime.now()
          .add(const Duration(days: 14))
          .millisecondsSinceEpoch;
      await prefs.setBool('rememberMe', true);
      await prefs.setInt('expiry', expiry);
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('expiry');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('expiry');
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}
