import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranAudioService extends ChangeNotifier {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  
  QuranAudioService._internal() {
    _loadSelectedReciter();
    _setupAudioPlayerListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // State
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentSurahNumber = 0;
  int _currentAyahNumber = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String _selectedReciter = 'Abdul Basit';
  
  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentSurahNumber => _currentSurahNumber;
  int get currentAyahNumber => _currentAyahNumber;
  Duration get position => _position;
  Duration get duration => _duration;
  String get selectedReciter => _selectedReciter;
  
  // Available reciters with their folder names
  static const Map<String, String> reciters = {
    'Abdul Basit': 'Abdul_Basit_Murattal_192kbps',
    'Mishary Alafasy': 'Alafasy_128kbps',
    'Saad Al-Ghamdi': 'Ghamadi_40kbps',
    'Mohammed Al-Minshawi': 'Minshawi_Murattal_128kbps',
    'Mahmoud Khalil Al-Hussary': 'Husary_128kbps',
  };

  void _setupAudioPlayerListeners() {
    // Listen to player state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isPaused = state == PlayerState.paused;
      notifyListeners();
      
      // Auto-play next ayah when current finishes
      if (state == PlayerState.completed) {
        playNextAyah();
      }
    });
    
    // Listen to position updates
    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });
    
    // Listen to duration updates
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedReciter = prefs.getString('selected_reciter') ?? 'Abdul Basit';
    notifyListeners();
  }

  Future<void> setReciter(String reciter) async {
    _selectedReciter = reciter;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reciter', reciter);
    notifyListeners();
    
    // If something is playing, restart with new reciter
    if (_isPlaying || _isPaused) {
      await playAyah(_currentSurahNumber, _currentAyahNumber);
    }
  }

  String _buildAudioUrl(int surahNumber, int ayahNumber) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    final reciterFolder = reciters[_selectedReciter] ?? reciters['Abdul Basit']!;
    
    return 'https://everyayah.com/data/$reciterFolder/$surah$ayah.mp3';
  }

  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      _currentSurahNumber = surahNumber;
      _currentAyahNumber = ayahNumber;
      
      final url = _buildAudioUrl(surahNumber, ayahNumber);
      await _audioPlayer.play(UrlSource(url));
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _isPaused = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> playNextAyah() async {
    // This will be called with max ayah count from the UI
    _currentAyahNumber++;
    await playAyah(_currentSurahNumber, _currentAyahNumber);
  }

  Future<void> playPreviousAyah() async {
    if (_currentAyahNumber > 1) {
      _currentAyahNumber--;
      await playAyah(_currentSurahNumber, _currentAyahNumber);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
