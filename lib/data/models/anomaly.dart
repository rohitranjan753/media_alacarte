import 'package:equatable/equatable.dart';

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

  final String campaignId;
  final String type;
  final String severity;
  final String message;
  final DateTime detectedAt;
  final String? campaignName;
  final double? actualValue;
  final double? expectedValue;
  final double? changePercentage;

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
