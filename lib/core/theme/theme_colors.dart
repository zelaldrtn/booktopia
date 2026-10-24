import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Dinamik tema renklerine kolay ve tutarlı erişim sağlayan Extension.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Arka planlar
  Color get scaffoldBg => isDark ? AppColors.darkBackground : AppColors.cream;
  Color get cardBg => isDark ? AppColors.darkSurfaceContainer : Colors.white;
  Color get containerBg => isDark ? AppColors.darkSurface : AppColors.creamContainer;
  Color get elevatedCardBg => isDark ? const Color(0xFF383533) : Colors.white;

  // Metin renkleri
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get headlineColor => isDark ? AppColors.darkTextPrimary : AppColors.deepForest;

  // Kenarlık & Çizgiler
  Color get borderColor => isDark ? const Color(0xFF474340) : AppColors.surfaceVariant;
  Color get dividerColor =>
      isDark ? const Color(0xFF383533) : AppColors.surfaceVariant.withValues(alpha: 0.6);
}
