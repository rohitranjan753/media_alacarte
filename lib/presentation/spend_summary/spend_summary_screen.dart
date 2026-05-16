import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/summary.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../injection.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/shimmer_layouts.dart';
import '../campaign_detail/campaign_detail_screen.dart';
import 'bloc/spend_summary_bloc.dart';
import 'bloc/spend_summary_event.dart';
import 'bloc/spend_summary_state.dart';
import 'widgets/kpi_card.dart';
import 'widgets/spend_donut_chart.dart';
import 'widgets/top_campaign_tile.dart';

class SpendSummaryScreen extends StatelessWidget {
  const SpendSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpendSummaryBloc(sl<CampaignRepository>())
        ..add(const LoadSpendSummary()),
      child: const _SpendSummaryView(),
    );
  }
}

class _SpendSummaryView extends StatelessWidget {
  const _SpendSummaryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Spend Summary')),
      body: BlocBuilder<SpendSummaryBloc, SpendSummaryState>(
        builder: (context, state) {
          // While re-fetching for a new range, keep showing stale data + spinner
          if (state is SpendSummaryLoading && state.previousSummary != null) {
            final summary = state.previousSummary!;
            final range = state.selectedRange ?? DateRangeOption.last30;
            return _Body(
              summary: summary,
              selectedRange: range,
              isRefreshing: true,
            );
          }

          if (state is SpendSummaryLoading) {
            return const SpendSummaryShimmer();
          }

          if (state is SpendSummaryError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<SpendSummaryBloc>()
                  .add(const LoadSpendSummary()),
            );
          }

          if (state is SpendSummaryLoaded) {
            return _Body(
              summary: state.summary,
              selectedRange: state.selectedRange,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.summary,
    required this.selectedRange,
    this.isRefreshing = false,
  });

  final Summary summary;
  final DateRangeOption selectedRange;
  final bool isRefreshing;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  Future<void> _onRefresh() async {
    context.read<SpendSummaryBloc>().add(const LoadSpendSummary());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    // Sort top campaigns by CTR descending, take top 3
    final sorted = [...widget.summary.topCampaigns]
      ..sort((a, b) => b.ctr.compareTo(a.ctr));
    final top3 = sorted.take(3).toList();
    final maxCtr = top3.isEmpty ? 1.0 : top3.first.ctr;

    return Stack(
      children: [
        // Floating decorative particles
        const _FloatingParticles(),

        // Main content with refresh
        RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated date range picker
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _DateRangePicker(selected: widget.selectedRange),
                ),
                const SizedBox(height: 16),

                // Animated KPI card
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value.clamp(0, 1), child: child),
                    );
                  },
                  child: KpiCard(
                    label: 'Total Spend',
                    value: formatCurrency(widget.summary.totalSpend),
                    subtitle: '${widget.selectedRange.label} across all campaigns',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // Animated donut chart card
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _SectionCard(
                    title: 'Spend by Channel',
                    child: SpendDonutChart(
                      byChannel: widget.summary.byChannel,
                      totalSpend: widget.summary.totalSpend,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Animated top campaigns
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _SectionCard(
                    title: 'Top Performers by CTR',
                    child: top3.isEmpty
                        ? const EmptyStateView(
                            title: 'No data',
                            message: 'No campaign data available',
                            subtitle:
                                'There is no data to display for this period.',
                            icon: Icons.leaderboard_outlined,
                          )
                        : Column(
                            children: [
                              for (int i = 0; i < top3.length; i++) ...[
                                TopCampaignTile(
                                  campaign: top3[i],
                                  rank: i + 1,
                                  maxCtr: maxCtr,
                                  onTap: () => Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          CampaignDetailScreen(
                                        campaignId: top3[i].id,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOut,
                                            )),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (i < top3.length - 1)
                                  const Divider(
                                    color: AppColors.cardBorder,
                                    height: 1,
                                    thickness: 1,
                                  ),
                              ],
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated progress indicator
        if (widget.isRefreshing)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardBorder,
              minHeight: 3,
            ),
          ),
      ],
    );
  }
}

class _DateRangePicker extends StatelessWidget {
  const _DateRangePicker({required this.selected});

  final DateRangeOption selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<DateRangeOption>(
        segments: DateRangeOption.values
            .map((r) => ButtonSegment(value: r, label: Text(r.label)))
            .toList(),
        selected: {selected},
        onSelectionChanged: (set) {
          if (set.isNotEmpty) {
            context
                .read<SpendSummaryBloc>()
                .add(ChangeDateRange(set.first));
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.2);
            }
            return AppColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.cardBorder),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        showSelectedIcon: false,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
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

    controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 400)),
        vsync: this,
      )..repeat(reverse: true),
    );

    particles.addAll([
      _Particle(
        x: 0.15,
        y: 0.2,
        size: 40,
        color: AppColors.primary.withValues(alpha: 0.04),
      ),
      _Particle(
        x: 0.80,
        y: 0.35,
        size: 50,
        color: AppColors.chartSocial.withValues(alpha: 0.03),
      ),
      _Particle(
        x: 0.25,
        y: 0.65,
        size: 35,
        color: AppColors.chartDisplay.withValues(alpha: 0.04),
      ),
      _Particle(
        x: 0.75,
        y: 0.8,
        size: 45,
        color: AppColors.primary.withValues(alpha: 0.03),
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
        final offsetY = 25 * controller.value;
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
