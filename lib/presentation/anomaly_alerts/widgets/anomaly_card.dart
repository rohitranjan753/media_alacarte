import 'package:flutter/material.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/anomaly.dart';

class AnomalyCard extends StatefulWidget {
  const AnomalyCard({super.key, required this.anomaly});

  final Anomaly anomaly;

  @override
  State<AnomalyCard> createState() => _AnomalyCardState();
}

class _AnomalyCardState extends State<AnomalyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpend = widget.anomaly.type == 'spend_spike';
    final accentColor = isSpend ? AppColors.alertSpend : AppColors.alertCTR;
    final icon = isSpend
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),

                  // Type & Campaign Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _typeLabel(widget.anomaly.type),
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.anomaly.campaignName ?? 'Unknown Campaign',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Campaign',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(widget.anomaly.detectedAt),
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                widget.anomaly.message,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              // Metrics (if available)
              if (widget.anomaly.actualValue != null &&
                  widget.anomaly.expectedValue != null &&
                  widget.anomaly.changePercentage != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: isSpend ? 'Spend' : 'CTR',
                        value: isSpend
                            ? formatCurrency(widget.anomaly.actualValue!)
                            : formatCTR(widget.anomaly.actualValue!),
                        icon: Icons.arrow_upward_rounded,
                        iconColor: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        label: 'Expected',
                        value: isSpend
                            ? formatCurrency(widget.anomaly.expectedValue!)
                            : formatCTR(widget.anomaly.expectedValue!),
                        icon: Icons.show_chart_rounded,
                        iconColor: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBox(
                        label: 'Change',
                        value:
                            '${widget.anomaly.changePercentage! > 0 ? '+' : ''}${widget.anomaly.changePercentage!.toStringAsFixed(1)}%',
                        icon: widget.anomaly.changePercentage! > 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        iconColor: widget.anomaly.changePercentage! > 0
                            ? AppColors.alertSpend
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'spend_spike' => 'SPEND SPIKE',
        'ctr_drop' => 'CTR DROP',
        _ => type.toUpperCase(),
      };

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
