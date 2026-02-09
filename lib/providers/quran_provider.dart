import 'package:flutter/foundation.dart';
import '../data/models/surah.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage_service.dart';

class QuranProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();
  List<Surah> _surahs = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  List<Surah> _surahResults = [];
  List<int> _parahResults = [];

  List<Surah> get surahs => _surahs;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<Surah> get surahResults => _surahResults;
  List<int> get parahResults => _parahResults;

  /// Check if Quran data is available locally
  bool isDataAvailable() {
    return _localStorage.isQuranDataAvailable();
  }

  Future<void> fetchSurahs() async {
    if (_surahs.isNotEmpty) return; // Don't refetch if already loaded

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await _apiService.getSurahList();
      final List<dynamic> surahList = data['data'];
      _surahs = surahList.map((json) => Surah.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchAyahs(String query) async {
    _isLoading = true;
    _errorMessage = '';
    _searchResults = [];
    _surahResults = [];
    _parahResults = [];
    notifyListeners();

    try {
      // 0. Ensure Surahs are loaded for local search
      if (_surahs.isEmpty) {
        await fetchSurahs();
      }

      // 1. Handle direct Ayat reference like "2:255"
      final parts = query.split(':');
      if (parts.length == 2) {
        final sn = int.tryParse(parts[0]);
        final an = int.tryParse(parts[1]);
        if (sn != null && an != null) {
          // Logic to handle direct navigation can be added here or in UI
        }
      }

      // 1.5 Handle "Parah X" or "Juz X"
      // Normalize query
      final normalizedQ = query.toLowerCase().trim();
      int? foundParah;
      
      if (normalizedQ.startsWith("parah") || normalizedQ.startsWith("juz") || normalizedQ.startsWith("para")) {
         // Remove all non-digit characters
         String numStr = normalizedQ.replaceAll(RegExp(r'[^0-9]'), '');
         foundParah = int.tryParse(numStr);
      } else {
        // Check if query is just a number?
        final justNum = int.tryParse(normalizedQ);
        if (justNum != null) {
          // If valid parah number, maybe show it?
          // Let's only match explicit 'parah' queries for now to avoid noise.
        }
      }

      if (foundParah != null && foundParah >= 1 && foundParah <= 30) {
        _parahResults = [foundParah];
      }

      // 2. Search locally for surah names (Robust)
      // Normalize query: remove spaces, hyphens, lowercase
      final normalizedQuery = query.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
      
      if (_surahs.isNotEmpty) {
        _surahResults = _surahs.where((s) {
          final normalizedEnglish = s.englishName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
          final normalizedTrans = s.englishNameTranslation.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
          return normalizedEnglish.contains(normalizedQuery) ||
                 normalizedTrans.contains(normalizedQuery) ||
                 s.name.contains(query);
        }).toList();
      }

      // 3. Search API for Ayat text (Try English first, then Urdu if no results?)
      // We updated ApiService to return empty list instead of throw.
      var data = await _apiService.searchQuran(query);
      // ignore: unnecessary_null_comparison
      if (data != null && data['data'] != null) {
         List<dynamic> matches = (data['data']['matches'] as List?) ?? [];
         
         // If english search yielded no results, try Urdu search? 
         // (Not implemented in ApiService yet, but good to have logic ready or assume query might be English).
         // For now, adhere to the robust ApiService we just fixed.
         
         _searchResults = matches;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
