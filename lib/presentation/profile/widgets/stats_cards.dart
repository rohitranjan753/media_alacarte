import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.yourPerformance,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.campaign_rounded,
                  iconColor: Color(0xFF3B82F6),
                  label: AppTexts.campaigns,
                  value: AppTexts.campaignsCount,
                  subtitle: AppTexts.active,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: Color(0xFF10B981),
                  label: AppTexts.totalSpend,
                  value: AppTexts.totalSpendValue,
                  subtitle: AppTexts.thisMonth,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.visibility_rounded,
                  iconColor: AppColors.primary,
                  label: AppTexts.impressions,
                  value: AppTexts.impressionsValue,
                  subtitle: AppTexts.total,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.mouse_rounded,
                  iconColor: Color(0xFFF59E0B),
                  label: AppTexts.clickRate,
                  value: AppTexts.clickRateValue,
                  subtitle: AppTexts.averageCtr,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.textSecondary,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: context.textSecondary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
