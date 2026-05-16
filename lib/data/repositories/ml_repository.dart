import '../models/anomaly.dart';
import '../models/daily_metric.dart';
import '../models/forecast_point.dart';
import '../models/snapshot.dart';
import '../services/ml_api_service.dart';

class MlRepository {
  const MlRepository(this._service);

  final MlApiService _service;

  Future<List<ForecastPoint>> getForecast({
    required String campaignId,
    required List<DailyMetric> history,
  }) =>
      _service.getForecast(campaignId: campaignId, history: history);

  Future<List<Anomaly>> detectAnomalies({required Snapshot snapshot}) =>
      _service.detectAnomalies(snapshot: snapshot);
}
