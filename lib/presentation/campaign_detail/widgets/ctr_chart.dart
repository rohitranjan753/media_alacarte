import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';

class CtrChart extends StatefulWidget {
  const CtrChart({
    super.key,
    required this.history,
    required this.forecast,
  });

  final List<DailyMetric> history;
  final List<ForecastPoint> forecast;

  @override
  State<CtrChart> createState() => _CtrChartState();
}

class _CtrChartState extends State<CtrChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  double _pct(double v) => v < 1.0 ? v * 100 : v;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) return const SizedBox.shrink();

    final histSpots = [
      for (int i = 0; i < widget.history.length; i++)
        FlSpot(i.toDouble(), _pct(widget.history[i].ctr)),
    ];

    final lastHistX = (widget.history.length - 1).toDouble();

    final forecastSpots = [
      FlSpot(lastHistX, _pct(widget.history.last.ctr)),
      for (int i = 0; i < widget.forecast.length; i++)
        FlSpot(lastHistX + i + 1, _pct(widget.forecast[i].predictedCtr)),
    ];

    final upperSpots = [
      FlSpot(lastHistX, _pct(widget.history.last.ctr)),
      for (int i = 0; i < widget.forecast.length; i++)
        FlSpot(lastHistX + i + 1, _pct(widget.forecast[i].upperBound)),
    ];

    final lowerSpots = [
      FlSpot(lastHistX, _pct(widget.history.last.ctr)),
      for (int i = 0; i < widget.forecast.length; i++)
        FlSpot(lastHistX + i + 1, _pct(widget.forecast[i].lowerBound)),
    ];

    final allY = [
      ...histSpots.map((s) => s.y),
      if (widget.forecast.isNotEmpty) ...upperSpots.map((s) => s.y),
      if (widget.forecast.isNotEmpty) ...lowerSpots.map((s) => s.y),
    ];
    final minY = ((allY.reduce((a, b) => a < b ? a : b)) - 0.5)
        .clamp(0.0, double.infinity);
    final maxY = allY.reduce((a, b) => a > b ? a : b) + 1.0;
    final maxX = lastHistX + widget.forecast.length.toDouble();

    final allDates = [
      ...widget.history.map((m) => m.date),
      ...widget.forecast.map((f) => f.date),
    ];

    const yAxisWidth = 42.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Legend
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        _LegendDot(color: AppColors.primary, dashed: false),
                        SizedBox(width: 6),
                        Text(
                          'Historical CTR',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        _LegendDot(color: AppColors.primaryLight, dashed: true),
                        SizedBox(width: 6),
                        Text(
                          'Forecast CTR',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'CTR (%)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final chartWidth = totalWidth - yAxisWidth;
                final totalSpan = maxX;
                final separatorFraction = totalSpan > 0 ? lastHistX / totalSpan : 0.0;
                final separatorOffset = yAxisWidth + chartWidth * separatorFraction;

                // Animate data points
                final animatedHistSpots = histSpots
                    .map((spot) => FlSpot(
                          spot.x,
                          spot.y * _animation.value,
                        ))
                    .toList();

                final animatedForecastSpots = forecastSpots
                    .map((spot) => FlSpot(
                          spot.x,
                          spot.y * _animation.value,
                        ))
                    .toList();

                return Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: maxX,
                      minY: minY,
                      maxY: maxY,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.cardBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: widget.forecast.isNotEmpty
                          ? ExtraLinesData(verticalLines: [
                              VerticalLine(
                                x: lastHistX,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.4),
                                strokeWidth: 2,
                                dashArray: [6, 4],
                              ),
                            ])
                          : null,
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.surface,
                          tooltipBorder: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(10),
                          getTooltipItems: (spots) => spots.map((spot) {
                            final idx = spot.x
                                .toInt()
                                .clamp(0, allDates.length - 1);
                            return LineTooltipItem(
                              '${formatDateAbbrev(allDates[idx])}\n${(spot.y / _animation.value).toStringAsFixed(2)}%',
                              const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: yAxisWidth,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            interval: (maxX / 5).ceilToDouble(),
                            getTitlesWidget: (v, _) {
                              if (v != v.roundToDouble()) {
                                return const SizedBox.shrink();
                              }
                              final idx =
                                  v.toInt().clamp(0, allDates.length - 1);
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  formatDateAbbrev(allDates[idx]),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      betweenBarsData: widget.forecast.isNotEmpty
                          ? [
                              BetweenBarsData(
                                fromIndex: 1,
                                toIndex: 2,
                                color: AppColors.primary
                                    .withValues(alpha: 0.15),
                              ),
                            ]
                          : [],
                      lineBarsData: [
                        // [0] Historical — solid teal (animated)
                        LineChartBarData(
                          spots: animatedHistSpots,
                          color: AppColors.primary,
                          barWidth: 3,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          dotData: FlDotData(
                            show: _animation.value > 0.9,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: AppColors.background,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.15),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // [1] Upper bound (invisible — for BetweenBarsData)
                        if (widget.forecast.isNotEmpty)
                          LineChartBarData(
                            spots: upperSpots
                                .map((spot) => FlSpot(spot.x, spot.y * _animation.value))
                                .toList(),
                            color: Colors.transparent,
                            barWidth: 0,
                            dotData: const FlDotData(show: false),
                          ),
                        // [2] Lower bound (invisible — for BetweenBarsData)
                        if (widget.forecast.isNotEmpty)
                          LineChartBarData(
                            spots: lowerSpots
                                .map((spot) => FlSpot(spot.x, spot.y * _animation.value))
                                .toList(),
                            color: Colors.transparent,
                            barWidth: 0,
                            dotData: const FlDotData(show: false),
                          ),
                        // [3] Forecast — dashed light teal (animated)
                        if (widget.forecast.isNotEmpty)
                          LineChartBarData(
                            spots: animatedForecastSpots,
                            color: AppColors.primaryLight,
                            barWidth: 3,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            dashArray: [8, 5],
                            dotData: FlDotData(
                              show: _animation.value > 0.9,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.primaryLight,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.background,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                      ),
                    ),
                    // Enhanced section labels with animation
                  if (widget.forecast.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: yAxisWidth,
                      width: separatorOffset - yAxisWidth,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, -10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _EnhancedSectionLabel(
                          text: 'Historical (${widget.history.length}d)',
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (widget.forecast.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: separatorOffset,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, -10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _EnhancedSectionLabel(
                          text: 'Forecast (${widget.forecast.length}d)',
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      );
    },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 2),
      painter: _LinePainter(color: color, dashed: dashed),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2),
          Offset(size.width, size.height / 2), paint);
    } else {
      double x = 0;
      const dashLen = 4.0;
      const gapLen = 3.0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset((x + dashLen).clamp(0, size.width), size.height / 2),
          paint,
        );
        x += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || old.dashed != dashed;
}

class _EnhancedSectionLabel extends StatelessWidget {
  const _EnhancedSectionLabel({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
