import 'dart:math';

class RandomHadith {
  final String arabic;
  final String translation;
  final String narrator;
  final String reference;

  RandomHadith({
    required this.arabic,
    required this.translation,
    required this.narrator,
    required this.reference,
  });
}

class RandomHadithService {
  static final RandomHadithService _instance = RandomHadithService._internal();
  factory RandomHadithService() => _instance;
  RandomHadithService._internal();

  final Random _random = Random();

  // Collection of authentic hadiths
  final List<RandomHadith> _hadiths = [
    RandomHadith(
      arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      translation: 'Actions are judged by intentions',
      narrator: 'Umar ibn Al-Khattab',
      reference: 'Sahih Bukhari 1',
    ),
    RandomHadith(
      arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      translation: 'A Muslim is one from whose tongue and hands other Muslims are safe',
      narrator: 'Abdullah ibn Amr',
      reference: 'Sahih Bukhari 10',
    ),
    RandomHadith(
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      translation: 'The best among you are those who learn the Quran and teach it',
      narrator: 'Uthman ibn Affan',
      reference: 'Sahih Bukhari 5027',
    ),
    RandomHadith(
      arabic: 'الدِّينُ النَّصِيحَةُ',
      translation: 'Religion is sincerity',
      narrator: 'Tamim Ad-Dari',
      reference: 'Sahih Muslim 55',
    ),
    RandomHadith(
      arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      translation: 'Whoever believes in Allah and the Last Day should speak good or remain silent',
      narrator: 'Abu Hurairah',
      reference: 'Sahih Bukhari 6018',
    ),
    RandomHadith(
      arabic: 'الْمُؤْمِنُ لِلْمُؤْمِنِ كَالْبُنْيَانِ يَشُدُّ بَعْضُهُ بَعْضًا',
      translation: 'The believer to another believer is like a building whose different parts support each other',
      narrator: 'Abu Musa',
      reference: 'Sahih Bukhari 481',
    ),
    RandomHadith(
      arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      translation: 'None of you truly believes until he loves for his brother what he loves for himself',
      narrator: 'Anas ibn Malik',
      reference: 'Sahih Bukhari 13',
    ),
    RandomHadith(
      arabic: 'مَنْ غَشَّنَا فَلَيْسَ مِنَّا',
      translation: 'Whoever deceives us is not one of us',
      narrator: 'Abu Hurairah',
      reference: 'Sahih Muslim 101',
    ),
    RandomHadith(
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      translation: 'Your smile in the face of your brother is charity',
      narrator: 'Abu Dharr',
      reference: 'Tirmidhi 1956',
    ),
    RandomHadith(
      arabic: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      translation: 'A good word is charity',
      narrator: 'Abu Hurairah',
      reference: 'Sahih Bukhari 2989',
    ),
    RandomHadith(
      arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
      translation: 'Fear Allah wherever you are',
      narrator: 'Abu Dharr',
      reference: 'Tirmidhi 1987',
    ),
    RandomHadith(
      arabic: 'إِنَّ اللَّهَ طَيِّبٌ لَا يَقْبَلُ إِلَّا طَيِّبًا',
      translation: 'Allah is Pure and accepts only that which is pure',
      narrator: 'Abu Hurairah',
      reference: 'Sahih Muslim 1015',
    ),
    RandomHadith(
      arabic: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
      translation: 'The strong believer is better and more beloved to Allah than the weak believer',
      narrator: 'Abu Hurairah',
      reference: 'Sahih Muslim 2664',
    ),
    RandomHadith(
      arabic: 'مَنْ صَلَّى الْفَجْرَ فَهُوَ فِي ذِمَّةِ اللَّهِ',
      translation: 'Whoever prays Fajr is under the protection of Allah',
      narrator: 'Jundub ibn Abdullah',
      reference: 'Sahih Muslim 657',
    ),
    RandomHadith(
      arabic: 'الْجَنَّةُ تَحْتَ أَقْدَامِ الْأُمَّهَاتِ',
      translation: 'Paradise lies at the feet of mothers',
      narrator: 'Anas ibn Malik',
      reference: 'Sunan An-Nasa\'i 3104',
    ),
  ];

  RandomHadith getRandomHadith() {
    final index = _random.nextInt(_hadiths.length);
    return _hadiths[index];
  }
}
