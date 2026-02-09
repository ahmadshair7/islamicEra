import 'package:permission_handler/permission_handler.dart';

/// Service for handling Android runtime permissions
/// Manages location permission requests and status checks
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check current location permission status
  Future<PermissionStatus> checkLocationPermission() async {
    return await Permission.location.status;
  }

  /// Request location permission from the user
  /// Returns a PermissionResult with status and user-friendly message
  Future<PermissionResult> requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: 'Location permission already granted.',
      );
    }

    if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        return PermissionResult(
          isGranted: true,
          message: 'Location permission granted.',
        );
      } else if (result.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          isPermanentlyDenied: true,
          message: 'Location permission permanently denied. Please enable it in app settings.',
        );
      } else {
        return PermissionResult(
          isGranted: false,
          message: 'Location permission denied. Please allow access to use this feature.',
        );
      }
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult(
        isGranted: false,
        isPermanentlyDenied: true,
        message: 'Location permission permanently denied. Please enable it in app settings.',
      );
    }

    if (status.isRestricted) {
      return PermissionResult(
        isGranted: false,
        message: 'Location permission is restricted on this device.',
      );
    }

    // Default case: request permission
    final result = await Permission.location.request();
    return PermissionResult(
      isGranted: result.isGranted,
      isPermanentlyDenied: result.isPermanentlyDenied,
      message: result.isGranted
          ? 'Location permission granted.'
          : 'Location permission denied.',
    );
  }

  /// Open app settings for the user to manually enable permissions
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
}

/// Result class for permission requests
class PermissionResult {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final String message;

  PermissionResult({
    required this.isGranted,
    this.isPermanentlyDenied = false,
    required this.message,
  });
}
