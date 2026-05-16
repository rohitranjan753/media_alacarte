import 'package:hive_flutter/hive_flutter.dart';
import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/snapshot.dart';
import '../models/summary.dart';
import '../services/ads_api_service.dart';

class CampaignRepository {
  CampaignRepository(this._service);

  final AdsApiService _service;
  static const String _campaignsCacheKey = 'campaigns_cache';
  Box<Campaign>? _campaignsBox;

  /// Initialize the Hive box for caching campaigns
  Future<void> _initCacheBox() async {
    _campaignsBox ??= await Hive.openBox<Campaign>('campaigns');
  }

  /// Get campaigns with offline caching support
  /// Returns cached data if API call fails
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

  /// Save campaigns to Hive cache
  Future<void> _saveCampaignsToCache(List<Campaign> campaigns) async {
    if (_campaignsBox == null) return;

    await _campaignsBox!.clear();
    for (var i = 0; i < campaigns.length; i++) {
      await _campaignsBox!.put('campaign_$i', campaigns[i]);
    }
  }

  /// Retrieve campaigns from Hive cache
  List<Campaign> _getCampaignsFromCache() {
    if (_campaignsBox == null || _campaignsBox!.isEmpty) {
      return [];
    }

    return _campaignsBox!.values.toList();
  }

  /// Clear the campaigns cache
  Future<void> clearCache() async {
    await _initCacheBox();
    await _campaignsBox?.clear();
  }

  Future<Campaign> getCampaign(String id) => _service.getCampaign(id);

  Future<List<DailyMetric>> getCampaignHistory(String id) =>
      _service.getCampaignHistory(id);

  Future<Summary> getSummary({required String dateRange}) =>
      _service.getSummary(dateRange: dateRange);

  Future<Snapshot> getLiveMetrics() => _service.getLiveMetrics();
}

/// Result wrapper that indicates whether data came from cache
class CampaignResult {
  const CampaignResult({
    required this.campaigns,
    required this.isFromCache,
  });

  final List<Campaign> campaigns;
  final bool isFromCache;
}
