import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/ml_repository.dart';
import 'campaign_detail_event.dart';
import 'campaign_detail_state.dart';

/// Business logic component for managing the campaign detail screen state.
///
/// This bloc handles:
/// - Loading campaign metadata (name, status, budget, spend, metrics)
/// - Fetching 30-day historical CTR data for chart visualization
/// - Requesting 7-day ML-powered CTR forecast from the ML service
/// - Graceful degradation when forecast API fails (shows history only)
///
/// **Data fetching strategy:**
/// - Campaign details and history are fetched in parallel using [Future.wait]
///   to minimize total loading time
/// - Forecast is fetched separately after the parallel requests complete
/// - If forecast fails, the screen still displays with historical data and
///   an error message, rather than failing completely
///
/// **State transitions:**
/// ```
/// Initial → Loading → Loaded (success, with or without forecast)
/// Initial → Loading → Error (critical failure: campaign or history API failed)
/// ```
///
/// **No background work:** This bloc does not use timers or subscriptions.
class CampaignDetailBloc
    extends Bloc<CampaignDetailEvent, CampaignDetailState> {
  CampaignDetailBloc({
    required this.campaignRepository,
    required this.mlRepository,
  }) : super(const CampaignDetailInitial()) {
    on<LoadCampaignDetail>(_onLoad);
  }

  /// Repository for fetching campaign data and historical metrics.
  final CampaignRepository campaignRepository;

  /// Repository for fetching ML-powered predictions and forecasts.
  final MlRepository mlRepository;

  /// Handles the loading of campaign details, history, and forecast.
  ///
  /// **Execution flow:**
  /// 1. Emit [CampaignDetailLoading] to show full-screen loader
  /// 2. Fetch campaign details and 30-day history in parallel
  /// 3. Fetch 7-day forecast using the historical data
  /// 4. Emit [CampaignDetailLoaded] with all data
  ///
  /// **Error handling:**
  /// - If campaign or history API fails: emit [CampaignDetailError]
  /// - If forecast API fails: emit [CampaignDetailLoaded] with empty forecast
  ///   and [forecastError] message, allowing the screen to display historical
  ///   data with a forecast error indicator
  ///
  /// **State transitions:**
  /// - Initial/Any → Loading → Loaded (success)
  /// - Initial/Any → Loading → Error (campaign/history fetch failed)
  Future<void> _onLoad(
      LoadCampaignDetail event, Emitter<CampaignDetailState> emit) async {
    emit(const CampaignDetailLoading());
    try {
      // Fetch campaign and history in parallel for better performance
      final results = await Future.wait([
        campaignRepository.getCampaign(event.campaignId),
        campaignRepository.getCampaignHistory(event.campaignId),
      ]);

      final campaign = results[0] as Campaign;
      final history = results[1] as List<DailyMetric>;

      // Attempt to fetch ML forecast, but allow graceful degradation
      List<ForecastPoint> forecast = [];
      String? forecastError;
      try {
        forecast = await mlRepository.getForecast(
          campaignId: event.campaignId,
          history: history,
        );
      } catch (e) {
        // Forecast failure is not critical - we can still show the screen
        forecastError = e.toString();
      }

      emit(CampaignDetailLoaded(
        campaign: campaign,
        history: history,
        forecast: forecast,
        forecastError: forecastError,
      ));
    } catch (e) {
      // Critical error - cannot display screen without campaign/history
      emit(CampaignDetailError(e.toString()));
    }
  }
}
