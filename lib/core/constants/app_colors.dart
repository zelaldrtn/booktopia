import 'package:flutter/material.dart';

/// Booktopia uygulamasının modern vintage tasarım renk paleti.
/// style.md ve Stitch tasarım referanslarına uygun olarak hazırlanmıştır.
abstract final class AppColors {
  // Açık Tema Renkleri
  static const Color cream = Color(0xFFFCF9F4);
  static const Color creamContainer = Color(0xFFF0EDE9);
  static const Color creamLow = Color(0xFFF6F3EE);
  static const Color creamHighest = Color(0xFFE5E2DD);

  // Marka & Vurgu Renkleri
  static const Color burgundy = Color(0xFF6B3038);
  static const Color deepForest = Color(0xFF07372D);
  static const Color forestContainer = Color(0xFF234E43);
  static const Color sage = Color(0xFF7C8062);
  static const Color terracotta = Color(0xFF994703);
  static const Color terracottaFixed = Color(0xFFFFDBC9);
  static const Color sandBeige = Color(0xFFD9C7AE);

  // Stitch & Material 3 Token Eşleşmeleri
  static const Color primary = deepForest;
  static const Color primaryContainer = forestContainer;
  static const Color primaryFixed = Color(0xFFBEECDD);
  static const Color secondary = terracotta;
  static const Color secondaryFixed = terracottaFixed;
  static const Color onSecondaryFixed = Color(0xFF321200);
  static const Color surfaceVariant = creamHighest;

  // Koyu / Metin Renkleri
  static const Color darkBrown = Color(0xFF302C29);
  static const Color textPrimary = Color(0xFF1C1C19);
  static const Color textSecondary = Color(0xFF414845);
  static const Color textMuted = Color(0xFF717975);

  // Koyu Tema Renkleri
  static const Color darkBackground = Color(0xFF242321);
  static const Color darkSurface = Color(0xFF1C1B1A);
  static const Color darkSurfaceContainer = Color(0xFF2E2C2A);
  static const Color darkTextPrimary = Color(0xFFF5F0E6);
  static const Color darkTextSecondary = Color(0xFFD9C7AE);

  // Durum Renkleri
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF2E6B4E);
}
