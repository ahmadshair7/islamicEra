import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app3/core/utils/qibla_utils.dart';

void main() {
  group('Qibla Direction Calculation Tests', () {
    // Test cases with expected Qibla directions from known locations
    // These values are verified against Google Qibla Finder
    
    test('London - Qibla should be approximately 118-119 degrees', () {
      // London coordinates: 51.5074° N, 0.1278° W
      final qibla = QiblaUtils.calculateQiblaDirection(51.5074, -0.1278);
      expect(qibla, greaterThan(117.0));
      expect(qibla, lessThan(120.0));
    });

    test('New York - Qibla should be approximately 58-59 degrees', () {
      // New York coordinates: 40.7128° N, 74.0060° W
      final qibla = QiblaUtils.calculateQiblaDirection(40.7128, -74.0060);
      expect(qibla, greaterThan(57.0));
      expect(qibla, lessThan(60.0));
    });

    test('Lahore - Qibla should be approximately 259-261 degrees (WSW)', () {
      // Lahore coordinates: 31.5204° N, 74.3587° E
      final qibla = QiblaUtils.calculateQiblaDirection(31.5204, 74.3587);
      expect(qibla, greaterThan(258.0));
      expect(qibla, lessThan(262.0));
    });

    test('Tokyo - Qibla should be approximately 293 degrees (WNW)', () {
      // Tokyo coordinates: 35.6762° N, 139.6503° E
      final qibla = QiblaUtils.calculateQiblaDirection(35.6762, 139.6503);
      expect(qibla, greaterThan(291.0));
      expect(qibla, lessThan(295.0));
    });

    test('Sydney - Qibla should be approximately 277 degrees (W)', () {
      // Sydney coordinates: 33.8688° S, 151.2093° E
      final qibla = QiblaUtils.calculateQiblaDirection(-33.8688, 151.2093);
      expect(qibla, greaterThan(275.0));
      expect(qibla, lessThan(280.0));
    });

    test('Mecca - Qibla should be close to 0 or any direction (at Kaaba)', () {
      // Very close to Kaaba - direction becomes undefined but should not error
      final qibla = QiblaUtils.calculateQiblaDirection(21.4224779, 39.8251832);
      expect(qibla, isNotNaN);
      expect(qibla, greaterThanOrEqualTo(0.0));
      expect(qibla, lessThanOrEqualTo(360.0));
    });
  });
}
