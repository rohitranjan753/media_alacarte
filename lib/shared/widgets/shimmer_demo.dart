import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'shimmer.dart';

/// Demo screen showcasing all shimmer animation types
/// Use this as a reference for implementing shimmer effects
class ShimmerDemoScreen extends StatelessWidget {
  const ShimmerDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shimmer Effects Demo'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flash Shimmer (Default)
            _DemoSection(
              title: '1. Flash Shimmer (Default)',
              description: 'Diagonal sweep animation - Best for lists and cards',
              child: Shimmer(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 200, height: 16),
                      SizedBox(height: 8),
                      ShimmerLine(width: 150, height: 12),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ShimmerCircle(size: 40),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLine(width: 120, height: 12),
                                SizedBox(height: 4),
                                ShimmerLine(width: 80, height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Wave Shimmer
            _DemoSection(
              title: '2. Wave Shimmer',
              description: 'Vertical wave animation - Best for large containers',
              child: WaveShimmer(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 200, height: 16),
                      SizedBox(height: 8),
                      ShimmerLine(width: double.infinity, height: 12),
                      SizedBox(height: 4),
                      ShimmerLine(width: double.infinity, height: 12),
                      SizedBox(height: 4),
                      ShimmerLine(width: 180, height: 12),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pulse Shimmer
            _DemoSection(
              title: '3. Pulse Shimmer',
              description: 'Breathing effect - Best for status indicators',
              child: Row(
                children: [
                  PulseShimmer(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PulseShimmer(
                    duration: const Duration(milliseconds: 1500),
                    minOpacity: 0.4,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.statusActive.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.statusActive),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.statusActive,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PulseShimmer(
                    duration: const Duration(milliseconds: 800),
                    minOpacity: 0.6,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.alertSpend.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.alertSpend),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: AppColors.alertSpend,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Combined Effects
            _DemoSection(
              title: '4. Combined Effects',
              description: 'Multiple shimmer types working together',
              child: Shimmer(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: ShimmerLine(width: 180, height: 18),
                          ),
                          const SizedBox(width: 12),
                          PulseShimmer(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const ShimmerBox(
                        width: double.infinity,
                        height: 6,
                        borderRadius: 3,
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                ShimmerLine(width: 60, height: 10),
                                SizedBox(height: 4),
                                ShimmerLine(width: 80, height: 14),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ShimmerLine(width: 60, height: 10),
                                SizedBox(height: 4),
                                ShimmerLine(width: 80, height: 14),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ShimmerLine(width: 60, height: 10),
                                SizedBox(height: 4),
                                ShimmerLine(width: 80, height: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Shimmer Box with Pulse
            _DemoSection(
              title: '5. Shimmer Box with Pulse',
              description: 'Enhanced box with pulsing effect',
              child: const Row(
                children: [
                  ShimmerBox(
                    width: 100,
                    height: 100,
                    borderRadius: 12,
                    withPulse: true,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 150, height: 16),
                        SizedBox(height: 8),
                        ShimmerLine(width: double.infinity, height: 12),
                        SizedBox(height: 4),
                        ShimmerLine(width: 120, height: 12),
                      ],
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

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
