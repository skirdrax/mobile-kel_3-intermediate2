import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna "Modern FinTech / SaaS POS".
/// Bersih, segar, profesional, dan berenergi tinggi (tidak membosankan/ngantuk).
class AppColors {
  const AppColors._();

  // Primer: Modern Indigo & Cobalt Blue
  static const primary = Color(0xFF4F46E5); // Indigo 600
  static const primaryHover = Color(0xFF4338CA); // Indigo 700
  static const primarySoft = Color(0xFFEEF2FF); // Indigo 50

  // Sekunder: Emerald Green (Penanda Uang / Pembayaran Sukses)
  static const emerald = Color(0xFF10B981); // Emerald 500
  static const emeraldSoft = Color(0xFFECFDF5); // Emerald 50

  // Aksen: Vibrant Amber (Penanda Notifikasi / Alert)
  static const amber = Color(0xFFF59E0B);
  static const amberSoft = Color(0xFFFEF3C7);

  // Background & Surface Terang
  static const bgLight = Color(0xFFF8FAFC); // Slate 50 (segar & bersih)
  static const surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const cardLight = Color(0xFFFFFFFF);

  // Outline & Border
  static const outline = Color(0xFFE2E8F0); // Slate 200
  static const outlineVariant = Color(0xFFCBD5E1); // Slate 300

  // Tipografi & Teks
  static const ink = Color(0xFF0F172A); // Slate 900 (kontras tajam & jelas)
  static const inkMuted = Color(0xFF64748B); // Slate 500
  static const inkLight = Color(0xFF94A3B8); // Slate 400

  // Status Warna
  static const error = Color(0xFFEF4444); // Red 500
  static const errorSoft = Color(0xFFFEF2F2);

  // Versi Gelap (Dark Mode Modern Slate)
  static const darkBg = Color(0xFF0F172A); // Slate 900
  static const darkSurface = Color(0xFF1E293B); // Slate 800
  static const darkCard = Color(0xFF1E293B);
  static const darkPrimary = Color(0xFF818CF8); // Indigo 400
  static const darkOutline = Color(0xFF334155); // Slate 700
  static const darkInk = Color(0xFFF8FAFC);
  static const darkInkMuted = Color(0xFF94A3B8);
}

/// Tipografi Plus Jakarta Sans dengan Tabular Figures agar angka harga rapi
TextTheme _textTheme(Brightness brightness) {
  final base = GoogleFonts.plusJakartaSansTextTheme(
    ThemeData(brightness: brightness).textTheme,
  );
  TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  return base.copyWith(
    headlineLarge: tabular(
      base.headlineLarge!.copyWith(fontWeight: FontWeight.w800),
    ),
    headlineMedium: tabular(
      base.headlineMedium!.copyWith(fontWeight: FontWeight.w700),
    ),
    headlineSmall: tabular(
      base.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
    ),
    titleLarge: tabular(base.titleLarge!.copyWith(fontWeight: FontWeight.w700)),
    titleMedium: tabular(
      base.titleMedium!.copyWith(fontWeight: FontWeight.w600),
    ),
    titleSmall: tabular(base.titleSmall!.copyWith(fontWeight: FontWeight.w600)),
    bodyLarge: tabular(base.bodyLarge!),
    bodyMedium: tabular(base.bodyMedium!),
    bodySmall: tabular(base.bodySmall!),
    labelLarge: tabular(base.labelLarge!.copyWith(fontWeight: FontWeight.w600)),
  );
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.emerald,
    onSecondary: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.ink,
    error: AppColors.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bgLight,
    textTheme: _textTheme(Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Plus Jakarta Sans',
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.outline, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 2,
      height: 68,
      indicatorColor: AppColors.primarySoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.inkMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.inkMuted, size: 24);
      }),
    ),
  );
}

ThemeData buildDarkTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkBg,
    secondary: AppColors.emerald,
    onSecondary: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkInk,
    error: AppColors.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkInk,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.darkOutline, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
