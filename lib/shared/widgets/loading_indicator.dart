import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A centered loading indicator widget that displays a circular progress indicator
/// in the app's primary brand color.
///
/// This is a reusable loading widget used across the app to indicate that
/// an asynchronous operation is in progress. It centers itself within its parent
/// and uses the brand teal color for consistency.
///
/// **Usage:**
/// ```dart
/// // Show loading state in a screen
/// if (state is CampaignListLoading) {
///   return const LoadingIndicator();
/// }
///
/// // Or use in any loading scenario
/// isLoading ? const LoadingIndicator() : YourContent()
/// ```
///
/// **When to use:**
/// - During initial data load
/// - While fetching from API
/// - During any async operation that blocks the UI
///
/// **Where used:**
/// - Campaign List Screen
/// - Campaign Detail Screen
/// - Spend Summary Screen
/// - Anomaly Alerts Screen
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
