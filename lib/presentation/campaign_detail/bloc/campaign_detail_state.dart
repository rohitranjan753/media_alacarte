import 'package:equatable/equatable.dart';
import '../../../data/models/campaign.dart';
import '../../../data/models/daily_metric.dart';
import '../../../data/models/forecast_point.dart';

/// Base class for all states emitted by [CampaignDetailBloc].
///
/// States represent the different phases of the campaign detail screen:
/// initial, loading, loaded with data (including optional forecast), or error.
abstract class CampaignDetailState extends Equatable {
  const CampaignDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before campaign details have been loaded.
///
/// This state is active when the bloc is first created and before
/// the [LoadCampaignDetail] event is processed.
///
/// **Active during**: Bloc initialization
/// **UI should show**: Loading indicator or splash screen
class CampaignDetailInitial extends CampaignDetailState {
  const CampaignDetailInitial();
}

/// State while campaign details, history, and forecast are being fetched.
///
/// This state indicates a full-screen loading operation where no
/// previous data is available to display.
///
/// **Active during**: Initial data fetch for campaign, history, and forecast
/// **UI should show**: Full-screen loading indicator
class CampaignDetailLoading extends CampaignDetailState {
  const CampaignDetailLoading();
}

/// State when campaign details, history, and forecast have been loaded.
///
/// This state contains all the data needed to display the campaign detail screen:
/// - Campaign metadata (name, status, budget, spend, metrics)
/// - 30-day historical CTR data for the chart
/// - 7-day ML forecast with confidence bounds (may be empty if forecast failed)
/// - Optional forecast error message if the ML API failed
///
/// The screen can be displayed even if the forecast fails, showing only the
/// historical data and an error message where the forecast would be.
///
/// **Active during**: Successful data display
/// **UI should show**: Campaign details, CTR chart with history and forecast,
///                     and budget recommendation card
class CampaignDetailLoaded extends CampaignDetailState {
  const CampaignDetailLoaded({
    required this.campaign,
    required this.history,
    required this.forecast,
    this.forecastError,
  });

  /// The campaign metadata including name, status, budget, and current metrics.
  final Campaign campaign;

  /// List of daily CTR measurements for the past 30 days.
  ///
  /// Each metric contains a date and the CTR value for that day.
  /// Used to render the historical portion of the CTR chart.
  final List<DailyMetric> history;

  /// List of ML-predicted CTR values for the next 7 days.
  ///
  /// Each forecast point contains:
  /// - Date: The future date
  /// - Predicted CTR: The ML model's prediction
  /// - Lower/Upper bounds: Confidence interval (typically 95%)
  ///
  /// This list may be empty if the forecast API failed.
  final List<ForecastPoint> forecast;

  /// Error message if the ML forecast API failed.
  ///
  /// When non-null, the UI should display the historical data but show
  /// an error message in place of the forecast section. This allows
  /// graceful degradation when the ML service is unavailable.
  final String? forecastError;

  @override
  List<Object?> get props => [campaign, history, forecast, forecastError];
}

/// State when an error occurs while fetching campaign details or history.
///
/// This state is emitted when either the campaign details API or the history
/// API fails. Note that a forecast API failure does NOT trigger this state;
/// instead, it results in a [CampaignDetailLoaded] state with a [forecastError].
///
/// **Active during**: Network errors, API errors, or campaign not found
/// **UI should show**: Error view with retry button
class CampaignDetailError extends CampaignDetailState {
  const CampaignDetailError(this.message);

  /// The error message describing what went wrong.
  ///
  /// This message is displayed to the user in the error view.
  final String message;

  @override
  List<Object?> get props => [message];
}
