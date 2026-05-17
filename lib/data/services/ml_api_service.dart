import 'dart:convert';

import 'package:dio/dio.dart';
import '../models/anomaly.dart';
import '../models/daily_metric.dart';
import '../models/forecast_point.dart';
import '../models/snapshot.dart';
import '../../core/constants/api_constants.dart';
import 'ads_api_service.dart';

Map<String, dynamic> _decode(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return jsonDecode(data as String) as Map<String, dynamic>;
}

/// Service for communicating with the Machine Learning API.
///
/// Handles CTR forecasting and anomaly detection requests. Uses the same
/// Dio instance as [AdsApiService] but targets ML-specific endpoints.
/// All methods wrap errors in [AppException].
class MlApiService {
  const MlApiService(this._dio);

  final Dio _dio;

  /// Generates a 7-day CTR forecast using ML models.
  ///
  /// Sends the [campaignId] and [history] (30 days of CTR data) to the ML API
  /// which returns predictions with confidence intervals for the next 7 days.
  ///
  /// Returns a list of [ForecastPoint] objects.
  /// Throws [AppException] on network or ML service errors.
  Future<List<ForecastPoint>> getForecast({
    required String campaignId,
    required List<DailyMetric> history,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.forecastCtr,
        data: {
          'campaign_id': campaignId,
          'history': history.map((m) => m.toJson()).toList(),
          'horizon_days': 7,
        },
      );
      final list = _decode(response.data)['forecast'] as List<dynamic>;
      return list
          .map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch forecast');
    }
  }

  /// Detects anomalies in real-time campaign metrics.
  ///
  /// Sends a [snapshot] of current hourly metrics to the ML API which analyzes
  /// patterns to identify spend spikes, CTR drops, and other unusual behavior.
  ///
  /// Returns a list of detected [Anomaly] objects. Returns an empty list if
  /// no anomalies are found.
  /// Throws [AppException] on network or ML service errors.
  Future<List<Anomaly>> detectAnomalies({required Snapshot snapshot}) async {
    try {
      final response = await _dio.post(
        ApiConstants.anomalyDetect,
        data: {'snapshot': snapshot.toJson()},
      );
      final list = _decode(response.data)['anomalies'] as List<dynamic>;
      return list
          .map((e) => Anomaly.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to detect anomalies');
    }
  }
}
