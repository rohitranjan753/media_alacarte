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
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory DailyMetric.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    final ctr = json['ctr'] as num?;

    if (dateStr == null) {
      throw const FormatException('Missing required field: date');
    }
    if (ctr == null) {
      throw const FormatException('Missing required field: ctr');
    }

    final date = DateTime.tryParse(dateStr);
    if (date == null) {
      throw FormatException('Invalid date format: $dateStr');
    }

    return DailyMetric(
      date: date,
      ctr: ctr.toDouble(),
    );
  }

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
