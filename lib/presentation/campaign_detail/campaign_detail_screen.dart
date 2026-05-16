import 'package:flutter/material.dart';
import '../../core/extensions/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/campaign.dart';
import '../../data/models/daily_metric.dart';
import '../../data/models/forecast_point.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../data/repositories/ml_repository.dart';
import '../../injection.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/shimmer_layouts.dart';
import 'bloc/campaign_detail_bloc.dart';
import 'bloc/campaign_detail_event.dart';
import 'bloc/campaign_detail_state.dart';
import 'widgets/budget_recommendation_card.dart';
import 'widgets/ctr_chart.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignDetailBloc(
        campaignRepository: sl<CampaignRepository>(),
        mlRepository: sl<MlRepository>(),
      )..add(LoadCampaignDetail(campaignId)),
      child: _CampaignDetailView(campaignId: campaignId),
    );
  }
}

class _CampaignDetailView extends StatelessWidget {
  const _CampaignDetailView({required this.campaignId});

  final String campaignId;

  Future<void> _onRefresh(BuildContext context) async {
    context.read<CampaignDetailBloc>().add(LoadCampaignDetail(campaignId));
    await context.read<CampaignDetailBloc>().stream.firstWhere(
          (s) => s is CampaignDetailLoaded || s is CampaignDetailError,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignDetailBloc, CampaignDetailState>(
      builder: (context, state) {
        if (state is CampaignDetailLoading ||
            state is CampaignDetailInitial) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(title: Text('Campaign Detail')),
            body: const CampaignDetailShimmer(),
          );
        }

        if (state is CampaignDetailError) {
          return Scaffold(
            appBar: AppBar(title: Text('Campaign Detail')),
            body: ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<CampaignDetailBloc>()
                  .add(LoadCampaignDetail(campaignId)),
            ),
          );
        }

        if (state is CampaignDetailLoaded) {
          final c = state.campaign;
          return Hero(
            tag: 'campaign_card_${c.id}',
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _buildAppBar(context, c),
              body: Stack(
              children: [
                // Floating decorative particles
                const _FloatingParticles(),

                // Main content
                RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onRefresh: () => _onRefresh(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _KpiRow(campaign: c),
                        const SizedBox(height: 8),
                        if (c.conversions != null ||
                            c.costPerClick != null ||
                            c.costPerConversion != null)
                          _ConversionMetricsRow(campaign: c),
                        const SizedBox(height: 16),
                        if (c.targetAudience != null)
                          _TargetAudienceCard(
                              targetAudience: c.targetAudience!),
                        const SizedBox(height: 16),
                        _ChartCard(state: state),
                        const SizedBox(height: 16),
                        if (state.forecast.isNotEmpty && state.history.isNotEmpty)
                          _AnimatedBudgetCard(
                            history: state.history,
                            forecast: state.forecast,
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        }

        return const SizedBox.shrink();
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, Campaign c) {
    final statusColor = switch (c.status.toLowerCase()) {
      'active' => AppColors.statusActive,
      'paused' => AppColors.statusPaused,
      _ => AppColors.statusEnded,
    };

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${formatDateFull(c.startDate)} - ${formatDateFull(c.endDate)}',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        _PulsingStatusBadge(
          status: c.status,
          color: statusColor,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.cardBorderColor),
            ),
          ),
          child: Row(
            children: [
              if (c.objective.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c.objective,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (c.channel.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.cardBorderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        color: context.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        c.channel,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI Row ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AnimatedKpiCard(
            index: 0,
            icon: Icons.visibility_outlined,
            value: formatCompact(campaign.impressions),
            label: 'Impressions',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AnimatedKpiCard(
            index: 1,
            icon: Icons.ads_click,
            value: formatCompact(campaign.clicks),
            label: 'Clicks',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AnimatedKpiCard(
            index: 2,
            icon: Icons.trending_up_rounded,
            value: formatCTR(campaign.ctr),
            label: 'CTR',
            valueColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _AnimatedKpiCard(
            index: 3,
            icon: Icons.account_balance_wallet_outlined,
            value: formatCompact(campaign.totalSpend.toInt()),
            label: campaign.currency,
          ),
        ),
      ],
    );
  }
}

class _AnimatedKpiCard extends StatefulWidget {
  const _AnimatedKpiCard({
    required this.index,
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final int index;
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  State<_AnimatedKpiCard> createState() => _AnimatedKpiCardState();
}

class _AnimatedKpiCardState extends State<_AnimatedKpiCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Main entry animation
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    // Pulsing icon animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..translate(0.0, _isHovered ? -4.0 : 0.0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  gradient: _isHovered
                      ? LinearGradient(
                          colors: [
                            AppColors.surface,
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isHovered ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered ? AppColors.primary : context.cardBorderColor,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 24,
                            spreadRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    // Shimmer effect overlay
                    if (_isHovered)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment(_shimmerController.value * 2 - 1, -0.5),
                                  end: Alignment(_shimmerController.value * 2, 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: _isHovered
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 800 + (widget.index * 200)),
                          curve: Curves.easeOutCubic,
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            widget.value,
                            style: TextStyle(
                              color: widget.valueColor ?? context.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

// ── Chart Card ───────────────────────────────────────────────────────────────

class _ChartCard extends StatefulWidget {
  const _ChartCard({required this.state});

  final CampaignDetailLoaded state;

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.show_chart_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CTR Performance & Forecast',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Historical data with ML prediction',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const _DaysChip(days: 30),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.state.history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.insert_chart_outlined,
                          color: context.textSecondary,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No history data available',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                CtrChart(history: widget.state.history, forecast: widget.state.forecast),
              if (widget.state.forecastError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.alertCTR.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.alertCTR.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.alertCTR,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Forecast unavailable: ${widget.state.forecastError}',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DaysChip extends StatelessWidget {
  const _DaysChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days Days',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down,
              color: context.textSecondary, size: 14),
        ],
      ),
    );
  }
}

// ── Animated Budget Card ─────────────────────────────────────────────────────

class _AnimatedBudgetCard extends StatefulWidget {
  const _AnimatedBudgetCard({
    required this.history,
    required this.forecast,
  });

  final List<DailyMetric> history;
  final List<ForecastPoint> forecast;

  @override
  State<_AnimatedBudgetCard> createState() => _AnimatedBudgetCardState();
}

class _AnimatedBudgetCardState extends State<_AnimatedBudgetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: BudgetRecommendationCard(
          history: widget.history,
          forecast: widget.forecast,
        ),
      ),
    );
  }
}

// ── Pulsing Status Badge ─────────────────────────────────────────────────────

class _PulsingStatusBadge extends StatefulWidget {
  const _PulsingStatusBadge({
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  State<_PulsingStatusBadge> createState() => _PulsingStatusBadgeState();
}

class _PulsingStatusBadgeState extends State<_PulsingStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: _glowAnimation.value,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.6),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.status,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Conversion Metrics Row ───────────────────────────────────────────────────

class _ConversionMetricsRow extends StatelessWidget {
  const _ConversionMetricsRow({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final metrics = <Widget>[];

    if (campaign.conversions != null) {
      metrics.add(
        Expanded(
          child: _AnimatedKpiCard(
            index: metrics.length,
            icon: Icons.check_circle_outline,
            value: formatCompact(campaign.conversions!),
            label: 'Conversions',
            valueColor: AppColors.statusActive,
          ),
        ),
      );
    }

    if (campaign.conversions != null && campaign.clicks > 0) {
      metrics.add(
        Expanded(
          child: _AnimatedKpiCard(
            index: metrics.length,
            icon: Icons.trending_up,
            value: formatCTR(campaign.conversionRate),
            label: 'Conv. Rate',
            valueColor: AppColors.primary,
          ),
        ),
      );
    }

    if (campaign.costPerClick != null) {
      metrics.add(
        Expanded(
          child: _AnimatedKpiCard(
            index: metrics.length,
            icon: Icons.payments_outlined,
            value: campaign.costPerClick!.toStringAsFixed(2),
            label: 'Cost/Click',
          ),
        ),
      );
    }

    if (campaign.costPerConversion != null) {
      metrics.add(
        Expanded(
          child: _AnimatedKpiCard(
            index: metrics.length,
            icon: Icons.attach_money_outlined,
            value: campaign.costPerConversion!.toStringAsFixed(2),
            label: 'Cost/Conv.',
          ),
        ),
      );
    }

    if (metrics.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < metrics.length; i++) ...[
          metrics[i],
          if (i < metrics.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

// ── Target Audience Card ─────────────────────────────────────────────────────

class _TargetAudienceCard extends StatefulWidget {
  const _TargetAudienceCard({required this.targetAudience});

  final TargetAudience targetAudience;

  @override
  State<_TargetAudienceCard> createState() => _TargetAudienceCardState();
}

class _TargetAudienceCardState extends State<_TargetAudienceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Target Audience',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.targetAudience.ageRange != null) ...[
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Age Range',
                  value: widget.targetAudience.ageRange!,
                ),
                const SizedBox(height: 12),
              ],
              if (widget.targetAudience.regions != null &&
                  widget.targetAudience.regions!.isNotEmpty) ...[
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Regions',
                  value: widget.targetAudience.regions!.join(', '),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.targetAudience.interests != null &&
                  widget.targetAudience.interests!.isNotEmpty)
                _InfoRow(
                  icon: Icons.interests_outlined,
                  label: 'Interests',
                  value: widget.targetAudience.interests!.join(', '),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: context.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Floating Particles ───────────────────────────────────────────────────────

class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with TickerProviderStateMixin {
  final List<_Particle> particles = [];
  late List<AnimationController> controllers;

  @override
  void initState() {
    super.initState();

    // Create 5 floating particles
    controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 500)),
        vsync: this,
      )..repeat(reverse: true),
    );

    // Generate random particles
    particles.addAll([
      _Particle(
        x: 0.1,
        y: 0.15,
        size: 30,
        color: AppColors.primary.withValues(alpha: 0.05),
      ),
      _Particle(
        x: 0.85,
        y: 0.25,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.03),
      ),
      _Particle(
        x: 0.2,
        y: 0.6,
        size: 35,
        color: AppColors.primaryLight.withValues(alpha: 0.04),
      ),
      _Particle(
        x: 0.75,
        y: 0.7,
        size: 45,
        color: AppColors.primary.withValues(alpha: 0.04),
      ),
      _Particle(
        x: 0.5,
        y: 0.85,
        size: 50,
        color: AppColors.primaryLight.withValues(alpha: 0.03),
      ),
    ]);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: List.generate(
            particles.length,
            (index) => _FloatingParticle(
              particle: particles[index],
              controller: controllers[index],
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

class _FloatingParticle extends StatelessWidget {
  const _FloatingParticle({
    required this.particle,
    required this.controller,
  });

  final _Particle particle;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offsetY = 20 * controller.value;
        final opacity = 0.3 + (0.7 * controller.value);

        return Positioned(
          left: size.width * particle.x,
          top: size.height * particle.y + offsetY,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    particle.color,
                    particle.color.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
