import 'package:url_launcher/url_launcher.dart';

/// Service for sharing location via Gmail and WhatsApp
/// Handles deep linking and email composition
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Validate email address format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number format (should be digits only, no + symbol)
  /// Example: 919876543210
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Send location via Gmail using mailto scheme
  /// Opens Gmail app with pre-filled email
  Future<ShareResult> sendViaGmail({
    required String recipientEmail,
    required String recipientName,
    required String locationUrl,
  }) async {
    if (!isValidEmail(recipientEmail)) {
      return ShareResult(
        success: false,
        message: 'Invalid email address format.',
      );
    }

    final subject = 'My Current Location';
    final body = '''Hi $recipientName,

Here is my current location:
$locationUrl

Sent from Ahmad Shair''';

    final emailUri = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return ShareResult(
          success: true,
          message: 'Email app opened successfully.',
        );
      } else {
        return ShareResult(
          success: false,
          message: 'Could not open email app. Please check if Gmail is installed.',
        );
      }
    } catch (e) {
      return ShareResult(
        success: false,
        message: 'Failed to open email app: ${e.toString()}',
      );
    }
  }

  /// Send location via WhatsApp using deep link
  Future<ShareResult> sendViaWhatsApp({
    required String phoneNumber,
    required String recipientName,
    required String locationUrl,
  }) async {
    if (!isValidPhoneNumber(phoneNumber)) {
      return ShareResult(
        success: false,
        message: 'Invalid phone number. Please enter digits only (e.g., 919876543210).',
      );
    }

    final message = 'Hi $recipientName, here is my current location:\n$locationUrl';
    
    // WhatsApp deep link format
    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return ShareResult(
          success: true,
          message: 'WhatsApp opened successfully.',
        );
      } else {
        return ShareResult(
          success: false,
          message: 'WhatsApp is not installed on this device.',
        );
      }
    } catch (e) {
      return ShareResult(
        success: false,
        message: 'Failed to open WhatsApp: ${e.toString()}',
      );
    }
  }

  /// Send location via both Gmail and WhatsApp
  Future<ShareResult> sendLocation({
    required String email,
    required String phoneNumber,
    required String recipientName,
    required String locationUrl,
  }) async {
    // Send via Gmail
    final gmailResult = await sendViaGmail(
      recipientEmail: email,
      recipientName: recipientName,
      locationUrl: locationUrl,
    );

    // Short delay before opening WhatsApp
    await Future.delayed(const Duration(milliseconds: 500));

    // Send via WhatsApp
    final whatsappResult = await sendViaWhatsApp(
      phoneNumber: phoneNumber,
      recipientName: recipientName,
      locationUrl: locationUrl,
    );

    // Return combined result
    if (gmailResult.success && whatsappResult.success) {
      return ShareResult(
        success: true,
        message: 'Location shared via Gmail and WhatsApp.',
      );
    } else if (gmailResult.success) {
      return ShareResult(
        success: true,
        message: 'Gmail opened. ${whatsappResult.message}',
      );
    } else if (whatsappResult.success) {
      return ShareResult(
        success: true,
        message: 'WhatsApp opened. ${gmailResult.message}',
      );
    } else {
      return ShareResult(
        success: false,
        message: '${gmailResult.message} ${whatsappResult.message}',
      );
    }
  }

  /// Helper to encode query parameters for mailto
  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

/// Result class for share operations
class ShareResult {
  final bool success;
  final String message;

  ShareResult({
    required this.success,
    required this.message,
  });
}
