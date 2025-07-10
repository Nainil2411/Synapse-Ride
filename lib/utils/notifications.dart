import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:synapseride/Routes/routes.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _getFCMToken();
    _setupMessageHandlers();
    log('FCM Token: $_fcmToken');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        log('Decoded payload: $data');
        _handleNotificationNavigation(data);
      } catch (e) {
        log('Error decoding payload: $e');
      }
    } else {
      log('No payload found in notification.');
    }
  }

  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        log('FCM Token obtained: $_fcmToken');
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log('Received foreground message: ${message.messageId}');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');
    _showLocalNotification(message);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    log('Received background message: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final payload = jsonEncode(message.data.isNotEmpty
        ? message.data
        : {'type': message.notification?.title ?? 'unknown'});

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Synapse Ride',
      message.notification?.body ?? 'You have a new notification',
      platformDetails,
      payload: payload,
    );
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    log('Handling notification navigation with data: $data');

    if (data.containsKey('type')) {
      final type = data['type'];
      log("Notification type: $type");

      switch (type) {
        case 'Ride Created':
          Get.toNamed(AppRoutes.joiningRide);
          return;
        case 'Create Ride':
          Get.toNamed(AppRoutes.createRide);
          return;
        case 'Contact Us':
          Get.toNamed(AppRoutes.contactus);
          return;
        case 'Edit Profile':
          Get.toNamed(AppRoutes.profile);
          return;
      }
    }

    if (data.containsKey('action')) {
      _handleNotificationAction(data['action'], data);
    } else {
      log('No route/type/action matched in notification.');
    }
  }

  void _handleNotificationAction(String action, Map<String, dynamic> data) {
    switch (action) {
      case 'open_ride':
        if (data.containsKey('rideId')) {
        }
        break;
      case 'show_message':
        Get.snackbar(
          'Notification',
          data['message'] ?? 'You have a new notification',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        break;
      default:
        log('Unknown action: $action');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  void dispose() {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
}
