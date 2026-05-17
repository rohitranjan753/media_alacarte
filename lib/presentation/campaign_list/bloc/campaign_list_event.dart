import 'package:equatable/equatable.dart';

/// Base class for all events that can be dispatched to [CampaignListBloc].
///
/// Events represent user actions or system events that trigger state changes
/// in the campaign list screen.
abstract class CampaignListEvent extends Equatable {
  const CampaignListEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the campaign list screen is first loaded.
///
/// This event is typically dispatched in the screen's `initState()` method
/// to fetch the initial list of campaigns from the repository.
///
/// **Triggers**: Screen initialization
/// **Result**: Fetches all campaigns and displays them with 'all' filter applied
class LoadCampaigns extends CampaignListEvent {
  const LoadCampaigns();
}

/// Event triggered when the user pulls down to refresh the campaign list.
///
/// This event maintains the current filter and search query while re-fetching
/// fresh data from the repository. It sets `isRefreshing` flag to true during
/// the fetch operation to show a refresh indicator without hiding the list.
///
/// **Triggers**: Pull-to-refresh gesture on campaign list
/// **Result**: Re-fetches campaigns while maintaining current filter state
class RefreshCampaigns extends CampaignListEvent {
  const RefreshCampaigns();
}

/// Event triggered when the user selects a different status filter.
///
/// Filters the campaign list in-memory without making an API call.
/// Does not affect the search query if one is active.
///
/// **Triggers**: Tapping a filter chip (All, Active, Paused)
/// **Result**: Updates displayed campaigns based on status filter
class FilterCampaigns extends CampaignListEvent {
  const FilterCampaigns(this.filter);

  /// The status filter to apply.
  ///
  /// Valid values: 'all', 'active', 'paused'
  /// Case-insensitive comparison is performed during filtering.
  final String filter;

  @override
  List<Object?> get props => [filter];
}

/// Event triggered when the user types in the search bar.
///
/// Filters the campaign list in-memory by matching the query against
/// campaign name, objective, and channel. Works in combination with
/// the active status filter.
///
/// **Triggers**: Text input in search bar
/// **Result**: Updates displayed campaigns based on search query
class SearchCampaigns extends CampaignListEvent {
  const SearchCampaigns(this.query);

  /// The search query string to filter campaigns.
  ///
  /// An empty string clears the search filter.
  /// The query is matched case-insensitively against campaign name,
  /// objective, and channel fields.
  final String query;

  @override
  List<Object?> get props => [query];
}
