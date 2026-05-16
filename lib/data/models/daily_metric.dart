import 'package:equatable/equatable.dart';

class DailyMetric extends Equatable {
  const DailyMetric({required this.date, required this.ctr});

  final DateTime date;
  final double ctr;

  factory DailyMetric.fromJson(Map<String, dynamic> json) => DailyMetric(
        date: DateTime.parse(json['date'] as String),
        ctr: (json['ctr'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'ctr': ctr,
      };

  DailyMetric copyWith({DateTime? date, double? ctr}) => DailyMetric(
        date: date ?? this.date,
        ctr: ctr ?? this.ctr,
      );

  @override
  List<Object?> get props => [date, ctr];
}
