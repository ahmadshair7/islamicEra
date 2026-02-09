import 'package:geolocator/geolocator.dart';

/// Service for GPS location fetching
/// Handles all location-related operations using the geolocator package
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;

  /// Gets the current cached position (if available)
  Position? get currentPosition => _currentPosition;

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get the current GPS position
  /// Returns the position or throws an exception with user-friendly message
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable GPS in your device settings.',
      );
    }

    try {
      // Get current position with high accuracy
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return _currentPosition!;
    } catch (e) {
      throw LocationServiceException(
        'Failed to get your location. Please try again.',
      );
    }
  }

  /// Generate a Google Maps shareable URL from coordinates
  String generateGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Clear cached position
  void clearPosition() {
    _currentPosition = null;
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}
