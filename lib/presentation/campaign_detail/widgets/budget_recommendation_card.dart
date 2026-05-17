import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';

/// An intelligent card that provides budget recommendations based on CTR forecast.
///
/// Analyzes the difference between the last historical CTR and the final forecasted
/// CTR to provide actionable budget advice:
///
/// - **CTR increasing > 5%**: Green card suggesting budget increase to maximize results
/// - **CTR dropping > 5%**: Red card warning to pause or reduce budget
/// - **CTR stable (±5%)**: Neutral card recommending to maintain current budget
///
/// The card displays:
/// - Color-coded icon (trending up/down/flat)
/// - Percentage change with directional arrow
/// - Headline message describing the trend
/// - Recommendation text
/// - "View Details" button for further action
///
/// Enhanced visuals for positive trends include gradient backgrounds,
/// animated shadows, and pulsing effects.
class BudgetRecommendationCard extends StatelessWidget {
  const BudgetRecommendationCard({
    super.key,
    required this.history,
    required this.forecast,
  });

  /// Historical CTR data used to establish the baseline.
  final List<DailyMetric> history;

  /// Forecasted CTR data used to predict future performance.
  final List<ForecastPoint> forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty || history.isEmpty) return const SizedBox.shrink();

    final lastCtr = history.last.ctr;
    final predictedCtr = forecast.last.predictedCtr;
    final pctChange =
        lastCtr == 0 ? 0.0 : (predictedCtr - lastCtr) / lastCtr * 100;

    final (iconData, accentColor, headline, subtext) = switch (pctChange) {
      > 5.0 => (
          Icons.trending_up_rounded,
          AppColors.statusActive,
          'CTR is predicted to increase by ${pctChange.abs().toStringAsFixed(0)}% ↗',
          'Consider increasing budget to maximize results',
        ),
      < -5.0 => (
          Icons.trending_down_rounded,
          AppColors.alertSpend,
          'CTR is predicted to drop by ${pctChange.abs().toStringAsFixed(0)}% ↘',
          'Consider pausing or reducing budget',
        ),
      _ => (
          Icons.trending_flat_rounded,
          AppColors.primary,
          'CTR appears stable',
          'Maintain current budget allocation',
        ),
    };

    final isPositive = pctChange > 5.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPositive
            ? LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPositive ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? accentColor.withValues(alpha: 0.3) : context.cardBorderColor,
          width: isPositive ? 2 : 1,
        ),
        boxShadow: isPositive
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isPositive ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isPositive
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Icon(iconData, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Recommendation',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  headline,
                  style: TextStyle(
                    color: isPositive ? accentColor : context.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: isPositive ? accentColor : AppColors.primary,
                    ),
                    label: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? accentColor : AppColors.primary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: isPositive
                          ? accentColor.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
