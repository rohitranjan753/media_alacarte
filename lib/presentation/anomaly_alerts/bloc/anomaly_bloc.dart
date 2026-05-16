import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/anomaly.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/ml_repository.dart';
import '../../../data/services/notification_service.dart';
import 'anomaly_event.dart';
import 'anomaly_state.dart';

// Private internal event — lives in same library as the bloc
class _PollTick extends AnomalyEvent with EquatableMixin {
  const _PollTick();
}

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

  final CampaignRepository campaignRepository;
  final MlRepository mlRepository;
  final NotificationService notificationService;

  StreamSubscription<void>? _timer;

  // Keys of anomalies we've already notified about
  final Set<String> _notifiedKeys = {};
  bool _isFirstPoll = true;

  Future<void> _onStart(
      StartPolling event, Emitter<AnomalyState> emit) async {
    _timer?.cancel();
    await _poll(emit);
    _timer = Stream.periodic(const Duration(seconds: 30))
        .listen((_) => add(const _PollTick()));
  }

  Future<void> _onStop(
      StopPolling event, Emitter<AnomalyState> emit) async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onTick(
      _PollTick event, Emitter<AnomalyState> emit) async {
    await _poll(emit);
  }

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

  String _key(Anomaly a) =>
      '${a.campaignId}_${a.type}_${a.detectedAt.toIso8601String()}';

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
