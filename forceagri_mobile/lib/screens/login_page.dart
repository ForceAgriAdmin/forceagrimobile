// lib/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final remember = ref.read(rememberMeProvider);
    try {
      await ref.read(authServiceProvider).signIn(
        email:    emailCtrl.text.trim(),
        password: passwordCtrl.text,
        rememberMe: remember,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your email first')));
      return;
    }
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset email sent')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Reset failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final remember = ref.watch(rememberMeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v != null && v.contains('@')
                  ? null
                  : 'Enter a valid email',
            ),
            TextFormField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v != null && v.length >= 6
                  ? null
                  : 'Min 6 characters',
            ),
            Row(children: [
              Checkbox(
                value: remember,
                onChanged: (v) =>
                    ref.read(rememberMeProvider.notifier).state = v ?? false,
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Forgot Password?'),
              ),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ]),
        ),
      ),
    );
  }
}
