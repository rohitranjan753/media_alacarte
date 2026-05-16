import 'package:equatable/equatable.dart';

enum DateRangeOption {
  last7('last_7_days', 'Last 7 Days'),
  last14('last_14_days', 'Last 14 Days'),
  last30('last_30_days', 'Last 30 Days');

  const DateRangeOption(this.value, this.label);
  final String value;
  final String label;
}

abstract class SpendSummaryEvent extends Equatable {
  const SpendSummaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSpendSummary extends SpendSummaryEvent {
  const LoadSpendSummary({this.range = DateRangeOption.last30});

  final DateRangeOption range;

  @override
  List<Object?> get props => [range];
}

class ChangeDateRange extends SpendSummaryEvent {
  const ChangeDateRange(this.range);

  final DateRangeOption range;

  @override
  List<Object?> get props => [range];
}
