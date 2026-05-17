import 'package:flutter/material.dart';

/// Centralized color palette for the Media Alacarte Ad Campaign Dashboard.
///
/// This class provides a comprehensive design system with colors for both
/// light and dark themes, plus shared accent colors that remain consistent
/// across all theme modes.
///
/// **Color Categories:**
/// - **Dark Theme**: Background, surface, borders, and text colors for dark mode
/// - **Light Theme**: Background, surface, borders, and text colors for light mode
/// - **Shared Colors**: Brand colors, status indicators, alerts, and chart colors
/// - **Legacy**: Backward-compatible aliases (deprecated)
///
/// **Usage:**
/// ```dart
/// // Theme-specific colors
/// Container(color: AppColors.darkBackground)
/// Text('Hello', style: TextStyle(color: AppColors.lightTextPrimary))
///
/// // Shared colors (work in any theme)
/// Container(color: AppColors.primary)
/// Icon(Icons.check, color: AppColors.statusActive)
/// ```
///
/// **Design System:**
/// - Primary brand color: Teal (#1CB4BF)
/// - Status colors: Green (active), Amber (paused), Gray (ended)
/// - Alert colors: Red (spend spike), Amber (CTR drop)
/// - Chart colors: Teal (search), Amber (social), Purple (display)
///
/// **Note:** Prefer using theme extensions (`context.textPrimary`) over direct
/// color references for automatic theme adaptation.
abstract final class AppColors {
  // ============================================================================
  // DARK THEME COLORS
  // ============================================================================

  /// Dark theme scaffold background color - Very dark gray (#111113)
  static const Color darkBackground = Color(0xFF111113);

  /// Dark theme surface color for cards and panels - Dark gray (#1B1A1E)
  static const Color darkSurface = Color(0xFF1B1A1E);

  /// Dark theme border color for cards and dividers - Medium dark gray (#232127)
  static const Color darkCardBorder = Color(0xFF232127);

  /// Dark theme primary text color - Off-white (#F5F5F6)
  static const Color darkTextPrimary = Color(0xFFF5F5F6);

  /// Dark theme secondary text color for labels and captions - Light gray (#9A9AA2)
  static const Color darkTextSecondary = Color(0xFF9A9AA2);

  // ============================================================================
  // LIGHT THEME COLORS
  // ============================================================================

  /// Light theme scaffold background color - Light gray (#F5F5F6)
  static const Color lightBackground = Color(0xFFF5F5F6);

  /// Light theme surface color for cards and panels - Pure white (#FFFFFF)
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme border color for cards and dividers - Light gray (#E5E5E7)
  static const Color lightCardBorder = Color(0xFFE5E5E7);

  /// Light theme primary text color - Very dark gray (#111113)
  static const Color lightTextPrimary = Color(0xFF111113);

  /// Light theme secondary text color for labels and captions - Medium gray (#6B6B70)
  static const Color lightTextSecondary = Color(0xFF6B6B70);

  // ============================================================================
  // SHARED COLORS (Same in both themes)
  // ============================================================================

  /// Primary brand color - Teal (#1CB4BF)
  ///
  /// Used for:
  /// - Progress bars and loading indicators
  /// - Active filter chips and selected states
  /// - CTR chart lines and primary actions
  /// - Theme toggle selection highlight
  static const Color primary = Color(0xFF1CB4BF);

  /// Lighter variant of primary color - Bright teal (#1ECDD9)
  static const Color primaryLight = Color(0xFF1ECDD9);

  /// Darker variant of primary color - Deep teal (#0D9BA5)
  static const Color primaryDark = Color(0xFF0D9BA5);

  /// Status color for active campaigns - Green (#22C55E)
  static const Color statusActive = Color(0xFF22C55E);

  /// Status color for paused campaigns - Amber (#F59E0B)
  static const Color statusPaused = Color(0xFFF59E0B);

  /// Status color for ended campaigns - Gray (#6B7280)
  static const Color statusEnded = Color(0xFF6B7280);

  /// Alert color for spend spike anomalies - Red (#EF4444)
  static const Color alertSpend = Color(0xFFEF4444);

  /// Alert color for CTR drop anomalies - Amber (#F59E0B)
  static const Color alertCTR = Color(0xFFF59E0B);

  /// Chart color for social media channel spend - Amber (#F59E0B)
  static const Color chartSocial = Color(0xFFF59E0B);

  /// Chart color for display advertising channel spend - Purple (#A78BFA)
  static const Color chartDisplay = Color(0xFFA78BFA);

  // ============================================================================
  // LEGACY (kept for backward compatibility - will use theme values)
  // ============================================================================

  /// @deprecated Use theme extensions instead (e.g., context.backgroundColor)
  static const Color background = darkBackground;

  /// @deprecated Use theme extensions instead (e.g., context.surfaceColor)
  static const Color surface = darkSurface;

  /// @deprecated Use theme extensions instead (e.g., context.cardBorderColor)
  static const Color cardBorder = darkCardBorder;

  /// @deprecated Use theme extensions instead (e.g., context.textPrimary)
  static const Color textPrimary = darkTextPrimary;

  /// @deprecated Use theme extensions instead (e.g., context.textSecondary)
  static const Color textSecondary = darkTextSecondary;
}
