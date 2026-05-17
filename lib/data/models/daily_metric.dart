import 'package:equatable/equatable.dart';

/// Represents a single day's Click-Through Rate (CTR) metric for a campaign.
///
/// Used to track historical CTR performance over time. This data is displayed
/// in charts and used as input for ML forecasting models.
class DailyMetric extends Equatable {
  const DailyMetric({required this.date, required this.ctr});

  /// The date for this metric.
  final DateTime date;

  /// Click-Through Rate as a percentage for this date.
  final double ctr;

  /// Creates a [DailyMetric] instance from JSON data.
  ///
  /// Expects a map with keys: 'date' (ISO 8601 string), 'ctr' (number).
  factory DailyMetric.fromJson(Map<String, dynamic> json) => DailyMetric(
        date: DateTime.parse(json['date'] as String),
        ctr: (json['ctr'] as num).toDouble(),
      );

  /// Converts this [DailyMetric] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'ctr': ctr,
      };

  /// Creates a copy of this [DailyMetric] with the given fields replaced.
  DailyMetric copyWith({DateTime? date, double? ctr}) => DailyMetric(
        date: date ?? this.date,
        ctr: ctr ?? this.ctr,
      );

  @override
  List<Object?> get props => [date, ctr];
}
