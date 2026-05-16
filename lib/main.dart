import 'package:flutter/material.dart';
import 'app.dart';
import 'data/services/notification_service.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  await sl<NotificationService>().init();
  runApp(const App());
}
