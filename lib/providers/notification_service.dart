// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../pages/message/chat_page.dart';

class HalperNotification{
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging fbNotif = FirebaseMessaging.instance;

  initialize() async {
    var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInit = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String payload = response.payload.toString();
        if(response.payload != null && response.payload.toString().isNotEmpty){
          print("Get ID: $payload");
          await  Get.to(() => ChatMessagePage(userId: AppServices().getUserLogin.id, chatId: payload,));
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage messages) {
      HalperNotification.showNotification(messages);
    });
  }

  Future<void> requestPermition() async {
    NotificationSettings settings = await fbNotif.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User granted permition");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User granted provisional");
    }else{
      print("User declined permition");
    }
  }

  static void showNotification(RemoteMessage message) async {
    BigTextStyleInformation bigTextStyleInfo = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidNotifDetail = AndroidNotificationDetails(
      Collections.androidChanId,
      Collections.androidChanName,
      importance: Importance.high,
      styleInformation: bigTextStyleInfo,
      priority: Priority.high,
      playSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotifDetail, iOS: const DarwinNotificationDetails());

    Random random = Random();
    int i = random.nextInt(10000);
    await flutterLocalNotificationsPlugin.show(i, message.notification!.title, message.notification!.body, notificationDetails, payload: message.data["some_data"]);
  }
}