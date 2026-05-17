import 'package:equatable/equatable.dart';

/// Represents a single ML-generated CTR forecast point with confidence bounds.
///
/// Contains predicted CTR value along with upper and lower confidence bounds
/// for uncertainty visualization. Used to display 7-day ahead forecasts on
/// campaign detail charts.
class ForecastPoint extends Equatable {
  const ForecastPoint({
    required this.date,
    required this.predictedCtr,
    required this.lowerBound,
    required this.upperBound,
  });

  /// The future date for this forecast.
  final DateTime date;

  /// The predicted CTR value as a percentage.
  final double predictedCtr;

  /// The lower bound of the prediction confidence interval.
  final double lowerBound;

  /// The upper bound of the prediction confidence interval.
  final double upperBound;

  /// Creates a [ForecastPoint] instance from JSON data.
  ///
  /// Expects a map with keys: 'date', 'predicted_ctr', 'lower_bound', 'upper_bound'.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String?;
    final predictedCtr = json['predicted_ctr'] as num?;
    final lowerBound = json['lower_bound'] as num?;
    final upperBound = json['upper_bound'] as num?;

    if (dateStr == null || predictedCtr == null ||
        lowerBound == null || upperBound == null) {
      throw const FormatException('Missing required fields in ForecastPoint');
    }

    final date = DateTime.tryParse(dateStr);
    if (date == null) {
      throw FormatException('Invalid date format: $dateStr');
    }

    return ForecastPoint(
      date: date,
      predictedCtr: predictedCtr.toDouble(),
      lowerBound: lowerBound.toDouble(),
      upperBound: upperBound.toDouble(),
    );
  }

  /// Converts this [ForecastPoint] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'predicted_ctr': predictedCtr,
        'lower_bound': lowerBound,
        'upper_bound': upperBound,
      };

  /// Creates a copy of this [ForecastPoint] with the given fields replaced.
  ForecastPoint copyWith({
    DateTime? date,
    double? predictedCtr,
    double? lowerBound,
    double? upperBound,
  }) =>
      ForecastPoint(
        date: date ?? this.date,
        predictedCtr: predictedCtr ?? this.predictedCtr,
        lowerBound: lowerBound ?? this.lowerBound,
        upperBound: upperBound ?? this.upperBound,
      );

  @override
  List<Object?> get props => [date, predictedCtr, lowerBound, upperBound];
}
