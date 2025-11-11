import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    await _handleTokenRefresh();

    _fcm.onTokenRefresh.listen((newToken) async {
      await _storeToken(newToken);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _handleTokenRefresh() async {
    String? token = await _fcm.getToken();
    await _storeToken(token!);
  }

  Future<void> _storeToken(String token) async {
    String userId = await _getCurrentUserId();

    await _firestore.collection('SUBSCRIBERS').doc(userId).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is logged in');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Foreground message: ${message.notification?.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Background message: ${message.notification?.title}');
  }
}
