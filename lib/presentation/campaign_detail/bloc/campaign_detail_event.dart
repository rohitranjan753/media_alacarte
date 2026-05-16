import 'package:equatable/equatable.dart';

abstract class CampaignDetailEvent extends Equatable {
  const CampaignDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCampaignDetail extends CampaignDetailEvent {
  const LoadCampaignDetail(this.campaignId);

  final String campaignId;

  @override
  List<Object?> get props => [campaignId];
}
