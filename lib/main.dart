import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/campaign.g.dart';
import 'data/services/notification_service.dart';
import 'injection.dart';

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
