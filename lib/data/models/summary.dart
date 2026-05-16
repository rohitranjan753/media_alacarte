import 'package:equatable/equatable.dart';

class ChannelSpend extends Equatable {
  const ChannelSpend({
    required this.channel,
    required this.spend,
    required this.impressions,
    required this.clicks,
  });

  final String channel;
  final double spend;
  final int impressions;
  final int clicks;

  factory ChannelSpend.fromJson(Map<String, dynamic> json) => ChannelSpend(
        channel: json['channel'] as String,
        spend: (json['spend'] as num).toDouble(),
        impressions: (json['impressions'] as num).toInt(),
        clicks: (json['clicks'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'spend': spend,
        'impressions': impressions,
        'clicks': clicks,
      };

  @override
  List<Object?> get props => [channel, spend, impressions, clicks];
}

class TopCampaign extends Equatable {
  const TopCampaign({
    required this.id,
    required this.name,
    required this.ctr,
    required this.spend,
  });

  final String id;
  final String name;
  // Stored as percentage (0.048 ratio → 4.8)
  final double ctr;
  final double spend;

  factory TopCampaign.fromJson(Map<String, dynamic> json) => TopCampaign(
        id: json['id'] as String,
        name: json['name'] as String,
        ctr: (json['ctr'] as num).toDouble() * 100,
        spend: (json['spend'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ctr': ctr / 100,
        'spend': spend,
      };

  @override
  List<Object?> get props => [id, name, ctr, spend];
}

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

  final double totalSpend;
  final int totalImpressions;
  final int totalClicks;
  final double overallCtr;
  final List<ChannelSpend> byChannel;
  final String dateRange;
  final List<TopCampaign> topCampaigns;

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

  Map<String, dynamic> toJson() => {
        'total_spend': totalSpend,
        'total_impressions': totalImpressions,
        'total_clicks': totalClicks,
        'overall_ctr': overallCtr,
        'by_channel': byChannel.map((c) => c.toJson()).toList(),
        'date_range': dateRange,
        'top_campaigns': topCampaigns.map((c) => c.toJson()).toList(),
      };

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
