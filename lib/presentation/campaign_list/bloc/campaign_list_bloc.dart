import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/campaign.dart';
import '../../../data/repositories/campaign_repository.dart';
import 'campaign_list_event.dart';
import 'campaign_list_state.dart';

/// Business logic component for managing the campaign list screen state.
///
/// This bloc handles:
/// - Initial campaign loading with full-screen loading state
/// - Pull-to-refresh that maintains current list during fetch
/// - Status filtering (all, active, paused) applied in-memory
/// - Search query filtering by name, objective, or channel
/// - Offline cache support via the repository layer
///
/// The bloc maintains a complete list of campaigns and applies filters/search
/// client-side without making additional API calls.
///
/// **State transitions:**
/// ```
/// Initial → Loading → Loaded (on LoadCampaigns)
/// Loaded → Loaded (isRefreshing=true) → Loaded (on RefreshCampaigns)
/// Loaded → Loaded (filtered) (on FilterCampaigns)
/// Loaded → Loaded (searched) (on SearchCampaigns)
/// Any → Error (on repository exception)
/// ```
class CampaignListBloc extends Bloc<CampaignListEvent, CampaignListState> {
  CampaignListBloc(this._repository) : super(const CampaignListInitial()) {
    on<LoadCampaigns>(_onLoad);
    on<RefreshCampaigns>(_onRefresh);
    on<FilterCampaigns>(_onFilter);
    on<SearchCampaigns>(_onSearch);
  }

  final CampaignRepository _repository;

  /// Handles the initial loading of campaigns.
  ///
  /// Emits [CampaignListLoading] immediately to show full-screen loader,
  /// then fetches campaigns from the repository and applies the 'all' filter.
  ///
  /// **State transitions:**
  /// - Initial → Loading → Loaded (success)
  /// - Initial → Loading → Error (failure)
  Future<void> _onLoad(
      LoadCampaigns event, Emitter<CampaignListState> emit) async {
    emit(const CampaignListLoading());
    await _fetchAndEmit(emit, filter: 'all');
  }

  /// Handles pull-to-refresh action from the user.
  ///
  /// Unlike [_onLoad], this maintains the current campaign list on screen
  /// by setting `isRefreshing: true` in the loaded state, allowing the UI
  /// to show a refresh indicator without hiding the list.
  ///
  /// Preserves the currently active filter and search query.
  ///
  /// **State transitions:**
  /// - Loaded → Loaded (isRefreshing=true) → Loaded (success)
  /// - Loaded → Loaded (isRefreshing=true) → Error (failure)
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

  /// Handles status filter changes (all, active, paused).
  ///
  /// Applies filtering in-memory without making an API call. This is a
  /// synchronous operation that maintains the current search query.
  ///
  /// Does nothing if the current state is not [CampaignListLoaded].
  ///
  /// **State transitions:**
  /// - Loaded → Loaded (with new filter applied)
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

  /// Handles search query changes.
  ///
  /// Applies search filtering in-memory without making an API call. This is a
  /// synchronous operation that maintains the current status filter.
  ///
  /// Searches across campaign name, objective, and channel fields using
  /// case-insensitive substring matching.
  ///
  /// Does nothing if the current state is not [CampaignListLoaded].
  ///
  /// **State transitions:**
  /// - Loaded → Loaded (with new search query applied)
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

  /// Fetches campaigns from repository and emits the appropriate state.
  ///
  /// This is a shared helper method used by both [_onLoad] and [_onRefresh].
  /// It applies the specified filter after fetching and handles errors by
  /// emitting [CampaignListError].
  ///
  /// [filter] - The status filter to apply ('all', 'active', or 'paused')
  Future<void> _fetchAndEmit(
    Emitter<CampaignListState> emit, {
    required String filter,
  }) async {
    try {
      final result = await _repository.getCampaigns();
      final filtered = _applyFilters(result.campaigns, filter, '');
      emit(CampaignListLoaded(
        allCampaigns: result.campaigns,
        campaigns: filtered,
        filter: filter,
        isFromCache: result.isFromCache,
      ));
    } catch (e) {
      emit(CampaignListError(e.toString()));
    }
  }

  /// Applies both status filter and search query to a list of campaigns.
  ///
  /// This method is used for client-side filtering and does not make API calls.
  ///
  /// **Status filter logic:**
  /// - 'all': returns all campaigns
  /// - 'active' or 'paused': filters by matching status (case-insensitive)
  ///
  /// **Search query logic:**
  /// - Empty query: no search filtering applied
  /// - Non-empty: matches substring (case-insensitive) against:
  ///   - Campaign name
  ///   - Campaign objective
  ///   - Campaign channel
  ///
  /// Both filters are applied sequentially if both are active.
  ///
  /// [campaigns] - The source list to filter
  /// [filter] - The status filter ('all', 'active', 'paused')
  /// [searchQuery] - The search query string (empty string for no search)
  ///
  /// Returns the filtered list of campaigns.
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
