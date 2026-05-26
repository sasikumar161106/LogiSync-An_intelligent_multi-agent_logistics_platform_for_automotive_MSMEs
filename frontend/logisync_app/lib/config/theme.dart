import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LogiSync Design System
/// Premium enterprise SaaS light theme with clean lines, slate grays, and precise typography.
class LogiSyncTheme {
  // ── COLOR PALETTE ──────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9); // Slate 100
  static const Color cardBg = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryLight = Color(0xFFDBEAFE); // Blue 100
  static const Color primaryDark = Color(0xFF1D4ED8); // Blue 700

  static const Color accent = Color(0xFF6366F1); // Indigo 500
  static const Color emerald = Color(0xFF10B981); // Emerald 500
  static const Color emeraldLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color amber = Color(0xFFF59E0B); // Amber 500
  static const Color amberLight = Color(0xFFFEF3C7); // Amber 100
  static const Color rose = Color(0xFFEF4444); // Rose 500
  static const Color roseLight = Color(0xFFFEE2E2); // Rose 100
  static const Color cyan = Color(0xFF06B6D4); // Cyan 500

  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFF1F5F9); // Slate 100

  // ── GRADIENTS (REMOVED FOR PROFESSIONAL LOOK) ──────────
  // Replaced with solid colors, keeping references so old code doesn't break
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBg, cardBg],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [emerald, emerald],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [rose, rose],
  );

  // ── BORDER RADIUS ──────────────────────────────────────
  static final BorderRadius radiusSm = BorderRadius.circular(6);
  static final BorderRadius radiusMd = BorderRadius.circular(8);
  static final BorderRadius radiusLg = BorderRadius.circular(12);
  static final BorderRadius radiusXl = BorderRadius.circular(16);
  static final BorderRadius radiusFull = BorderRadius.circular(100);

  // ── SHADOWS ────────────────────────────────────────────
  // Soft, diffused shadows for a premium feel
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ── DECORATIONS ────────────────────────────────────────
  static BoxDecoration get solidCard => BoxDecoration(
    color: cardBg,
    borderRadius: radiusLg,
    border: Border.all(color: border),
    boxShadow: cardShadow,
  );

  static BoxDecoration get glassCard => solidCard; // Deprecated, use solid

  // ── THEME DATA ─────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
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
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: border)),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLg,
          side: const BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textMuted),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
