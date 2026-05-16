import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/campaign.dart';
import 'status_badge.dart';

class CampaignCard extends StatefulWidget {
  const CampaignCard({super.key, required this.campaign, required this.onTap});

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    final spendProgress = widget.campaign.budget > 0
        ? (widget.campaign.totalSpend / widget.campaign.budget).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: spendProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  IconData _getCampaignIcon() {
    final name = widget.campaign.name.toLowerCase();
    final objective = widget.campaign.objective.toLowerCase();

    if (name.contains('sale') || objective.contains('conversion')) {
      return Icons.shopping_cart_rounded;
    } else if (name.contains('loyalty') || name.contains('premium')) {
      return Icons.card_giftcard_rounded;
    } else if (objective.contains('awareness')) {
      return Icons.campaign_rounded;
    } else if (objective.contains('engagement')) {
      return Icons.people_rounded;
    }
    return Icons.ads_click_rounded;
  }

  Color _getIconColor() {
    final objective = widget.campaign.objective.toLowerCase();

    if (objective.contains('conversion')) {
      return const Color(0xFF10B981); // green
    } else if (objective.contains('awareness')) {
      return const Color(0xFF3B82F6); // blue
    } else if (objective.contains('engagement')) {
      return const Color(0xFFF59E0B); // amber
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? AppColors.primary : context.cardBorderColor,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon + Name/Objective + Status + Menu
              Row(
                children: [
                  // Campaign Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getIconColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCampaignIcon(),
                      color: _getIconColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Objective
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.campaign.name,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.campaign.objective,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge
                  StatusBadge(status: widget.campaign.status),
                  const SizedBox(width: 8),

                  // Menu Icon
                  Icon(
                    Icons.more_vert_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Animated Spend Progress Bar
              Stack(
                children: [
                  // Background container
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.cardBorderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Animated progress
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Shimmer effect
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      if (_progressAnimation.value < 1.0) {
                        return Positioned(
                          left: 0,
                          right: 0,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1200),
                            tween: Tween(begin: -1.0, end: 1.0),
                            builder: (context, value, child) {
                              return FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                      begin: Alignment(value - 0.3, 0),
                                      end: Alignment(value + 0.3, 0),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                            onEnd: () {
                              // Loop shimmer during animation
                              if (mounted && _progressAnimation.value < 1.0) {
                                setState(() {});
                              }
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Spend Label with animated counter
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final animatedSpend =
                      widget.campaign.totalSpend * _progressAnimation.value;
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatCurrency(animatedSpend, symbol: widget.campaign.currency)} / ${formatCurrency(widget.campaign.budget, symbol: widget.campaign.currency)}',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _progressAnimation.value > 0.8
                              ? AppColors.alertSpend.withValues(alpha: 0.15)
                              : _progressAnimation.value > 0.6
                                  ? AppColors.alertCTR.withValues(alpha: 0.15)
                                  : AppColors.statusActive
                                      .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: _progressAnimation.value > 0.8
                                ? AppColors.alertSpend
                                : _progressAnimation.value > 0.6
                                    ? AppColors.alertCTR
                                    : AppColors.statusActive,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Metrics Row
              Row(
                children: [
                  _MetricCell(
                    icon: Icons.visibility_outlined,
                    label: 'Impressions',
                    value: formatCompact(widget.campaign.impressions),
                  ),
                  const SizedBox(width: 20),
                  _MetricCell(
                    icon: Icons.ads_click_outlined,
                    label: 'Clicks',
                    value: formatCompact(widget.campaign.clicks),
                  ),
                  const SizedBox(width: 20),
                  _MetricCell(
                    icon: Icons.trending_up_rounded,
                    label: 'CTR',
                    value: formatCTR(widget.campaign.ctr),
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer Row: Start Date, End Date, Channel
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: context.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Start: ${formatDateFull(widget.campaign.startDate)}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stop_circle_outlined,
                        color: context.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'End: ${formatDateFull(widget.campaign.endDate)}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.track_changes_outlined,
                        color: context.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.campaign.channel,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: context.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
