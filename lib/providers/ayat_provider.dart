import 'package:flutter/foundation.dart';
import '../data/models/ayat.dart';
import '../data/services/ayat_service.dart';

class AyatProvider with ChangeNotifier {
  final AyatService _ayatService = AyatService();
  
  Ayat? _currentAyat;
  bool _isLoading = false;
  String _errorMessage = '';

  Ayat? get currentAyat => _currentAyat;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchRandomAyat() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentAyat = await _ayatService.getRandomAyat();
    } catch (e) {
      _errorMessage = e.toString();
      _currentAyat = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAyat() async {
    await fetchRandomAyat();
  }
}
