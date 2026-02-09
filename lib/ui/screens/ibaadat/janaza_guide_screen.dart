import 'package:flutter/material.dart';

class JanazaGuideScreen extends StatelessWidget {
  const JanazaGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Namaz-e-Janaza'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 20),
            _buildSectionHeader('Procedure (4 Takbeers)'),
            _buildProcedureStep(1, 'First Takbeer', 'Raise hands, say Allahu Akbar, then recite Thana and Surah Al-Fatiha'),
            _buildProcedureStep(2, 'Second Takbeer', 'Say Allahu Akbar (without raising hands), then recite Durood-e-Ibrahim'),
            _buildProcedureStep(3, 'Third Takbeer', 'Say Allahu Akbar, then recite the Janaza Dua for the deceased'),
            _buildProcedureStep(4, 'Fourth Takbeer', 'Say Allahu Akbar, then offer Salam to both sides'),
            const SizedBox(height: 24),
            
            _buildSectionHeader('1st Takbeer - Thana'),
            _buildDuaCard(
              'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
              'Subhanakal-lahumma wa bihamdika wa tabarakasmuka wa ta\'ala jadduka wa la ilaha ghayruk',
              'Glory be to You, O Allah, and praise be to You. Blessed is Your name and exalted is Your majesty. There is no god but You.'
            ),
            const SizedBox(height: 16),
            _buildDuaCard(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ * الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ * الرَّحْمَنِ الرَّحِيمِ * مَالِكِ يَوْمِ الدِّينِ * إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ * اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ * صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
              'Bismillahir-Rahmanir-Rahim...',
              'Surah Al-Fatiha (The Opening)'
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('2nd Takbeer - Durood-e-Ibrahim'),
            _buildDuaCard(
              'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ * اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
              'Allahumma salli \'ala Muhammadin wa \'ala ali Muhammadin kama sallayta \'ala Ibrahima wa \'ala ali Ibrahima innaka Hamidun Majid. Allahumma barik \'ala Muhammadin wa \'ala ali Muhammadin kama barakta \'ala Ibrahima wa \'ala ali Ibrahima innaka Hamidun Majid',
              'O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim. You are indeed Praiseworthy, Glorious. O Allah, bless Muhammad and the family of Muhammad, as You blessed Ibrahim and the family of Ibrahim. You are indeed Praiseworthy, Glorious.'
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('3rd Takbeer - Janaza Dua'),
            _buildDuaCard(
              'اللَّهُمَّ اغْفِرْ لِحَيِّنَا وَمَيِّتِنَا وَشَاهِدِنَا وَغَائِبِنَا وَصَغِيرِنَا وَكَبِيرِنَا وَذَكَرِنَا وَأُنْثَانَا * اللَّهُمَّ مَنْ أَحْيَيْتَهُ مِنَّا فَأَحْيِهِ عَلَى الْإِسْلَامِ وَمَنْ تَوَفَّيْتَهُ مِنَّا فَتَوَفَّهُ عَلَى الْإِيمَانِ',
              'Allahumma-ghfir lihayyina wa mayyitina wa shahidina wa gha\'ibina wa saghirina wa kabirina wa dhakarina wa unthana. Allahumma man ahyaytahu minna fa-ahyihi \'alal-Islam wa man tawaffaytahu minna fatawaffahu \'alal-iman',
              'O Allah, forgive our living and our dead, those present and those absent, our young and our old, our males and our females. O Allah, whomever You keep alive, keep him alive in Islam, and whomever You cause to die, cause him to die in faith.'
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'For Male Deceased',
              'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ',
              'Allahumma-ghfir lahu warhamhu wa \'afihi wa\'fu \'anhu',
              'O Allah, forgive him, have mercy on him, pardon him, and grant him wellness.'
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'For Female Deceased',
              'اللَّهُمَّ اغْفِرْ لَهَا وَارْحَمْهَا وَعَافِهَا وَاعْفُ عَنْهَا',
              'Allahumma-ghfir laha warhamha wa \'afiha wa\'fu \'anha',
              'O Allah, forgive her, have mercy on her, pardon her, and grant her wellness.'
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('4th Takbeer'),
            _buildInfoCard(
              'After Fourth Takbeer',
              'Make a brief dua for yourself and all Muslims, then offer Salam to the right and left',
              'As-salamu \'alaykum wa rahmatullah (to the right)\nAs-salamu \'alaykum wa rahmatullah (to the left)',
              'Peace and mercy of Allah be upon you'
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF003366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.mosque, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Namaz-e-Janaza',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Funeral Prayer - A final prayer for the deceased Muslim',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003366),
        ),
      ),
    );
  }

  Widget _buildProcedureStep(int num, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF003366),
          foregroundColor: Colors.white,
          radius: 22,
          child: Text(
            '$num',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(content, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildDuaCard(String arabic, String transliteration, String translation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Column(
        children: [
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 20,
              height: 1.8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String arabic, String transliteration, String translation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
