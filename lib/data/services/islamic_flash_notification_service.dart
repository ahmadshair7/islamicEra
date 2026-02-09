import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/islamic_flash.dart';
import 'islamic_flash_service.dart';
import 'islamic_flash_settings_service.dart';

/// Islamic Flash Notification Service
/// Handles scheduling and managing Islamic flash notifications
class IslamicFlashNotificationService {
  static final IslamicFlashNotificationService _instance = IslamicFlashNotificationService._internal();
  factory IslamicFlashNotificationService() => _instance;
  IslamicFlashNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final IslamicFlashService _flashService = IslamicFlashService();
  final IslamicFlashSettingsService _settingsService = IslamicFlashSettingsService();
  
  bool _initialized = false;
  final Random _random = Random();

  // Notification IDs
  static const int dailyFlashNotificationId = 100;
  static const int fridayFlashNotificationId = 101;

  // Notification channel
  static const String channelId = 'islamic_flash_channel';
  static const String channelName = 'Islamic Reminders';
  static const String channelDescription = 'Daily Islamic reminders and inspirations';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

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
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Initialize flash service
      await _flashService.initialize();
      await _settingsService.initialize();

      _initialized = true;
    } catch (e) {
      print('Error initializing IslamicFlashNotificationService: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('Islamic Flash notification tapped: ${response.payload}');
    // Could navigate to a specific screen here
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    bool granted = true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final bool? androidGranted = await androidImplementation.requestNotificationsPermission();
      if (androidGranted == false) {
        granted = false;
      }
    }

    return granted;
  }

  /// Schedule daily Islamic flash notification
  Future<void> scheduleDailyNotification() async {
    if (!_initialized) await initialize();
    if (kIsWeb) return;

    final isEnabled = await _settingsService.isNotificationsEnabled();
    if (!isEnabled) {
      await cancelDailyNotification();
      return;
    }

    try {
      // Get a random flash for the notification
      final flash = _flashService.getRandomFlash();
      if (flash == null) return;

      // Get scheduled time
      final hour = await _settingsService.getNotificationHour();
      int minute = await _settingsService.getNotificationMinute();

      // If random time is enabled, randomize within the day
      final isRandomTime = await _settingsService.isRandomTimeEnabled();
      int scheduledHour = hour;
      if (isRandomTime) {
        scheduledHour = 7 + _random.nextInt(14); // Between 7 AM and 9 PM
        minute = _random.nextInt(60);
      }

      // Calculate next scheduled time
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, scheduledHour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Build notification content
      final String title = '🌙 ${flash.typeDisplayName}';
      final String body = _buildNotificationBody(flash);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        dailyFlashNotificationId,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: flash.id,
      );

      print('Scheduled Islamic Flash notification for ${scheduledDate.hour}:${scheduledDate.minute}');
    } catch (e) {
      print('Error scheduling daily notification: $e');
    }
  }

  /// Schedule Friday-specific notification
  Future<void> scheduleFridayNotification() async {
    if (!_initialized) await initialize();
    if (kIsWeb) return;

    final isEnabled = await _settingsService.isNotificationsEnabled();
    final isFridayOnly = await _settingsService.isFridayOnlyEnabled();

    if (!isEnabled) {
      await cancelFridayNotification();
      return;
    }

    try {
      final flash = _flashService.getFridayFlash();
      if (flash == null) return;

      // Schedule for Friday at 12:00 PM (before Jumu'ah)
      final now = DateTime.now();
      var fridayDate = _getNextFriday(now);
      fridayDate = DateTime(fridayDate.year, fridayDate.month, fridayDate.day, 12, 0);

      if (fridayDate.isBefore(now)) {
        fridayDate = fridayDate.add(const Duration(days: 7));
      }

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(fridayDate, tz.local);

      const String title = '🕌 Jumu\'ah Mubarak';
      final String body = _buildNotificationBody(flash);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.zonedSchedule(
        fridayFlashNotificationId,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'friday_${flash.id}',
      );

      print('Scheduled Friday notification for $fridayDate');
    } catch (e) {
      print('Error scheduling Friday notification: $e');
    }
  }

  /// Build notification body from flash
  String _buildNotificationBody(IslamicFlash flash) {
    final StringBuffer buffer = StringBuffer();

    if (flash.arabic != null && flash.arabic!.isNotEmpty) {
      buffer.writeln(flash.arabic);
      buffer.writeln();
    }

    buffer.write(flash.translation);
    buffer.writeln();
    buffer.write('— ${flash.reference}');

    return buffer.toString();
  }

  /// Get next Friday date
  DateTime _getNextFriday(DateTime from) {
    int daysUntilFriday = DateTime.friday - from.weekday;
    if (daysUntilFriday <= 0) {
      daysUntilFriday += 7;
    }
    return from.add(Duration(days: daysUntilFriday));
  }

  /// Cancel daily notification
  Future<void> cancelDailyNotification() async {
    if (kIsWeb) return;
    await _notifications.cancel(dailyFlashNotificationId);
  }

  /// Cancel Friday notification
  Future<void> cancelFridayNotification() async {
    if (kIsWeb) return;
    await _notifications.cancel(fridayFlashNotificationId);
  }

  /// Cancel all Islamic flash notifications
  Future<void> cancelAllFlashNotifications() async {
    await cancelDailyNotification();
    await cancelFridayNotification();
  }

  /// Reschedule all notifications based on current settings
  Future<void> rescheduleNotifications() async {
    final isEnabled = await _settingsService.isNotificationsEnabled();
    
    if (!isEnabled) {
      await cancelAllFlashNotifications();
      return;
    }

    final isFridayOnly = await _settingsService.isFridayOnlyEnabled();

    if (isFridayOnly) {
      await cancelDailyNotification();
      await scheduleFridayNotification();
    } else {
      await scheduleDailyNotification();
      await scheduleFridayNotification();
    }
  }

  /// Show immediate test notification
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    if (kIsWeb) return;

    final flash = _flashService.getRandomFlash();
    if (flash == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      999,
      '🌙 ${flash.typeDisplayName}',
      _buildNotificationBody(flash),
      notificationDetails,
      payload: flash.id,
    );
  }
}
