import 'package:equatable/equatable.dart';
import '../../../data/models/campaign.dart';

abstract class CampaignListState extends Equatable {
  const CampaignListState();

  @override
  List<Object?> get props => [];
}

class CampaignListInitial extends CampaignListState {
  const CampaignListInitial();
}

class CampaignListLoading extends CampaignListState {
  const CampaignListLoading();
}

class CampaignListLoaded extends CampaignListState {
  const CampaignListLoaded({
    required this.allCampaigns,
    required this.campaigns,
    required this.filter,
    this.searchQuery = '',
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  final List<Campaign> allCampaigns;
  final List<Campaign> campaigns;
  final String filter;
  final String searchQuery;
  final bool isRefreshing;
  final bool isFromCache;

  /// Computed property: Campaign counts by status
  Map<String, int> get campaignCounts => {
        'all': allCampaigns.length,
        'active': allCampaigns
            .where((c) => c.status.toLowerCase() == 'active')
            .length,
        'paused': allCampaigns
            .where((c) => c.status.toLowerCase() == 'paused')
            .length,
      };

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

class CampaignListError extends CampaignListState {
  const CampaignListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
