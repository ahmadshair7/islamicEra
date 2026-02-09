import 'dart:convert';

class PrayerStatus {
  final bool isOffered;
  final String? time; // Time when marked as offered (HH:mm format)

  PrayerStatus({
    required this.isOffered,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'isOffered': isOffered,
      'time': time,
    };
  }

  factory PrayerStatus.fromJson(Map<String, dynamic> json) {
    return PrayerStatus(
      isOffered: json['isOffered'] ?? false,
      time: json['time'],
    );
  }
}

class SalahRecord {
  final String date; // YYYY-MM-DD format
  final Map<String, PrayerStatus> prayers;
  final bool isSubmitted;

  SalahRecord({
    required this.date,
    required this.prayers,
    this.isSubmitted = false,
  });

  // Create empty record for a date
  factory SalahRecord.empty(String date) {
    return SalahRecord(
      date: date,
      isSubmitted: false,
      prayers: {
        'Fajr': PrayerStatus(isOffered: false),
        'Dhuhr': PrayerStatus(isOffered: false),
        'Asr': PrayerStatus(isOffered: false),
        'Maghrib': PrayerStatus(isOffered: false),
        'Isha': PrayerStatus(isOffered: false),
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isSubmitted': isSubmitted,
      'prayers': prayers.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory SalahRecord.fromJson(Map<String, dynamic> json) {
    final prayersMap = json['prayers'] as Map<String, dynamic>;
    return SalahRecord(
      date: json['date'],
      isSubmitted: json['isSubmitted'] ?? false,
      prayers: prayersMap.map(
        (key, value) => MapEntry(key, PrayerStatus.fromJson(value as Map<String, dynamic>)),
      ),
    );
  }

  // Get number of prayers offered
  int get offeredCount {
    return prayers.values.where((p) => p.isOffered).length;
  }

  // Check if all prayers are offered
  bool get isComplete {
    return offeredCount == 5;
  }

  // Get completion percentage
  double get completionPercentage {
    return (offeredCount / 5) * 100;
  }

  // Create a copy with updated prayer status
  SalahRecord copyWith({
    String? date,
    Map<String, PrayerStatus>? prayers,
    bool? isSubmitted,
  }) {
    return SalahRecord(
      date: date ?? this.date,
      prayers: prayers ?? this.prayers,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
