import 'dart:convert';
import 'package:http/http.dart' as http;
// ignore: unused_import
import '../models/chat_message.dart';

class AIAssistantService {
  final List<Map<String, String>> _history = [];

  String? _apiKey;
  String? _model;

  AIAssistantService();

  void initialize({required String apiKey, String? model}) {
    _apiKey = apiKey;
    _model = model ?? "gpt-3.5-turbo";
  }

  Future<String> sendMessage(String text, {String? context}) async {
    final query = text.toLowerCase().trim();

    // 1. If we have an API Key, try OpenAI first
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      try {
        return await _getOpenAIResponse(text, context);
      } catch (e) {
        print("OpenAI Error, falling back to local: $e");
        // Fall through to local rules
      }
    }
    
    // 2. Local rule-based responses (Offline fallback)
    if (_containsAny(query, ['prayer', 'salah', 'namaz', 'time'])) {
      return _getPrayerTimeResponse(context);
    }
    
    if (_containsAny(query, ['quran', 'surah', 'ayah', 'verse'])) {
      return _getQuranResponse(query, context);
    }
    
    if (_containsAny(query, ['hadith', 'bukhari', 'muslim', 'prophet'])) {
      return _getHadithResponse(context);
    }
    
    if (_containsAny(query, ['dua', 'supplication', 'prayer'])) {
      return _getDuaResponse(context);
    }
    
    if (_containsAny(query, ['hello', 'hi', 'assalam', 'salam'])) {
      return "Wa Alaikum Assalam! I am your Islamic Assistant. I can help you with:\n\n• Prayer times\n• Quran verses and Surahs\n• Hadith from authentic books\n• Duas and supplications\n\nHow may I assist you today? Allah knows best.";
    }
    
    // Default response
    return "I can help you with information about:\n\n• Prayer Times - Ask 'What are today's prayer times?'\n• Quran - Ask about specific Surahs or verses\n• Hadith - Ask about Hadith collections\n• Duas - Ask for specific supplications\n\nPlease ask a question related to these topics. Allah knows best.";
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _getPrayerTimeResponse(String? context) {
    if (context != null && context.contains('Prayer Timings')) {
      final lines = context.split('\n');
      final prayerLine = lines.firstWhere(
        (line) => line.contains('Prayer Timings'),
        orElse: () => '',
      );
      
      if (prayerLine.isNotEmpty) {
        return "According to the app's prayer timings:\n\n$prayerLine\n\nMay Allah accept your prayers. Allah knows best.";
      }
    }
    
    return "Prayer times are calculated based on your location. Please check the Prayer Times section in the app for accurate timings for today.\n\nThe five daily prayers are:\n• Fajr (Dawn)\n• Dhuhr (Noon)\n• Asr (Afternoon)\n• Maghrib (Sunset)\n• Isha (Night)\n\nAllah knows best.";
  }

  String _getQuranResponse(String query, String? context) {
    if (context != null && context.contains('Quran Info')) {
      return "The Holy Quran contains 114 Surahs (chapters) revealed to Prophet Muhammad ﷺ over 23 years.\n\nYou can explore all Surahs in the Quran section of this app, including:\n• Arabic text\n• English translation\n• Urdu translation\n• Audio recitation\n\nSome well-known Surahs include Al-Fatiha, Al-Baqarah, Al-Ikhlas, and Al-Falaq.\n\nAllah knows best.";
    }
    
    return "The Holy Quran is the final revelation from Allah to humanity, revealed to Prophet Muhammad ﷺ.\n\nYou can read and listen to the complete Quran in the Quran section of this app with translations in English and Urdu.\n\nAllah knows best.";
  }

  String _getHadithResponse(String? context) {
    if (context != null && context.contains('Hadith Books')) {
      return "The app contains authentic Hadith collections including:\n\n• Sahih Bukhari\n• Sahih Muslim\n• And other authentic collections\n\nHadith are the sayings, actions, and approvals of Prophet Muhammad ﷺ, which guide us in understanding and practicing Islam.\n\nYou can browse these collections in the Hadith section of the app.\n\nAllah knows best.";
    }
    
    return "Hadith are the recorded sayings and actions of Prophet Muhammad ﷺ. The most authentic collections are Sahih Bukhari and Sahih Muslim.\n\nYou can explore authentic Hadith in the Hadith section of this app.\n\nAllah knows best.";
  }

  String _getDuaResponse(String? context) {
    if (context != null && context.contains('Available Duas')) {
      final lines = context.split('\n');
      final duaLines = lines.where((line) => line.trim().startsWith('-')).take(5).join('\n');
      
      if (duaLines.isNotEmpty) {
        return "Here are some Duas available in the app:\n\n$duaLines\n\nYou can find more Duas in the Duas section of the app with Arabic text and translations.\n\nAllah knows best.";
      }
    }
    
    return "The app contains a collection of authentic Duas (supplications) for various occasions including:\n\n• Morning and evening remembrance\n• Before and after meals\n• For protection\n• For guidance\n• And many more\n\nPlease visit the Duas section to explore the complete collection.\n\nAllah knows best.";
  }

  Future<String> _getOpenAIResponse(String text, String? context) async {
    const url = "https://api.openai.com/v1/chat/completions";
    
    // Add to history
    _history.add({"role": "user", "content": text});

    final messages = [
      {
        "role": "system", 
        "content": "You are a knowledgeable Islamic Assistant in a mobile app called 'Islamic Era'. "
                  "Provide accurate, polite responses based on Quran and Sunnah. "
                  "Use the following app context if relevant: $context"
      },
      ..._history,
    ];

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_apiKey",
      },
      body: json.encode({
        "model": _model,
        "messages": messages,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      _history.add({"role": "assistant", "content": reply});
      return reply;
    } else {
      throw Exception("OpenAI API returned status: ${response.statusCode}");
    }
  }

  void resetChat() {
    _history.clear();
  }
}
