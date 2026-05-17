import 'package:hive_flutter/hive_flutter.dart';
import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/snapshot.dart';
import '../models/summary.dart';
import '../services/ads_api_service.dart';

/// Repository for managing campaign data with offline caching capabilities.
///
/// Wraps [AdsApiService] and provides an additional caching layer using Hive.
/// When API calls fail (network errors), returns cached data if available.
/// This ensures the app can display stale data when offline rather than showing errors.
class CampaignRepository {
  CampaignRepository(this._service);

  final AdsApiService _service;
  static const String _campaignsCacheKey = 'campaigns_cache';
  Box<Campaign>? _campaignsBox;

  /// Initializes the Hive box for caching campaigns.
  ///
  /// Opens the box only once and reuses it for subsequent operations.
  Future<void> _initCacheBox() async {
    _campaignsBox ??= await Hive.openBox<Campaign>('campaigns');
  }

  /// Fetches the list of all campaigns with offline caching support.
  ///
  /// First attempts to fetch from the API. On success, caches the result and
  /// returns it with [isFromCache] = false. On failure (network error, timeout),
  /// attempts to return cached data with [isFromCache] = true.
  ///
  /// Throws the original exception if both API call and cache retrieval fail.
  Future<CampaignResult> getCampaigns() async {
    await _initCacheBox();

    try {
      // Try to fetch from API
      final campaigns = await _service.getCampaigns();

      // Cache the successful result
      await _saveCampaignsToCache(campaigns);

      return CampaignResult(campaigns: campaigns, isFromCache: false);
    } catch (e) {
      // On failure, try to return cached data
      final cachedCampaigns = _getCampaignsFromCache();

      if (cachedCampaigns.isNotEmpty) {
        return CampaignResult(campaigns: cachedCampaigns, isFromCache: true);
      }

      // No cache available, rethrow the error
      rethrow;
    }
  }

  /// Saves the list of campaigns to the Hive cache.
  ///
  /// Clears existing cache before writing new data to avoid stale entries.
  Future<void> _saveCampaignsToCache(List<Campaign> campaigns) async {
    if (_campaignsBox == null) return;

    await _campaignsBox!.clear();
    for (var i = 0; i < campaigns.length; i++) {
      await _campaignsBox!.put('campaign_$i', campaigns[i]);
    }
  }

  /// Retrieves campaigns from the Hive cache.
  ///
  /// Returns an empty list if cache is not initialized or empty.
  List<Campaign> _getCampaignsFromCache() {
    if (_campaignsBox == null || _campaignsBox!.isEmpty) {
      return [];
    }

    return _campaignsBox!.values.toList();
  }

  /// Clears all cached campaigns.
  ///
  /// Useful for forcing a fresh fetch or during logout.
  Future<void> clearCache() async {
    await _initCacheBox();
    await _campaignsBox?.clear();
  }

  /// Fetches detailed information for a single campaign by ID.
  ///
  /// Throws [AppException] on network or server errors.
  Future<Campaign> getCampaign(String id) => _service.getCampaign(id);

  /// Fetches 30-day historical CTR data for a campaign.
  ///
  /// Returns a list of [DailyMetric] objects for charting and ML forecasting.
  /// Throws [AppException] on errors.
  Future<List<DailyMetric>> getCampaignHistory(String id) =>
      _service.getCampaignHistory(id);

  /// Fetches aggregated summary data for a specified date range.
  ///
  /// [dateRange] should be one of: 'last7', 'last14', 'last30'.
  /// Returns [Summary] with total metrics and breakdowns by channel.
  /// Throws [AppException] on errors.
  Future<Summary> getSummary({required String dateRange}) =>
      _service.getSummary(dateRange: dateRange);

  /// Fetches real-time metrics snapshot for all active campaigns.
  ///
  /// Used for anomaly detection. Returns metrics from the last hour.
  /// Throws [AppException] on errors.
  Future<Snapshot> getLiveMetrics() => _service.getLiveMetrics();
}

/// Wrapper class indicating the source of campaign data (API vs cache).
///
/// Used by [CampaignRepository.getCampaigns] to inform the UI whether
/// displayed data is fresh or stale (cached). The UI can show indicators
/// like "Offline - showing cached data" when [isFromCache] is true.
class CampaignResult {
  const CampaignResult({
    required this.campaigns,
    required this.isFromCache,
  });

  /// The list of campaigns retrieved.
  final List<Campaign> campaigns;

  /// Whether this data came from the local cache (true) or fresh from API (false).
  final bool isFromCache;
}
