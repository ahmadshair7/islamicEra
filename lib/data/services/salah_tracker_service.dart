import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/salah_record.dart';

class SalahTrackerService {
  static final SalahTrackerService _instance = SalahTrackerService._internal();
  factory SalahTrackerService() => _instance;
  SalahTrackerService._internal();

  static const String _storageKey = 'salah_records';

  // Save a salah record for a specific date
  Future<void> saveSalahRecord(SalahRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final allRecords = await getAllRecords();
    
    // Update or add the record
    allRecords[record.date] = record;
    
    // Convert to JSON and save
    final jsonMap = allRecords.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_storageKey, json.encode(jsonMap));
  }

  // Get salah record for a specific date
  Future<SalahRecord> getSalahRecord(String date) async {
    final allRecords = await getAllRecords();
    return allRecords[date] ?? SalahRecord.empty(date);
  }

  // Get all salah records
  Future<Map<String, SalahRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap.map(
        (key, value) => MapEntry(key, SalahRecord.fromJson(value as Map<String, dynamic>)),
      );
    } catch (e) {
      print('Error loading salah records: $e');
      return {};
    }
  }

  // Update prayer status for a specific date
  Future<void> updatePrayerStatus({
    required String date,
    required String prayerName,
    required bool isOffered,
    String? time,
  }) async {
    final record = await getSalahRecord(date);
    final updatedPrayers = Map<String, PrayerStatus>.from(record.prayers);
    
    updatedPrayers[prayerName] = PrayerStatus(
      isOffered: isOffered,
      time: time,
    );

    final updatedRecord = record.copyWith(prayers: updatedPrayers);
    await saveSalahRecord(updatedRecord);
  }

  // Submit a salah record for a specific date
  Future<void> submitSalahRecord(String date) async {
    final record = await getSalahRecord(date);
    final updatedRecord = record.copyWith(isSubmitted: true);
    await saveSalahRecord(updatedRecord);
  }

  // Get records for a list of dates
  Future<Map<String, SalahRecord>> getRecordsForDates(List<String> dates) async {
    final allRecords = await getAllRecords();
    final Map<String, SalahRecord> result = {};
    for (var date in dates) {
      result[date] = allRecords[date] ?? SalahRecord.empty(date);
    }
    return result;
  }

  // Get current streak (consecutive days with all prayers AND submitted)
  Future<int> getCurrentStreak() async {
    final allRecords = await getAllRecords();
    
    int streak = 0;
    
    // 1. Check if today is complete and submitted
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayRecord = allRecords[todayStr];
    bool todayIsComplete = todayRecord != null && todayRecord.isComplete && todayRecord.isSubmitted;
    
    if (todayIsComplete) {
      streak++;
    }

    // 2. Go backwards from yesterday
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));
    while (true) {
      final dateStr = DateFormat('yyyy-MM-dd').format(checkDate);
      final record = allRecords[dateStr];
      
      if (record == null || !record.isComplete || !record.isSubmitted) {
        break;
      }
      
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
      
      if (streak > 365) break;
    }
    
    return streak;
  }

  // Get monthly statistics
  Future<Map<String, dynamic>> getMonthlyStats(int year, int month) async {
    final allRecords = await getAllRecords();
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    int totalPrayers = 0;
    int offeredPrayers = 0;
    int completeDays = 0;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final record = allRecords[dateStr];
      
      if (record != null) {
        totalPrayers += 5;
        offeredPrayers += record.offeredCount;
        if (record.isComplete) completeDays++;
      }
    }
    
    return {
      'totalPrayers': totalPrayers,
      'offeredPrayers': offeredPrayers,
      'completeDays': completeDays,
      'completionRate': totalPrayers > 0 ? (offeredPrayers / totalPrayers * 100) : 0.0,
    };
  }

  // Get weekly statistics (last 7 days)
  Future<Map<String, dynamic>> getWeeklyStats() async {
    final allRecords = await getAllRecords();
    final today = DateTime.now();
    
    int totalPrayers = 0;
    int offeredPrayers = 0;
    int completeDays = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final record = allRecords[dateStr];
      
      if (record != null) {
        totalPrayers += 5;
        offeredPrayers += record.offeredCount;
        if (record.isComplete) completeDays++;
      }
    }
    
    return {
      'totalPrayers': totalPrayers,
      'offeredPrayers': offeredPrayers,
      'completeDays': completeDays,
      'completionRate': totalPrayers > 0 ? (offeredPrayers / totalPrayers * 100) : 0.0,
    };
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // Get records for a date range
  Future<Map<String, SalahRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    final allRecords = await getAllRecords();
    final filteredRecords = <String, SalahRecord>{};
    
    DateTime currentDate = start;
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
      if (allRecords.containsKey(dateStr)) {
        filteredRecords[dateStr] = allRecords[dateStr]!;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return filteredRecords;
  }
}
