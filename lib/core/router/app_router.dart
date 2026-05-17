import 'package:flutter/material.dart';
import '../../presentation/anomaly_alerts/anomaly_alerts_screen.dart';
import '../../presentation/campaign_detail/campaign_detail_screen.dart';
import '../../presentation/campaign_list/campaign_list_screen.dart';
import '../../presentation/spend_summary/spend_summary_screen.dart';
import 'animated_page_route.dart';

/// Route name constants for navigation throughout the app.
///
/// Centralizes all route paths to ensure consistency and avoid typos.
///
/// **Usage:**
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.spendSummary);
/// Navigator.pushNamed(context, '${AppRoutes.campaignDetail}/$campaignId');
/// ```
abstract final class AppRoutes {
  /// Home screen route - Campaign list view.
  static const String campaignList = '/';

  /// Campaign detail route - Requires campaign ID parameter.
  ///
  /// Usage: `'${AppRoutes.campaignDetail}/$campaignId'`
  static const String campaignDetail = '/campaign';

  /// Spend summary analytics screen route.
  static const String spendSummary = '/spend-summary';

  /// Real-time anomaly alerts monitoring screen route.
  static const String anomalyAlerts = '/anomaly-alerts';
}

/// Generates routes for the app based on [RouteSettings].
///
/// This is the main navigation router that handles all route generation
/// and screen instantiation for the app.
///
/// **Supported Routes:**
/// - `/` - Campaign List Screen (home)
/// - `/campaign/:id` - Campaign Detail Screen (animated transition)
/// - `/spend-summary` - Spend Summary Screen
/// - `/anomaly-alerts` - Anomaly Alerts Screen
///
/// **Features:**
/// - Type-safe route generation
/// - Custom animated transitions for campaign details
/// - 404 fallback for unknown routes
/// - Automatic parameter extraction from route paths
///
/// **Usage:**
/// ```dart
/// MaterialApp(
///   onGenerateRoute: onGenerateRoute,
/// )
/// ```
///
/// **Parameters:**
/// - [settings]: Route settings containing the route name and arguments
///
/// **Returns:** A [Route] configured for the requested screen, or a 404 route
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
    // Use animated route for campaign detail
    return AnimatedPageRoute(
      page: CampaignDetailScreen(campaignId: id),
      routeSettings: settings,
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
