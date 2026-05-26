import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LogiSync Design System
/// Premium dark theme with glassmorphism, vibrant accents, and micro-animations.
class LogiSyncTheme {
  // ── COLOR PALETTE ──────────────────────────────────────
  static const Color background = Color(0xFF0A1628);
  static const Color surface = Color(0xFF111D35);
  static const Color surfaceLight = Color(0xFF1A2744);
  static const Color cardBg = Color(0xFF152038);

  static const Color primary = Color(0xFF3B82F6);       // Electric blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);

  static const Color accent = Color(0xFF8B5CF6);         // Violet accent
  static const Color emerald = Color(0xFF10B981);         // Positive / healthy
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color amber = Color(0xFFF59E0B);           // Warning
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color rose = Color(0xFFEF4444);            // Critical / error
  static const Color roseLight = Color(0xFFF87171);
  static const Color cyan = Color(0xFF06B6D4);            // Info

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFF1E3A5F);
  static const Color divider = Color(0xFF1E293B);

  // ── GRADIENTS ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF152038), Color(0xFF1A2744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── BORDER RADIUS ──────────────────────────────────────
  static final BorderRadius radiusSm = BorderRadius.circular(8);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusXl = BorderRadius.circular(20);
  static final BorderRadius radiusFull = BorderRadius.circular(100);

  // ── SHADOWS ────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  // ── GLASSMORPHISM DECORATION ───────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
    color: surfaceLight.withValues(alpha: 0.6),
    borderRadius: radiusLg,
    border: Border.all(color: border.withValues(alpha: 0.3)),
    boxShadow: cardShadow,
  );

  static BoxDecoration get solidCard => BoxDecoration(
    gradient: cardGradient,
    borderRadius: radiusLg,
    border: Border.all(color: border.withValues(alpha: 0.2)),
    boxShadow: cardShadow,
  );

  // ── THEME DATA ─────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: rose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
