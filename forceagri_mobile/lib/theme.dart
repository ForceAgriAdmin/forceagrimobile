// lib/theme.dart
import 'package:flutter/material.dart';

/// Your five core colors in one place
class AppColors {
  static const primary      = Color(0xFF45664C);
  static const background   = Color(0xFFF9FAF5);
  static const fieldFill    = Color(0xFFE8F5EA);
  static const linkBlue     = Colors.blue;
}

final ThemeData appTheme = ThemeData(
  // Scaffold & drawer bg
  scaffoldBackgroundColor: AppColors.background,
  canvasColor: AppColors.background,

  // Primary color (still used in many places)
  primaryColor: AppColors.primary,

  // AppBar styling
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // Color scheme (for switches, snackbars, etc.)
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primary,
    secondary: AppColors.fieldFill,
    surface: AppColors.background,
  ),

  // Input fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black54),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black54),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black87, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.black87),
  ),

  // Elevated (primary) buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,  // <-- no more `primary:`
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16),
    ),
  ),

  // TextButtons (e.g. “Forgot password?”)
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.linkBlue,
      textStyle: const TextStyle(
        decoration: TextDecoration.underline,
      ),
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  ),

  // Your typography
  textTheme: const TextTheme(
    // headline5 is gone; use titleLarge for ~20sp bold
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    // bodyMedium is ~16sp
    bodyMedium: TextStyle(fontSize: 16),
    // bodySmall ~14sp, for captions
    bodySmall: TextStyle(fontSize: 14),
  ),
);
