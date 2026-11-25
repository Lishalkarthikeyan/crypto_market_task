import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class AppColors {
  static const Color brand = Color(0xFF3861FB);
  static const Color up = Color(0xFF16C784);
  static const Color down = Color(0xFFEA3943);
  static const Color gold = Color(0xFFF5B301);

  static Color change(double value) => value >= 0 ? up : down;
}

class AppTheme {
  static const Color _darkBg = Color(0xFF0D1118);
  static const Color _darkCard = Color(0xFF161B24);
  static const Color _lightBg = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFF5F7FA);

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _darkCard : _lightCard;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bg = dark ? _darkBg : _lightBg;
    final card = dark ? _darkCard : _lightCard;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      primary: AppColors.brand,
      surface: bg,
    );

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.brand, 1.5),
        errorBorder: border(AppColors.down),
        focusedErrorBorder: border(AppColors.down, 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        height: 66,
        indicatorColor: AppColors.brand.withOpacity(0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(dark ? 0.25 : 0.5),
        space: 1,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

class Tabular {
  static const List<FontFeature> features = [FontFeature.tabularFigures()];
}
