import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../data/models/chat_message.dart';
import '../../../../core/theme.dart';
import 'package:intl/intl.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController(text: "gpt-3.5-turbo");

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Islamic AI Assistant"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, chatProvider),
            tooltip: "Settings",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => chatProvider.clearChat(),
            tooltip: "Clear Chat",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.dark : AppGradients.primary,
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 60),
            // Header Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text(
                "Ask anything about Islam. Works offline using local rules, or online with OpenAI.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: chatProvider.messages.isEmpty
                    ? _buildWelcomeState(isDark)
                    : _buildChatList(chatProvider, isDark),
              ),
            ),
            _buildInputArea(chatProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 60, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          const Text(
            "Assalamu Alaikum",
            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "I am your Islamic Assistant. Ask me anything about Prayer Times, Quran, Hadith, or Duas!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "✨ Works Offline - No Setup Required",
            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(ChatProvider chatProvider, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatProvider.messages.length) {
          return _buildLoadingBubble(isDark);
        }
        final message = chatProvider.messages[index];
        return _buildMessageBubble(message, isDark);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isAssistant = message.role == MessageRole.assistant;
    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAssistant 
              ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white)
              : AppColors.accent,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAssistant ? 0 : 20),
            bottomRight: Radius.circular(isAssistant ? 20 : 0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isAssistant ? (isDark ? Colors.white : Colors.black87) : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: TextStyle(
                fontSize: 9,
                color: isAssistant ? (isDark ? Colors.white54 : Colors.grey) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider chatProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Ask about Islam...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) {
                  chatProvider.sendMessage(_messageController.text, context);
                  _messageController.clear();
                  _scrollToBottom();
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              chatProvider.sendMessage(_messageController.text, context);
              _messageController.clear();
              _scrollToBottom();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black87, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("OpenAI Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: "OpenAI API Key",
                hintText: "sk-...",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: "Model Name",
                hintText: "gpt-3.5-turbo, gpt-4, etc.",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_apiKeyController.text.isNotEmpty) {
                chatProvider.initAssistant(
                  apiKey: _apiKeyController.text,
                  model: _modelController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("OpenAI Configured!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter an API Key")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
