import 'package:equatable/equatable.dart';

/// Base class for all events that can be dispatched to [AnomalyBloc].
///
/// Events represent user actions or system events that control the
/// anomaly detection polling lifecycle.
abstract class AnomalyEvent extends Equatable {
  const AnomalyEvent();
  @override
  List<Object?> get props => [];
}

/// Event triggered to start periodic polling for anomaly detection.
///
/// This event initiates a background timer that fetches live campaign metrics
/// and runs ML-powered anomaly detection every 30 seconds. When new anomalies
/// are detected (ones not seen in previous polls), local push notifications
/// are triggered to alert the user.
///
/// **Triggers**: Screen initialization (in `initState()`)
/// **Result**: Starts a 30-second polling loop that:
///   1. Fetches live campaign metrics snapshot
///   2. Runs ML anomaly detection on the snapshot
///   3. Compares with previously seen anomalies
///   4. Triggers notifications for new anomalies only
///   5. Updates UI with latest anomaly list
///
/// **Note**: On the first poll, all existing anomalies are marked as "seen"
/// to avoid notification spam when the screen is first opened.
class StartPolling extends AnomalyEvent {
  const StartPolling();
}

/// Event triggered to stop periodic polling for anomaly detection.
///
/// This event cancels the background timer and stops all anomaly detection
/// activity. Should be called when the screen is disposed to prevent
/// unnecessary background work and memory leaks.
///
/// **Triggers**: Screen disposal (in `dispose()`)
/// **Result**: Cancels the polling timer and clears the subscription
class StopPolling extends AnomalyEvent {
  const StopPolling();
}
