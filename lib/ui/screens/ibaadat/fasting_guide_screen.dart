import 'package:flutter/material.dart';

class FastingGuideScreen extends StatelessWidget {
  const FastingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fasting (Roza)'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Essential Duas'),
            _buildDuaCard('Sehri (Suhoor)', 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ', 'I intend to keep the fast for tomorrow in the month of Ramadan.'),
            _buildDuaCard('Iftari (Iftar)', 'اللَّهُمَّ اِنِّى لَكَ صُمْتُ وَبِكَ امنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ اَفْطَرْتُ', 'O Allah! I fasted for You and I believe in You and I put my trust in You and with Your sustenance I break my fast.'),
            const SizedBox(height: 24),
            _buildSectionHeader('Rules & Guidance'),
            _buildInfoCard('What breaks the fast?', 'Eating, drinking, or smoking intentionally breaks the fast.'),
            _buildInfoCard('Who is exempt?', 'Children, elderly, travelers, and those with certain medical conditions are exempt.'),
            _buildInfoCard('Voluntary Fasts', 'Days like Arafah, Ashura, and Mondays/Thursdays are highly encouraged.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
    );
  }

  Widget _buildDuaCard(String title, String arabic, String translation) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 12),
            Text(arabic, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'Amiri')),
            const SizedBox(height: 8),
            Text(translation, style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.info, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }
}
