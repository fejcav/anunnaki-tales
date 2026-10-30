import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logic/risk_rules.dart';

// Colores de la app (ver "Aspecto" en CLAUDE.md): una paleta oscura (la de
// siempre) y una clara con los mismos roles. Se leen desde el tema con
// `context.palette`, así cada pantalla toma la del tema elegido.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.gold,
    required this.softGold,
    required this.lapis,
    required this.text,
    required this.textSecondary,
    required this.riskLow,
    required this.riskMedium,
    required this.riskHigh,
    required this.stars,
  });

  final Color background;
  final Color surface;
  final Color gold;
  final Color softGold;
  final Color lapis;
  final Color text;
  final Color textSecondary;
  // Riesgo de las opciones y dificultad del catálogo.
  final Color riskLow;
  final Color riskMedium;
  final Color riskHigh;
  // Color de las estrellas del fondo (cada una le aplica su propio brillo).
  final Color stars;

  static const dark = AppPalette(
    background: Color(0xFF0A0E1A),
    surface: Color(0xFF141927),
    gold: Color(0xFFD4A843),
    softGold: Color(0xFFF0D68A),
    lapis: Color(0xFF1A237E),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xB3FFFFFF), // blanco al 70 %
    riskLow: Color(0xFF4CAF50),
    riskMedium: Color(0xFFFF9800),
    riskHigh: Color(0xFFE53935),
    stars: Color(0xFFFFFFFF),
  );

  // Fondo arena y tarjetas blancas. El dorado y los colores de riesgo están
  // oscurecidos para que el texto llegue a contraste AA (4,5:1) sobre los dos.
  static const light = AppPalette(
    background: Color(0xFFF5EFE3),
    surface: Color(0xFFFFFFFF),
    gold: Color(0xFF7F5D12),
    softGold: Color(0xFF8C4F0E),
    lapis: Color(0xFFDCE0F5),
    text: Color(0xFF1F1B16),
    textSecondary: Color(0xB31F1B16), // texto al 70 %
    riskLow: Color(0xFF2E7D32),
    riskMedium: Color(0xFFB85C00),
    riskHigh: Color(0xFFC62828),
    stars: Color(0x407F5D12), // dorado oscuro, muy suave
  );

  // El color de un nivel de riesgo (o de dificultad).
  Color risk(RiskLevel level) => switch (level) {
    RiskLevel.low => riskLow,
    RiskLevel.medium => riskMedium,
    RiskLevel.high => riskHigh,
  };

  @override
  AppPalette copyWith() => this;

  // El tema cambia de golpe, sin transición entre paletas.
  @override
  AppPalette lerp(AppPalette? other, double t) => t < 0.5 ? this : (other ?? this);
}

// Estilos de texto: Cinzel para títulos, Lora para la narrativa, Inter para
// botones y etiquetas. Toman el color de la paleta del tema: se leen con
// `context.appText`.
class AppText {
  const AppText(this._palette);

  final AppPalette _palette;

  static const _cinzel = 'Cinzel';
  static const _lora = 'Lora';
  static const _inter = 'Inter';

  TextStyle get logo => TextStyle(
    fontFamily: _cinzel,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: _palette.gold,
  );

  TextStyle get title => TextStyle(
    fontFamily: _cinzel,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: _palette.gold,
  );

  TextStyle get subtitle => TextStyle(
    fontFamily: _cinzel,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 1,
    color: _palette.textSecondary,
  );

  TextStyle get narrative =>
      TextStyle(fontFamily: _lora, fontSize: 16, height: 1.6, color: _palette.text);

  TextStyle get body => TextStyle(fontFamily: _inter, fontSize: 14, color: _palette.text);

  TextStyle get bodySecondary =>
      TextStyle(fontFamily: _inter, fontSize: 14, color: _palette.textSecondary);

  static const button = TextStyle(fontFamily: _inter, fontSize: 16, fontWeight: FontWeight.w600);
}

// `context.palette.gold`, `context.appText.title`.
extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  AppText get appText => AppText(palette);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final text = AppText(p);
    // Barras del sistema: íconos claros sobre el tema oscuro y oscuros sobre
    // el claro; la barra de navegación del color del fondo.
    final systemBars = (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: p.background,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
    final base = ThemeData(
      brightness: brightness,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: p.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.gold,
        onPrimary: p.background,
        secondary: p.softGold,
        onSecondary: p.background,
        surface: p.surface,
        onSurface: p.text,
        error: p.riskHigh,
        onError: Colors.white,
      ),
      extensions: [p],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.gold,
        elevation: 0,
        // Sin esto, la barra se pone gris al desplazar una lista debajo.
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.title,
        systemOverlayStyle: systemBars,
      ),
      cardTheme: CardThemeData(color: p.surface),
      // Botón principal: dorado relleno con texto del color del fondo.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.gold,
          foregroundColor: p.background,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      // Botón secundario: superficie con texto dorado.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.gold,
          textStyle: AppText.button,
          side: BorderSide(color: p.gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: p.gold)),
      // Avisos (SnackBar): superficie con borde dorado tenue, texto normal y
      // la acción ("Reintentar") en dorado. Sin esto, Material 3 los pinta
      // con el color contrario al fondo.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surface,
        contentTextStyle: text.body,
        actionTextColor: p.gold,
        behavior: SnackBarBehavior.floating,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.gold.withValues(alpha: 0.4)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.gold, linearTrackColor: p.lapis),
    );
  }

  // Para las pantallas sin barra de arriba (Inicio): el mismo estilo de
  // barras del sistema que pone la AppBar.
  static SystemUiOverlayStyle systemBarsOf(ThemeData theme) =>
      theme.appBarTheme.systemOverlayStyle!;
}
