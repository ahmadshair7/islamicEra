import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import 'local_storage_service.dart';

/// Service for managing Quran data in local storage
class QuranLocalService {
  static final QuranLocalService _instance = QuranLocalService._internal();
  factory QuranLocalService() => _instance;
  QuranLocalService._internal();

  final LocalStorageService _storage = LocalStorageService();

  /// Helper function to recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
  /// This is needed because Hive on mobile returns _Map<dynamic, dynamic> for nested objects
  dynamic _convertToMapStringDynamic(dynamic item) {
    if (item is Map) {
      return Map<String, dynamic>.fromEntries(
        item.entries.map((e) => MapEntry(e.key.toString(), _convertToMapStringDynamic(e.value))),
      );
    } else if (item is List) {
      return item.map((e) => _convertToMapStringDynamic(e)).toList();
    } else {
      return item;
    }
  }

  /// Get Surah list from local storage or fetch and cache
  Future<Map<String, dynamic>> getSurahList() async {
    final box = _storage.getQuranBox();
    
    // Try to get from local storage first
    final cached = box.get('surah_list');
    if (cached != null) {
      return _convertToMapStringDynamic(cached) as Map<String, dynamic>;
    }

    // Fetch from API and cache
    try {
      const String url = '${AppConstants.quranApiUrl}/surah';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await box.put('surah_list', data);
        return data;
      } else {
        throw Exception('Failed to load Surah list');
      }
    } catch (e) {
      throw Exception('Error fetching Surah list: $e');
    }
  }

  /// Get Surah details from local storage or fetch and cache
  Future<Map<String, dynamic>> getSurahDetails(int number) async {
    final box = _storage.getQuranBox();
    final key = 'surah_$number';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return _convertToMapStringDynamic(cached) as Map<String, dynamic>;
    }

    // Fetch from API and cache
    try {
      final String url = '${AppConstants.quranApiUrl}/surah/$number/editions/quran-uthmani,ur.jalandhry,en.sahih';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load Surah details');
      }
    } catch (e) {
      throw Exception('Error fetching Surah details: $e');
    }
  }

  /// Get Juz details from local storage or fetch and cache
  Future<Map<String, dynamic>> getJuzDetails(int juzNumber) async {
    final box = _storage.getQuranBox();
    final key = 'juz_$juzNumber';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return _convertToMapStringDynamic(cached) as Map<String, dynamic>;
    }

    // Fetch from API and cache
    try {
      final String arabicUrl = '${AppConstants.quranApiUrl}/juz/$juzNumber/quran-uthmani';
      final String urduUrl = '${AppConstants.quranApiUrl}/juz/$juzNumber/ur.jalandhry';
      final String englishUrl = '${AppConstants.quranApiUrl}/juz/$juzNumber/en.sahih';
      
      final responses = await Future.wait([
        http.get(Uri.parse(arabicUrl)),
        http.get(Uri.parse(urduUrl)),
        http.get(Uri.parse(englishUrl)),
      ]);

      final arabicResponse = responses[0];
      final urduResponse = responses[1];
      final englishResponse = responses[2];

      if (arabicResponse.statusCode == 200 && 
          urduResponse.statusCode == 200 && 
          englishResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final urduData = json.decode(urduResponse.body);
        final englishData = json.decode(englishResponse.body);

        final data = {
          'data': [
            {'ayahs': arabicData['data']['ayahs']},
            {'ayahs': urduData['data']['ayahs']},
            {'ayahs': englishData['data']['ayahs']}
          ]
        };
        
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load Juz details');
      }
    } catch (e) {
      throw Exception('Error fetching Juz details: $e');
    }
  }

  /// Search Quran in local storage or fetch and cache
  Future<Map<String, dynamic>> searchQuran(String query) async {
    final box = _storage.getQuranBox();
    final key = 'search_${query.toLowerCase().trim()}';
    
    // Try to get from cache first (cache search results for performance)
    final cacheBox = _storage.getCacheBox();
    final cached = cacheBox.get(key);
    if (cached != null) {
      return _convertToMapStringDynamic(cached) as Map<String, dynamic>;
    }

    // Fetch from API and cache
    try {
      final String url = '${AppConstants.quranApiUrl}/search/${Uri.encodeComponent(query)}/all/en.sahih';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache search results for 7 days
        await cacheBox.put(key, data);
        return data;
      } else {
        return {'data': {'matches': []}};
      }
    } catch (e) {
      return {'data': {'matches': []}};
    }
  }

  /// Get a specific Ayah by number (1-6236)
  Future<Map<String, dynamic>> getAyahByNumber(int ayahNumber) async {
    final box = _storage.getQuranBox();
    final key = 'ayah_$ayahNumber';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return _convertToMapStringDynamic(cached) as Map<String, dynamic>;
    }

    // Fetch from API and cache
    try {
      final String url = '${AppConstants.quranApiUrl}/ayah/$ayahNumber/editions/quran-uthmani,en.asad';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load Ayah');
      }
    } catch (e) {
      throw Exception('Error fetching Ayah: $e');
    }
  }

  /// Download all Quran data for offline use
  Future<void> downloadCompleteQuran({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      // Download Surah list
      onProgress?.call(0.0, 'Downloading Surah list...');
      await getSurahList();

      // Download all 114 Surahs
      for (int i = 1; i <= 114; i++) {
        onProgress?.call(i / 114 * 0.7, 'Downloading Surah $i of 114...');
        await getSurahDetails(i);
      }

      // Download all 30 Juz
      for (int i = 1; i <= 30; i++) {
        onProgress?.call(0.7 + (i / 30 * 0.3), 'Downloading Juz $i of 30...');
        await getJuzDetails(i);
      }

      // Mark as complete
      await _storage.markQuranDataComplete();
      onProgress?.call(1.0, 'Quran data download complete!');
    } catch (e) {
      throw Exception('Error downloading Quran data: $e');
    }
  }

  /// Check if specific Surah is cached
  bool isSurahCached(int number) {
    final box = _storage.getQuranBox();
    return box.containsKey('surah_$number');
  }

  /// Check if specific Juz is cached
  bool isJuzCached(int number) {
    final box = _storage.getQuranBox();
    return box.containsKey('juz_$number');
  }

  /// Get total number of cached Surahs
  int getCachedSurahCount() {
    final box = _storage.getQuranBox();
    int count = 0;
    for (int i = 1; i <= 114; i++) {
      if (box.containsKey('surah_$i')) count++;
    }
    return count;
  }
}
