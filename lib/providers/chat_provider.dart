import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/chat_message.dart';
import '../data/services/ai_assistant_service.dart';
import 'prayer_provider.dart';
import 'dua_provider.dart';
import 'quran_provider.dart';
import 'hadith_provider.dart';

class ChatProvider with ChangeNotifier {
  final AIAssistantService _aiService = AIAssistantService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    // OpenAI requires an API Key, so we don't initialize with defaults here.
  }

  void initAssistant({required String apiKey, String? model}) {
    _aiService.initialize(apiKey: apiKey, model: model);
    notifyListeners();
  }

  Future<void> sendMessage(String text, BuildContext context) async {
    if (text.trim().isEmpty) return;

    // Collect Context
    final String appData = _collectAppData(context);

    _messages.add(ChatMessage(text: text, role: MessageRole.user));
    _isLoading = true;
    notifyListeners();

    final response = await _aiService.sendMessage(text, context: appData);
    
    _messages.add(ChatMessage(text: response, role: MessageRole.assistant));
    _isLoading = false;
    notifyListeners();
  }

  String _collectAppData(BuildContext context) {
    String contextStr = "";
    
    try {
      // 1. Prayer Times
      final prayer = Provider.of<PrayerProvider>(context, listen: false);
      if (prayer.prayerData != null) {
        final t = prayer.prayerData!.timings;
        contextStr += "Prayer Timings (Today): Fajr: ${t.fajr}, Dhuhr: ${t.dhuhr}, Asr: ${t.asr}, Maghrib: ${t.maghrib}, Isha: ${t.isha}\n";
      }

      // 2. Duas
      final duaProvider = Provider.of<DuaProvider>(context, listen: false);
      contextStr += "Available Duas in App:\n";
      for (var d in duaProvider.duas.take(10)) { // Limit to 10 for context length
        contextStr += "- ${d.title}: ${d.arabic} (${d.translation})\n";
      }

      // 3. Hadith Books
      final hadith = Provider.of<HadithProvider>(context, listen: false);
      if (hadith.books.isNotEmpty) {
        contextStr += "Available Hadith Books: ${hadith.books.map((b) => b['bookName']).join(', ')}\n";
      }
      
      // 4. Quran Surahs
      final quran = Provider.of<QuranProvider>(context, listen: false);
      if (quran.surahs.isNotEmpty) {
        contextStr += "Quran Info: Total 114 Surahs available. First few: ${quran.surahs.take(5).map((s) => s.englishName).join(', ')}\n";
      }

    } catch (e) {
      print("Error gathering context: $e");
    }

    return contextStr;
  }

  void clearChat() {
    _messages.clear();
    _aiService.resetChat();
    notifyListeners();
  }
}
