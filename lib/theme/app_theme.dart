// THEME LOCK: light — source: domain signal (consumer travel app, outdoor use)
// Scaffold.backgroundColor = AppTheme.backgroundLight — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary palette — deep emerald
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryContainer = Color(0xFFB7E4C7);
  static const Color accent = Color(0xFFA8E063);
  static const Color accentDark = Color(0xFF74B816);

  // Semantic colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Crowd colors
  static const Color crowdLow = Color(0xFF27AE60);
  static const Color crowdMedium = Color(0xFFF39C12);
  static const Color crowdHigh = Color(0xFFE74C3C);

  // Marker colors
  static const Color markerRestaurant = Color(0xFFE74C3C);
  static const Color markerCafe = Color(0xFFF39C12);
  static const Color markerHistorical = Color(0xFF9B59B6);
  static const Color markerPark = Color(0xFF27AE60);
  static const Color markerGeneral = Color(0xFF3498DB);

  // Light surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F7F2);
  static const Color backgroundLight = Color(0xFFF0F4EE);
  static const Color outlineLight = Color(0xFFCDD5C8);
  static const Color outlineVariantLight = Color(0xFFE8EDE5);

  // Dark surfaces
  static const Color surfaceDark = Color(0xFF1E2420);
  static const Color backgroundDark = Color(0xFF121812);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF0A2E1A),
      secondary: accentDark,
      onSecondary: Colors.white,
      tertiary: primaryLight,
      surface: surfaceLight,
      onSurface: Color(0xFF1A2318),
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: Color(0xFF4A5548),
      error: error,
      onError: Colors.white,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2E3530),
      onInverseSurface: Color(0xFFEFF2EC),
      inversePrimary: primaryLight,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarThemeData(
      backgroundColor: surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A2318),
      ),
      iconTheme: IconThemeData(color: Color(0xFF1A2318)),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: accent,
      labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: outlineLight),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: GoogleFonts.outfit(fontSize: 14, color: Color(0xFF4A5548)),
      hintStyle: GoogleFonts.outfit(fontSize: 14, color: Color(0xFF9E9E9E)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF9E9E9E),
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: outlineVariantLight,
      thickness: 1,
      space: 0,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      onPrimary: Color(0xFF0A2E1A),
      primaryContainer: primary,
      onPrimaryContainer: Color(0xFFB7E4C7),
      secondary: accent,
      onSecondary: Color(0xFF1A2318),
      surface: surfaceDark,
      onSurface: Color(0xFFE6EDE4),
      surfaceContainerHighest: Color(0xFF2A3028),
      onSurfaceVariant: Color(0xFFB0BAAD),
      error: Color(0xFFCF6679),
      onError: Colors.white,
      outline: Color(0xFF5A6558),
      outlineVariant: Color(0xFF3A4038),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.outfitTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6EDE4),
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6EDE4),
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6EDE4),
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0BAAD),
        ),
      ),
    ),
  );

  // Utility methods
  static BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF2D6A4F).withAlpha(20),
        blurRadius: 16,
        offset: Offset(0, 4),
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration glassmorphismDecoration({double radius = 20}) =>
      BoxDecoration(
        color: Colors.white.withAlpha(217),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withAlpha(102), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2D6A4F).withAlpha(31),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      );
}
