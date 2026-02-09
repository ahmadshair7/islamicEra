class Ayat {
  final String arabicText;
  final String translation;
  final String surahName;
  final int surahNumber;
  final int ayatNumber;

  Ayat({
    required this.arabicText,
    required this.translation,
    required this.surahName,
    required this.surahNumber,
    required this.ayatNumber,
  });

  factory Ayat.fromJson(Map<String, dynamic> json, Map<String, dynamic> translationJson) {
    return Ayat(
      arabicText: json['text'] ?? '',
      translation: translationJson['text'] ?? '',
      surahName: json['surah']['englishName'] ?? '',
      surahNumber: json['surah']['number'] ?? 0,
      ayatNumber: json['numberInSurah'] ?? 0,
    );
  }

  String get reference => '$surahName [$surahNumber:$ayatNumber]';
}
