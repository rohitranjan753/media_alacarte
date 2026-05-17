import 'package:equatable/equatable.dart';

/// Enum representing the available date range options for spend summary.
///
/// Each option maps to a specific time window for aggregating campaign spend data.
enum DateRangeOption {
  /// Last 7 days of spend data.
  last7('last_7_days', 'Last 7 Days'),

  /// Last 14 days of spend data.
  last14('last_14_days', 'Last 14 Days'),

  /// Last 30 days of spend data (default).
  last30('last_30_days', 'Last 30 Days');

  const DateRangeOption(this.value, this.label);

  /// The API parameter value sent to the backend.
  final String value;

  /// The human-readable label displayed in the UI.
  final String label;
}

/// Base class for all events that can be dispatched to [SpendSummaryBloc].
///
/// Events represent user actions or system events that trigger state changes
/// in the spend summary screen.
abstract class SpendSummaryEvent extends Equatable {
  const SpendSummaryEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the spend summary screen is first loaded.
///
/// This event fetches the initial spend summary data for the specified
/// date range (defaults to last 30 days).
///
/// **Triggers**: Screen initialization
/// **Result**: Fetches spend summary with KPIs, channel breakdown, and top campaigns
class LoadSpendSummary extends SpendSummaryEvent {
  const LoadSpendSummary({this.range = DateRangeOption.last30});

  /// The date range to load.
  ///
  /// Defaults to [DateRangeOption.last30] if not specified.
  final DateRangeOption range;

  @override
  List<Object?> get props => [range];
}

/// Event triggered when the user selects a different date range.
///
/// This event re-fetches the spend summary data for the new time window.
/// Unlike [LoadSpendSummary], this preserves the previous summary data
/// during the fetch to avoid a jarring full-screen loader.
///
/// **Triggers**: User tapping a different date range button (7/14/30 days)
/// **Result**: Re-fetches spend summary for the selected date range
class ChangeDateRange extends SpendSummaryEvent {
  const ChangeDateRange(this.range);

  /// The new date range to switch to.
  final DateRangeOption range;

  @override
  List<Object?> get props => [range];
}
