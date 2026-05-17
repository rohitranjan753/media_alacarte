import '../models/anomaly.dart';
import '../models/daily_metric.dart';
import '../models/forecast_point.dart';
import '../models/snapshot.dart';
import '../services/ml_api_service.dart';

/// Repository for machine learning predictions and anomaly detection.
///
/// Wraps [MlApiService] to provide CTR forecasting and real-time anomaly
/// detection capabilities. Does not implement caching as ML predictions
/// are always calculated fresh based on current data.
class MlRepository {
  const MlRepository(this._service);

  final MlApiService _service;

  /// Generates a 7-day CTR forecast for a campaign.
  ///
  /// Takes the campaign's 30-day [history] and uses ML models to predict
  /// future CTR with confidence intervals. Returns a list of [ForecastPoint]
  /// objects for the next 7 days.
  ///
  /// Throws [AppException] on network or ML service errors.
  Future<List<ForecastPoint>> getForecast({
    required String campaignId,
    required List<DailyMetric> history,
  }) =>
      _service.getForecast(campaignId: campaignId, history: history);

  /// Detects anomalies in real-time campaign metrics.
  ///
  /// Analyzes the provided [snapshot] of live metrics to identify unusual
  /// patterns like spend spikes or CTR drops. Returns a list of detected
  /// [Anomaly] objects.
  ///
  /// Throws [AppException] on network or ML service errors.
  Future<List<Anomaly>> detectAnomalies({required Snapshot snapshot}) =>
      _service.detectAnomalies(snapshot: snapshot);
}
