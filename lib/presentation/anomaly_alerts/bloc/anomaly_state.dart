import 'package:equatable/equatable.dart';
import '../../../data/models/anomaly.dart';

/// Base class for all states emitted by [AnomalyBloc].
///
/// States represent the different phases of the anomaly alerts screen:
/// initial (before polling starts), actively polling, or error state.
abstract class AnomalyState extends Equatable {
  const AnomalyState();
  @override
  List<Object?> get props => [];
}

/// Initial state before anomaly polling has started.
///
/// This state is active when the bloc is first created and before
/// the [StartPolling] event is processed.
///
/// **Active during**: Bloc initialization, before polling begins
/// **UI should show**: Loading indicator or empty state
class AnomalyInitial extends AnomalyState {
  const AnomalyInitial();
}

/// State when anomaly polling is active and anomaly data is available.
///
/// This state indicates that the periodic polling loop is running and
/// anomalies have been detected (or none exist). The state contains:
/// - A list of all detected anomalies, sorted by detection time (newest first)
/// - The timestamp of the last successful poll
///
/// The anomaly list may be empty if no anomalies have been detected,
/// which is a valid state (all metrics healthy).
///
/// **Active during**: Active polling with successful API responses
/// **UI should show**: Live indicator dot, last updated timestamp, and
///                     list of anomaly cards (or "all healthy" message if empty)
class AnomalyPolling extends AnomalyState {
  const AnomalyPolling({
    required this.anomalies,
    required this.lastUpdated,
  });

  /// List of detected anomalies, sorted by detection time (newest first).
  ///
  /// Each anomaly contains:
  /// - campaignId: The affected campaign
  /// - type: The anomaly type ('spend_spike' or 'ctr_drop')
  /// - severity: How severe the anomaly is
  /// - message: Human-readable description
  /// - detectedAt: When the anomaly was first detected
  ///
  /// This list may be empty if no anomalies are currently active.
  final List<Anomaly> anomalies;

  /// Timestamp of the last successful poll.
  ///
  /// Used to display "Last updated HH:MM:SS" in the UI to show
  /// that polling is active and data is fresh.
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [anomalies, lastUpdated];
}

/// State when an error occurs during anomaly polling.
///
/// This state is emitted when either:
/// - The live metrics API fails
/// - The anomaly detection ML API fails
/// - A network error occurs
///
/// The polling loop will continue to retry on the next scheduled tick
/// (every 30 seconds), so this is typically a transient state.
///
/// **Active during**: Network errors or API failures during a poll
/// **UI should show**: Error indicator dot, error message, and possibly
///                     stale anomaly data if available from previous polls
class AnomalyError extends AnomalyState {
  const AnomalyError(this.message);

  /// The error message describing what went wrong.
  ///
  /// This message is displayed to the user in the error indicator.
  final String message;

  @override
  List<Object?> get props => [message];
}
