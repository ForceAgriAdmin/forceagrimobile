// lib/screens/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final remember = ref.read(rememberMeProvider);
    try {
      await ref.read(authServiceProvider).signIn(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        rememberMe: remember,
      );
      ref.read(snackBarServiceProvider).showSuccess('Login successful');
    } catch (error) {
      ref.read(snackBarServiceProvider).showError('Login Failed!!!');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetPassword() {
    final email = emailCtrl.text.trim();
    if (email.isEmpty) {
      ref.read(snackBarServiceProvider).showWarning('Enter your email first.');
      return;
    }
    ref.read(authServiceProvider).resetPassword(email).then((_) {
      ref.read(snackBarServiceProvider).showSuccess('Reset email sent!');
    });
  }

  @override
  Widget build(BuildContext context) {
    final remember = ref.watch(rememberMeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo above the card (increased size)
              Image.asset(
                'assets/app_logo_transparent.png',
                height: 150,
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email*',
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password*',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.primary,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Min 6 characters',
                        ),
                        const SizedBox(height: 24),

                        // Remember me + Forgot password
                        Row(
                          children: [
                            Checkbox(
                              value: remember,
                              onChanged: (v) => ref
                                  .read(rememberMeProvider.notifier)
                                  .state = v ?? false,
                            ),
                            const Text('Remember me'),
                            const Spacer(),
                            TextButton(
                              onPressed: _resetPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Login',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
