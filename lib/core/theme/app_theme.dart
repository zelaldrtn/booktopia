import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Booktopia Material Design 3 Tema Yapılandırması.
/// style.md ve Stitch tasarım referanslarına uygun açık ve koyu temaları yönetir.
/// Tema geçişleri (light <-> dark) sırasında TextStyle.inherit uyumsuzluğu yaşanmaması için
/// tüm tipografi stilleri base TextTheme üzerinden türetilir (inherit: false korunur).
abstract final class AppTheme {
  /// Açık Tema (Varsayılan)
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.deepForest,
        onPrimary: Colors.white,
        primaryContainer: AppColors.forestContainer,
        onPrimaryContainer: AppColors.cream,
        secondary: AppColors.burgundy,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.terracottaFixed,
        onSecondaryContainer: AppColors.terracotta,
        tertiary: AppColors.sage,
        onTertiary: Colors.white,
        surface: AppColors.cream,
        onSurface: AppColors.textPrimary,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: AppColors.creamLow,
        surfaceContainer: AppColors.creamContainer,
        surfaceContainerHighest: AppColors.creamHighest,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.textMuted,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.error,
      ),
      textTheme: _buildTextTheme(baseTextTheme, AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.newsreader(
          textStyle: baseTextTheme.titleLarge,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.deepForest,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepForest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: baseTextTheme.labelLarge,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepForest,
          side: const BorderSide(color: AppColors.deepForest, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: baseTextTheme.labelLarge,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Koyu Tema
  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.sage,
        onPrimary: AppColors.darkBackground,
        primaryContainer: AppColors.forestContainer,
        onPrimaryContainer: AppColors.cream,
        secondary: AppColors.sandBeige,
        onSecondary: AppColors.darkBackground,
        secondaryContainer: AppColors.darkSurfaceContainer,
        onSecondaryContainer: AppColors.sandBeige,
        tertiary: AppColors.terracottaFixed,
        onTertiary: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkSurface,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerHighest: Color(0xFF383533),
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.textMuted,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(baseTextTheme, AppColors.darkTextPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground.withValues(alpha: 0.9),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.newsreader(
          textStyle: baseTextTheme.titleLarge,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: baseTextTheme.labelLarge,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sage,
          side: const BorderSide(color: AppColors.sage, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            textStyle: baseTextTheme.labelLarge,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Tüm yazı tiplerini base TextTheme üzerinden türeterek inherit: false özelliğini korur.
  /// Böylece açık/koyu tema animasyonlu geçişlerinde "Failed to interpolate TextStyles with different inherit values"
  /// hatası tamamen önlenir.
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      // Başlıklarda edebi serif (Newsreader)
      displayLarge: GoogleFonts.newsreader(
        textStyle: base.displayLarge,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.newsreader(
        textStyle: base.displayMedium,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.newsreader(
        textStyle: base.displaySmall,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.newsreader(
        textStyle: base.headlineLarge,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.newsreader(
        textStyle: base.headlineMedium,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.newsreader(
        textStyle: base.headlineSmall,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.titleLarge,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.titleMedium,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.titleSmall,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // Gövde metinlerinde okunaklı sans-serif (Plus Jakarta Sans)
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.bodyLarge,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.bodyMedium,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        textStyle: base.bodySmall,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: base.labelLarge,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        textStyle: base.labelMedium,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        textStyle: base.labelSmall,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: textColor.withValues(alpha: 0.8),
      ),
    );
  }
}
