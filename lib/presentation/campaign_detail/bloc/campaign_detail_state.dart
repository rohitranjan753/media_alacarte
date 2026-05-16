import 'package:equatable/equatable.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';

abstract class CampaignDetailState extends Equatable {
  const CampaignDetailState();

  @override
  List<Object?> get props => [];
}

class CampaignDetailInitial extends CampaignDetailState {
  const CampaignDetailInitial();
}

class CampaignDetailLoading extends CampaignDetailState {
  const CampaignDetailLoading();
}

class CampaignDetailLoaded extends CampaignDetailState {
  const CampaignDetailLoaded({
    required this.campaign,
    required this.history,
    required this.forecast,
    this.forecastError,
  });

  final Campaign campaign;
  final List<DailyMetric> history;
  final List<ForecastPoint> forecast;
  final String? forecastError;

  @override
  List<Object?> get props => [campaign, history, forecast, forecastError];
}

class CampaignDetailError extends CampaignDetailState {
  const CampaignDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
