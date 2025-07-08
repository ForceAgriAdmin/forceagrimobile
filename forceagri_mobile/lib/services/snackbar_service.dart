import 'package:flutter/material.dart';
import '../theme.dart';

/// A global key for our root ScaffoldMessenger.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Call `snackBarService.showXxx(...)` anywhere in your app.
class SnackBarService {
  SnackBarService(this._messengerKey);

  final GlobalKey<ScaffoldMessengerState> _messengerKey;

  void _show(String message, Color backgroundColor) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
  }

  /// Green / primary
  void showSuccess(String message) {
    _show(message, AppColors.primary);
  }

  /// Amber / warning
  void showWarning(String message) {
    _show(message, Colors.orange);
  }

  /// Red / error
  void showError(String message) {
    _show(message, Colors.red);
  }
}
