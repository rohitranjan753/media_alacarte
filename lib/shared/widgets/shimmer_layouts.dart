import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import '../../core/constants/app_colors.dart';
import 'shimmer.dart';

/// Shimmer effect for Campaign Card
class CampaignCardShimmer extends StatelessWidget {
  const CampaignCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Name + Status badge
            Row(
              children: [
                const Expanded(
                  child: ShimmerLine(width: 150, height: 16),
                ),
                const SizedBox(width: 12),
                ShimmerBox(
                  width: 70,
                  height: 24,
                  borderRadius: 12,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            const ShimmerBox(
              width: double.infinity,
              height: 6,
              borderRadius: 3,
            ),
            const SizedBox(height: 6),

            // Spend label
            const ShimmerLine(width: 120, height: 12),
            const SizedBox(height: 16),

            // Bottom row: Stats (Impressions, Clicks, CTR)
            Row(
              children: [
                Expanded(
                  child: _ShimmerStat(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.cardBorderColor,
                ),
                Expanded(
                  child: _ShimmerStat(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.cardBorderColor,
                ),
                Expanded(
                  child: _ShimmerStat(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerStat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerLine(width: 40, height: 10),
        SizedBox(height: 4),
        ShimmerLine(width: 60, height: 14),
      ],
    );
  }
}

/// Shimmer effect for Campaign List (multiple cards)
class CampaignListShimmer extends StatelessWidget {
  const CampaignListShimmer({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) => const CampaignCardShimmer(),
    );
  }
}

/// Shimmer effect for Campaign Detail Screen
class CampaignDetailShimmer extends StatelessWidget {
  const CampaignDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16),
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
                      const Expanded(
                        child: ShimmerLine(width: 200, height: 20),
                      ),
                      ShimmerBox(
                        width: 80,
                        height: 28,
                        borderRadius: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < 2 ? 8 : 0,
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerLine(width: 60, height: 10),
                              SizedBox(height: 6),
                              ShimmerLine(width: 80, height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chart section
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 150, height: 16),
                  SizedBox(height: 16),
                  Expanded(
                    child: ShimmerBox(
                      width: double.infinity,
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recommendation card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLine(width: 120, height: 14),
                  SizedBox(height: 12),
                  ShimmerLine(width: double.infinity, height: 12),
                  SizedBox(height: 6),
                  ShimmerLine(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer effect for Spend Summary Screen
class SpendSummaryShimmer extends StatelessWidget {
  const SpendSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range picker
            const ShimmerBox(
              width: double.infinity,
              height: 40,
              borderRadius: 8,
            ),
            const SizedBox(height: 16),

            // KPI Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor),
              ),
              child: const Column(
                children: [
                  ShimmerLine(width: 100, height: 12),
                  SizedBox(height: 8),
                  ShimmerLine(width: 150, height: 32),
                  SizedBox(height: 4),
                  ShimmerLine(width: 120, height: 10),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Donut chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: 140, height: 16),
                  const SizedBox(height: 16),
                  const Center(
                    child: ShimmerCircle(size: 200),
                  ),
                  const SizedBox(height: 24),
                  // Legend items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => const Column(
                        children: [
                          ShimmerBox(width: 12, height: 12, borderRadius: 4),
                          SizedBox(height: 4),
                          ShimmerLine(width: 60, height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Top campaigns
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLine(width: 180, height: 16),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index < 2 ? 12 : 0,
                      ),
                      child: Row(
                        children: [
                          const ShimmerCircle(size: 32),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLine(width: 120, height: 12),
                                SizedBox(height: 4),
                                ShimmerLine(width: 80, height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShimmerBox(
                            width: 50,
                            height: 24,
                            borderRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer effect for Anomaly Alerts Screen
class AnomalyAlertsShimmer extends StatelessWidget {
  const AnomalyAlertsShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorderColor),
          ),
          child: Row(
            children: [
              const ShimmerCircle(size: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(width: 150, height: 14),
                    SizedBox(height: 6),
                    ShimmerLine(width: 200, height: 12),
                    SizedBox(height: 6),
                    ShimmerLine(width: 100, height: 10),
                  ],
                ),
              ),
              ShimmerBox(
                width: 24,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic list shimmer - can be used for any list
class GenericListShimmer extends StatelessWidget {
  const GenericListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorderColor),
          ),
        ),
      ),
    );
  }
}
