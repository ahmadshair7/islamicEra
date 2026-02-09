import 'package:flutter/material.dart';

class SupplicationsScreen extends StatelessWidget {
  const SupplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of 20+ common Islamic supplications
    final List<Map<String, String>> supplications = [
      {
        'title': 'Morning Supplication',
        'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
        'transliteration': 'Asbahna wa asbahal-mulku lillah',
        'translation': 'We have entered the morning and the kingdom belongs to Allah',
      },
      {
        'title': 'Evening Supplication',
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        'transliteration': 'Amsayna wa amsal-mulku lillah',
        'translation': 'We have entered the evening and the kingdom belongs to Allah',
      },
      {
        'title': 'Before Eating',
        'arabic': 'بِسْمِ اللَّهِ',
        'transliteration': 'Bismillah',
        'translation': 'In the name of Allah',
      },
      {
        'title': 'After Eating',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
        'transliteration': 'Alhamdulillahil-ladhi at\'amana wa saqana',
        'translation': 'Praise be to Allah who has fed us and given us drink',
      },
      {
        'title': 'Entering Home',
        'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا',
        'transliteration': 'Bismillahi walajna wa bismillahi kharajna',
        'translation': 'In the name of Allah we enter and in the name of Allah we leave',
      },
      {
        'title': 'Leaving Home',
        'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
        'transliteration': 'Bismillah, tawakkaltu \'alallah',
        'translation': 'In the name of Allah, I place my trust in Allah',
      },
      {
        'title': 'Before Sleeping',
        'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        'transliteration': 'Bismika Allahumma amutu wa ahya',
        'translation': 'In Your name O Allah, I die and I live',
      },
      {
        'title': 'Waking Up',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا',
        'transliteration': 'Alhamdulillahil-ladhi ahyana ba\'da ma amatana',
        'translation': 'Praise be to Allah who gave us life after death',
      },
      {
        'title': 'Entering Masjid',
        'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
        'transliteration': 'Allahumma iftah li abwaba rahmatik',
        'translation': 'O Allah, open for me the doors of Your mercy',
      },
      {
        'title': 'Leaving Masjid',
        'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
        'transliteration': 'Allahumma inni as\'aluka min fadlik',
        'translation': 'O Allah, I ask You from Your bounty',
      },
      {
        'title': 'For Forgiveness',
        'arabic': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
        'transliteration': 'Astaghfirullah wa atubu ilayh',
        'translation': 'I seek forgiveness from Allah and repent to Him',
      },
      {
        'title': 'For Parents',
        'arabic': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
        'transliteration': 'Rabbir-hamhuma kama rabbayani saghira',
        'translation': 'My Lord, have mercy upon them as they brought me up when I was small',
      },
      {
        'title': 'For Knowledge',
        'arabic': 'رَبِّ زِدْنِي عِلْمًا',
        'transliteration': 'Rabbi zidni \'ilma',
        'translation': 'My Lord, increase me in knowledge',
      },
      {
        'title': 'For Guidance',
        'arabic': 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
        'transliteration': 'Allahumma-hdini wa saddidni',
        'translation': 'O Allah, guide me and make me steadfast',
      },
      {
        'title': 'For Protection',
        'arabic': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        'transliteration': 'A\'udhu bikalimatillahit-tammati min sharri ma khalaq',
        'translation': 'I seek refuge in the perfect words of Allah from the evil of what He has created',
      },
      {
        'title': 'For Patience',
        'arabic': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا',
        'transliteration': 'Rabbana afrigh \'alayna sabra',
        'translation': 'Our Lord, pour upon us patience',
      },
      {
        'title': 'For Health',
        'arabic': 'اللَّهُمَّ عَافِنِي فِي بَدَنِي',
        'transliteration': 'Allahumma \'afini fi badani',
        'translation': 'O Allah, grant me health in my body',
      },
      {
        'title': 'For Provision',
        'arabic': 'اللَّهُمَّ ارْزُقْنِي رِزْقًا حَلَالًا طَيِّبًا',
        'transliteration': 'Allahumma-rzuqni rizqan halalan tayyiba',
        'translation': 'O Allah, grant me lawful and good provision',
      },
      {
        'title': 'For Good Character',
        'arabic': 'اللَّهُمَّ اهْدِنِي لِأَحْسَنِ الْأَخْلَاقِ',
        'transliteration': 'Allahumma-hdini li-ahsanil-akhlaqi',
        'translation': 'O Allah, guide me to the best of character',
      },
      {
        'title': 'For Success',
        'arabic': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
        'transliteration': 'Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan',
        'translation': 'Our Lord, give us good in this world and good in the Hereafter',
      },
      {
        'title': 'When in Difficulty',
        'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        'transliteration': 'Hasbunallahu wa ni\'mal-wakil',
        'translation': 'Allah is sufficient for us and He is the best Disposer of affairs',
      },
      {
        'title': 'For Gratitude',
        'arabic': 'الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ',
        'transliteration': 'Alhamdulillahi \'ala kulli hal',
        'translation': 'Praise be to Allah in all circumstances',
      },
      {
        'title': 'Before Travel',
        'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا',
        'transliteration': 'Subhanal-ladhi sakhkhara lana hadha',
        'translation': 'Glory be to Him who has subjected this to us',
      },
      {
        'title': 'When Seeing Someone Afflicted',
        'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ',
        'transliteration': 'Alhamdulillahil-ladhi \'afani mimma-btalaka bihi',
        'translation': 'Praise be to Allah who has spared me from what He has afflicted you with',
      },
      {
        'title': 'For the Deceased',
        'arabic': 'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ',
        'transliteration': 'Allahumma-ghfir lahu warhamhu',
        'translation': 'O Allah, forgive him and have mercy on him',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Supplications'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: supplications.length,
        itemBuilder: (context, index) {
          final dua = supplications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dua['title']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Arabic Text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      dua['arabic']!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF003366),
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Transliteration
                  Text(
                    dua['transliteration']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Translation
                  Text(
                    dua['translation']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
