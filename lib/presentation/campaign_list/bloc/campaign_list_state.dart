import 'package:equatable/equatable.dart';
import '../../../data/models/campaign.dart';

/// Base class for all states emitted by [CampaignListBloc].
///
/// States represent the different phases of the campaign list screen:
/// initial, loading, loaded with data, or error.
abstract class CampaignListState extends Equatable {
  const CampaignListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any campaigns have been loaded.
///
/// This state is active when the bloc is first created and before
/// the [LoadCampaigns] event is processed.
///
/// **Active during**: Bloc initialization
/// **UI should show**: Loading indicator or splash screen
class CampaignListInitial extends CampaignListState {
  const CampaignListInitial();
}

/// State while campaigns are being fetched for the first time.
///
/// This state indicates a full-screen loading operation where no
/// previous data is available to display.
///
/// **Active during**: Initial campaign fetch
/// **UI should show**: Full-screen loading indicator
class CampaignListLoading extends CampaignListState {
  const CampaignListLoading();
}

/// State when campaigns have been successfully loaded and are ready to display.
///
/// This state contains both the complete list of campaigns and the filtered/searched
/// subset that should be displayed. It also tracks whether a refresh is in progress
/// and whether the data came from cache (offline mode).
///
/// **Active during**: Successful campaign display, filtering, searching, or refreshing
/// **UI should show**: Campaign list with applied filters and search query
class CampaignListLoaded extends CampaignListState {
  const CampaignListLoaded({
    required this.allCampaigns,
    required this.campaigns,
    required this.filter,
    this.searchQuery = '',
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  /// The complete unfiltered list of campaigns fetched from the repository.
  ///
  /// This list is used as the source data for all filtering and searching operations.
  final List<Campaign> allCampaigns;

  /// The filtered and/or searched subset of campaigns to display in the UI.
  ///
  /// This list reflects the currently active filter and search query.
  final List<Campaign> campaigns;

  /// The currently active status filter.
  ///
  /// Valid values: 'all', 'active', 'paused'
  final String filter;

  /// The currently active search query.
  ///
  /// Empty string indicates no search is active.
  final String searchQuery;

  /// Whether a pull-to-refresh operation is currently in progress.
  ///
  /// When true, the UI can show a refresh indicator at the top of the list
  /// while still displaying the existing campaign data.
  final bool isRefreshing;

  /// Whether the campaign data was loaded from local cache (offline mode).
  ///
  /// When true, the UI can show an indicator that the data may be stale.
  final bool isFromCache;

  /// Computed property: Campaign counts by status.
  ///
  /// Returns a map with keys 'all', 'active', and 'paused' containing
  /// the count of campaigns for each status from the complete list.
  ///
  /// Used to display badge counts on filter chips.
  Map<String, int> get campaignCounts => {
        'all': allCampaigns.length,
        'active': allCampaigns
            .where((c) => c.status.toLowerCase() == 'active')
            .length,
        'paused': allCampaigns
            .where((c) => c.status.toLowerCase() == 'paused')
            .length,
      };

  /// Creates a copy of this state with some fields replaced.
  ///
  /// This is used by the bloc to update individual fields without
  /// recreating the entire state object.
  CampaignListLoaded copyWith({
    List<Campaign>? allCampaigns,
    List<Campaign>? campaigns,
    String? filter,
    String? searchQuery,
    bool? isRefreshing,
    bool? isFromCache,
  }) =>
      CampaignListLoaded(
        allCampaigns: allCampaigns ?? this.allCampaigns,
        campaigns: campaigns ?? this.campaigns,
        filter: filter ?? this.filter,
        searchQuery: searchQuery ?? this.searchQuery,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [allCampaigns, campaigns, filter, searchQuery, isRefreshing, isFromCache];
}

/// State when an error occurs while fetching campaigns.
///
/// This state is emitted when the repository throws an exception during
/// a campaign fetch operation.
///
/// **Active during**: Network errors, API errors, or other fetch failures
/// **UI should show**: Error view with retry button
class CampaignListError extends CampaignListState {
  const CampaignListError(this.message);

  /// The error message describing what went wrong.
  ///
  /// This message is displayed to the user in the error view.
  final String message;

  @override
  List<Object?> get props => [message];
}
