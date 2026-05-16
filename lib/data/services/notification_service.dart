import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/anomaly.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,  // Don't request on init, request when user enables
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'anomaly_alerts',
      'Anomaly Alerts',
      description: 'Alerts for campaign anomalies',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    // Request iOS permissions
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );


    // Request Android 13+ permissions
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Return true if any platform granted permission or if null (older Android)
    return iosGranted ?? androidGranted ?? true;
  }

  Future<bool> areNotificationsEnabled() async {
    // Check Android notification status
    final androidEnabled = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    // For iOS, we assume enabled if we successfully initialized
    // (actual permission is checked when requesting)
    if (androidEnabled != null) {
      return androidEnabled;
    }

    // Default to true for iOS and older Android versions
    return true;
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> showAnomalyAlert({required Anomaly anomaly}) async {
    if (!_isEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'anomaly_alerts',
      'Anomaly Alerts',
      channelDescription: 'Alerts for campaign anomalies',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      anomaly.detectedAt.millisecondsSinceEpoch ~/ 1000,
      _title(anomaly.type),
      anomaly.message,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  String _title(String type) => switch (type) {
        'spend_spike' => 'Spend Spike Detected',
        'ctr_drop' => 'CTR Drop Detected',
        _ => 'Anomaly Detected',
      };
}
