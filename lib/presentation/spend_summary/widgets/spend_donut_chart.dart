import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/summary.dart';

class SpendDonutChart extends StatefulWidget {
  const SpendDonutChart({
    super.key,
    required this.byChannel,
    required this.totalSpend,
  });

  final List<ChannelSpend> byChannel;
  final double totalSpend;

  @override
  State<SpendDonutChart> createState() => _SpendDonutChartState();
}

class _SpendDonutChartState extends State<SpendDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  static const _channelOrder = ['Search', 'Social', 'Display'];
  static const _channelColors = [
    AppColors.primary,
    AppColors.chartSocial,
    AppColors.chartDisplay,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorFor(String channel) {
    final idx = _channelOrder.indexOf(channel);
    if (idx == -1) return AppColors.textSecondary;
    return _channelColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.byChannel.isEmpty) return const SizedBox.shrink();

    // Build pie sections in channel order
    final ordered = _channelOrder
        .map((name) =>
            widget.byChannel.where((c) => c.channel == name).firstOrNull)
        .whereType<ChannelSpend>()
        .toList();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sections = ordered
            .where((c) => c.spend > 0)
            .toList()
            .asMap()
            .entries
            .map((entry) {
          final idx = entry.key;
          final c = entry.value;
          final isTouched = idx == _touchedIndex;
          final percentage = (c.spend / widget.totalSpend * 100);

          return PieChartSectionData(
            value: c.spend * _animation.value,
            color: _colorFor(c.channel),
            radius: isTouched ? 50 : 40,
            title: '${percentage.toStringAsFixed(1)}%',
            titleStyle: TextStyle(
              fontSize: isTouched ? 14 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                ),
              ],
            ),
            titlePositionPercentageOffset: 0.55,
            badgeWidget: isTouched
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _colorFor(c.channel),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _colorFor(c.channel).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : null,
            badgePositionPercentageOffset: 1.3,
          );
        }).toList();

        return Column(
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 70,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  // Center content with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pie_chart_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Total Spend',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeOut,
                            tween: Tween(
                              begin: 0.0,
                              end: widget.totalSpend,
                            ),
                            builder: (context, value, child) {
                              return Text(
                                formatCurrency(value),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: ordered
                  .where((c) => c.spend > 0)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => _AnimatedLegendItem(
                        index: entry.key,
                        color: _colorFor(entry.value.channel),
                        channel: entry.value.channel,
                        spend: entry.value.spend,
                        percentage: (entry.value.spend / widget.totalSpend * 100),
                        isSelected: entry.key == _touchedIndex,
                        onTap: () => setState(() => _touchedIndex = entry.key),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedLegendItem extends StatefulWidget {
  const _AnimatedLegendItem({
    required this.index,
    required this.color,
    required this.channel,
    required this.spend,
    required this.percentage,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final Color color;
  final String channel;
  final double spend;
  final double percentage;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedLegendItem> createState() => _AnimatedLegendItemState();
}

class _AnimatedLegendItemState extends State<_AnimatedLegendItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.color.withValues(alpha: 0.15)
                    : _isHovered
                        ? AppColors.cardBorder
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.color
                      : _isHovered
                          ? AppColors.cardBorder
                          : Colors.transparent,
                  width: widget.isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.isSelected || _isHovered ? 14 : 12,
                    height: widget.isSelected || _isHovered ? 14 : 12,
                    decoration: BoxDecoration(
                      color: widget.color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: widget.isSelected || _isHovered
                          ? [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.channel,
                        style: TextStyle(
                          color: widget.isSelected
                              ? widget.color
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatCurrency(widget.spend),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${widget.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
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
        ),
      ),
    );
  }
}
