import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';

/// A customizable empty state view widget that displays when there is no data to show.
///
/// This widget provides a clean, user-friendly empty state with:
/// - A small header label at the top
/// - An icon in a rounded container
/// - A main message
/// - A descriptive subtitle
///
/// All components are optional and have sensible defaults, making this widget
/// highly reusable across different screens and contexts.
///
/// **Usage:**
/// ```dart
/// // Basic usage with defaults
/// const EmptyStateView()
///
/// // Custom empty state for campaigns
/// EmptyStateView(
///   title: 'NO CAMPAIGNS',
///   message: 'No campaigns found',
///   icon: Icons.campaign_outlined,
///   subtitle: 'Try adjusting your filters or create a new campaign.',
/// )
///
/// // Anomaly alerts healthy state
/// EmptyStateView(
///   title: 'ALL CLEAR',
///   message: 'All metrics look healthy',
///   icon: Icons.check_circle_outline,
///   subtitle: 'No anomalies detected in your campaigns.',
/// )
/// ```
///
/// **Default values:**
/// - [title]: "No data" (displayed in secondary color, small, uppercase)
/// - [message]: "No data available"
/// - [icon]: `Icons.inventory_2_outlined`
/// - [subtitle]: "There is no data to display for this period."
///
/// **Design characteristics:**
/// - Centers content vertically and horizontally
/// - 48px padding on all sides
/// - Icon size: 40px in an 80x80px rounded container
/// - Responsive text styling with theme-aware colors
///
/// **Where used:**
/// - Campaign List Screen (no campaigns after filtering)
/// - Anomaly Alerts Screen (no anomalies detected)
/// - Spend Summary Screen (no data for selected period)
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.subtitle,
  });

  /// Small uppercase label displayed at the top of the empty state.
  ///
  /// Defaults to "No data" if not provided.
  final String? title;

  /// Main message displayed below the icon.
  ///
  /// This should be a short, clear statement about why there's no data.
  /// Defaults to "No data available" if not provided.
  final String? message;

  /// Icon displayed in the center of the empty state.
  ///
  /// Defaults to `Icons.inventory_2_outlined` if not provided.
  final IconData? icon;

  /// Descriptive text displayed below the main message.
  ///
  /// This can provide additional context or suggestions for the user.
  /// Defaults to "There is no data to display for this period." if not provided.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Label
            Text(
              title ?? 'No data',
              style: TextStyle(
                color: context.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Icon Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.cardBorderColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon ?? Icons.inventory_2_outlined,
                color: context.textSecondary.withValues(alpha: 0.5),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Main Message
            Text(
              message ?? 'No data available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle ?? 'There is no data to display for this period.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
