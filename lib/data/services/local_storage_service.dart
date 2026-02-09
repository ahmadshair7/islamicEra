import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Central service for managing all local storage operations using Hive
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Box names
  static const String quranBox = 'quran_data';
  static const String hadithBox = 'hadith_data';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String tasbeehBox = 'tasbeeh_targets';
  
  // Cache keys
  static const String keyLastLat = 'last_latitude';
  static const String keyLastLong = 'last_longitude';
  static const String keyPrayerTimings = 'prayer_timings';

  bool _isInitialized = false;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Open all boxes
    await Future.wait([
      Hive.openBox(quranBox),
      Hive.openBox(hadithBox),
      Hive.openBox(settingsBox),
      Hive.openBox(cacheBox),
      Hive.openBox(tasbeehBox),
    ]);

    _isInitialized = true;
  }

  /// Check if Quran data is downloaded
  bool isQuranDataAvailable() {
    final box = Hive.box(quranBox);
    return box.get('quran_complete', defaultValue: false);
  }

  /// Check if Hadith data is downloaded
  bool isHadithDataAvailable() {
    final box = Hive.box(hadithBox);
    return box.get('hadith_complete', defaultValue: false);
  }

  /// Mark Quran data as complete
  Future<void> markQuranDataComplete() async {
    final box = Hive.box(quranBox);
    await box.put('quran_complete', true);
    await box.put('quran_download_date', DateTime.now().toIso8601String());
  }

  /// Mark Hadith data as complete
  Future<void> markHadithDataComplete() async {
    final box = Hive.box(hadithBox);
    await box.put('hadith_complete', true);
    await box.put('hadith_download_date', DateTime.now().toIso8601String());
  }

  /// Get Quran box
  Box getQuranBox() => Hive.box(quranBox);

  /// Get Hadith box
  Box getHadithBox() => Hive.box(hadithBox);

  /// Get Settings box
  Box getSettingsBox() => Hive.box(settingsBox);

  /// Get Cache box
  Box getCacheBox() => Hive.box(cacheBox);

  /// Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    await Hive.box(quranBox).clear();
    await Hive.box(hadithBox).clear();
    await Hive.box(cacheBox).clear();
  }

  /// Get data version (for future updates)
  int getDataVersion() {
    final box = Hive.box(settingsBox);
    return box.get('data_version', defaultValue: 1);
  }

  /// Update data version
  Future<void> setDataVersion(int version) async {
    final box = Hive.box(settingsBox);
    await box.put('data_version', version);
  }

  /// Get storage size estimate in bytes
  Future<int> getStorageSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      int totalSize = 0;
      
      // This is an estimate - Hive doesn't provide direct size API
      // In production, you might want to traverse the directory
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // --- Location Cache ---
  Future<void> saveLastLocation(double lat, double long) async {
    final box = Hive.box(cacheBox);
    await box.put(keyLastLat, lat);
    await box.put(keyLastLong, long);
  }

  Map<String, double>? getLastLocation() {
    final box = Hive.box(cacheBox);
    final lat = box.get(keyLastLat);
    final long = box.get(keyLastLong);
    if (lat != null && long != null) {
      return {'latitude': lat, 'longitude': long};
    }
    return null;
  }

  // --- Prayer Timings Cache ---
  Future<void> savePrayerTimings(Map<String, dynamic> data) async {
    final box = Hive.box(cacheBox);
    await box.put(keyPrayerTimings, data);
    await box.put('prayer_cache_date', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getCachedPrayerTimings() {
    final box = Hive.box(cacheBox);
    final data = box.get(keyPrayerTimings);
    if (data != null) {
      // If it's stored as a JSON string, decode it. Hive can store Maps directly though.
      if (data is String) {
        return json.decode(data);
      }
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // --- Tasbeeh Targets ---
  
  /// Save or update a Tasbeeh target for a specific date
  Future<void> saveTasbeehTarget(Map<String, dynamic> target) async {
    final box = Hive.box(tasbeehBox);
    final date = target['date'] as String;
    await box.put(date, target);
  }

  /// Get Tasbeeh target for a specific date
  Map<String, dynamic>? getTasbeehTarget(String date) {
    final box = Hive.box(tasbeehBox);
    final data = box.get(date);
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  /// Update count for a specific date
  Future<void> updateTasbeehCount(String date, int count) async {
    final box = Hive.box(tasbeehBox);
    final existingTarget = box.get(date);
    if (existingTarget != null) {
      final updated = Map<String, dynamic>.from(existingTarget);
      updated['currentCount'] = count;
      await box.put(date, updated);
    }
  }

  /// Get all Tasbeeh targets (for calendar color-coding)
  Map<String, Map<String, dynamic>> getAllTasbeehTargets() {
    final box = Hive.box(tasbeehBox);
    final result = <String, Map<String, dynamic>>{};
    
    for (var key in box.keys) {
      if (key is String) {
        final data = box.get(key);
        if (data != null) {
          result[key] = Map<String, dynamic>.from(data);
        }
      }
    }
    
    return result;
  }

  /// Delete a Tasbeeh target for a specific date
  Future<void> deleteTasbeehTarget(String date) async {
    final box = Hive.box(tasbeehBox);
    await box.delete(date);
  }

  /// Get Tasbeeh box
  Box getTasbeehBox() => Hive.box(tasbeehBox);
}
