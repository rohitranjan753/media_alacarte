import 'dart:convert';

import 'package:dio/dio.dart';
import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/snapshot.dart';
import '../models/summary.dart';
import '../../core/constants/api_constants.dart';

class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

Map<String, dynamic> _decode(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  return jsonDecode(data as String) as Map<String, dynamic>;
}

class AdsApiService {
  const AdsApiService(this._dio);

  final Dio _dio;

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

  Future<Campaign> getCampaign(String id) async {
    try {
      final response = await _dio.get(ApiConstants.campaign(id));
      return Campaign.fromJson(_decode(response.data)['campaign'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch campaign');
    }
  }

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

  Future<Snapshot> getLiveMetrics() async {
    try {
      final response = await _dio.get(ApiConstants.liveMetrics);
      return Snapshot.fromJson(_decode(response.data));
    } on DioException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch live metrics');
    }
  }
}
