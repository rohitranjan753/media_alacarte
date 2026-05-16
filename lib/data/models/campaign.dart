import 'package:equatable/equatable.dart';

class TargetAudience extends Equatable {
  const TargetAudience({
    this.ageRange,
    this.regions,
    this.interests,
  });

  final String? ageRange;
  final List<String>? regions;
  final List<String>? interests;

  factory TargetAudience.fromJson(Map<String, dynamic> json) => TargetAudience(
        ageRange: json['age_range'] as String?,
        regions: (json['regions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        interests: (json['interests'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'age_range': ageRange,
        'regions': regions,
        'interests': interests,
      };

  @override
  List<Object?> get props => [ageRange, regions, interests];
}

class Campaign extends Equatable {
  const Campaign({
    required this.id,
    required this.name,
    required this.status,
    required this.objective,
    required this.channel,
    required this.totalSpend,
    required this.budget,
    required this.impressions,
    required this.clicks,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.budgetUtilization,
    this.thumbnail,
    this.conversions,
    this.costPerClick,
    this.costPerConversion,
    this.dailyBudget,
    this.targetAudience,
  });

  final String id;
  final String name;
  final String status;
  final String objective;
  final String channel;
  final double totalSpend;
  final double budget;
  final int impressions;
  final int clicks;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final double budgetUtilization;
  final String? thumbnail;
  final int? conversions;
  final double? costPerClick;
  final double? costPerConversion;
  final double? dailyBudget;
  final TargetAudience? targetAudience;

  double get ctr =>
      impressions == 0 || clicks == 0 ? 0.0 : clicks / impressions * 100;

  double get conversionRate =>
      clicks == 0 || conversions == null ? 0.0 : (conversions! / clicks) * 100;

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        objective: (json['objective'] as String?) ?? '',
        channel: (json['channel'] as String?) ?? '',
        totalSpend: (json['spend'] as num).toDouble(),
        budget: (json['budget'] as num).toDouble(),
        impressions: (json['impressions'] as num).toInt(),
        clicks: (json['clicks'] as num).toInt(),
        startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
            DateTime.now(),
        endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ??
            DateTime.now(),
        currency: (json['currency'] as String?) ?? 'USD',
        budgetUtilization:
            (json['budget_utilization'] as num?)?.toDouble() ?? 0.0,
        thumbnail: json['thumbnail'] as String?,
        conversions: (json['conversions'] as num?)?.toInt(),
        costPerClick: (json['cost_per_click'] as num?)?.toDouble(),
        costPerConversion: (json['cost_per_conversion'] as num?)?.toDouble(),
        dailyBudget: (json['daily_budget'] as num?)?.toDouble(),
        targetAudience: json['target_audience'] != null
            ? TargetAudience.fromJson(
                json['target_audience'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'objective': objective,
        'channel': channel,
        'spend': totalSpend,
        'budget': budget,
        'impressions': impressions,
        'clicks': clicks,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'currency': currency,
        'budget_utilization': budgetUtilization,
        'thumbnail': thumbnail,
        'conversions': conversions,
        'cost_per_click': costPerClick,
        'cost_per_conversion': costPerConversion,
        'daily_budget': dailyBudget,
        'target_audience': targetAudience?.toJson(),
      };

  Campaign copyWith({
    String? id,
    String? name,
    String? status,
    String? objective,
    String? channel,
    double? totalSpend,
    double? budget,
    int? impressions,
    int? clicks,
    DateTime? startDate,
    DateTime? endDate,
    String? currency,
    double? budgetUtilization,
    String? thumbnail,
    int? conversions,
    double? costPerClick,
    double? costPerConversion,
    double? dailyBudget,
    TargetAudience? targetAudience,
  }) =>
      Campaign(
        id: id ?? this.id,
        name: name ?? this.name,
        status: status ?? this.status,
        objective: objective ?? this.objective,
        channel: channel ?? this.channel,
        totalSpend: totalSpend ?? this.totalSpend,
        budget: budget ?? this.budget,
        impressions: impressions ?? this.impressions,
        clicks: clicks ?? this.clicks,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        currency: currency ?? this.currency,
        budgetUtilization: budgetUtilization ?? this.budgetUtilization,
        thumbnail: thumbnail ?? this.thumbnail,
        conversions: conversions ?? this.conversions,
        costPerClick: costPerClick ?? this.costPerClick,
        costPerConversion: costPerConversion ?? this.costPerConversion,
        dailyBudget: dailyBudget ?? this.dailyBudget,
        targetAudience: targetAudience ?? this.targetAudience,
      );

  @override
  List<Object?> get props => [
        id, name, status, objective, channel,
        totalSpend, budget, impressions, clicks,
        startDate, endDate, currency, budgetUtilization, thumbnail,
        conversions, costPerClick, costPerConversion, dailyBudget, targetAudience,
      ];
}
