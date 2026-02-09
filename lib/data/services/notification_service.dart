import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification IDs for each prayer
  static const int fajrNotificationId = 1;
  static const int dhuhrNotificationId = 2;
  static const int asrNotificationId = 3;
  static const int maghribNotificationId = 4;
  static const int ishaNotificationId = 5;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );

      _initialized = true;
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true; // Permissions are not applicable for web

    bool granted = true;

    // Request Android permissions
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? androidGranted = await androidImplementation.requestNotificationsPermission();
      if (androidGranted == false) {
        granted = false;
      }
    }

    // Request iOS permissions
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final bool? iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosGranted == false) {
        granted = false;
      }
    }
    return granted;
  }

  Future<void> schedulePrayerNotifications({
    required String fajr,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (kIsWeb) return;

    // Cancel all existing notifications
    await cancelAllNotifications();

    // Schedule each prayer notification
    await _schedulePrayerNotification('Fajr', fajr, fajrNotificationId);
    await _schedulePrayerNotification('Dhuhr', dhuhr, dhuhrNotificationId);
    await _schedulePrayerNotification('Asr', asr, asrNotificationId);
    await _schedulePrayerNotification('Maghrib', maghrib, maghribNotificationId);
    await _schedulePrayerNotification('Isha', isha, ishaNotificationId);
  }

  Future<void> _schedulePrayerNotification(String prayerName, String timeString, int notificationId) async {
    if (kIsWeb) return;
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) return;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Custom sound for Azaan
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'azaan_channel',
        'Azaan Notifications',
        channelDescription: 'Notifications with Azaan sound',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        // In a real app, you would add a custom sound asset here
        // sound: RawResourceAndroidNotificationSound('azaan'),
        enableVibration: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        notificationId,
        'Azaan: $prayerName',
        'It\'s time for $prayerName prayer. Click to open.',
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: prayerName,
      );

      print('Scheduled Azaan for $prayerName at ${DateFormat('HH:mm').format(scheduledDate)}');
    } catch (e) {
      print('Error scheduling Azaan: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  Future<void> cancelPrayerNotification(int notificationId) async {
    if (kIsWeb) return;
    await _notifications.cancel(notificationId);
  }
}
