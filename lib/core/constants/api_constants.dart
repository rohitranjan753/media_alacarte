/// API endpoint constants for the Media Alacarte Ad Campaign Dashboard.
///
/// This class centralizes all API endpoint paths used throughout the app,
/// including both campaign management endpoints and ML service endpoints.
///
/// **Base URL:**
/// The Postman mock server base URL is configured as a constant. All endpoints
/// are relative to this base URL.
///
/// **Endpoint Categories:**
/// - **Campaign Endpoints**: CRUD operations for campaigns, summaries, and metrics
/// - **ML Endpoints**: Machine learning services for forecasting and anomaly detection
///
/// **Usage:**
/// ```dart
/// // In API services
/// final url = '${ApiConstants.baseUrl}${ApiConstants.campaigns}';
/// final detailUrl = '${ApiConstants.baseUrl}${ApiConstants.campaign(id)}';
/// ```
abstract final class ApiConstants {
  /// The base URL for all API requests.
  ///
  /// Points to the Postman mock server hosting the Ad Campaign API.
  static const String baseUrl =
      'https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1';

  // ============================================================================
  // CAMPAIGN ENDPOINTS
  // ============================================================================

  /// GET /campaigns - Fetches the list of all campaigns.
  static const String campaigns = '/campaigns';

  /// GET /campaigns/:id - Fetches details for a specific campaign.
  ///
  /// **Parameters:**
  /// - [id]: The campaign ID
  static String campaign(String id) => '/campaigns/$id';

  /// GET /campaigns/:id/history - Fetches 30-day CTR history for a campaign.
  ///
  /// Returns a list of daily metrics used for chart visualization.
  ///
  /// **Parameters:**
  /// - [id]: The campaign ID
  static String campaignHistory(String id) => '/campaigns/$id/history';

  /// GET /campaigns/summary - Fetches aggregated spend summary.
  ///
  /// Includes:
  /// - Total spend across all campaigns
  /// - Spend breakdown by channel (search, social, display)
  /// - Top performing campaigns
  /// - Date range: 7/14/30 days (query parameter)
  static const String summary = '/campaigns/summary';

  /// GET /campaigns/metrics/live - Fetches real-time snapshot of all campaigns.
  ///
  /// Returns last-hour metrics for anomaly detection.
  /// Polled every 30 seconds by the Anomaly Alerts screen.
  static const String liveMetrics = '/campaigns/metrics/live';

  // ============================================================================
  // ML (MACHINE LEARNING) ENDPOINTS
  // ============================================================================

  /// POST /forecast/ctr - Generates 7-day CTR forecast for a campaign.
  ///
  /// **Request body:**
  /// - campaign_id: Campaign identifier
  /// - history: Array of daily CTR metrics (30 days)
  /// - horizon_days: 7 (fixed)
  ///
  /// **Response:**
  /// List of forecast points with predicted CTR and confidence intervals
  static const String forecastCtr = '/forecast/ctr';

  /// POST /anomaly/detect - Detects performance anomalies in real-time metrics.
  ///
  /// **Request body:**
  /// - snapshot: Live metrics snapshot from all campaigns
  ///
  /// **Response:**
  /// List of detected anomalies (spend spikes, CTR drops) with severity levels
  static const String anomalyDetect = '/anomaly/detect';
}
