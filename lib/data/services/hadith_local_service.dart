import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import 'local_storage_service.dart';

/// Service for managing Hadith data in local storage
class HadithLocalService {
  static final HadithLocalService _instance = HadithLocalService._internal();
  factory HadithLocalService() => _instance;
  HadithLocalService._internal();

  final LocalStorageService _storage = LocalStorageService();

  /// Get Hadith chapters/sections for a book from local storage or fetch
  Future<Map<String, dynamic>> getHadithChapters(String bookSlug) async {
    final box = _storage.getHadithBox();
    final key = 'chapters_$bookSlug';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return Map<String, dynamic>.from(cached);
    }

    // Fetch from API and cache
    try {
      final String url = '${AppConstants.hadithApiUrl}/editions/ara-$bookSlug/sections.json';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load chapters for $bookSlug');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  /// Get Hadith section data from local storage or fetch
  Future<List<dynamic>> getHadithSection(String bookSlug, String sectionId) async {
    final box = _storage.getHadithBox();
    final key = 'section_${bookSlug}_$sectionId';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return List<dynamic>.from(cached);
    }

    // Fetch from API and cache
    try {
      final String arabicUrl = '${AppConstants.hadithApiUrl}/editions/ara-$bookSlug/sections/$sectionId.json';
      final String urduUrl = '${AppConstants.hadithApiUrl}/editions/urd-$bookSlug/sections/$sectionId.json';

      final responses = await Future.wait([
        http.get(Uri.parse(arabicUrl)),
        http.get(Uri.parse(urduUrl)),
      ]);

      final arabicResponse = responses[0];
      final urduResponse = responses[1];
      
      List<dynamic> arabicHadiths = [];
      List<dynamic> urduHadiths = [];

      if (arabicResponse.statusCode == 200) {
        final data = json.decode(arabicResponse.body);
        if (data['hadiths'] != null) {
          arabicHadiths = data['hadiths'];
        }
      }
      
      if (urduResponse.statusCode == 200) {
        final data = json.decode(urduResponse.body);
        if (data['hadiths'] != null) {
          urduHadiths = data['hadiths'];
        }
      }

      // Merge logic: Match by 'hadithnumber'
      final urduMap = {
        for (var h in urduHadiths) h['hadithnumber'].toString(): h['text']
      };

      final mergedData = arabicHadiths.map((h) {
        final num = h['hadithnumber'].toString();
        return {
          'hadithNumber': num,
          'hadithArabic': h['text'],
          'hadithUrdu': urduMap[num] ?? 'Translation not available',
        };
      }).toList();

      await box.put(key, mergedData);
      return mergedData;
    } catch (e) {
      throw Exception('Error fetching Hadiths: $e');
    }
  }

  /// Get Hadith books from alternative API (hadithapi.com)
  Future<List<dynamic>> getHadithBooks() async {
    final box = _storage.getHadithBox();
    final key = 'hadith_books';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return List<dynamic>.from(cached);
    }

    // Fetch from API and cache
    try {
      const apiKey = r"$2y$10$GA3ElRrv48pXzrqlUl4ZK4RA7OrIMGnkz7qtxIz3aQK4kF0NO2";
      final url = "https://hadithapi.com/api/books?apiKey=$apiKey";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final books = jsonResponse["books"] ?? [];
        await box.put(key, books);
        return books;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get Hadiths for a specific book from alternative API
  Future<List<dynamic>> getHadithsByBook(String bookSlug) async {
    final box = _storage.getHadithBox();
    final key = 'hadiths_$bookSlug';
    
    // Try to get from local storage first
    final cached = box.get(key);
    if (cached != null) {
      return List<dynamic>.from(cached);
    }

    // Fetch from API and cache
    try {
      const apiKey = r"$2y$10$GA3ElRrv48pXzrqlUl4ZK4RA7OrIMGnkz7qtxIz3aQK4kF0NO2";
      final url = "https://hadithapi.com/api/hadiths?apiKey=$apiKey&book=$bookSlug";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final hadiths = jsonResponse["hadiths"]["data"] ?? [];
        await box.put(key, hadiths);
        return hadiths;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Download all available Hadith collections
  Future<void> downloadAllHadiths({
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      // Download books list
      onProgress?.call(0.0, 'Downloading Hadith books...');
      final books = await getHadithBooks();

      if (books.isEmpty) {
        onProgress?.call(1.0, 'No Hadith books available');
        return;
      }

      // Download hadiths for each book
      for (int i = 0; i < books.length; i++) {
        final bookSlug = books[i]['bookSlug'];
        onProgress?.call((i + 1) / books.length, 'Downloading ${books[i]['bookName']}...');
        await getHadithsByBook(bookSlug);
      }

      // Mark as complete
      await _storage.markHadithDataComplete();
      onProgress?.call(1.0, 'Hadith download complete!');
    } catch (e) {
      throw Exception('Error downloading Hadith data: $e');
    }
  }

  /// Check if specific book's chapters are cached
  bool areChaptersCached(String bookSlug) {
    final box = _storage.getHadithBox();
    return box.containsKey('chapters_$bookSlug');
  }

  /// Check if specific section is cached
  bool isSectionCached(String bookSlug, String sectionId) {
    final box = _storage.getHadithBox();
    return box.containsKey('section_${bookSlug}_$sectionId');
  }
}
