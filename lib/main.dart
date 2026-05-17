/// Entry point for the Media Alacarte Ad Campaign Performance Dashboard.
///
/// This file initializes all required services before launching the app:
/// - Hive for offline data caching
/// - Dependency injection container (GetIt)
/// - Local notification service
library;

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/campaign.g.dart';
import 'data/services/notification_service.dart';
import 'injection.dart';

/// Application entry point.
///
/// Initializes core services in the following order:
/// 1. Flutter engine binding
/// 2. Hive (offline caching) with Campaign and TargetAudience adapters
/// 3. Dependency injection (DI) container setup
/// 4. Local notification service initialization
/// 5. App launch
///
/// All async initialization must complete before the app starts.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline caching
  await Hive.initFlutter();
  Hive.registerAdapter(CampaignAdapter());
  Hive.registerAdapter(TargetAudienceAdapter());

  await setupDI();
  await sl<NotificationService>().init();
  runApp(const App());
}
