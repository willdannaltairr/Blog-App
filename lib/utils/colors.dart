import 'package:flutter/material.dart';

// Satu-satunya sumber warna: hitam-putih saja. Jangan hardcode hex di file lain.
class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color pattern = Color(0xFF101010);
  static const Color patternAlt = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceBorder = Color(0xFF242424);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color accent = Color(0xFFFFFFFF);
  static const Color accentFg = Color(0xFF000000);
  static const Color danger = Color(0xFFFFFFFF);

  // Turunan yang masih dalam palet yang sama.
  static const Color inputFill = Color(0xFF121212);
  static const Color inputFillLight = Color(0xFFF5F5F5);
  static const Color placeholder = Color(0xFF2A2A2A);
}
