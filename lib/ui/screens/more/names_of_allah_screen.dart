import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> names = [
    {'arabic': 'الرَّحْمَنُ', 'trans': 'Ar-Rahman', 'meaning': 'The Most Merciful'},
    {'arabic': 'الرَّحِيمُ', 'trans': 'Ar-Raheem', 'meaning': 'The Bestower of Mercy'},
    {'arabic': 'الْمَلِكُ', 'trans': 'Al-Malik', 'meaning': 'The King'},
    {'arabic': 'الْقُدُّوسُ', 'trans': 'Al-Quddus', 'meaning': 'The Most Holy'},
    {'arabic': 'السَّلَامُ', 'trans': 'As-Salam', 'meaning': 'The Source of Peace'},
    {'arabic': 'الْمُؤْمِنُ', 'trans': 'Al-Mu\'min', 'meaning': 'The Giver of Faith'},
    {'arabic': 'الْمُهَيْمِنُ', 'trans': 'Al-Muhaymin', 'meaning': 'The Guardian'},
    {'arabic': 'الْعَزِيزُ', 'trans': 'Al-Aziz', 'meaning': 'The All Mighty'},
    {'arabic': 'الْجَبَّارُ', 'trans': 'Al-Jabbar', 'meaning': 'The Compeller'},
    {'arabic': 'الْمُتَكَبِّرُ', 'trans': 'Al-Mutakabbir', 'meaning': 'The Supreme'},
    {'arabic': 'الْخَالِقُ', 'trans': 'Al-Khaliq', 'meaning': 'The Creator'},
    {'arabic': 'الْبَارِئُ', 'trans': 'Al-Bari\'', 'meaning': 'The Evolver'},
    {'arabic': 'الْمُصَوِّرُ', 'trans': 'Al-Musawwir', 'meaning': 'The Fashioner'},
    {'arabic': 'الْغَفَّارُ', 'trans': 'Al-Ghaffar', 'meaning': 'The Great Forgiver'},
    {'arabic': 'الْقَهَّارُ', 'trans': 'Al-Qahhar', 'meaning': 'The All-Prevailing One'},
    {'arabic': 'الْوَهَّابُ', 'trans': 'Al-Wahhab', 'meaning': 'The Supreme Bestower'},
    {'arabic': 'الرَّزَّاقُ', 'trans': 'Ar-Razzaq', 'meaning': 'The Provider'},
    {'arabic': 'الْفَتَّاحُ', 'trans': 'Al-Fattah', 'meaning': 'The Opener'},
    {'arabic': 'الْعَلِيمُ', 'trans': 'Al-Alim', 'meaning': 'The All-Knowing'},
    {'arabic': 'الْقَابِضُ', 'trans': 'Al-Qabid', 'meaning': 'The Withholder'},
    {'arabic': 'الْبَاسِطُ', 'trans': 'Al-Basit', 'meaning': 'The Expander'},
    {'arabic': 'الْخَافِضُ', 'trans': 'Al-Khafid', 'meaning': 'The Abaser'},
    {'arabic': 'الرَّافِعُ', 'trans': 'Ar-Rafi\'', 'meaning': 'The Exalter'},
    {'arabic': 'الْمُعِزُّ', 'trans': 'Al-Mu\'izz', 'meaning': 'The Giver of Honor'},
    {'arabic': 'الْمُذِلُّ', 'trans': 'Al-Mudhill', 'meaning': 'The Giver of Dishonor'},
    {'arabic': 'السَّمِيعُ', 'trans': 'As-Sami\'', 'meaning': 'The All-Hearing'},
    {'arabic': 'الْبَصِيرُ', 'trans': 'Al-Basir', 'meaning': 'The All-Seeing'},
    {'arabic': 'الْحَكَمُ', 'trans': 'Al-Hakam', 'meaning': 'The Judge'},
    {'arabic': 'الْعَدْلُ', 'trans': 'Al-Adl', 'meaning': 'The Just'},
    {'arabic': 'اللَّطِيفُ', 'trans': 'Al-Latif', 'meaning': 'The Subtle One'},
    {'arabic': 'الْخَبِيرُ', 'trans': 'Al-Khabir', 'meaning': 'The All-Aware'},
    {'arabic': 'الْحَلِيمُ', 'trans': 'Al-Halim', 'meaning': 'The Forbearing'},
    {'arabic': 'الْعَظِيمُ', 'trans': 'Al-Azim', 'meaning': 'The Magnificent'},
    {'arabic': 'الْغَفُورُ', 'trans': 'Al-Ghafur', 'meaning': 'The Forgiving'},
    {'arabic': 'الشَّكُورُ', 'trans': 'Ash-Shakur', 'meaning': 'The Appreciative'},
    {'arabic': 'الْعَلِيُّ', 'trans': 'Al-Aliyy', 'meaning': 'The Most High'},
    {'arabic': 'الْكَبِيرُ', 'trans': 'Al-Kabir', 'meaning': 'The Most Great'},
    {'arabic': 'الْحَفِيظُ', 'trans': 'Al-Hafiz', 'meaning': 'The Preserver'},
    {'arabic': 'الْمُقِيتُ', 'trans': 'Al-Muqit', 'meaning': 'The Sustainer'},
    {'arabic': 'الْحَسِيبُ', 'trans': 'Al-Hasib', 'meaning': 'The Reckoner'},
    {'arabic': 'الْجَلِيلُ', 'trans': 'Al-Jalil', 'meaning': 'The Majestic'},
    {'arabic': 'الْكَرِيمُ', 'trans': 'Al-Karim', 'meaning': 'The Generous'},
    {'arabic': 'الرَّقِيبُ', 'trans': 'Ar-Raqib', 'meaning': 'The Watchful'},
    {'arabic': 'الْمُجِيبُ', 'trans': 'Al-Mujib', 'meaning': 'The Responsive'},
    {'arabic': 'الْوَاسِعُ', 'trans': 'Al-Wasi\'', 'meaning': 'The All-Encompassing'},
    {'arabic': 'الْحَكِيمُ', 'trans': 'Al-Hakim', 'meaning': 'The Wise'},
    {'arabic': 'الْوَدُودُ', 'trans': 'Al-Wadud', 'meaning': 'The Loving'},
    {'arabic': 'الْمَجِيدُ', 'trans': 'Al-Majid', 'meaning': 'The Glorious'},
    {'arabic': 'الْبَاعِثُ', 'trans': 'Al-Ba\'ith', 'meaning': 'The Resurrector'},
    {'arabic': 'الشَّهِيدُ', 'trans': 'Ash-Shahid', 'meaning': 'The Witness'},
    {'arabic': 'الْحَقُّ', 'trans': 'Al-Haqq', 'meaning': 'The Truth'},
    {'arabic': 'الْوَكِيلُ', 'trans': 'Al-Wakil', 'meaning': 'The Trustee'},
    {'arabic': 'الْقَوِيُّ', 'trans': 'Al-Qawiyy', 'meaning': 'The Strong'},
    {'arabic': 'الْمَتِينُ', 'trans': 'Al-Matin', 'meaning': 'The Firm'},
    {'arabic': 'الْوَلِيُّ', 'trans': 'Al-Waliyy', 'meaning': 'The Protecting Friend'},
    {'arabic': 'الْحَمِيدُ', 'trans': 'Al-Hamid', 'meaning': 'The Praiseworthy'},
    {'arabic': 'الْمُحْصِي', 'trans': 'Al-Muhsi', 'meaning': 'The Reckoner'},
    {'arabic': 'الْمُبْدِئُ', 'trans': 'Al-Mubdi\'', 'meaning': 'The Originator'},
    {'arabic': 'الْمُعِيدُ', 'trans': 'Al-Mu\'id', 'meaning': 'The Restorer'},
    {'arabic': 'الْمُحْيِي', 'trans': 'Al-Muhyi', 'meaning': 'The Giver of Life'},
    {'arabic': 'الْمُمِيتُ', 'trans': 'Al-Mumit', 'meaning': 'The Bringer of Death'},
    {'arabic': 'الْحَيُّ', 'trans': 'Al-Hayy', 'meaning': 'The Ever-Living'},
    {'arabic': 'الْقَيُّومُ', 'trans': 'Al-Qayyum', 'meaning': 'The Self-Sustaining'},
    {'arabic': 'الْوَاجِدُ', 'trans': 'Al-Wajid', 'meaning': 'The Finder'},
    {'arabic': 'الْمَاجِدُ', 'trans': 'Al-Majid', 'meaning': 'The Noble'},
    {'arabic': 'الْوَاحِدُ', 'trans': 'Al-Wahid', 'meaning': 'The Unique'},
    {'arabic': 'الصَّمَدُ', 'trans': 'As-Samad', 'meaning': 'The Eternal'},
    {'arabic': 'الْقَادِرُ', 'trans': 'Al-Qadir', 'meaning': 'The Capable'},
    {'arabic': 'الْمُقْتَدِرُ', 'trans': 'Al-Muqtadir', 'meaning': 'The Powerful'},
    {'arabic': 'الْمُقَدِّمُ', 'trans': 'Al-Muqaddim', 'meaning': 'The Expediter'},
    {'arabic': 'الْمُؤَخِّرُ', 'trans': 'Al-Mu\'akhkhir', 'meaning': 'The Delayer'},
    {'arabic': 'الأَوَّلُ', 'trans': 'Al-Awwal', 'meaning': 'The First'},
    {'arabic': 'الآخِرُ', 'trans': 'Al-Akhir', 'meaning': 'The Last'},
    {'arabic': 'الظَّاهِرُ', 'trans': 'Az-Zahir', 'meaning': 'The Manifest'},
    {'arabic': 'الْبَاطِنُ', 'trans': 'Al-Batin', 'meaning': 'The Hidden'},
    {'arabic': 'الْوَالِي', 'trans': 'Al-Wali', 'meaning': 'The Governor'},
    {'arabic': 'الْمُتَعَالِي', 'trans': 'Al-Muta\'ali', 'meaning': 'The Most Exalted'},
    {'arabic': 'الْبَرُّ', 'trans': 'Al-Barr', 'meaning': 'The Source of Goodness'},
    {'arabic': 'التَّوَّابُ', 'trans': 'At-Tawwab', 'meaning': 'The Acceptor of Repentance'},
    {'arabic': 'الْمُنْتَقِمُ', 'trans': 'Al-Muntaqim', 'meaning': 'The Avenger'},
    {'arabic': 'الْعَفُوُّ', 'trans': 'Al-Afuww', 'meaning': 'The Pardoner'},
    {'arabic': 'الرَّؤُوفُ', 'trans': 'Ar-Ra\'uf', 'meaning': 'The Kind'},
    {'arabic': 'مَالِكُ الْمُلْكِ', 'trans': 'Malik-ul-Mulk', 'meaning': 'Master of the Kingdom'},
    {'arabic': 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'trans': 'Dhul-Jalali wal-Ikram', 'meaning': 'Lord of Majesty and Generosity'},
    {'arabic': 'الْمُقْسِطُ', 'trans': 'Al-Muqsit', 'meaning': 'The Equitable'},
    {'arabic': 'الْجَامِعُ', 'trans': 'Al-Jami\'', 'meaning': 'The Gatherer'},
    {'arabic': 'الْغَنِيُّ', 'trans': 'Al-Ghaniyy', 'meaning': 'The Self-Sufficient'},
    {'arabic': 'الْمُغْنِي', 'trans': 'Al-Mughni', 'meaning': 'The Enricher'},
    {'arabic': 'الْمَانِعُ', 'trans': 'Al-Mani\'', 'meaning': 'The Preventer'},
    {'arabic': 'الضَّارُّ', 'trans': 'Ad-Darr', 'meaning': 'The Distresser'},
    {'arabic': 'النَّافِعُ', 'trans': 'An-Nafi\'', 'meaning': 'The Benefactor'},
    {'arabic': 'النُّورُ', 'trans': 'An-Nur', 'meaning': 'The Light'},
    {'arabic': 'الْهَادِي', 'trans': 'Al-Hadi', 'meaning': 'The Guide'},
    {'arabic': 'الْبَدِيعُ', 'trans': 'Al-Badi\'', 'meaning': 'The Incomparable'},
    {'arabic': 'الْبَاقِي', 'trans': 'Al-Baqi', 'meaning': 'The Everlasting'},
    {'arabic': 'الْوَارِثُ', 'trans': 'Al-Warith', 'meaning': 'The Inheritor'},
    {'arabic': 'الرَّشِيدُ', 'trans': 'Ar-Rashid', 'meaning': 'The Guide to the Right Path'},
    {'arabic': 'الصَّبُورُ', 'trans': 'As-Sabur', 'meaning': 'The Patient'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNames = names.where((name) =>
      name['trans']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      name['meaning']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      name['arabic']!.contains(_searchQuery)
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredNames.length,
              itemBuilder: (context, index) {
                final name = filteredNames[index];
                final realIndex = names.indexOf(name) + 1;
                return _buildNameCard(name, realIndex);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '99 Names of Allah',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Name or Meaning...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(Map<String, String> name, int index) {
    final List<Color> cardColors = [
      Colors.teal.shade700,
      Colors.indigo.shade700,
      Colors.brown.shade700,
      Colors.deepPurple.shade700,
      Colors.blueGrey.shade700,
    ];
    
    final Color color = cardColors[index % cardColors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$index',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                FittedBox(
                  child: Text(
                    name['arabic']!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name['trans']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name['meaning']!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
