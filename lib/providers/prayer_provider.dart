import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import '../data/models/prayer_timing.dart';
import '../data/services/api_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/local_storage_service.dart';

class PrayerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final LocalStorageService _storageService = LocalStorageService();
  
  PrayerData? _prayerData;
  bool _isLoading = false;
  bool _isAzaanEnabled = true; // Enabled by default
  String _errorMessage = '';
  Position? _currentPosition;

  PrayerData? get prayerData => _prayerData;
  bool get isLoading => _isLoading;
  bool get isAzaanEnabled => _isAzaanEnabled;
  String get errorMessage => _errorMessage;

  Future<void> fetchPrayerTimes() async {
    _isLoading = true;
    _errorMessage = '';
    
    // Try to load cached data first if we have nothing
    if (_prayerData == null) {
      final cached = _storageService.getCachedPrayerTimings();
      if (cached != null) {
        _prayerData = PrayerData.fromJson(cached);
        notifyListeners();
      }
    } else {
      notifyListeners();
    }

    try {
      Position? position;
      
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            // Get current position with a timeout
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5),
            );
          }
        }
      } catch (e) {
        print('Error getting current position: $e');
      }

      // Fallback 1: Last known position from Geolocator
      if (position == null) {
        position = await Geolocator.getLastKnownPosition();
      }

      // Fallback 2: Cached position from our local storage
      if (position == null) {
        final lastLoc = _storageService.getLastLocation();
        if (lastLoc != null) {
          position = Position(
            latitude: lastLoc['latitude']!,
            longitude: lastLoc['longitude']!,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      if (position == null) {
        // If still null, and we have cached data, just stop here (quietly use cache)
        if (_prayerData != null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
        throw Exception('Could not determine location. Please enable location services.');
      }

      _currentPosition = position;
      // Cache this location
      await _storageService.saveLastLocation(position.latitude, position.longitude);

      // Fetch times
      final data = await _apiService.getPrayerTimes(position.latitude, position.longitude, 2);
      _prayerData = PrayerData.fromJson(data['data']);
      
      // Cache the prayer data
      await _storageService.savePrayerTimings(data['data']);

      // Schedule notifications for prayer times
      await _scheduleNotifications();
    } catch (e) {
      _errorMessage = e.toString();
      // If we have cached data, don't show error to user, just stick with cache
      if (_prayerData != null) {
        _errorMessage = '';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAzaan(bool enabled) async {
    _isAzaanEnabled = enabled;
    notifyListeners();
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _scheduleNotifications() async {
    if (_prayerData == null || !isAzaanEnabled) return;

    try {
      await _notificationService.initialize();
      await _notificationService.requestPermissions();
      
      await _notificationService.schedulePrayerNotifications(
        fajr: _prayerData!.timings.fajr,
        dhuhr: _prayerData!.timings.dhuhr,
        asr: _prayerData!.timings.asr,
        maghrib: _prayerData!.timings.maghrib,
        isha: _prayerData!.timings.isha,
      );
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

  // Get the name of the next prayer
  String getNextPrayerName() {
    if (_prayerData == null) return 'Fajr';

    final now = DateTime.now();
    final timings = _prayerData!.timings;

    final prayers = [
      {'name': 'Fajr', 'time': _parseTime(timings.fajr)},
      {'name': 'Dhuhr', 'time': _parseTime(timings.dhuhr)},
      {'name': 'Asr', 'time': _parseTime(timings.asr)},
      {'name': 'Maghrib', 'time': _parseTime(timings.maghrib)},
      {'name': 'Isha', 'time': _parseTime(timings.isha)},
    ];

    // Find the next prayer
    for (var prayer in prayers) {
      if (prayer['time'] != null && (prayer['time'] as DateTime).isAfter(now)) {
        return prayer['name'] as String;
      }
    }

    // If no prayer is left today, next is Fajr tomorrow
    return 'Fajr';
  }

  // Get the current prayer (the one that just passed or is ongoing)
  String getCurrentPrayerName() {
    if (_prayerData == null) return 'Isha';

    final now = DateTime.now();
    final timings = _prayerData!.timings;

    final prayers = [
      {'name': 'Fajr', 'time': _parseTime(timings.fajr)},
      {'name': 'Dhuhr', 'time': _parseTime(timings.dhuhr)},
      {'name': 'Asr', 'time': _parseTime(timings.asr)},
      {'name': 'Maghrib', 'time': _parseTime(timings.maghrib)},
      {'name': 'Isha', 'time': _parseTime(timings.isha)},
    ];

    String currentPrayer = 'Isha';
    for (var prayer in prayers) {
      if (prayer['time'] != null && (prayer['time'] as DateTime).isBefore(now)) {
        currentPrayer = prayer['name'] as String;
      } else {
        break;
      }
    }

    return currentPrayer;
  }

  // Get time remaining until next prayer
  String getTimeUntilNextPrayer() {
    if (_prayerData == null) return 'Loading...';

    final duration = getNextPrayerDuration();
    if (duration == null) return 'Loading...';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get duration until next prayer
  Duration? getNextPrayerDuration() {
    if (_prayerData == null) return null;

    final now = DateTime.now();
    final timings = _prayerData!.timings;

    final prayers = [
      _parseTime(timings.fajr),
      _parseTime(timings.dhuhr),
      _parseTime(timings.asr),
      _parseTime(timings.maghrib),
      _parseTime(timings.isha),
    ];

    // Find the next prayer time
    for (var prayerTime in prayers) {
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return prayerTime.difference(now);
      }
    }

    // If no prayer is left today, calculate time until Fajr tomorrow
    final fajrTime = _parseTime(timings.fajr);
    if (fajrTime != null) {
      final tomorrowFajr = fajrTime.add(const Duration(days: 1));
      return tomorrowFajr.difference(now);
    }

    return null;
  }

  // Get next prayer time as string
  String getNextPrayerTime() {
    if (_prayerData == null) return '--:--';

    final nextPrayer = getNextPrayerName();
    final timings = _prayerData!.timings;

    switch (nextPrayer) {
      case 'Fajr':
        return timings.fajr;
      case 'Dhuhr':
        return timings.dhuhr;
      case 'Asr':
        return timings.asr;
      case 'Maghrib':
        return timings.maghrib;
      case 'Isha':
        return timings.isha;
      default:
        return '--:--';
    }
  }

  // Parse time string (HH:mm format) to DateTime
  DateTime? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // Get location name (city, country)
  String getLocationName() {
    if (_currentPosition == null) return 'Unknown Location';
    // In a real app, you would use reverse geocoding to get the city name
    // For now, return coordinates
    return '${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}';
  }
}
