import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';

/// A horizontal scrollable bar displaying campaign filter options.
///
/// Displays three filter chips:
/// - "All" - Shows all campaigns regardless of status
/// - "Active" - Shows only active campaigns
/// - "Paused" - Shows only paused campaigns
///
/// Each chip features:
/// - Status-specific icon (apps, play circle, pause circle)
/// - Count badge showing number of campaigns in that category
/// - Color-coded when selected (green for active, amber for paused, teal for all)
/// - Staggered entry animation with elastic bounce
/// - Animated border, background, and shadow on selection
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.selected,
    required this.onFilterChanged,
    this.campaignCounts,
  });

  /// The currently selected filter ('all', 'active', or 'paused').
  final String selected;

  /// Callback invoked when a filter chip is tapped.
  final ValueChanged<String> onFilterChanged;

  /// Optional map of filter names to campaign counts for displaying badges.
  final Map<String, int>? campaignCounts;

  static const _filters = ['all', 'active', 'paused'];
  static const _labels = ['All', 'Active', 'Paused'];

  IconData _getIcon(String filter) {
    switch (filter) {
      case 'all':
        return Icons.apps_rounded;
      case 'active':
        return Icons.play_circle_filled_rounded;
      case 'paused':
        return Icons.pause_circle_filled_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color _getActiveColor(String filter) {
    switch (filter) {
      case 'active':
        return AppColors.statusActive;
      case 'paused':
        return AppColors.statusPaused;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final filter = _filters[i];
          final isSelected = selected == filter;
          final activeColor = _getActiveColor(filter);
          final count = campaignCounts?[filter] ?? 0;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (i * 50)),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            activeColor.withValues(alpha: 0.25),
                            activeColor.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? activeColor : context.cardBorderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        _getIcon(filter),
                        color: isSelected ? activeColor : context.textSecondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        color: isSelected ? activeColor : context.textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (campaignCounts != null) ...[
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor
                              : context.cardBorderColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : context.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
