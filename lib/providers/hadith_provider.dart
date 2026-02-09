import 'package:flutter/foundation.dart';
import '../data/services/hadith_api.dart';
import '../data/services/local_storage_service.dart';

class HadithProvider with ChangeNotifier {
  final HadithApi _apiService = HadithApi();
  final LocalStorageService _localStorage = LocalStorageService();
  
  List<dynamic> _books = [];
  List<dynamic> _allBooks = []; // For filtering
  List<dynamic> _hadiths = [];
  List<dynamic> _allHadiths = []; // For filtering
  
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get books => _books;
  List<dynamic> get hadiths => _hadiths;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Check if Hadith data is available locally
  bool isDataAvailable() {
    return _localStorage.isHadithDataAvailable();
  }

  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = '';
    _books = [];
    notifyListeners();

    try {
      final data = await _apiService.fetchBooks();
      _allBooks = data;
      _books = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHadithsByBook(String bookSlug) async {
    _isLoading = true;
    _errorMessage = '';
    _hadiths = [];
    notifyListeners();

    try {
      final data = await _apiService.fetchHadiths(bookSlug);
      _allHadiths = data;
      _hadiths = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterBooks(String query) {
    _books = _apiService.filterBooks(_allBooks, query);
    notifyListeners();
  }

  void filterHadiths(String query) {
    _hadiths = _apiService.filterHadiths(_allHadiths, query);
    notifyListeners();
  }
}
