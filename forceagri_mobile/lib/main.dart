// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final remember = prefs.getBool('rememberMe') ?? false;
  final expiry   = prefs.getInt('expiry') ?? 0;
  final now      = DateTime.now().millisecondsSinceEpoch;

  // If not remembered or expired, sign out
  if (!remember || now > expiry) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const ProviderScope(child: MyApp()));
}
