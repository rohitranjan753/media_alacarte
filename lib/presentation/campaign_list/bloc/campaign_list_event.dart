import 'package:equatable/equatable.dart';

abstract class CampaignListEvent extends Equatable {
  const CampaignListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCampaigns extends CampaignListEvent {
  const LoadCampaigns();
}

class RefreshCampaigns extends CampaignListEvent {
  const RefreshCampaigns();
}

class FilterCampaigns extends CampaignListEvent {
  const FilterCampaigns(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

class SearchCampaigns extends CampaignListEvent {
  const SearchCampaigns(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
