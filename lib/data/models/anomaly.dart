import 'package:equatable/equatable.dart';

/// Represents a detected anomaly in campaign performance metrics.
///
/// Anomalies are identified by the ML API and include spend spikes or CTR drops.
/// Each anomaly contains context about what was detected, its severity, and
/// recommended actions. These are displayed in the Anomaly Alerts screen and
/// trigger local notifications.
class Anomaly extends Equatable {
  const Anomaly({
    required this.campaignId,
    required this.type,
    required this.severity,
    required this.message,
    required this.detectedAt,
    this.campaignName,
    this.actualValue,
    this.expectedValue,
    this.changePercentage,
  });

  /// ID of the campaign where the anomaly was detected.
  final String campaignId;

  /// Type of anomaly: 'spend_spike' or 'ctr_drop'.
  final String type;

  /// Severity level: 'low', 'medium', or 'high'.
  final String severity;

  /// Human-readable description of the anomaly.
  final String message;

  /// Timestamp when the anomaly was detected.
  final DateTime detectedAt;

  /// Optional name of the affected campaign.
  final String? campaignName;

  /// The actual observed value that triggered the anomaly.
  final double? actualValue;

  /// The expected baseline value for comparison.
  final double? expectedValue;

  /// Percentage change from expected to actual value.
  final double? changePercentage;

  /// Creates an [Anomaly] instance from JSON data.
  ///
  /// Parses anomaly data from the ML API response.
  factory Anomaly.fromJson(Map<String, dynamic> json) => Anomaly(
        campaignId: json['campaign_id'] as String,
        type: json['type'] as String,
        severity: json['severity'] as String,
        message: json['message'] as String,
        detectedAt: DateTime.parse(json['detected_at'] as String),
        campaignName: json['campaign_name'] as String?,
        actualValue: (json['actual_value'] as num?)?.toDouble(),
        expectedValue: (json['expected_value'] as num?)?.toDouble(),
        changePercentage: (json['change_percentage'] as num?)?.toDouble(),
      );

  /// Converts this [Anomaly] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'campaign_id': campaignId,
        'type': type,
        'severity': severity,
        'message': message,
        'detected_at': detectedAt.toIso8601String(),
        if (campaignName != null) 'campaign_name': campaignName,
        if (actualValue != null) 'actual_value': actualValue,
        if (expectedValue != null) 'expected_value': expectedValue,
        if (changePercentage != null) 'change_percentage': changePercentage,
      };

  /// Creates a copy of this [Anomaly] with the given fields replaced.
  Anomaly copyWith({
    String? campaignId,
    String? type,
    String? severity,
    String? message,
    DateTime? detectedAt,
    String? campaignName,
    double? actualValue,
    double? expectedValue,
    double? changePercentage,
  }) =>
      Anomaly(
        campaignId: campaignId ?? this.campaignId,
        type: type ?? this.type,
        severity: severity ?? this.severity,
        message: message ?? this.message,
        detectedAt: detectedAt ?? this.detectedAt,
        campaignName: campaignName ?? this.campaignName,
        actualValue: actualValue ?? this.actualValue,
        expectedValue: expectedValue ?? this.expectedValue,
        changePercentage: changePercentage ?? this.changePercentage,
      );

  @override
  List<Object?> get props => [
        campaignId,
        type,
        severity,
        message,
        detectedAt,
        campaignName,
        actualValue,
        expectedValue,
        changePercentage,
      ];
}
