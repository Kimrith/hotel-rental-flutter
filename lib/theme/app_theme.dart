import 'package:flutter/material.dart';

class AppTheme {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  // Brand colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color secondary = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  
  // Neutral colors
  static Color get cardBg => themeModeNotifier.value == ThemeMode.dark ? const Color(0xFF1E293B) : Colors.white;
  static Color get textDark => themeModeNotifier.value == ThemeMode.dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textMuted => themeModeNotifier.value == ThemeMode.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get border => themeModeNotifier.value == ThemeMode.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get background => themeModeNotifier.value == ThemeMode.dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: cardBg,
        onSurface: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineLarge: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textDark, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: textMuted, fontSize: 14, height: 1.5),
        labelLarge: TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF0F172A); // Slate 900
    const darkCardBg = Color(0xFF1E293B); // Slate 800
    const darkText = Color(0xFFF8FAFC); // Slate 50
    const darkTextMuted = Color(0xFF94A3B8); // Slate 400
    const darkBorder = Color(0xFF334155); // Slate 800

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryLight,
        background: darkBackground,
        surface: darkCardBg,
        onSurface: darkText,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: darkText, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineLarge: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkText, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: darkTextMuted, fontSize: 14, height: 1.5),
        labelLarge: TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: darkBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: darkTextMuted, fontSize: 14),
      ),
    );
  }
}
