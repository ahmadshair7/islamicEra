import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/bookmark.dart';

class BookmarkProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];
  bool _isInit = false;

  List<Bookmark> get bookmarks => [..._bookmarks];

  Future<void> loadBookmarks() async {
    if (_isInit) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? bookmarksJson = prefs.getString('bookmarks');
    
    if (bookmarksJson != null) {
      final List<dynamic> decoded = json.decode(bookmarksJson);
      _bookmarks = decoded.map((item) => Bookmark.fromJson(item)).toList();
      _bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    
    _isInit = true;
    notifyListeners();
  }

  Future<void> toggleBookmark(Bookmark bookmark) async {
    final index = _bookmarks.indexWhere((b) => b.id == bookmark.id && b.type == bookmark.type);
    
    if (index >= 0) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.add(bookmark);
      _bookmarks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    
    await _saveToPrefs();
    notifyListeners();
  }

  bool isBookmarked(String id, String type) {
    return _bookmarks.any((b) => b.id == id && b.type == type);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString('bookmarks', encoded);
  }

  Future<void> removeBookmark(String id, String type) async {
     _bookmarks.removeWhere((b) => b.id == id && b.type == type);
     await _saveToPrefs();
     notifyListeners();
  }
}
