import 'package:flutter/foundation.dart';
import '../data/models/islamic_flash.dart';
import '../data/services/islamic_flash_service.dart';
import '../data/services/islamic_flash_settings_service.dart';
import '../data/services/islamic_flash_notification_service.dart';

/// Islamic Flash Provider
/// Manages state for Islamic Flashes feature
class IslamicFlashProvider extends ChangeNotifier {
  final IslamicFlashService _flashService = IslamicFlashService();
  final IslamicFlashSettingsService _settingsService = IslamicFlashSettingsService();
  final IslamicFlashNotificationService _notificationService = IslamicFlashNotificationService();

  IslamicFlash? _currentFlash;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  // Settings state
  bool _flashEnabled = true;
  bool _notificationsEnabled = true;
  int _notificationHour = 8;
  int _notificationMinute = 0;
  bool _fridayOnly = false;
  bool _offlineEnabled = true;
  bool _showOnHome = true;
  bool _randomTime = false;

  // Getters
  IslamicFlash? get currentFlash => _currentFlash;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get flashEnabled => _flashEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  int get notificationHour => _notificationHour;
  int get notificationMinute => _notificationMinute;
  bool get fridayOnly => _fridayOnly;
  bool get offlineEnabled => _offlineEnabled;
  bool get showOnHome => _showOnHome;
  bool get randomTime => _randomTime;

  String get notificationTimeFormatted {
    final hour = _notificationHour > 12 ? _notificationHour - 12 : _notificationHour;
    final period = _notificationHour >= 12 ? 'PM' : 'AM';
    final hourStr = hour == 0 ? '12' : hour.toString().padLeft(2, '0');
    final minuteStr = _notificationMinute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  /// Initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Initialize services
      await _flashService.initialize();
      await _settingsService.initialize();
      await _notificationService.initialize();

      // Load settings
      await _loadSettings();

      // Get flash of the day if enabled
      if (_flashEnabled && _showOnHome) {
        await loadFlashOfTheDay();
      }

      // Schedule notifications if enabled
      if (_notificationsEnabled) {
        await _notificationService.rescheduleNotifications();
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    _flashEnabled = await _settingsService.isFlashEnabled();
    _notificationsEnabled = await _settingsService.isNotificationsEnabled();
    _notificationHour = await _settingsService.getNotificationHour();
    _notificationMinute = await _settingsService.getNotificationMinute();
    _fridayOnly = await _settingsService.isFridayOnlyEnabled();
    _offlineEnabled = await _settingsService.isOfflineEnabled();
    _showOnHome = await _settingsService.shouldShowOnHome();
    _randomTime = await _settingsService.isRandomTimeEnabled();
  }

  /// Load flash of the day
  Future<void> loadFlashOfTheDay() async {
    try {
      _currentFlash = await _flashService.getFlashOfTheDay();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load flash: $e';
      notifyListeners();
    }
  }

  /// Refresh with a new random flash
  Future<void> refreshFlash() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentFlash = _flashService.getNewRandomFlash();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to refresh flash: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a random flash
  void getRandomFlash() {
    _currentFlash = _flashService.getRandomFlash();
    notifyListeners();
  }

  /// Set flash enabled
  Future<void> setFlashEnabled(bool enabled) async {
    _flashEnabled = enabled;
    await _settingsService.setFlashEnabled(enabled);
    
    if (enabled && _showOnHome) {
      await loadFlashOfTheDay();
    }
    
    notifyListeners();
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _settingsService.setNotificationsEnabled(enabled);
    await _notificationService.rescheduleNotifications();
    notifyListeners();
  }

  /// Set notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    _notificationHour = hour;
    _notificationMinute = minute;
    await _settingsService.setNotificationTime(hour, minute);
    await _notificationService.rescheduleNotifications();
    notifyListeners();
  }

  /// Set Friday only
  Future<void> setFridayOnly(bool enabled) async {
    _fridayOnly = enabled;
    await _settingsService.setFridayOnlyEnabled(enabled);
    await _notificationService.rescheduleNotifications();
    notifyListeners();
  }

  /// Set offline enabled
  Future<void> setOfflineEnabled(bool enabled) async {
    _offlineEnabled = enabled;
    await _settingsService.setOfflineEnabled(enabled);
    notifyListeners();
  }

  /// Set show on home
  Future<void> setShowOnHome(bool show) async {
    _showOnHome = show;
    await _settingsService.setShowOnHome(show);
    
    if (show && _flashEnabled) {
      await loadFlashOfTheDay();
    }
    
    notifyListeners();
  }

  /// Set random time
  Future<void> setRandomTime(bool enabled) async {
    _randomTime = enabled;
    await _settingsService.setRandomTimeEnabled(enabled);
    await _notificationService.rescheduleNotifications();
    notifyListeners();
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    await _notificationService.showTestNotification();
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    await _settingsService.resetToDefaults();
    await _loadSettings();
    await _notificationService.rescheduleNotifications();
    notifyListeners();
  }
}
