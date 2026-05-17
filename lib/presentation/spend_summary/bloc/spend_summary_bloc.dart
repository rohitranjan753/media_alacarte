import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/campaign_repository.dart';
import 'spend_summary_event.dart';
import 'spend_summary_state.dart';

/// Business logic component for managing the spend summary screen state.
///
/// This bloc handles:
/// - Loading aggregate spend data across all campaigns
/// - Fetching spend breakdown by marketing channel (Search, Social, Display)
/// - Retrieving top-performing campaigns by CTR
/// - Switching between different date ranges (7, 14, 30 days)
/// - Maintaining previous data during date range changes for smoother UX
///
/// **State transitions:**
/// ```
/// Initial → Loading → Loaded (on LoadSpendSummary)
/// Loaded → Loading (with previous data) → Loaded (on ChangeDateRange)
/// Any → Error (on repository exception)
/// ```
///
/// **No background work:** This bloc does not use timers or subscriptions.
class SpendSummaryBloc extends Bloc<SpendSummaryEvent, SpendSummaryState> {
  SpendSummaryBloc(this._repository) : super(const SpendSummaryInitial()) {
    on<LoadSpendSummary>(_onLoad);
    on<ChangeDateRange>(_onChangeRange);
  }

  /// Repository for fetching campaign and spend summary data.
  final CampaignRepository _repository;

  /// Handles the initial loading of spend summary data.
  ///
  /// Emits [SpendSummaryLoading] without previous data (causing full-screen
  /// loader), then fetches summary for the specified date range.
  ///
  /// **State transitions:**
  /// - Initial → Loading → Loaded (success)
  /// - Initial → Loading → Error (failure)
  Future<void> _onLoad(
      LoadSpendSummary event, Emitter<SpendSummaryState> emit) async {
    emit(const SpendSummaryLoading());
    await _fetch(emit, event.range);
  }

  /// Handles date range selection changes.
  ///
  /// Unlike [_onLoad], this preserves the previous summary data in the
  /// loading state, allowing the UI to continue displaying stale data
  /// while fetching fresh data for the new range. This provides a smoother
  /// user experience during range switches.
  ///
  /// **State transitions:**
  /// - Loaded → Loading (with previous data) → Loaded (success)
  /// - Loaded → Loading (with previous data) → Error (failure)
  Future<void> _onChangeRange(
      ChangeDateRange event, Emitter<SpendSummaryState> emit) async {
    final current = state;
    emit(SpendSummaryLoading(
      previousSummary:
          current is SpendSummaryLoaded ? current.summary : null,
      selectedRange: event.range,
    ));
    await _fetch(emit, event.range);
  }

  /// Fetches spend summary from repository and emits the appropriate state.
  ///
  /// This is a shared helper method used by both [_onLoad] and [_onChangeRange].
  /// It handles errors by emitting [SpendSummaryError].
  ///
  /// [emit] - The state emitter
  /// [range] - The date range option to fetch data for
  Future<void> _fetch(
      Emitter<SpendSummaryState> emit, DateRangeOption range) async {
    try {
      final summary =
          await _repository.getSummary(dateRange: range.value);
      emit(SpendSummaryLoaded(summary: summary, selectedRange: range));
    } catch (e) {
      emit(SpendSummaryError(e.toString()));
    }
  }
}
