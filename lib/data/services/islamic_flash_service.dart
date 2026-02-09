import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/islamic_flash.dart';

/// Islamic Flash Service
/// Manages loading, caching, and retrieving Islamic flashes
/// Supports both online (Firestore-ready) and offline (local JSON) modes
class IslamicFlashService {
  static final IslamicFlashService _instance = IslamicFlashService._internal();
  factory IslamicFlashService() => _instance;
  IslamicFlashService._internal();

  List<IslamicFlash> _flashes = [];
  IslamicFlash? _currentFlash;
  bool _isInitialized = false;
  final Random _random = Random();

  // Keys for SharedPreferences
  static const String _lastFlashIdKey = 'islamic_flash_last_id';
  static const String _lastFlashDateKey = 'islamic_flash_last_date';
  static const String _cachedFlashesKey = 'islamic_flash_cached';

  /// Initialize the service and load flashes
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Try to load from cache first
      await _loadFromCache();

      // Load from local assets as fallback/primary source
      await _loadFromLocalAssets();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing IslamicFlashService: $e');
    }
  }

  /// Load flashes from local JSON assets
  Future<void> _loadFromLocalAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/islamic_flashes.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _flashes = jsonList
          .map((json) => IslamicFlash.fromJson(json as Map<String, dynamic>))
          .where((flash) => flash.active)
          .toList();

      // Cache the loaded flashes
      await _cacheFlashes();
    } catch (e) {
      print('Error loading flashes from assets: $e');
    }
  }

  /// Cache flashes to SharedPreferences
  Future<void> _cacheFlashes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _flashes.map((f) => f.toJson()).toList();
      await prefs.setString(_cachedFlashesKey, json.encode(jsonList));
    } catch (e) {
      print('Error caching flashes: $e');
    }
  }

  /// Load flashes from cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cachedFlashesKey);

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(cachedJson);
        _flashes = jsonList
            .map((json) => IslamicFlash.fromJson(json as Map<String, dynamic>))
            .where((flash) => flash.active)
            .toList();
      }
    } catch (e) {
      print('Error loading from cache: $e');
    }
  }

  /// Get a random flash
  IslamicFlash? getRandomFlash() {
    if (_flashes.isEmpty) return null;

    final index = _random.nextInt(_flashes.length);
    _currentFlash = _flashes[index];
    return _currentFlash;
  }

  /// Get a new random flash (different from current)
  IslamicFlash? getNewRandomFlash() {
    if (_flashes.isEmpty) return null;
    if (_flashes.length == 1) return _flashes.first;

    IslamicFlash? newFlash;
    int attempts = 0;
    
    do {
      newFlash = getRandomFlash();
      attempts++;
    } while (newFlash?.id == _currentFlash?.id && attempts < 10);

    _currentFlash = newFlash;
    return _currentFlash;
  }

  /// Get flash of the day (same flash for the entire day)
  Future<IslamicFlash?> getFlashOfTheDay() async {
    if (_flashes.isEmpty) {
      await initialize();
      if (_flashes.isEmpty) return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastDate = prefs.getString(_lastFlashDateKey);
      final lastFlashId = prefs.getString(_lastFlashIdKey);

      // If same day and we have a cached flash, return it
      if (lastDate == today && lastFlashId != null) {
        final cachedFlash = _flashes.firstWhere(
          (f) => f.id == lastFlashId,
          orElse: () => _flashes[_random.nextInt(_flashes.length)],
        );
        _currentFlash = cachedFlash;
        return cachedFlash;
      }

      // New day, get a new random flash
      final newFlash = getRandomFlash();
      if (newFlash != null) {
        await prefs.setString(_lastFlashDateKey, today);
        await prefs.setString(_lastFlashIdKey, newFlash.id);
      }

      return newFlash;
    } catch (e) {
      print('Error getting flash of the day: $e');
      return getRandomFlash();
    }
  }

  /// Get flash by type
  List<IslamicFlash> getFlashesByType(FlashType type) {
    return _flashes.where((f) => f.type == type).toList();
  }

  /// Get a random flash of specific type
  IslamicFlash? getRandomFlashByType(FlashType type) {
    final typeFlashes = getFlashesByType(type);
    if (typeFlashes.isEmpty) return null;

    return typeFlashes[_random.nextInt(typeFlashes.length)];
  }

  /// Get Friday-specific flash (Jumu'ah reminder)
  IslamicFlash? getFridayFlash() {
    // First try to find a Friday-specific reminder
    final fridayFlash = _flashes.firstWhere(
      (f) => f.reference.toLowerCase().contains('jumu') || 
             f.translation.toLowerCase().contains('friday'),
      orElse: () => _flashes.isNotEmpty 
          ? _flashes[_random.nextInt(_flashes.length)] 
          : const IslamicFlash(
              id: 'default',
              type: FlashType.tip,
              translation: 'May your Friday be blessed.',
              reference: 'Jumu\'ah Reminder',
            ),
    );
    return fridayFlash;
  }

  /// Get current flash
  IslamicFlash? get currentFlash => _currentFlash;

  /// Get all flashes
  List<IslamicFlash> get allFlashes => List.unmodifiable(_flashes);

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get flash count
  int get flashCount => _flashes.length;
}
