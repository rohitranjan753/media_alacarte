import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.subtitle,
  });

  final String? title;
  final String? message;
  final IconData? icon;
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
