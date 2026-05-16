import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../data/repositories/ml_repository.dart';
import '../../data/services/notification_service.dart';
import '../../injection.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/shimmer_layouts.dart';
import 'bloc/anomaly_bloc.dart';
import 'bloc/anomaly_event.dart';
import 'bloc/anomaly_state.dart';
import 'widgets/anomaly_card.dart';

class AnomalyAlertsScreen extends StatelessWidget {
  const AnomalyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnomalyBloc(
        campaignRepository: sl<CampaignRepository>(),
        mlRepository: sl<MlRepository>(),
        notificationService: sl<NotificationService>(),
      )..add(const StartPolling()),
      child: const _AnomalyAlertsView(),
    );
  }
}

class _AnomalyAlertsView extends StatefulWidget {
  const _AnomalyAlertsView();

  @override
  State<_AnomalyAlertsView> createState() => _AnomalyAlertsViewState();
}

class _AnomalyAlertsViewState extends State<_AnomalyAlertsView> {
  @override
  void dispose() {
    context.read<AnomalyBloc>().add(const StopPolling());
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<AnomalyBloc>().add(const StopPolling());
    context.read<AnomalyBloc>().add(const StartPolling());
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anomaly Alerts'),
        actions: [
          BlocBuilder<AnomalyBloc, AnomalyState>(
            builder: (context, state) {
              final count =
                  state is AnomalyPolling ? state.anomalies.length : 0;
              if (count == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.alertSpend.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.alertSpend,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const _StatusBar(),
          Expanded(
            child: BlocBuilder<AnomalyBloc, AnomalyState>(
              builder: (context, state) {
                if (state is AnomalyInitial) {
                  return const AnomalyAlertsShimmer(itemCount: 5);
                }

                if (state is AnomalyError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<AnomalyBloc>().add(const StartPolling()),
                  );
                }

                if (state is AnomalyPolling) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: _onRefresh,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Header Section
                        const SliverToBoxAdapter(child: _HeaderSection()),

                        // Recent Anomalies Title
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                            child: Row(
                              children: [
                                Text(
                                  'Recent Anomalies',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.swipe_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Pull to refresh',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Anomaly List or Empty State
                        if (state.anomalies.isEmpty)
                          const SliverFillRemaining(
                            child: EmptyStateView(
                              title: 'All clear',
                              message: 'All metrics look healthy',
                              subtitle: 'No anomalies detected. Your campaigns are performing as expected.',
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => AnomalyCard(
                                  anomaly: state.anomalies[index],
                                  key: ValueKey(
                                    state.anomalies[index].detectedAt,
                                  ),
                                ),
                                childCount: state.anomalies.length,
                              ),
                            ),
                          ),

                        // Notification Toggle Card
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: _NotificationToggle(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatefulWidget {
  const _StatusBar();

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    // Update clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnomalyBloc, AnomalyState>(
      builder: (context, state) {
        final isError = state is AnomalyError;
        final dotColor =
            isError ? AppColors.alertSpend : AppColors.statusActive;

        String label;
        String? countdown;

        if (isError) {
          label = 'Error — tap retry';
        } else if (state is AnomalyPolling) {
          final t = state.lastUpdated;
          final time = '${_pad(t.hour)}:${_pad(t.minute)}:${_pad(t.second)}';
          label = 'Live • Last updated $time';

          // Calculate countdown to next poll (30 seconds)
          final elapsed = _now.difference(t).inSeconds;
          final remaining = 30 - elapsed;
          if (remaining > 0) {
            countdown = '${remaining}s';
          }
        } else {
          label = 'Connecting…';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          child: Row(
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Current time: ${_pad(_now.hour)}:${_pad(_now.minute)}:${_pad(_now.second)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (countdown != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        countdown,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const Text(
                  'Updates every 30s',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.monitor_heart_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring in real-time',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Polling Dds API every 30 seconds',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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

class _NotificationToggle extends StatefulWidget {
  const _NotificationToggle();

  @override
  State<_NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<_NotificationToggle> {
  bool _enabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final service = sl<NotificationService>();
    final enabled = await service.areNotificationsEnabled();
    if (mounted) {
      setState(() => _enabled = enabled && service.isEnabled);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Show explanation dialog before requesting permissions
      final shouldRequest = await _showPermissionExplanationDialog();
      if (!shouldRequest) {
        return;
      }
    }

    setState(() => _isLoading = true);

    final service = sl<NotificationService>();

    if (value) {
      // Request permission first
      final granted = await service.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notification permissions denied. Please enable in Settings.',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.alertSpend,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () {
                  // Could open app settings here if needed
                },
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
          _enabled = false;
        });
        return;
      }
    }

    service.setEnabled(value);

    if (mounted) {
      setState(() {
        _enabled = value;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                value ? Icons.check_circle_outline : Icons.notifications_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value
                      ? 'Notifications enabled successfully'
                      : 'Notifications disabled',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.statusActive,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _showPermissionExplanationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Enable Notifications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stay informed about your campaigns',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'We\'ll notify you when anomalies are detected, such as:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 12),
            _PermissionBullet(
              icon: Icons.trending_up,
              text: 'Unexpected spend spikes',
              color: AppColors.alertSpend,
            ),
            SizedBox(height: 8),
            _PermissionBullet(
              icon: Icons.trending_down,
              text: 'Significant CTR drops',
              color: AppColors.alertCTR,
            ),
            SizedBox(height: 8),
            _PermissionBullet(
              icon: Icons.speed,
              text: 'Real-time performance changes',
              color: AppColors.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Enable',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _enabled ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _enabled
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    _enabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color:
                        _enabled ? AppColors.primary : AppColors.textSecondary,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Push Notifications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Get notified when new anomalies are detected',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _enabled,
            onChanged: _isLoading ? null : _toggleNotifications,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _PermissionBullet extends StatelessWidget {
  const _PermissionBullet({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
