import 'package:flutter/material.dart';
import '../../presentation/anomaly_alerts/anomaly_alerts_screen.dart';
import '../../presentation/campaign_detail/campaign_detail_screen.dart';
import '../../presentation/campaign_list/campaign_list_screen.dart';
import '../../presentation/spend_summary/spend_summary_screen.dart';

abstract final class AppRoutes {
  static const String campaignList = '/';
  static const String campaignDetail = '/campaign';
  static const String spendSummary = '/spend-summary';
  static const String anomalyAlerts = '/anomaly-alerts';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? '';

  if (name == AppRoutes.campaignList) {
    return MaterialPageRoute(
      builder: (_) => const CampaignListScreen(),
      settings: settings,
    );
  }

  if (name.startsWith('${AppRoutes.campaignDetail}/')) {
    final id = name.substring('${AppRoutes.campaignDetail}/'.length);
    return MaterialPageRoute(
      builder: (_) => CampaignDetailScreen(campaignId: id),
      settings: settings,
    );
  }

  if (name == AppRoutes.spendSummary) {
    return MaterialPageRoute(
      builder: (_) => const SpendSummaryScreen(),
      settings: settings,
    );
  }

  if (name == AppRoutes.anomalyAlerts) {
    return MaterialPageRoute(
      builder: (_) => const AnomalyAlertsScreen(),
      settings: settings,
    );
  }

  return MaterialPageRoute(
    builder: (_) => const Scaffold(
      body: Center(child: Text('404 — Route not found')),
    ),
  );
}
