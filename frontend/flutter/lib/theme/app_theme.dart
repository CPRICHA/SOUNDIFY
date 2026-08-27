import 'package:flutter/material.dart';
import '../models/models.dart';

class AppColors {
  // Brand colors
  static const primary = Color(0xFF4F46E5); // Indigo 600
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFFEEF2FF);

  // Surface colors
  static const background = Color(0xFFF8FAFC); // Slate 50
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0); // Slate 200
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textMuted = Color(0xFF94A3B8); // Slate 400

  // High Contrast
  static const hcBackground = Color(0xFFFFFFFF);
  static const hcText = Color(0xFF020617); // Slate 950
  static const hcBorder = Color(0xFF020617);

  // Severity Colors
  static const critical = Color(0xFFDC2626); // Red 600
  static const criticalBg = Color(0xFFFEF2F2); // Red 50
  static const criticalBorder = Color(0xFFFECACA); // Red 200

  static const high = Color(0xFFEA580C); // Orange 600
  static const highBg = Color(0xFFFFF7ED); // Orange 50
  static const highBorder = Color(0xFFFED7AA); // Orange 200

  static const medium = Color(0xFF2563EB); // Blue 600
  static const mediumBg = Color(0xFFEFF6FF); // Blue 50
  static const mediumBorder = Color(0xFFBFDBFE); // Blue 200

  static const low = Color(0xFF16A34A); // Green 600
  static const lowBg = Color(0xFFF0FDF4); // Green 50
  static const lowBorder = Color(0xFFBBF7D0); // Green 200

  static Color getSeverityColor(PriorityLevel level, {bool highContrast = false}) {
    if (highContrast) {
      switch (level) {
        case PriorityLevel.critical:
          return const Color(0xFF991B1B);
        case PriorityLevel.high:
          return const Color(0xFFC2410C);
        case PriorityLevel.medium:
          return const Color(0xFF1D4ED8);
        case PriorityLevel.low:
          return const Color(0xFF166534);
      }
    }
    switch (level) {
      case PriorityLevel.critical:
        return critical;
      case PriorityLevel.high:
        return high;
      case PriorityLevel.medium:
        return medium;
      case PriorityLevel.low:
        return low;
    }
  }

  static Color getSeverityBg(PriorityLevel level) {
    switch (level) {
      case PriorityLevel.critical:
        return criticalBg;
      case PriorityLevel.high:
        return highBg;
      case PriorityLevel.medium:
        return mediumBg;
      case PriorityLevel.low:
        return lowBg;
    }
  }

  static Color getSeverityBorder(PriorityLevel level) {
    switch (level) {
      case PriorityLevel.critical:
        return criticalBorder;
      case PriorityLevel.high:
        return highBorder;
      case PriorityLevel.medium:
        return mediumBorder;
      case PriorityLevel.low:
        return lowBorder;
    }
  }
}

class AppTheme {
  static ThemeData lightTheme({bool highContrast = false}) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: highContrast ? AppColors.hcBackground : AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: highContrast ? Colors.white : AppColors.surface,
        background: highContrast ? AppColors.hcBackground : AppColors.background,
      ),
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: highContrast ? AppColors.hcText : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
