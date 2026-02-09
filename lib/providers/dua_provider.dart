import 'package:flutter/foundation.dart';

class Dua {
  final String title;
  final String arabic;
  final String translation;

  Dua({required this.title, required this.arabic, required this.translation});
}

class DuaProvider with ChangeNotifier {
  final List<Dua> _duas = [
    Dua(
      title: "Morning Supplication",
      arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ",
      translation: "We have entered the morning and the kingdom belongs to Allah, and all praise is for Allah.",
    ),
    Dua(
      title: "Evening Supplication",
      arabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ",
      translation: "We have entered the evening and the kingdom belongs to Allah, and all praise is for Allah.",
    ),
    Dua(
      title: "Before Sleeping",
      arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
      translation: "In Your name O Allah, I die and I live.",
    ),
    Dua(
      title: "Waking Up",
      arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ",
      translation: "Praise be to Allah who gave us life after death and to Him is the resurrection.",
    ),
    Dua(
      title: "Before Eating",
      arabic: "بِسْمِ اللَّهِ",
      translation: "In the name of Allah.",
    ),
    Dua(
      title: "After Eating",
      arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ",
      translation: "Praise be to Allah who has fed us and given us drink and made us Muslims.",
    ),
    Dua(
      title: "Entering Home",
      arabic: "بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا وَعَلَى اللَّهِ رَبِّنَا تَوَكَّلْنَا",
      translation: "In the name of Allah we enter and in the name of Allah we leave, and upon Allah our Lord we place our trust.",
    ),
    Dua(
      title: "Leaving Home",
      arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
      translation: "In the name of Allah, I place my trust in Allah. There is no power nor strength except with Allah.",
    ),
    Dua(
      title: "Entering Masjid",
      arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
      translation: "O Allah, open for me the doors of Your mercy.",
    ),
    Dua(
      title: "Leaving Masjid",
      arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ",
      translation: "O Allah, I ask You from Your bounty.",
    ),
    Dua(
      title: "For Forgiveness",
      arabic: "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
      translation: "I seek forgiveness from Allah and repent to Him.",
    ),
    Dua(
      title: "For Parents",
      arabic: "رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
      translation: "My Lord, have mercy upon them as they brought me up when I was small.",
    ),
    Dua(
      title: "For Knowledge",
      arabic: "رَبِّ زِدْنِي عِلْمًا",
      translation: "My Lord, increase me in knowledge.",
    ),
    Dua(
      title: "For Guidance",
      arabic: "اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي",
      translation: "O Allah, guide me and make me steadfast.",
    ),
    Dua(
      title: "For Protection",
      arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
      translation: "I seek refuge in the perfect words of Allah from the evil of what He has created.",
    ),
    Dua(
      title: "For Patience",
      arabic: "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا",
      translation: "Our Lord, pour upon us patience and make our steps firm.",
    ),
    Dua(
      title: "For Health",
      arabic: "اللَّهُمَّ عَافِنِي فِي بَدَنِي اللَّهُمَّ عَافِنِي فِي سَمْعِي اللَّهُمَّ عَافِنِي فِي بَصَرِي",
      translation: "O Allah, grant me health in my body. O Allah, grant me health in my hearing. O Allah, grant me health in my sight.",
    ),
    Dua(
      title: "For Provision",
      arabic: "اللَّهُمَّ ارْزُقْنِي رِزْقًا حَلَالًا طَيِّبًا",
      translation: "O Allah, grant me lawful and good provision.",
    ),
    Dua(
      title: "For Good Character",
      arabic: "اللَّهُمَّ اهْدِنِي لِأَحْسَنِ الْأَخْلَاقِ لَا يَهْدِي لِأَحْسَنِهَا إِلَّا أَنْتَ",
      translation: "O Allah, guide me to the best of character, for none can guide to the best of it except You.",
    ),
    Dua(
      title: "For Success",
      arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      translation: "Our Lord, give us good in this world and good in the Hereafter and protect us from the punishment of the Fire.",
    ),
    Dua(
      title: "When in Difficulty",
      arabic: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
      translation: "Allah is sufficient for us and He is the best Disposer of affairs.",
    ),
    Dua(
      title: "For Gratitude",
      arabic: "الْحَمْدُ لِلَّهِ عَلَى كُلِّ حَالٍ",
      translation: "Praise be to Allah in all circumstances.",
    ),
    Dua(
      title: "Before Travel",
      arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ",
      translation: "Glory be to Him who has subjected this to us, and we could never have it by our efforts. Surely, to our Lord we are returning.",
    ),
    Dua(
      title: "When Seeing Someone Afflicted",
      arabic: "الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ وَفَضَّلَنِي عَلَى كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلًا",
      translation: "Praise be to Allah who has spared me from what He has afflicted you with and favored me over many of His creation.",
    ),
    Dua(
      title: "For the Deceased",
      arabic: "اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ",
      translation: "O Allah, forgive him, have mercy on him, pardon him, and grant him wellness.",
    ),
  ];

  List<Dua> get duas => _duas;
}
