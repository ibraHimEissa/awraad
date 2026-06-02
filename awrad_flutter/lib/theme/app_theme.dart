import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central typography + theme for the app.
/// Cairo  -> modern UI / headings (sans, like the old CairoFontFamily)
/// Amiri  -> the sacred Arabic body text (serif manuscript feel)
class AppTheme {
  AppTheme._();

  static const String fontUi = 'Cairo';
  static const String fontScripture = 'Amiri';

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.background,
        secondary: AppColors.emerald,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      fontFamily: fontUi,
      textTheme: _textTheme(base.textTheme),
      iconTheme: const IconThemeData(color: AppColors.gold),
      splashColor: AppColors.gold.withValues(alpha: 0.12),
      highlightColor: AppColors.gold.withValues(alpha: 0.08),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      // Sacred body text
      bodyLarge: const TextStyle(
        fontFamily: fontScripture,
        fontSize: 23,
        height: 1.9,
        color: AppColors.inkBrown,
      ),
      // Section headings
      titleLarge: const TextStyle(
        fontFamily: fontUi,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.gold,
      ),
      titleMedium: const TextStyle(
        fontFamily: fontUi,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      labelLarge: const TextStyle(
        fontFamily: fontUi,
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      bodyMedium: const TextStyle(
        fontFamily: fontUi,
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      bodySmall: const TextStyle(
        fontFamily: fontUi,
        fontSize: 12,
        color: AppColors.textMuted,
      ),
    );
  }
}

/// Convenience text-style helpers used across ornamental widgets.
class AppText {
  AppText._();

  static const TextStyle scripture = TextStyle(
    fontFamily: AppTheme.fontScripture,
    fontSize: 23,
    height: 1.95,
    color: AppColors.inkBrown,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppTheme.fontUi,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.gold,
  );

  static const TextStyle ui = TextStyle(
    fontFamily: AppTheme.fontUi,
    fontSize: 14,
    color: AppColors.textPrimary,
  );
}
