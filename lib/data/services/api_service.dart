import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/constants.dart';
import 'quran_local_service.dart';

class ApiService {
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final QuranLocalService _quranLocal = QuranLocalService();

  /// Get prayer times using offline calculation with adhan package
  Future<Map<String, dynamic>> getPrayerTimes(double lat, double long, int method) async {
    try {
      // Use adhan package for offline prayer time calculation
      final coordinates = Coordinates(lat, long);
      
      // Map method parameter to CalculationMethod
      CalculationMethod calculationMethod;
      switch (method) {
        case 0:
          calculationMethod = CalculationMethod.other;
          break;
        case 1:
          calculationMethod = CalculationMethod.karachi;
          break;
        case 2:
          calculationMethod = CalculationMethod.north_america;
          break;
        case 3:
          calculationMethod = CalculationMethod.muslim_world_league;
          break;
        case 4:
          calculationMethod = CalculationMethod.umm_al_qura;
          break;
        default:
          calculationMethod = CalculationMethod.muslim_world_league;
      }
      
      final params = calculationMethod.getParameters();
      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      final hijriDate = HijriCalendar.now();
      
      // Format to match the API response structure expected by PrayerData.fromJson
      return {
        'code': 200,
        'status': 'OK',
        'data': {
          'timings': {
            'Fajr': _formatTime(prayerTimes.fajr),
            'Sunrise': _formatTime(prayerTimes.sunrise),
            'Dhuhr': _formatTime(prayerTimes.dhuhr),
            'Asr': _formatTime(prayerTimes.asr),
            'Maghrib': _formatTime(prayerTimes.maghrib),
            'Isha': _formatTime(prayerTimes.isha),
            'Sunset': _formatTime(prayerTimes.maghrib), // Using maghrib as a close approximation if not provided
          },
          'date': {
            'readable': DateFormat('dd MMM yyyy').format(DateTime.now()),
            'gregorian': {
              'date': DateTime.now().toString().split(' ')[0],
            },
            'hijri': {
              'day': hijriDate.hDay.toString(),
              'month': {
                'en': hijriDate.longMonthName,
              },
              'year': hijriDate.hYear.toString(),
            }
          }
        }
      };
    } catch (e) {
      throw Exception('Error calculating prayer times: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<Map<String, dynamic>> getSurahList() async {
    return await _quranLocal.getSurahList();
  }

  Future<Map<String, dynamic>> getSurahDetails(int number) async {
    return await _quranLocal.getSurahDetails(number);
  }

  Future<Map<String, dynamic>> getJuzDetails(int juzNumber) async {
    return await _quranLocal.getJuzDetails(juzNumber);
  }

  // Hadith Methods (Using fawazahmed0/hadith-api)
  
  // Fetch list of sections (chapters) for a book
  // We use the Arabic edition to get the chapter structure.
  Future<Map<String, dynamic>> getHadithChapters(String bookSlug) async {
    // bookSlug example: 'bukhari' -> we use 'ara-bukhari' for metadata
    final String url = '${AppConstants.hadithApiUrl}/editions/ara-$bookSlug/sections.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // The API returns a Map: {"1": "Revelation", "2": "Belief", ...} or object with metadata
        // For fawazahmed0, sections.json is usually a Map<String, String> of section_id -> section_name
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load chapters for $bookSlug');
      }
    } catch (e) {
      throw Exception('Error fetching chapters: $e');
    }
  }

  // Fetch Hadiths for a specific section (chapter), merging Arabic and Urdu
  Future<List<dynamic>> getHadithSection(String bookSlug, String sectionId) async {
    final String arabicUrl = '${AppConstants.hadithApiUrl}/editions/ara-$bookSlug/sections/$sectionId.json';
    final String urduUrl = '${AppConstants.hadithApiUrl}/editions/urd-$bookSlug/sections/$sectionId.json';

    try {
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

      // Merge logic: Match by 'hadithnumber'.
      // Create a map of Urdu hadiths for quick lookup
      final urduMap = {
        for (var h in urduHadiths) h['hadithnumber'].toString(): h['text']
      };

      return arabicHadiths.map((h) {
        final num = h['hadithnumber'].toString();
        return {
          'hadithNumber': num,
          'hadithArabic': h['text'],
          'hadithUrdu': urduMap[num] ?? 'Translation not available',
          // 'grades': h['grades'] ?? [], // Optional: add grades if available
        };
      }).toList();

    } catch (e) {
      throw Exception('Error fetching Hadiths: $e');
    }
  }

  Future<Map<String, dynamic>> searchQuran(String query) async {
    return await _quranLocal.searchQuran(query);
  }
}
