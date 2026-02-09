import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/quran_audio_service.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../data/models/bookmark.dart';

class ParahDetailScreen extends StatefulWidget {
  final int parahNumber;

  const ParahDetailScreen({super.key, required this.parahNumber});

  @override
  State<ParahDetailScreen> createState() => _ParahDetailScreenState();
}

class _ParahDetailScreenState extends State<ParahDetailScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final QuranAudioService _audioService = QuranAudioService();
  
  bool _isLoading = true;
  List<dynamic> _allAyahs = []; // All loaded ayahs
  List<dynamic> _displayedAyahs = []; // Currently displayed ayahs (for pagination)
  String _error = '';
  
  // Pagination settings
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  
  // Auto-scroll state
  bool _isAutoScrolling = false;
  Timer? _autoScrollTimer;
  double _scrollSpeedMultiplier = 1.0;
  bool _showSpeedControl = false;

  @override
  void initState() {
    super.initState();
    _fetchParahDetails();
    _audioService.addListener(_onAudioStateChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _audioService.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    // Load more when reaching near the bottom
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreAyahs();
    }
  }

  void _loadMoreAyahs() {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });

    final startIndex = (_currentPage + 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    if (startIndex >= _allAyahs.length) {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
      return;
    }

    final newItems = _allAyahs.sublist(
      startIndex,
      endIndex > _allAyahs.length ? _allAyahs.length : endIndex,
    );

    setState(() {
      _currentPage++;
      _displayedAyahs.addAll(newItems);
      _hasMoreData = endIndex < _allAyahs.length;
      _isLoadingMore = false;
    });
  }

  void _startAutoScroll() {
    setState(() {
      _isAutoScrolling = true;
      _showSpeedControl = true;
    });
    
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _stopAutoScroll();
          return;
        }
        
        final scrollAmount = 15.0 * _scrollSpeedMultiplier;
        _scrollController.animateTo(
          currentScroll + scrollAmount,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    setState(() {
      _isAutoScrolling = false;
      _showSpeedControl = false;
    });
  }

  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _setScrollSpeed(double multiplier) {
    setState(() {
      _scrollSpeedMultiplier = multiplier;
    });
  }

  Future<void> _fetchParahDetails() async {
    try {
      final data = await _apiService.getJuzDetails(widget.parahNumber);
      setState(() {
        final List<dynamic> editions = data['data'];
        final arabicAyahs = editions[0]['ayahs'] as List;
        final urduAyahs = editions[1]['ayahs'] as List;
        final englishAyahs = editions[2]['ayahs'] as List;

        _allAyahs = List.generate(arabicAyahs.length, (index) {
          final arabicAyah = arabicAyahs[index];
          final urduAyah = urduAyahs[index];
          final englishAyah = englishAyahs[index];
          
          return {
            'text': arabicAyah['text'],
            'translationUrdu': urduAyah['text'],
            'translationEnglish': englishAyah['text'],
            'number': arabicAyah['numberInSurah'],
            'surahName': arabicAyah['surah']['englishName'],
            'surahNumber': arabicAyah['surah']['number'],
            'ayahNumberInSurah': arabicAyah['numberInSurah'],
          };
        });

        // Initial pagination: load first page
        _displayedAyahs = _allAyahs.length > _pageSize 
            ? _allAyahs.sublist(0, _pageSize) 
            : List.from(_allAyahs);
        _hasMoreData = _allAyahs.length > _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Reciter', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: QuranAudioService.reciters.keys.map((reciter) {
              final isSelected = _audioService.selectedReciter == reciter;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
                ),
                title: Text(reciter),
                onTap: () {
                  _audioService.setReciter(reciter);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAudioPlaying = _audioService.isPlaying || _audioService.isPaused;
    
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text("Parah ${widget.parahNumber}", style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Select Reciter',
            onPressed: _showReciterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], 
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
              ),
            ),
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _error.isNotEmpty
                  ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: 100, 
                        left: 16, 
                        right: 16, 
                        bottom: isAudioPlaying ? 180 : 100,
                      ),
                      itemCount: _displayedAyahs.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the bottom
                        if (index == _displayedAyahs.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                            ),
                          );
                        }
                        
                        final ayah = _displayedAyahs[index];
                        final ayahNumber = ayah['ayahNumberInSurah'] as int;
                        final surahNumber = ayah['surahNumber'] as int;
                        final isCurrentlyPlaying = _audioService.isPlaying &&
                            _audioService.currentSurahNumber == surahNumber &&
                            _audioService.currentAyahNumber == ayahNumber;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: isCurrentlyPlaying
                                ? Colors.white.withOpacity(0.15)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCurrentlyPlaying
                                  ? const Color(0xFFD4AF37).withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                              width: isCurrentlyPlaying ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header: Surah info and Ayah Number
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Show Surah Name context for Parah
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37).withOpacity(0.2), 
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${ayah['surahName']} : ${ayah['number']}',
                                            style: const TextStyle(
                                              color: Color(0xFFD4AF37),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Play button for this ayah
                                        InkWell(
                                          onTap: () {
                                            if (isCurrentlyPlaying) {
                                              if (_audioService.isPlaying) {
                                                _audioService.pause();
                                              } else {
                                                _audioService.resume();
                                              }
                                            } else {
                                              _audioService.playAyah(surahNumber, ayahNumber);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isCurrentlyPlaying
                                                  ? const Color(0xFFD4AF37).withOpacity(0.3)
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isCurrentlyPlaying && _audioService.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: const Color(0xFFD4AF37),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Consumer<BookmarkProvider>(
                                          builder: (context, provider, child) {
                                            // Unique ID for bookmark: surah_ayah
                                            final bookmarkId = '${ayah['surahNumber']}_${ayah['ayahNumberInSurah']}';
                                            final isBookmarked = provider.isBookmarked(bookmarkId, 'quran');
                                            
                                            return IconButton(
                                              icon: Icon(
                                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                                color: isBookmarked ? const Color(0xFFD4AF37) : Colors.white54,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                provider.toggleBookmark(Bookmark(
                                                  id: bookmarkId,
                                                  type: 'quran',
                                                  title: 'Ayah ${ayah['ayahNumberInSurah']} of ${ayah['surahName']}',
                                                  content: ayah['text'],
                                                  subtitle: ayah['translationUrdu'],
                                                  timestamp: DateTime.now(),
                                                ));
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share, size: 20, color: Colors.white54),
                                          onPressed: () {}, 
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Content Body
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Arabic
                                    Text(
                                      ayah['text'],
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.amiri(
                                        fontSize: 30,
                                        height: 2.2,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 20),
                                    // Urdu Translation Label
                                    Text(
                                      'اردو ترجمہ:',
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Urdu Translation
                                    Text(
                                      ayah['translationUrdu'],
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: GoogleFonts.notoNastaliqUrdu(
                                        fontSize: 19,
                                        height: 2.0,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 20),
                                    // English Translation Label
                                    const Text(
                                      'English Translation:',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB3B3B3),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // English Translation
                                    Text(
                                      ayah['translationEnglish'],
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        height: 1.8,
                                        color: Color(0xFFCCCCCC),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          
          // Speed Control Panel
          if (_showSpeedControl)
            Positioned(
              bottom: isAudioPlaying ? 140 : 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F2027).withOpacity(0.95),
                      const Color(0xFF203A43).withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Auto-Scroll Speed',
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Speed Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSpeedButton(0.5, '0.5x'),
                        _buildSpeedButton(1.0, '1x'),
                        _buildSpeedButton(2.0, '2x'),
                        _buildSpeedButton(3.0, '3x'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Audio Player (bottom bar)
          if (isAudioPlaying)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAudioPlayer(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAutoScroll,
        backgroundColor: const Color(0xFFD4AF37),
        child: Icon(
          _isAutoScrolling ? Icons.pause : Icons.play_arrow,
          color: const Color(0xFF0F2027),
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    final position = _audioService.position;
    final duration = _audioService.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2027).withOpacity(0.98),
            const Color(0xFF203A43).withOpacity(0.98),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reciter name and current ayah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _audioService.selectedReciter,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ayah ${_audioService.currentAyahNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () {
                  _audioService.stop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                iconSize: 32,
                onPressed: _audioService.currentAyahNumber > 1
                    ? () => _audioService.playPreviousAyah()
                    : null,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF0F2027),
                  ),
                  iconSize: 32,
                  onPressed: () {
                    if (_audioService.isPlaying) {
                      _audioService.pause();
                    } else {
                      _audioService.resume();
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                iconSize: 32,
                onPressed: () => _audioService.playNextAyah(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    final newPosition = Duration(
                      milliseconds: (value * duration.inMilliseconds).round(),
                    );
                    _audioService.seek(newPosition);
                  },
                  activeColor: const Color(0xFFD4AF37),
                  inactiveColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(double multiplier, String label) {
    final isSelected = _scrollSpeedMultiplier == multiplier;
    return GestureDetector(
      onTap: () => _setScrollSpeed(multiplier),
      child: Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFD4AF37) 
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFD4AF37) 
                : Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected 
                  ? const Color(0xFF0F2027) 
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
