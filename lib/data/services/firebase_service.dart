import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: unused_import
import 'notification_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _fcm;

  Future<void> initialize() async {
    // Note: This requires google-services.json to be present in android/app/
    // or FirebaseOptions to be provided for Web.
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      
      _fcm = FirebaseMessaging.instance;
      
      // Request permission for iOS
      await _fcm?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          print('Message received in foreground: ${message.notification!.title}');
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
    } catch (e) {
      print('Firebase initialization error: $e');
      // If we are on web and it failed, we just log it and don't crash the app
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print("Error in background handler: $e");
    }
    print("Handling a background message: ${message.messageId}");
  }

  Future<String?> getToken() async {
    try {
      return await _fcm?.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
}
