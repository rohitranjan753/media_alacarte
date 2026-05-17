import 'dart:convert';

import 'package:dio/dio.dart';
import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/snapshot.dart';
import '../models/summary.dart';
import '../../core/constants/api_constants.dart';

/// Custom exception thrown by API services when requests fail.
///
/// Wraps [DioException] and other errors with user-friendly messages.
class AppException implements Exception {
  const AppException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _decode(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return jsonDecode(data as String) as Map<String, dynamic>;
}

/// Service for communicating with the Ads Performance API.
///
/// Handles all HTTP requests to the campaign management backend. Uses Dio
/// for HTTP communication with automatic timeout and logging. All methods
/// wrap errors in [AppException] for consistent error handling.
class AdsApiService {
  const AdsApiService(this._dio);

  final Dio _dio;

  /// Fetches the complete list of advertising campaigns.
  ///
  /// Returns a list of [Campaign] objects with all metrics and metadata.
  /// Throws [AppException] if the network request fails or response is invalid.
  Future<List<Campaign>> getCampaigns() async {
    try {
      final response = await _dio.get(ApiConstants.campaigns);
      final body = _decode(response.data);
      final list = body['campaigns'] as List<dynamic>;
      return list
          .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch campaigns');
    }
  }

  /// Fetches detailed information for a specific campaign.
  ///
  /// [id] is the unique campaign identifier.
  /// Returns a [Campaign] object with full details.
  /// Throws [AppException] on errors.
  Future<Campaign> getCampaign(String id) async {
    try {
      final response = await _dio.get(ApiConstants.campaign(id));
      return Campaign.fromJson(_decode(response.data)['campaign'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch campaign');
    }
  }

  /// Fetches 30-day historical CTR data for a campaign.
  ///
  /// [id] is the campaign identifier.
  /// Returns a chronological list of [DailyMetric] objects.
  /// Used for charting and ML forecast input.
  /// Throws [AppException] on errors.
  Future<List<DailyMetric>> getCampaignHistory(String id) async {
    try {
      final response = await _dio.get(ApiConstants.campaignHistory(id));
      final list = _decode(response.data)['history'] as List<dynamic>;
      return list
          .map((e) => DailyMetric.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch campaign history');
    }
  }

  /// Fetches aggregated campaign performance summary.
  ///
  /// [dateRange] should be 'last7', 'last14', or 'last30' to specify the
  /// time period for aggregation.
  /// Returns a [Summary] with total metrics and channel breakdowns.
  /// Throws [AppException] on errors.
  Future<Summary> getSummary({required String dateRange}) async {
    try {
      final response = await _dio.get(
        ApiConstants.summary,
        queryParameters: {'range': dateRange},
      );
      return Summary.fromJson(_decode(response.data)['summary'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch summary');
    }
  }

  /// Fetches real-time performance metrics for all active campaigns.
  ///
  /// Returns a [Snapshot] containing last-hour metrics for each campaign.
  /// Used for real-time anomaly detection. Polled every 30 seconds.
  /// Throws [AppException] on errors.
  Future<Snapshot> getLiveMetrics() async {
    try {
      final response = await _dio.get(ApiConstants.liveMetrics);
      return Snapshot.fromJson(_decode(response.data));
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch live metrics');
    }
  }
}
