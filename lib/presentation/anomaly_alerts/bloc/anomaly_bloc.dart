import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/anomaly.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/ml_repository.dart';
import '../../../data/services/notification_service.dart';
import 'anomaly_event.dart';
import 'anomaly_state.dart';

/// Private internal event for periodic polling ticks.
///
/// This event is dispatched internally by the timer every 30 seconds
/// and is not exposed to external callers.
class _PollTick extends AnomalyEvent with EquatableMixin {
  const _PollTick();
}

/// Business logic component for managing anomaly detection and alerts.
///
/// This bloc handles:
/// - Periodic polling (every 30 seconds) of live campaign metrics
/// - ML-powered anomaly detection on the live metrics snapshot
/// - Tracking which anomalies have been seen to avoid duplicate notifications
/// - Triggering local push notifications for new anomalies only
/// - Maintaining a sorted list of all detected anomalies for display
///
/// **Notification strategy:**
/// - On first poll: mark all existing anomalies as "seen" (no notifications)
/// - On subsequent polls: notify only about anomalies not seen before
/// - Each anomaly is uniquely identified by: campaignId + type + detectedAt
///
/// **State transitions:**
/// ```
/// Initial → Polling (on StartPolling + successful poll)
/// Initial → Error (on StartPolling + failed poll)
/// Polling → Polling (on each successful poll tick)
/// Polling → Error (on failed poll tick)
/// Any → (timer cancelled) (on StopPolling)
/// ```
///
/// **Background work:**
/// - [_timer]: A [StreamSubscription] that triggers polls every 30 seconds
/// - Automatically cancelled in [close()] to prevent memory leaks
/// - Should be manually stopped by dispatching [StopPolling] in screen dispose
class AnomalyBloc extends Bloc<AnomalyEvent, AnomalyState> {
  AnomalyBloc({
    required this.campaignRepository,
    required this.mlRepository,
    required this.notificationService,
  }) : super(const AnomalyInitial()) {
    on<StartPolling>(_onStart);
    on<StopPolling>(_onStop);
    on<_PollTick>(_onTick);
  }

  /// Repository for fetching live campaign metrics snapshot.
  final CampaignRepository campaignRepository;

  /// Repository for running ML-powered anomaly detection.
  final MlRepository mlRepository;

  /// Service for displaying local push notifications.
  final NotificationService notificationService;

  /// The polling timer subscription.
  ///
  /// Emits an event every 30 seconds to trigger a new poll.
  /// Cancelled when [StopPolling] is dispatched or when the bloc is closed.
  StreamSubscription<void>? _timer;

  /// Set of unique keys for anomalies we've already sent notifications for.
  ///
  /// Each key is formatted as: "campaignId_type_detectedAtIso8601"
  /// This prevents duplicate notifications for the same anomaly.
  final Set<String> _notifiedKeys = {};

  /// Flag to track if this is the first poll since [StartPolling].
  ///
  /// On the first poll, we mark all anomalies as "seen" without notifying
  /// to avoid spamming the user with notifications when they open the screen.
  bool _isFirstPoll = true;

  /// Handles the start of anomaly polling.
  ///
  /// **Actions:**
  /// 1. Cancels any existing timer (in case StartPolling is called multiple times)
  /// 2. Performs an immediate poll to fetch current anomalies
  /// 3. Sets up a periodic timer to poll every 30 seconds
  ///
  /// The immediate poll on start ensures the user sees data right away
  /// without waiting for the first 30-second interval.
  ///
  /// **State transitions:**
  /// - Initial → Polling (success) or Error (failure)
  Future<void> _onStart(
      StartPolling event, Emitter<AnomalyState> emit) async {
    _timer?.cancel();
    await _poll(emit);
    _timer = Stream.periodic(const Duration(seconds: 30))
        .listen((_) => add(const _PollTick()));
  }

  /// Handles the stop of anomaly polling.
  ///
  /// Cancels the periodic timer and clears the timer reference.
  /// Should be called when the screen is disposed to prevent unnecessary
  /// background work and memory leaks.
  ///
  /// Does not change the current state, so the last poll results remain visible.
  Future<void> _onStop(
      StopPolling event, Emitter<AnomalyState> emit) async {
    _timer?.cancel();
    _timer = null;
  }

  /// Handles periodic polling ticks from the timer.
  ///
  /// This is a thin wrapper around [_poll] that's called by the internal
  /// [_PollTick] event dispatched by the timer every 30 seconds.
  Future<void> _onTick(
      _PollTick event, Emitter<AnomalyState> emit) async {
    await _poll(emit);
  }

  /// Performs a single poll for anomalies.
  ///
  /// **Execution flow:**
  /// 1. Fetch live metrics snapshot from campaign repository
  /// 2. Run ML anomaly detection on the snapshot
  /// 3. Sort anomalies by detection time (newest first)
  /// 4. Handle first-poll logic (mark all as seen, no notifications)
  /// 5. Handle subsequent polls (notify only for new anomalies)
  /// 6. Emit [AnomalyPolling] state with updated anomaly list
  ///
  /// **First poll behavior:**
  /// To avoid notification spam when the user first opens the screen,
  /// all existing anomalies are marked as "seen" without triggering
  /// notifications. Only anomalies detected in subsequent polls will
  /// generate notifications.
  ///
  /// **Subsequent poll behavior:**
  /// Compares the new anomaly list with [_notifiedKeys] to identify
  /// anomalies we haven't seen before. For each new anomaly, triggers
  /// a local push notification and adds it to [_notifiedKeys].
  ///
  /// **Error handling:**
  /// If either the metrics API or anomaly detection API fails, emits
  /// [AnomalyError] state. The timer continues running, so the next
  /// poll will retry after 30 seconds.
  Future<void> _poll(Emitter<AnomalyState> emit) async {
    try {
      final snapshot = await campaignRepository.getLiveMetrics();
      final anomalies =
          await mlRepository.detectAnomalies(snapshot: snapshot);

      // Sort newest first
      final sorted = [...anomalies]
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

      if (_isFirstPoll) {
        // Mark all current anomalies as seen — don't spam on first load
        for (final a in sorted) {
          _notifiedKeys.add(_key(a));
        }
        _isFirstPoll = false;
      } else {
        // Notify only for anomalies we haven't seen before
        for (final a in sorted) {
          final k = _key(a);
          if (!_notifiedKeys.contains(k)) {
            _notifiedKeys.add(k);
            await notificationService.showAnomalyAlert(anomaly: a);
          }
        }
      }

      emit(AnomalyPolling(
        anomalies: sorted,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AnomalyError(e.toString()));
    }
  }

  /// Generates a unique key for an anomaly.
  ///
  /// The key is formatted as: "campaignId_type_detectedAtIso8601"
  ///
  /// This ensures each unique anomaly (identified by campaign, type, and
  /// detection time) is only notified once, even if it appears in multiple
  /// poll results.
  ///
  /// **Example:**
  /// ```
  /// "camp-123_spend_spike_2025-01-15T14:30:00.000Z"
  /// ```
  String _key(Anomaly a) =>
      '${a.campaignId}_${a.type}_${a.detectedAt.toIso8601String()}';

  /// Cleanup method called when the bloc is closed.
  ///
  /// Cancels the polling timer to prevent memory leaks and background
  /// activity after the bloc is disposed.
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
