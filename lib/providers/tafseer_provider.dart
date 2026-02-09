import 'package:flutter/foundation.dart';
import '../data/services/tafseer_service.dart';

class TafseerProvider with ChangeNotifier {
  final TafseerService _service = TafseerService();
  
  Map<int, dynamic> _surahTafseer = {}; // surahIndex -> tafseerData
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<int, dynamic> get surahTafseer => _surahTafseer;

  Future<void> fetchSurahTafseer(int surahNumber, {String edition = 'en.ibnkathir'}) async {
    if (_surahTafseer.containsKey(surahNumber)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getSurahTafseer(surahNumber, edition);
      _surahTafseer[surahNumber] = data['data'];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _surahTafseer.clear();
    notifyListeners();
  }
}
