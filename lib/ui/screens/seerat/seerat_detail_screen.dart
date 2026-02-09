import 'package:flutter/material.dart';

class SeeratDetailScreen extends StatelessWidget {
  final String category;

  const SeeratDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> content = _getContent();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: content.isEmpty 
        ? const Center(child: Text('Content coming soon...'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return _buildContentCard(item, index);
            },
          ),
    );
  }

  Widget _buildContentCard(Map<String, String> item, int index) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF003366).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF003366),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF003366),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              item['body']!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getContent() {
    switch (category) {
      case 'Early Life':
        return [
          {
            'title': 'Birth (Year of the Elephant)',
            'body': 'Prophet Muhammad (SAW) was born in Mecca in 570 CE. His father, Abdullah, passed away before his birth.'
          },
          {
            'title': 'Childhood with Halimah (RA)',
            'body': 'As was the custom of the Meccans, he was sent to the desert to be raised by Halimah Sa\'dia (RA) for several years.'
          },
          {
            'title': 'Loss of Mother and Grandfather',
            'body': 'His mother Aminah passed away when he was 6, and his grandfather Abdul-Muttalib when he was 8. He was then raised by his uncle, Abu Talib.'
          },
          {
            'title': 'Marriage to Khadijah (RA)',
            'body': 'Known for his honesty (Al-Amin), he managed the trade caravans of Khadijah (RA) and eventually married her at age 25.'
          },
        ];
      case 'Prophethood':
        return [
          {
            'title': 'The First Revelation',
            'body': 'At age 40, while meditating in Cave Hira, the Angel Jibril (AS) appeared and commanded him to "Read" (Iqra).'
          },
          {
            'title': 'Private & Public Daw\'ah',
            'body': 'He first invited his close family and friends to Islam secretly for 3 years, then began public preaching at Mount Safa.'
          },
          {
            'title': 'The Year of Sorrow',
            'body': 'In the 10th year of Prophethood, both his uncle Abu Talib and his beloved wife Khadijah (RA) passed away.'
          },
        ];
      case 'Character':
        return [
          {
            'title': 'Honesty & Integrity',
            'body': 'Even before Islam, he was known as "As-Sadiq" (The Truthful) and "Al-Amin" (The Trustworthy).'
          },
          {
            'title': 'Mercy to All',
            'body': 'Allah says in the Quran: "We have not sent you except as a mercy to the worlds." He showed kindness to children, animals, and even his enemies.'
          },
          {
            'title': 'Simplicity',
            'body': 'Despite being the leader of the Ummah, he lived a very simple life, often sleeping on a straw mat and going days without a hot meal.'
          },
        ];
      case 'The Hijrah':
        return [
          {
            'title': 'The Migration to Madinah',
            'body': 'In 622 CE, after 13 years of persecution in Mecca, the Prophet (SAW) and his companions migrated to Yathrib (later known as Madinah Al-Munawwarah).'
          },
          {
            'title': 'Brotherhood (Mu\'akhah)',
            'body': 'In Madinah, the Prophet (SAW) established a unique bond of brotherhood between the Muhajireen (Migrants) and the Ansar (Helpers).'
          },
          {
            'title': 'The Constitution of Madinah',
            'body': 'He drafted a formal agreement between the Muslims and the Jews, ensuring religious freedom and mutual defense, making him the head of the first Islamic state.'
          },
        ];
      case 'Battles':
        return [
          {
            'title': 'The Battle of Badr',
            'body': 'The first major battle in Islam, where 313 Muslims defeated a much larger Meccan army of over 1,000, signifying Allah\'s support for the believers.'
          },
          {
            'title': 'The Battle of Uhud',
            'body': 'A significant encounter where the Muslims faced a setback due to a tactical error, teaching an enduring lesson on the importance of obedience to the Prophet (SAW).'
          },
          {
            'title': 'The Battle of the Trench (Khandaq)',
            'body': 'The Muslims successfully defended Madinah by digging a trench, as suggested by Salman Al-Farsi (RA), leading to the failure of the Meccan siege.'
          },
          {
            'title': 'The Conquest of Mecca',
            'body': 'In the 8th year of Hijrah, the Prophet (SAW) entered Mecca peacefully with 10,000 soldiers, granting a general amnesty to his former enemies.'
          },
        ];
      case 'Miracles':
        return [
          {
            'title': 'The Holy Quran',
            'body': 'The greatest and eternal miracle given to the Prophet (SAW), which remains unchanged and continues to guide humanity.'
          },
          {
            'title': 'Al-Isra wal-Mi\'raj',
            'body': 'The miraculous night journey from Mecca to Jerusalem and the ascension to the heavens where he spoke with Allah and was given the five daily prayers.'
          },
          {
            'title': 'Splitting of the Moon',
            'body': 'When the Meccans asked for a sign, the Prophet (SAW) pointed to the moon, and it was split into two distinct parts by the will of Allah.'
          },
          {
            'title': 'Water from Fingers',
            'body': 'On several occasions when water was scarce, the Prophet (SAW) placed his hand in a bowl, and water gushed out from between his fingers for the companions to drink and perform Wudu.'
          },
        ];
      default:
        return [
          {
            'title': 'Overview',
            'body': 'Detailed content for $category is being prepared including key events, timelines, and authentic narrations.'
          }
        ];
    }
  }
}
