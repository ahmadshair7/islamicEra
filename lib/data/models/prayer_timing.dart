class PrayerTimings {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String sunrise;
  final String sunset;

  PrayerTimings({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.sunset,
  });

  factory PrayerTimings.fromJson(Map<String, dynamic> json) {
    return PrayerTimings(
      fajr: json['Fajr'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      sunrise: json['Sunrise'],
      sunset: json['Sunset'],
    );
  }
}

class PrayerData {
  final PrayerTimings timings;
  final String dateReadable;
  final String hijriDate;

  PrayerData({
    required this.timings,
    required this.dateReadable,
    required this.hijriDate,
  });

  factory PrayerData.fromJson(Map<String, dynamic> json) {
    return PrayerData(
      timings: PrayerTimings.fromJson(json['timings']),
      dateReadable: json['date']['readable'],
      hijriDate: '${json['date']['hijri']['day']} ${json['date']['hijri']['month']['en']} ${json['date']['hijri']['year']}',
    );
  }
}
