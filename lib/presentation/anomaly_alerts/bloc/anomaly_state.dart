import 'package:equatable/equatable.dart';
import '../../../data/models/anomaly.dart';

abstract class AnomalyState extends Equatable {
  const AnomalyState();
  @override
  List<Object?> get props => [];
}

class AnomalyInitial extends AnomalyState {
  const AnomalyInitial();
}

class AnomalyPolling extends AnomalyState {
  const AnomalyPolling({
    required this.anomalies,
    required this.lastUpdated,
  });

  final List<Anomaly> anomalies;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [anomalies, lastUpdated];
}

class AnomalyError extends AnomalyState {
  const AnomalyError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
