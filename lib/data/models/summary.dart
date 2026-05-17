import 'package:equatable/equatable.dart';

/// Represents spending and performance metrics for a single advertising channel.
///
/// Used within the spend summary screen to show breakdowns by channel
/// (e.g., Search, Social, Display) for donut chart visualization.
class ChannelSpend extends Equatable {
  const ChannelSpend({
    required this.channel,
    required this.spend,
    required this.impressions,
    required this.clicks,
  });

  /// Channel name (e.g., "Search", "Social", "Display").
  final String channel;

  /// Total spend for this channel.
  final double spend;

  /// Total impressions for this channel.
  final int impressions;

  /// Total clicks for this channel.
  final int clicks;

  /// Creates a [ChannelSpend] instance from JSON data.
  factory ChannelSpend.fromJson(Map<String, dynamic> json) => ChannelSpend(
        channel: json['channel'] as String,
        spend: (json['spend'] as num).toDouble(),
        impressions: (json['impressions'] as num).toInt(),
        clicks: (json['clicks'] as num).toInt(),
      );

  /// Converts this [ChannelSpend] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'channel': channel,
        'spend': spend,
        'impressions': impressions,
        'clicks': clicks,
      };

  @override
  List<Object?> get props => [channel, spend, impressions, clicks];
}

/// Represents a top-performing campaign with key metrics.
///
/// Used in the spend summary screen to display ranked lists of best-performing
/// campaigns based on CTR and spend.
class TopCampaign extends Equatable {
  const TopCampaign({
    required this.id,
    required this.name,
    required this.ctr,
    required this.spend,
  });

  /// Campaign ID.
  final String id;

  /// Campaign name.
  final String name;

  /// Click-Through Rate stored as percentage (API ratio 0.048 → 4.8%).
  final double ctr;

  /// Total spend for this campaign.
  final double spend;

  /// Creates a [TopCampaign] instance from JSON data.
  ///
  /// Converts CTR from ratio (0-1) to percentage (0-100) during parsing.
  factory TopCampaign.fromJson(Map<String, dynamic> json) => TopCampaign(
        id: json['id'] as String,
        name: json['name'] as String,
        ctr: (json['ctr'] as num).toDouble() * 100,
        spend: (json['spend'] as num).toDouble(),
      );

  /// Converts this [TopCampaign] instance to a JSON map.
  ///
  /// Converts CTR from percentage back to ratio format for API compatibility.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ctr': ctr / 100,
        'spend': spend,
      };

  @override
  List<Object?> get props => [id, name, ctr, spend];
}

/// Represents aggregated campaign performance summary across a date range.
///
/// Contains overall metrics (total spend, impressions, clicks, CTR) along with
/// breakdowns by channel and rankings of top campaigns. Displayed in the
/// spend summary screen with KPI cards and donut charts.
class Summary extends Equatable {
  const Summary({
    required this.totalSpend,
    required this.totalImpressions,
    required this.totalClicks,
    required this.overallCtr,
    required this.byChannel,
    required this.dateRange,
    required this.topCampaigns,
  });

  /// Total spend across all campaigns in the date range.
  final double totalSpend;

  /// Total impressions across all campaigns.
  final int totalImpressions;

  /// Total clicks across all campaigns.
  final int totalClicks;

  /// Overall CTR percentage across all campaigns.
  final double overallCtr;

  /// Spend breakdown by advertising channel.
  final List<ChannelSpend> byChannel;

  /// Date range for this summary (e.g., "last7", "last30").
  final String dateRange;

  /// List of top-performing campaigns ranked by performance.
  final List<TopCampaign> topCampaigns;

  /// Creates a [Summary] instance from JSON data.
  ///
  /// Parses the summary API response with safe defaults for optional fields.
  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        totalSpend: (json['total_spend'] as num).toDouble(),
        totalImpressions:
            (json['total_impressions'] as num?)?.toInt() ?? 0,
        totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
        overallCtr: (json['overall_ctr'] as num?)?.toDouble() ?? 0.0,
        byChannel: (json['by_channel'] as List<dynamic>)
            .map((e) => ChannelSpend.fromJson(e as Map<String, dynamic>))
            .toList(),
        dateRange: (json['date_range'] as String?) ?? '',
        topCampaigns: (json['top_campaigns'] as List<dynamic>)
            .map((e) => TopCampaign.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts this [Summary] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'total_spend': totalSpend,
        'total_impressions': totalImpressions,
        'total_clicks': totalClicks,
        'overall_ctr': overallCtr,
        'by_channel': byChannel.map((c) => c.toJson()).toList(),
        'date_range': dateRange,
        'top_campaigns': topCampaigns.map((c) => c.toJson()).toList(),
      };

  /// Creates a copy of this [Summary] with the given fields replaced.
  Summary copyWith({
    double? totalSpend,
    int? totalImpressions,
    int? totalClicks,
    double? overallCtr,
    List<ChannelSpend>? byChannel,
    String? dateRange,
    List<TopCampaign>? topCampaigns,
  }) =>
      Summary(
        totalSpend: totalSpend ?? this.totalSpend,
        totalImpressions: totalImpressions ?? this.totalImpressions,
        totalClicks: totalClicks ?? this.totalClicks,
        overallCtr: overallCtr ?? this.overallCtr,
        byChannel: byChannel ?? this.byChannel,
        dateRange: dateRange ?? this.dateRange,
        topCampaigns: topCampaigns ?? this.topCampaigns,
      );

  @override
  List<Object?> get props => [
        totalSpend, totalImpressions, totalClicks, overallCtr,
        byChannel, dateRange, topCampaigns,
      ];
}
