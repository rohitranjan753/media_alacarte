import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_cubit.dart';

/// An animated toggle button widget that switches between light and dark theme modes.
///
/// This widget provides a smooth, interactive UI for theme switching with:
/// - Two options: Light and Dark mode
/// - Visual feedback with animations and hover states
/// - Selected state highlighting with primary brand color
/// - Smooth transitions between themes
///
/// The widget automatically reflects the current theme mode from [ThemeCubit]
/// and updates the app theme when the user selects a different option.
///
/// **Features:**
/// - Fade-in animation on mount
/// - Scale animation on selection
/// - Hover effects for better interactivity
/// - Rounded pill-shaped container with shadow
/// - Theme-aware colors that adapt to current mode
///
/// **Usage:**
/// ```dart
/// // In Profile Screen or Settings
/// const ThemeToggleButton()
/// ```
///
/// **Dependencies:**
/// - Requires [ThemeCubit] to be available in the widget tree
/// - Uses [AppColors] for consistent theming
///
/// **Where used:**
/// - Profile Screen settings section
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ThemeOption(
                  icon: Icons.light_mode_rounded,
                  isSelected: !isDark,
                  onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.light),
                  label: 'Light',
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  isSelected: isDark,
                  onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.dark),
                  label: 'Dark',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A single theme option button within the theme toggle.
///
/// This internal widget represents one selectable theme option (Light or Dark).
/// It includes animations for selection state and hover interactions.
///
/// **Features:**
/// - Scale animation when selected
/// - Hover state with background color change
/// - Selected state with primary color highlight and border
/// - Icon and label display
class _ThemeOption extends StatefulWidget {
  const _ThemeOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  /// The icon to display for this theme option.
  final IconData icon;

  /// Whether this theme option is currently selected.
  final bool isSelected;

  /// Callback invoked when this option is tapped.
  final VoidCallback onTap;

  /// The text label for this theme option ("Light" or "Dark").
  final String label;

  @override
  State<_ThemeOption> createState() => _ThemeOptionState();
}

class _ThemeOptionState extends State<_ThemeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_ThemeOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : _isHovered
                          ? (isDarkMode
                              ? AppColors.darkCardBorder
                              : AppColors.lightCardBorder)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isSelected
                          ? AppColors.primary
                          : isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? AppColors.primary
                            : isDarkMode
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
