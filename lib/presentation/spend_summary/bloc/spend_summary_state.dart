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

  /// Computed property: Top 3 campaigns sorted by CTR descending
  List<TopCampaign> get top3Campaigns {
    final sorted = [...summary.topCampaigns]
      ..sort((a, b) => b.ctr.compareTo(a.ctr));
    return sorted.take(3).toList();
  }

  /// Computed property: Maximum CTR from top campaigns
  double get maxCtr {
    final top3 = top3Campaigns;
    return top3.isEmpty ? 1.0 : top3.first.ctr;
  }

  @override
  List<Object?> get props => [summary, selectedRange];
}

class SpendSummaryError extends SpendSummaryState {
  const SpendSummaryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
