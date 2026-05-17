import 'package:equatable/equatable.dart';

/// Represents real-time performance metrics for a single campaign over the last hour.
///
/// Contains recent hourly metrics used for anomaly detection. Part of a larger
/// [Snapshot] that aggregates all campaigns' live data.
class CampaignSnapshot extends Equatable {
  const CampaignSnapshot({
    required this.id,
    required this.impressionsLastHour,
    required this.clicksLastHour,
    required this.spendLastHour,
    required this.ctrLastHour,
  });

  /// Campaign ID.
  final String id;

  /// Number of impressions in the last hour.
  final int impressionsLastHour;

  /// Number of clicks in the last hour.
  final int clicksLastHour;

  /// Amount spent in the last hour.
  final double spendLastHour;

  /// CTR percentage for the last hour.
  final double ctrLastHour;

  /// Creates a [CampaignSnapshot] instance from JSON data.
  factory CampaignSnapshot.fromJson(Map<String, dynamic> json) =>
      CampaignSnapshot(
        id: json['id'] as String,
        impressionsLastHour:
            (json['impressions_last_hour'] as num).toInt(),
        clicksLastHour: (json['clicks_last_hour'] as num).toInt(),
        spendLastHour: (json['spend_last_hour'] as num).toDouble(),
        ctrLastHour: (json['ctr_last_hour'] as num).toDouble(),
      );

  /// Converts this [CampaignSnapshot] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'impressions_last_hour': impressionsLastHour,
        'clicks_last_hour': clicksLastHour,
        'spend_last_hour': spendLastHour,
        'ctr_last_hour': ctrLastHour,
      };

  /// Creates a copy of this [CampaignSnapshot] with the given fields replaced.
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

/// Represents a complete snapshot of real-time metrics across all campaigns.
///
/// Fetched periodically (every 30 seconds) from the live metrics endpoint.
/// Sent to the ML API for anomaly detection. Used in the anomaly alerts screen.
class Snapshot extends Equatable {
  const Snapshot({
    required this.timestamp,
    required this.campaigns,
  });

  /// Timestamp when this snapshot was captured.
  final DateTime timestamp;

  /// List of real-time metrics for each active campaign.
  final List<CampaignSnapshot> campaigns;

  /// Creates a [Snapshot] instance from JSON data.
  factory Snapshot.fromJson(Map<String, dynamic> json) => Snapshot(
        timestamp: DateTime.parse(json['timestamp'] as String),
        campaigns: (json['campaigns'] as List<dynamic>)
            .map((e) => CampaignSnapshot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts this [Snapshot] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'campaigns': campaigns.map((c) => c.toJson()).toList(),
      };

  /// Creates a copy of this [Snapshot] with the given fields replaced.
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
