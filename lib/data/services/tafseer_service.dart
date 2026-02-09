import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class TafseerService {
  final String baseUrl = "https://api.alquran.cloud/v1";
  final LocalStorageService _storage = LocalStorageService();

  // Get Tafseer for a specific Ayah (e.g., Quran 2:255)
  // Editions: en.ibnkathir (English), ur.tafsir-ibn-kathir (Urdu)
  Future<Map<String, dynamic>> getAyahTafseer(int surah, int ayah, String edition) async {
    final box = _storage.getCacheBox();
    final key = 'tafseer_${surah}_${ayah}_$edition';

    // Check cache first
    final cached = box.get(key);
    if (cached != null) {
      return Map<String, dynamic>.from(cached);
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/ayah/$surah:$ayah/$edition'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load Tafseer');
      }
    } catch (e) {
      throw Exception('Error fetching Tafseer: $e');
    }
  }

  // Get Tafseer for an entire Surah
  Future<Map<String, dynamic>> getSurahTafseer(int surah, String edition) async {
    final box = _storage.getCacheBox();
    final key = 'tafseer_surah_${surah}_$edition';

    // Check cache first
    final cached = box.get(key);
    if (cached != null) {
      return Map<String, dynamic>.from(cached);
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/surah/$surah/$edition'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await box.put(key, data);
        return data;
      } else {
        throw Exception('Failed to load Surah Tafseer');
      }
    } catch (e) {
      throw Exception('Error fetching Surah Tafseer: $e');
    }
  }
}
