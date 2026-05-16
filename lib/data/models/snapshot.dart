import 'package:equatable/equatable.dart';

class CampaignSnapshot extends Equatable {
  const CampaignSnapshot({
    required this.id,
    required this.impressionsLastHour,
    required this.clicksLastHour,
    required this.spendLastHour,
    required this.ctrLastHour,
  });

  final String id;
  final int impressionsLastHour;
  final int clicksLastHour;
  final double spendLastHour;
  final double ctrLastHour;

  factory CampaignSnapshot.fromJson(Map<String, dynamic> json) =>
      CampaignSnapshot(
        id: json['id'] as String,
        impressionsLastHour:
            (json['impressions_last_hour'] as num).toInt(),
        clicksLastHour: (json['clicks_last_hour'] as num).toInt(),
        spendLastHour: (json['spend_last_hour'] as num).toDouble(),
        ctrLastHour: (json['ctr_last_hour'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'impressions_last_hour': impressionsLastHour,
        'clicks_last_hour': clicksLastHour,
        'spend_last_hour': spendLastHour,
        'ctr_last_hour': ctrLastHour,
      };

  CampaignSnapshot copyWith({
    String? id,
    int? impressionsLastHour,
    int? clicksLastHour,
    double? spendLastHour,
    double? ctrLastHour,
  }) =>
      CampaignSnapshot(
        id: id ?? this.id,
        impressionsLastHour: impressionsLastHour ?? this.impressionsLastHour,
        clicksLastHour: clicksLastHour ?? this.clicksLastHour,
        spendLastHour: spendLastHour ?? this.spendLastHour,
        ctrLastHour: ctrLastHour ?? this.ctrLastHour,
      );

  @override
  List<Object?> get props =>
      [id, impressionsLastHour, clicksLastHour, spendLastHour, ctrLastHour];
}

class Snapshot extends Equatable {
  const Snapshot({
    required this.timestamp,
    required this.campaigns,
  });

  final DateTime timestamp;
  final List<CampaignSnapshot> campaigns;

  factory Snapshot.fromJson(Map<String, dynamic> json) => Snapshot(
        timestamp: DateTime.parse(json['timestamp'] as String),
        campaigns: (json['campaigns'] as List<dynamic>)
            .map((e) => CampaignSnapshot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'campaigns': campaigns.map((c) => c.toJson()).toList(),
      };

  Snapshot copyWith({
    DateTime? timestamp,
    List<CampaignSnapshot>? campaigns,
  }) =>
      Snapshot(
        timestamp: timestamp ?? this.timestamp,
        campaigns: campaigns ?? this.campaigns,
      );

  @override
  List<Object?> get props => [timestamp, campaigns];
}
