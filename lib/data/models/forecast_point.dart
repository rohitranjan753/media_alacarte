import 'package:equatable/equatable.dart';

class ForecastPoint extends Equatable {
  const ForecastPoint({
    required this.date,
    required this.predictedCtr,
    required this.lowerBound,
    required this.upperBound,
  });

  final DateTime date;
  final double predictedCtr;
  final double lowerBound;
  final double upperBound;

  factory ForecastPoint.fromJson(Map<String, dynamic> json) => ForecastPoint(
        date: DateTime.parse(json['date'] as String),
        predictedCtr: (json['predicted_ctr'] as num).toDouble(),
        lowerBound: (json['lower_bound'] as num).toDouble(),
        upperBound: (json['upper_bound'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'predicted_ctr': predictedCtr,
        'lower_bound': lowerBound,
        'upper_bound': upperBound,
      };

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
