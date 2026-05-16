import '../models/campaign.dart';
import '../models/daily_metric.dart';
import '../models/snapshot.dart';
import '../models/summary.dart';
import '../services/ads_api_service.dart';

class CampaignRepository {
  const CampaignRepository(this._service);

  final AdsApiService _service;

  Future<List<Campaign>> getCampaigns() => _service.getCampaigns();

  Future<Campaign> getCampaign(String id) => _service.getCampaign(id);

  Future<List<DailyMetric>> getCampaignHistory(String id) =>
      _service.getCampaignHistory(id);

  Future<Summary> getSummary({required String dateRange}) =>
      _service.getSummary(dateRange: dateRange);

  Future<Snapshot> getLiveMetrics() => _service.getLiveMetrics();
}
