import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/ml_repository.dart';
import 'campaign_detail_event.dart';
import 'campaign_detail_state.dart';

class CampaignDetailBloc
    extends Bloc<CampaignDetailEvent, CampaignDetailState> {
  CampaignDetailBloc({
    required this.campaignRepository,
    required this.mlRepository,
  }) : super(const CampaignDetailInitial()) {
    on<LoadCampaignDetail>(_onLoad);
  }

  final CampaignRepository campaignRepository;
  final MlRepository mlRepository;

  Future<void> _onLoad(
      LoadCampaignDetail event, Emitter<CampaignDetailState> emit) async {
    emit(const CampaignDetailLoading());
    try {
      final results = await Future.wait([
        campaignRepository.getCampaign(event.campaignId),
        campaignRepository.getCampaignHistory(event.campaignId),
      ]);

      final campaign = results[0] as Campaign;
      final history = results[1] as List<DailyMetric>;

      List<ForecastPoint> forecast = [];
      String? forecastError;
      try {
        forecast = await mlRepository.getForecast(
          campaignId: event.campaignId,
          history: history,
        );
      } catch (e) {
        forecastError = e.toString();
      }

      emit(CampaignDetailLoaded(
        campaign: campaign,
        history: history,
        forecast: forecast,
        forecastError: forecastError,
      ));
    } catch (e) {
      emit(CampaignDetailError(e.toString()));
    }
  }
}
