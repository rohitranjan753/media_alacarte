import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/campaign_repository.dart';
import 'spend_summary_event.dart';
import 'spend_summary_state.dart';

class SpendSummaryBloc extends Bloc<SpendSummaryEvent, SpendSummaryState> {
  SpendSummaryBloc(this._repository) : super(const SpendSummaryInitial()) {
    on<LoadSpendSummary>(_onLoad);
    on<ChangeDateRange>(_onChangeRange);
  }

  final CampaignRepository _repository;

  Future<void> _onLoad(
      LoadSpendSummary event, Emitter<SpendSummaryState> emit) async {
    emit(const SpendSummaryLoading());
    await _fetch(emit, event.range);
  }

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
