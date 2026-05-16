abstract final class ApiConstants {
  static const String baseUrl =
      'https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1';

  // Campaigns
  static const String campaigns = '/campaigns';
  static String campaign(String id) => '/campaigns/$id';
  static String campaignHistory(String id) => '/campaigns/$id/history';
  static const String summary = '/campaigns/summary';
  static const String liveMetrics = '/campaigns/metrics/live';

  // ML
  static const String forecastCtr = '/forecast/ctr';
  static const String anomalyDetect = '/anomaly/detect';
}
