import 'package:equatable/equatable.dart';

/// Base class for all events that can be dispatched to [CampaignDetailBloc].
///
/// Events represent user actions or system events that trigger state changes
/// in the campaign detail screen.
abstract class CampaignDetailEvent extends Equatable {
  const CampaignDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the campaign detail screen is loaded.
///
/// This event fetches:
/// 1. Campaign details (name, status, budget, spend, metrics)
/// 2. 30-day historical CTR data
/// 3. 7-day ML-powered CTR forecast (optional, may fail gracefully)
///
/// The campaign details and history are fetched in parallel using [Future.wait].
/// If the forecast API fails, the screen still displays with a forecast error
/// message instead of failing completely.
///
/// **Triggers**: Screen initialization with campaign ID from navigation arguments
/// **Result**: Loads campaign data, history chart, and ML forecast for display
class LoadCampaignDetail extends CampaignDetailEvent {
  const LoadCampaignDetail(this.campaignId);

  /// The unique identifier of the campaign to load.
  ///
  /// This ID is passed from the campaign list screen via navigation arguments
  /// and is used to fetch campaign-specific data from the repository.
  final String campaignId;

  @override
  List<Object?> get props => [campaignId];
}
