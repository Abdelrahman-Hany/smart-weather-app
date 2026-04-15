import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fpdart/fpdart.dart';

class FcmMessagingService {
  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;

  StreamSubscription<String>? _tokenRefreshSubscription;

  FcmMessagingService({required this.messaging, required this.firestore});

  Future<bool> requestPermissions() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> initializeMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages here
      print('Received a message while in the foreground: ${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle messages that opened the app from a terminated state
      print('App opened from a message: ${message.messageId}');
    });
  }

  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  Future<void> syncToken({
    required String userId,
    required String token,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('fcm_tokens')
        .doc(token)
        .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> startTokenSyncForUser(String userId) async {
    final currentToken = await getToken();
    if (currentToken != null && currentToken.isNotEmpty) {
      await syncToken(userId: userId, token: currentToken);
    }

    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((
      newToken,
    ) async {
      await syncToken(userId: userId, token: newToken);
    });
  }

  Future<Unit> stopTokenSync() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    return unit;
  }
}
