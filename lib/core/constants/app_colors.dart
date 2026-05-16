import 'package:flutter/material.dart';

abstract final class AppColors {
  // ============================================================================
  // DARK THEME COLORS
  // ============================================================================

  // Background - Dark
  static const Color darkBackground = Color(0xFF111113);
  static const Color darkSurface = Color(0xFF1B1A1E);
  static const Color darkCardBorder = Color(0xFF232127);

  // Text - Dark
  static const Color darkTextPrimary = Color(0xFFF5F5F6);
  static const Color darkTextSecondary = Color(0xFF9A9AA2);

  // ============================================================================
  // LIGHT THEME COLORS
  // ============================================================================

  // Background - Light
  static const Color lightBackground = Color(0xFFF5F5F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E5E7);

  // Text - Light
  static const Color lightTextPrimary = Color(0xFF111113);
  static const Color lightTextSecondary = Color(0xFF6B6B70);

  // ============================================================================
  // SHARED COLORS (Same in both themes)
  // ============================================================================

  // Accent
  static const Color primary = Color(0xFF1CB4BF);
  static const Color primaryLight = Color(0xFF1ECDD9);
  static const Color primaryDark = Color(0xFF0D9BA5);

  // Status
  static const Color statusActive = Color(0xFF22C55E);
  static const Color statusPaused = Color(0xFFF59E0B);
  static const Color statusEnded = Color(0xFF6B7280);

  // Alert
  static const Color alertSpend = Color(0xFFEF4444);
  static const Color alertCTR = Color(0xFFF59E0B);

  // Chart
  static const Color chartSocial = Color(0xFFF59E0B);
  static const Color chartDisplay = Color(0xFFA78BFA);

  // ============================================================================
  // LEGACY (kept for backward compatibility - will use theme values)
  // ============================================================================

  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color cardBorder = darkCardBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
}
