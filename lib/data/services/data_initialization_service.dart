import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import 'quran_local_service.dart';
import 'hadith_local_service.dart';

/// Service to manage data initialization and download
class DataInitializationService {
  static final DataInitializationService _instance = DataInitializationService._internal();
  factory DataInitializationService() => _instance;
  DataInitializationService._internal();

  final LocalStorageService _storage = LocalStorageService();
  final QuranLocalService _quranLocal = QuranLocalService();
  final HadithLocalService _hadithLocal = HadithLocalService();

  /// Initialize local storage
  Future<void> initialize() async {
    await _storage.initialize();
  }

  /// Check if app data is ready (Quran data downloaded)
  bool isDataReady() {
    return _storage.isQuranDataAvailable();
  }

  /// Check if Quran data is available
  bool isQuranDataAvailable() {
    return _storage.isQuranDataAvailable();
  }

  /// Check if Hadith data is available
  bool isHadithDataAvailable() {
    return _storage.isHadithDataAvailable();
  }

  /// Download Quran data with progress callback
  Future<void> downloadQuranData({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      await _quranLocal.downloadCompleteQuran(onProgress: onProgress);
    } catch (e) {
      debugPrint('Error downloading Quran data: $e');
      rethrow;
    }
  }

  /// Download Hadith data with progress callback
  Future<void> downloadHadithData({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      await _hadithLocal.downloadAllHadiths(onProgress: onProgress);
    } catch (e) {
      debugPrint('Error downloading Hadith data: $e');
      rethrow;
    }
  }

  /// Download all essential data (Quran + Hadith)
  Future<void> downloadAllData({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      // Download Quran (70% of total progress)
      await downloadQuranData(
        onProgress: (progress, status) {
          onProgress?.call(progress * 0.7, status);
        },
      );

      // Download Hadith (30% of total progress)
      await downloadHadithData(
        onProgress: (progress, status) {
          onProgress?.call(0.7 + (progress * 0.3), status);
        },
      );

      onProgress?.call(1.0, 'Download complete!');
    } catch (e) {
      debugPrint('Error downloading all data: $e');
      rethrow;
    }
  }

  /// Download only Quran data (minimum required)
  Future<void> downloadMinimumData({
    void Function(double progress, String status)? onProgress,
  }) async {
    await downloadQuranData(onProgress: onProgress);
  }

  /// Reset all data (for testing)
  Future<void> resetAllData() async {
    await _storage.clearAllData();
  }

  /// Get estimated data sizes
  Map<String, String> getEstimatedSizes() {
    return {
      'quran': '~50 MB',
      'hadith': '~30 MB',
      'total': '~80 MB',
    };
  }

  /// Get download progress info
  Future<Map<String, dynamic>> getDownloadStatus() async {
    return {
      'quranDownloaded': isQuranDataAvailable(),
      'hadithDownloaded': isHadithDataAvailable(),
      'dataVersion': _storage.getDataVersion(),
    };
  }
}
