import 'dart:math';

class QiblaUtils {
  // Kaaba coordinates (Mecca, Saudi Arabia)
  // Using precise coordinates from Google Qibla Finder for maximum accuracy
  static const double kaabaLat = 21.4224779;
  static const double kaabaLng = 39.8251832;

  /// Calculates the Qibla direction (initial bearing) from user's location to the Kaaba.
  /// Uses the correct spherical bearing formula (great-circle navigation).
  /// Result is in degrees from North (0-360), where:
  /// - 0° = North
  /// - 90° = East
  /// - 180° = South
  /// - 270° = West
  static double calculateQiblaDirection(double userLat, double userLng) {
    // Convert degrees to radians
    double userLatRad = userLat * pi / 180.0;
    double userLngRad = userLng * pi / 180.0;
    double kaabaLatRad = kaabaLat * pi / 180.0;
    double kaabaLngRad = kaabaLng * pi / 180.0;

    // Calculate the difference in longitude
    double deltaLng = kaabaLngRad - userLngRad;

    // Calculate the initial bearing using the correct spherical formula
    // Formula: θ = atan2(sin(Δλ) * cos(φ2), cos(φ1) * sin(φ2) − sin(φ1) * cos(φ2) * cos(Δλ))
    // Where:
    // - φ1 = user latitude, φ2 = Kaaba latitude
    // - Δλ = difference in longitude (Kaaba longitude - user longitude)
    double y = sin(deltaLng) * cos(kaabaLatRad);
    double x = cos(userLatRad) * sin(kaabaLatRad) - 
               sin(userLatRad) * cos(kaabaLatRad) * cos(deltaLng);

    double qiblaRad = atan2(y, x);
    double qiblaDeg = qiblaRad * 180.0 / pi;

    // Normalize to 0-360 degrees
    return (qiblaDeg + 360.0) % 360.0;
  }
}
