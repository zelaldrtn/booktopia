import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Booktopia Material Design 3 Tema Yapılandırması.
/// style.md ve Stitch tasarım referanslarına uygun açık ve koyu temaları yönetir.
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
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return TextTheme(
      // Başlıklarda serif (Newsreader)
      displayLarge: GoogleFonts.newsreader(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // Gövde metinlerinde okunaklı sans-serif (Plus Jakarta Sans)
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: textColor.withValues(alpha: 0.8),
      ),
    );
  }
}
