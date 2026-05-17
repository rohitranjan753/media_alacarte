import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/anomaly.dart';

/// Service for managing local push notifications.
///
/// Wraps [FlutterLocalNotificationsPlugin] to provide anomaly alert notifications.
/// Handles platform-specific initialization (Android & iOS), permission requests,
/// and notification display with proper channels and priorities.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _isEnabled = true;

  /// Whether notifications are currently enabled by user preference.
  bool get isEnabled => _isEnabled;

  /// Initializes the notification plugin with platform-specific settings.
  ///
  /// Sets up Android notification channels and iOS notification settings.
  /// Must be called before showing any notifications, typically in main().
  /// Does not request permissions on iOS initially - call [requestPermissions]
  /// when the user explicitly enables notifications.
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

  /// Requests notification permissions from the user.
  ///
  /// On iOS, shows the system permission dialog. On Android 13+, requests
  /// the POST_NOTIFICATIONS permission. Returns true if permission is granted
  /// or not required (older Android versions).
  ///
  /// Should be called when the user enables notifications in settings.
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

  /// Checks whether notifications are enabled at the system level.
  ///
  /// On Android, queries the system for notification permission status.
  /// On iOS, assumes enabled after initialization (actual permission checked on request).
  /// Returns true if notifications are allowed, false otherwise.
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

  /// Sets whether notifications should be shown.
  ///
  /// When set to false, [showAnomalyAlert] will return early without displaying
  /// notifications. Used to respect user preference from settings.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Displays a local notification for a detected anomaly.
  ///
  /// Shows a high-priority notification with the anomaly message. The notification
  /// title is determined by the anomaly type (spend spike, CTR drop, etc.).
  /// Uses a unique ID based on timestamp to avoid conflicts.
  ///
  /// Does nothing if notifications are disabled via [setEnabled].
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

  /// Generates a user-friendly notification title based on anomaly type.
  String _title(String type) => switch (type) {
        'spend_spike' => 'Spend Spike Detected',
        'ctr_drop' => 'CTR Drop Detected',
        _ => 'Anomaly Detected',
      };
}
