import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/campaign.dart';
import '../../../data/repositories/campaign_repository.dart';
import 'campaign_list_event.dart';
import 'campaign_list_state.dart';

class CampaignListBloc extends Bloc<CampaignListEvent, CampaignListState> {
  CampaignListBloc(this._repository) : super(const CampaignListInitial()) {
    on<LoadCampaigns>(_onLoad);
    on<RefreshCampaigns>(_onRefresh);
    on<FilterCampaigns>(_onFilter);
    on<SearchCampaigns>(_onSearch);
  }

  final CampaignRepository _repository;

  Future<void> _onLoad(
      LoadCampaigns event, Emitter<CampaignListState> emit) async {
    emit(const CampaignListLoading());
    await _fetchAndEmit(emit, filter: 'all');
  }

  Future<void> _onRefresh(
      RefreshCampaigns event, Emitter<CampaignListState> emit) async {
    final current = state;
    if (current is CampaignListLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    await _fetchAndEmit(
      emit,
      filter: current is CampaignListLoaded ? current.filter : 'all',
    );
  }

  void _onFilter(FilterCampaigns event, Emitter<CampaignListState> emit) {
    final current = state;
    if (current is! CampaignListLoaded) return;

    final filtered = _applyFilters(
      current.allCampaigns,
      event.filter,
      current.searchQuery,
    );
    emit(current.copyWith(campaigns: filtered, filter: event.filter));
  }

  void _onSearch(SearchCampaigns event, Emitter<CampaignListState> emit) {
    final current = state;
    if (current is! CampaignListLoaded) return;

    final filtered = _applyFilters(
      current.allCampaigns,
      current.filter,
      event.query,
    );
    emit(current.copyWith(campaigns: filtered, searchQuery: event.query));
  }

  Future<void> _fetchAndEmit(
    Emitter<CampaignListState> emit, {
    required String filter,
  }) async {
    try {
      final campaigns = await _repository.getCampaigns();
      final filtered = _applyFilters(campaigns, filter, '');
      emit(CampaignListLoaded(
        allCampaigns: campaigns,
        campaigns: filtered,
        filter: filter,
      ));
    } catch (e) {
      emit(CampaignListError(e.toString()));
    }
  }

  List<Campaign> _applyFilters(
    List<Campaign> campaigns,
    String filter,
    String searchQuery,
  ) {
    var result = campaigns;

    // Apply status filter
    if (filter != 'all') {
      result = result
          .where((c) => c.status.toLowerCase() == filter.toLowerCase())
          .toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.objective.toLowerCase().contains(query) ||
            c.channel.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }
}
