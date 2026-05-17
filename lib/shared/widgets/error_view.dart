import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';

/// A standardized error view widget that displays an error state with a retry option.
///
/// This widget shows a user-friendly error message with:
/// - A red error icon in a circular container
/// - An "Error" title
/// - The custom error message (or a default message if empty)
/// - A subtitle explaining the error
/// - A retry button to attempt the operation again
///
/// **Usage:**
/// ```dart
/// // In a Bloc Builder
/// if (state is CampaignListError) {
///   return ErrorView(
///     message: state.message,
///     onRetry: () {
///       context.read<CampaignListBloc>().add(LoadCampaigns());
///     },
///   );
/// }
///
/// // Custom error handling
/// ErrorView(
///   message: 'Failed to load campaigns',
///   onRetry: () => _loadData(),
/// )
/// ```
///
/// **Parameters:**
/// - [message]: The error message to display. If empty, defaults to "Failed to load data".
/// - [onRetry]: Callback function invoked when the retry button is tapped.
///
/// **Default behavior:**
/// - Centers itself within parent
/// - Provides 32px padding on all sides
/// - Uses red accent color for error indication
/// - Retry button styled with primary brand color
///
/// **Where used:**
/// - Campaign List Screen
/// - Campaign Detail Screen
/// - Spend Summary Screen
/// - Anomaly Alerts Screen
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  /// The error message to display to the user.
  ///
  /// If this is empty, the widget will display "Failed to load data" as a fallback.
  final String message;

  /// Callback function invoked when the user taps the retry button.
  ///
  /// Typically triggers a reload of data or retries the failed operation.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.alertSpend.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.alertSpend,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Error',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Main message
            Text(
              message.isEmpty ? 'Failed to load data' : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),

            // Retry button
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
