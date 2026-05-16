import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ThemeExtensions on BuildContext {
  /// Get theme-aware colors based on current brightness
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  Brightness get brightness => theme.brightness;

  bool get isDark => brightness == Brightness.dark;

  bool get isLight => brightness == Brightness.light;

  /// Background colors
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colors.surface;

  Color get cardBorderColor => isDark
      ? AppColors.darkCardBorder
      : AppColors.lightCardBorder;

  /// Text colors
  Color get textPrimary => isDark
      ? AppColors.darkTextPrimary
      : AppColors.lightTextPrimary;

  Color get textSecondary => isDark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;

  /// Shared colors (same in both themes)
  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;
  Color get statusActive => AppColors.statusActive;
  Color get statusPaused => AppColors.statusPaused;
  Color get alertSpend => AppColors.alertSpend;
  Color get alertCTR => AppColors.alertCTR;
}
