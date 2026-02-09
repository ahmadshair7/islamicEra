import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/ayat.dart';
import 'quran_local_service.dart';

class AyatService {
  static final AyatService _instance = AyatService._internal();
  factory AyatService() => _instance;
  AyatService._internal();

  final Random _random = Random();
  final QuranLocalService _quranLocal = QuranLocalService();

  // Total number of ayats in Quran
  static const int totalAyats = 6236;

  Future<Ayat> getRandomAyat() async {
    try {
      // Generate a random ayat number (1 to 6236)
      final randomAyatNumber = _random.nextInt(totalAyats) + 1;

      // Get from local storage using QuranLocalService
      final data = await _quranLocal.getAyahByNumber(randomAyatNumber);
      final ayahData = data['data'] as List;
      
      if (ayahData.length >= 2) {
        // First element is Arabic, second is translation
        return Ayat.fromJson(ayahData[0], ayahData[1]);
      } else {
        throw Exception('Invalid ayat data received');
      }
    } catch (e) {
      throw Exception('Error fetching random ayat: $e');
    }
  }

  Future<Ayat> getAyatByReference(int surahNumber, int ayatNumber) async {
    try {
      final String url = '${AppConstants.quranApiUrl}/ayah/$surahNumber:$ayatNumber/editions/quran-uthmani,en.asad';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahData = data['data'] as List;
        
        if (ayahData.length >= 2) {
          return Ayat.fromJson(ayahData[0], ayahData[1]);
        } else {
          throw Exception('Invalid ayat data received');
        }
      } else {
        throw Exception('Failed to load ayat');
      }
    } catch (e) {
      throw Exception('Error fetching ayat: $e');
    }
  }
}
