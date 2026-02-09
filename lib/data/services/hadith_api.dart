import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'hadith_local_service.dart';

class HadithApi {
  final String apiKey = r"$2y$10$GA3ElRrv48pXzrqlUl4ZK4RA7OrIMGnkz7qtxIz3aQK4kF0NO2";
  final HadithLocalService _hadithLocal = HadithLocalService();

  // Fetch all books using local storage
  Future<List<dynamic>> fetchBooks() async {
    try {
      return await _hadithLocal.getHadithBooks();
    } catch (e) {
      debugPrint("Error fetching books: $e");
      return [];
    }
  }

  // Fetch hadiths for a specific book using local storage
  Future<List<dynamic>> fetchHadiths(String bookSlug) async {
    try {
      return await _hadithLocal.getHadithsByBook(bookSlug);
    } catch (e) {
      debugPrint("Error fetching hadiths: $e");
      return [];
    }
  }

  // Filter books by search query
  List<dynamic> filterBooks(List<dynamic> books, String query) {
    if (query.isEmpty) {
      return List.from(books);
    }
    
    return books.where((book) {
      final name = book["bookName"]?.toString().toLowerCase() ?? "";
      final author = book["writerName"]?.toString().toLowerCase() ?? "";
      return name.contains(query) || author.contains(query);
    }).toList();
  }

  // Filter hadiths by search query
  List<dynamic> filterHadiths(List<dynamic> hadiths, String query) {
    if (query.isEmpty) {
      return List.from(hadiths);
    }
    
    return hadiths.where((h) {
      final arabic = h["hadithArabic"]?.toString().toLowerCase() ?? "";
      final english = h["hadithEnglish"]?.toString().toLowerCase() ?? "";
      final urdu = h["hadithUrdu"]?.toString().toLowerCase() ?? "";
      return arabic.contains(query) ||
             english.contains(query) ||
             urdu.contains(query);
    }).toList();
  }
}
