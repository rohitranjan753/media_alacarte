import 'package:equatable/equatable.dart';

/// Represents the target audience configuration for a campaign.
///
/// Defines demographic and interest-based targeting parameters including
/// age ranges, geographic regions, and interest categories.
class TargetAudience extends Equatable {
  const TargetAudience({
    this.ageRange,
    this.regions,
    this.interests,
  });

  /// Age range for the target audience (e.g., "18-24", "25-34").
  final String? ageRange;

  /// Geographic regions where the campaign should be shown.
  final List<String>? regions;

  /// Interest categories for targeting (e.g., "sports", "technology").
  final List<String>? interests;

  /// Creates a [TargetAudience] instance from JSON data.
  ///
  /// Expects a map with optional keys: 'age_range', 'regions', 'interests'.
  factory TargetAudience.fromJson(Map<String, dynamic> json) => TargetAudience(
        ageRange: json['age_range'] as String?,
        regions: (json['regions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        interests: (json['interests'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  /// Converts this [TargetAudience] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'age_range': ageRange,
        'regions': regions,
        'interests': interests,
      };

  @override
  List<Object?> get props => [ageRange, regions, interests];
}

/// Represents an advertising campaign with its performance metrics and configuration.
///
/// Contains all essential campaign data including budget, spend, performance metrics
/// (impressions, clicks, CTR), status, and targeting information. This is the primary
/// data model used throughout the application for displaying and analyzing campaigns.
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

  /// Unique identifier for the campaign.
  final String id;

  /// Display name of the campaign.
  final String name;

  /// Current status: 'active', 'paused', or 'ended'.
  final String status;

  /// Campaign objective (e.g., "brand_awareness", "conversions").
  final String objective;

  /// Advertising channel (e.g., "Search", "Social", "Display").
  final String channel;

  /// Total amount spent on the campaign to date.
  final double totalSpend;

  /// Total allocated budget for the campaign.
  final double budget;

  /// Total number of ad impressions delivered.
  final int impressions;

  /// Total number of clicks received.
  final int clicks;

  /// Campaign start date.
  final DateTime startDate;

  /// Campaign end date.
  final DateTime endDate;

  /// Currency code (e.g., "USD", "EUR").
  final String currency;

  /// Percentage of budget utilized (0.0 to 1.0).
  final double budgetUtilization;

  /// Optional URL to campaign thumbnail image.
  final String? thumbnail;

  /// Total number of conversions tracked.
  final int? conversions;

  /// Average cost per click.
  final double? costPerClick;

  /// Average cost per conversion.
  final double? costPerConversion;

  /// Daily budget limit.
  final double? dailyBudget;

  /// Target audience configuration.
  final TargetAudience? targetAudience;

  /// Calculates the Click-Through Rate (CTR) as a percentage.
  ///
  /// Returns the ratio of clicks to impressions multiplied by 100.
  /// Returns 0.0 if impressions or clicks are zero to avoid division by zero.
  double get ctr =>
      impressions == 0 || clicks == 0 ? 0.0 : clicks / impressions * 100;

  /// Calculates the conversion rate as a percentage.
  ///
  /// Returns the ratio of conversions to clicks multiplied by 100.
  /// Returns 0.0 if clicks are zero or conversions are null.
  double get conversionRate =>
      clicks == 0 || conversions == null ? 0.0 : (conversions! / clicks) * 100;

  /// Creates a [Campaign] instance from JSON data.
  ///
  /// Parses API response data into a Campaign object. Handles missing or null
  /// values with sensible defaults. Date parsing failures default to current time.
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

  /// Converts this [Campaign] instance to a JSON map.
  ///
  /// Serializes all campaign data for API requests or local storage.
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

  /// Creates a copy of this [Campaign] with the given fields replaced.
  ///
  /// Returns a new Campaign instance with updated values while preserving
  /// unchanged fields from the original instance.
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
