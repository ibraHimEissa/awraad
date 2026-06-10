import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Central Material 3 theme for the diwan.
///
/// The look is a *balanced* Material 3: modern M3 components and tonal
/// surfaces, but tuned to the order's identity — deep emerald greens, soft
/// gold accents, and the Cairo (UI) / Amiri (scripture) Arabic fonts.
class AppTheme {
  AppTheme._();

  static const String fontUi = 'Cairo';
  static const String fontScripture = 'Amiri';

  // Shared M3 shape language.
  static const double rSm = 12;
  static const double rMd = 16;
  static const double rLg = 24;
  static const double rXl = 28;

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    const scheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.gold,
      onPrimary: Color(0xFF2A2110),
      primaryContainer: AppColors.goldDeep,
      onPrimaryContainer: Color(0xFF1A1505),
      secondary: AppColors.emerald,
      onSecondary: Color(0xFF06160E),
      secondaryContainer: Color(0xFF2C4C3A),
      onSecondaryContainer: AppColors.greenLight,
      tertiary: AppColors.goldBright,
      onTertiary: Color(0xFF2A2110),
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontUi,
      textTheme: _textTheme(base.textTheme),
      iconTheme: const IconThemeData(color: AppColors.gold),
      splashFactory: InkSparkle.splashFactory,
      splashColor: AppColors.gold.withValues(alpha: 0.10),
      highlightColor: AppColors.gold.withValues(alpha: 0.06),

      // ── Components ───────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        modalBackgroundColor: AppColors.surfaceContainerLow,
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(rXl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rXl)),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: AppColors.drawerBg,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        indicatorColor: AppColors.gold.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rLg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: fontUi,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: const TextStyle(
            fontFamily: fontUi,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        side: const BorderSide(color: AppColors.outlineVariant),
        labelStyle: const TextStyle(
          fontFamily: fontUi,
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rSm)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: const TextStyle(
          fontFamily: fontUi,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rMd)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontUi,
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rMd),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      bodyLarge: const TextStyle(
        fontFamily: fontScripture,
        fontSize: 23,
        height: 1.9,
        color: AppColors.inkBrown,
      ),
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
