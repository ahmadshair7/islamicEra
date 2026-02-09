import 'package:flutter/foundation.dart';
import '../data/services/random_hadith_service.dart';

class RandomHadithProvider with ChangeNotifier {
  final RandomHadithService _service = RandomHadithService();
  
  RandomHadith? _currentHadith;
  bool _isLoading = false;

  RandomHadith? get currentHadith => _currentHadith;
  bool get isLoading => _isLoading;

  // Fetch a random hadith
  Future<void> fetchRandomHadith() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate slight delay for smooth UX
      await Future.delayed(const Duration(milliseconds: 300));
      _currentHadith = _service.getRandomHadith();
    } catch (e) {
      print('Error fetching random hadith: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh to get a new random hadith
  Future<void> refreshHadith() async {
    await fetchRandomHadith();
  }
}
