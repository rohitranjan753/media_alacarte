import 'package:equatable/equatable.dart';

abstract class AnomalyEvent extends Equatable {
  const AnomalyEvent();
  @override
  List<Object?> get props => [];
}

class StartPolling extends AnomalyEvent {
  const StartPolling();
}

class StopPolling extends AnomalyEvent {
  const StopPolling();
}
