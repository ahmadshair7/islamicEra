import 'package:shared_preferences/shared_preferences.dart';

/// Islamic Flash Settings Service
/// Manages user preferences for Islamic Flashes feature
class IslamicFlashSettingsService {
  static final IslamicFlashSettingsService _instance = IslamicFlashSettingsService._internal();
  factory IslamicFlashSettingsService() => _instance;
  IslamicFlashSettingsService._internal();

  // SharedPreferences keys
  static const String _flashEnabledKey = 'islamic_flash_enabled';
  static const String _notificationsEnabledKey = 'islamic_flash_notifications_enabled';
  static const String _notificationHourKey = 'islamic_flash_notification_hour';
  static const String _notificationMinuteKey = 'islamic_flash_notification_minute';
  static const String _fridayOnlyKey = 'islamic_flash_friday_only';
  static const String _offlineEnabledKey = 'islamic_flash_offline_enabled';
  static const String _showOnHomeKey = 'islamic_flash_show_on_home';
  static const String _randomTimeEnabledKey = 'islamic_flash_random_time';

  // Default values
  static const int defaultNotificationHour = 8;
  static const int defaultNotificationMinute = 0;

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ Getters ============

  /// Check if Islamic Flashes feature is enabled
  Future<bool> isFlashEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_flashEnabledKey) ?? true;
  }

  /// Check if notifications are enabled
  Future<bool> isNotificationsEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Get notification hour (0-23)
  Future<int> getNotificationHour() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_notificationHourKey) ?? defaultNotificationHour;
  }

  /// Get notification minute (0-59)
  Future<int> getNotificationMinute() async {
    final prefs = await _getPrefs();
    return prefs.getInt(_notificationMinuteKey) ?? defaultNotificationMinute;
  }

  /// Get notification time as DateTime (today's date with the set time)
  Future<DateTime> getNotificationTime() async {
    final hour = await getNotificationHour();
    final minute = await getNotificationMinute();
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Check if Friday-only reminders are enabled
  Future<bool> isFridayOnlyEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_fridayOnlyKey) ?? false;
  }

  /// Check if offline flashes are enabled
  Future<bool> isOfflineEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_offlineEnabledKey) ?? true;
  }

  /// Check if flash should show on home screen
  Future<bool> shouldShowOnHome() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_showOnHomeKey) ?? true;
  }

  /// Check if random notification time is enabled
  Future<bool> isRandomTimeEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_randomTimeEnabledKey) ?? false;
  }

  // ============ Setters ============

  /// Enable or disable Islamic Flashes feature
  Future<void> setFlashEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_flashEnabledKey, enabled);
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// Set notification hour
  Future<void> setNotificationHour(int hour) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_notificationHourKey, hour.clamp(0, 23));
  }

  /// Set notification minute
  Future<void> setNotificationMinute(int minute) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_notificationMinuteKey, minute.clamp(0, 59));
  }

  /// Set notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    await setNotificationHour(hour);
    await setNotificationMinute(minute);
  }

  /// Enable or disable Friday-only reminders
  Future<void> setFridayOnlyEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_fridayOnlyKey, enabled);
  }

  /// Enable or disable offline flashes
  Future<void> setOfflineEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_offlineEnabledKey, enabled);
  }

  /// Set whether to show flash on home screen
  Future<void> setShowOnHome(bool show) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_showOnHomeKey, show);
  }

  /// Enable or disable random notification time
  Future<void> setRandomTimeEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_randomTimeEnabledKey, enabled);
  }

  // ============ Bulk Operations ============

  /// Get all settings as a map
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'flashEnabled': await isFlashEnabled(),
      'notificationsEnabled': await isNotificationsEnabled(),
      'notificationHour': await getNotificationHour(),
      'notificationMinute': await getNotificationMinute(),
      'fridayOnly': await isFridayOnlyEnabled(),
      'offlineEnabled': await isOfflineEnabled(),
      'showOnHome': await shouldShowOnHome(),
      'randomTime': await isRandomTimeEnabled(),
    };
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await setFlashEnabled(true);
    await setNotificationsEnabled(true);
    await setNotificationTime(defaultNotificationHour, defaultNotificationMinute);
    await setFridayOnlyEnabled(false);
    await setOfflineEnabled(true);
    await setShowOnHome(true);
    await setRandomTimeEnabled(false);
  }
}
