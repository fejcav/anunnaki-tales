import 'package:flutter/material.dart';

// Colores de la app (ver "Aspecto" en CLAUDE.md).
class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0E1A);
  static const surface = Color(0xFF141927);
  static const gold = Color(0xFFD4A843);
  static const softGold = Color(0xFFF0D68A);
  static const lapis = Color(0xFF1A237E);
  static const text = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // blanco al 70 %

  // Riesgo de las opciones y dificultad del catálogo.
  static const riskLow = Color(0xFF4CAF50);
  static const riskMedium = Color(0xFFFF9800);
  static const riskHigh = Color(0xFFE53935);
}

// Estilos de texto: Cinzel para títulos, Lora para la narrativa, Inter para
// botones y etiquetas.
class AppText {
  AppText._();

  static const _cinzel = 'Cinzel';
  static const _lora = 'Lora';
  static const _inter = 'Inter';

  static const logo = TextStyle(
    fontFamily: _cinzel,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: AppColors.gold,
  );

  static const title = TextStyle(
    fontFamily: _cinzel,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.gold,
  );

  static const subtitle = TextStyle(
    fontFamily: _cinzel,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 1,
    color: AppColors.textSecondary,
  );

  static const narrative = TextStyle(
    fontFamily: _lora,
    fontSize: 16,
    height: 1.6,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    color: AppColors.text,
  );

  static const bodySecondary = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.background,
        secondary: AppColors.softGold,
        onSecondary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.riskHigh,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.title,
      ),
      cardTheme: const CardThemeData(color: AppColors.surface),
      // Botón principal: dorado relleno con texto oscuro.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.background,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Botón secundario: superficie oscura con texto dorado.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.gold,
          textStyle: AppText.button,
          side: const BorderSide(color: AppColors.gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.lapis,
      ),
    );
  }
}
