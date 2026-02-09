import 'package:flutter/material.dart';
import '../../data/services/data_initialization_service.dart';
import '../../data/services/local_storage_service.dart';

class DataDownloadScreen extends StatefulWidget {
  const DataDownloadScreen({Key? key}) : super(key: key);

  @override
  State<DataDownloadScreen> createState() => _DataDownloadScreenState();
}

class _DataDownloadScreenState extends State<DataDownloadScreen> {
  final DataInitializationService _dataService = DataInitializationService();
  double _progress = 0.0;
  String _status = 'Waiting to start...';
  bool _isDownloading = false;
  bool _isComplete = false;
  bool _isQuranDownloaded = false;
  bool _isHadithDownloaded = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    final LocalStorageService storage = LocalStorageService();
    setState(() {
      _isQuranDownloaded = storage.isQuranDataAvailable();
      _isHadithDownloaded = storage.isHadithDataAvailable();
      if (_isQuranDownloaded && _isHadithDownloaded) {
        _isComplete = true;
        _progress = 1.0;
        _status = 'All data downloaded.';
      } else if (_isQuranDownloaded) {
        _progress = 0.5;
        _status = 'Quran downloaded, Hadith pending.';
      }
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = '';
      _progress = 0.0;
      _status = 'Initializing download...';
    });

    try {
      await _dataService.downloadAllData(
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isComplete = true;
          _status = 'Download complete!';
          _progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Error: ${e.toString()}';
          _status = 'Download failed.';
        });
      }
    }
  }

  Future<void> _skipHadith() async {
     setState(() {
      _isDownloading = true;
      _errorMessage = '';
      _progress = 0.0;
      _status = 'Downloading Quran data only...';
    });

    try {
      await _dataService.downloadMinimumData(
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _status = status;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isComplete = true;
          _status = 'Download complete!';
          _progress = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Error: ${e.toString()}';
          _status = 'Download failed.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Data Manager'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.cloud_download_outlined,
                size: 80,
                color: Color(0xFF1B5E20), // Islamic Green
              ),
              const SizedBox(height: 24),
              const Text(
                'Offline Data Manager',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isComplete 
                  ? 'All data is available for offline use. You can re-download if needed or return to using the app.'
                  : 'Download Quran and Hadith data for full offline access. This is optional but recommended for the best experience (~100MB).',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatusTile('Quran Data', _isQuranDownloaded),
              _buildStatusTile('Hadith Data', _isHadithDownloaded),
              const SizedBox(height: 48),
              if (_isDownloading || _isComplete) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF1B5E20),
                  minHeight: 10,
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).toInt()}% - $_status',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Download All Data (~100MB)'),
                ),
                const SizedBox(height: 16),
                if (_isComplete)
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to home or pop all the way back
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Home'),
                  )
                else
                  OutlinedButton(
                    onPressed: _skipHadith,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF1B5E20)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Download Quran Only (~50MB)'),
                  ),
              ],
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _startDownload,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(String title, bool isDone) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? Colors.green[700] : Colors.grey[700],
            ),
          ),
          const Spacer(),
          if (isDone)
            const Text('Available', style: TextStyle(fontSize: 12, color: Colors.green))
          else
            const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
