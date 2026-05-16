import 'package:equatable/equatable.dart';
import '../../../data/models/summary.dart';
import 'spend_summary_event.dart';

abstract class SpendSummaryState extends Equatable {
  const SpendSummaryState();

  @override
  List<Object?> get props => [];
}

class SpendSummaryInitial extends SpendSummaryState {
  const SpendSummaryInitial();
}

class SpendSummaryLoading extends SpendSummaryState {
  const SpendSummaryLoading({this.previousSummary, this.selectedRange});

  final Summary? previousSummary;
  final DateRangeOption? selectedRange;

  @override
  List<Object?> get props => [previousSummary, selectedRange];
}

class SpendSummaryLoaded extends SpendSummaryState {
  const SpendSummaryLoaded({
    required this.summary,
    required this.selectedRange,
  });

  final Summary summary;
  final DateRangeOption selectedRange;

  @override
  List<Object?> get props => [summary, selectedRange];
}

class SpendSummaryError extends SpendSummaryState {
  const SpendSummaryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
