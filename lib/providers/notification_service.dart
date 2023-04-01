// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../pages/message/chat_page.dart';

class HalperNotification{
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void initialize() async {
    var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInit = DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidRecivNotifIos
    );

    final InitializationSettings initializationSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidRecivNotifAndroid,
    );
  }

  void onDidRecivNotifAndroid(NotificationResponse response) async {
      final String payload = response.payload.toString();
      if(response.payload != null && response.payload.toString().isNotEmpty){
        await  Get.to(() => ChatMessagePage(userId: AppServices().getUserLogin.id, chatId: payload,));
      }
    }

  void onDidRecivNotifIos(id, title, body, payload) async {
    if(payload != null && payload.toString().isNotEmpty){
      await  Get.to(() => ChatMessagePage(userId: AppServices().getUserLogin.id, chatId: payload,));
    }
  }


  void showNotification({required String title, required String body, required String payload}) async {
    BigTextStyleInformation bigTextStyleInfo = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
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

    DarwinNotificationDetails iosNotifDetail = DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotifDetail, iOS: iosNotifDetail);

    Random random = Random();
    int i = random.nextInt(10000);
    await flutterLocalNotificationsPlugin.show(i, title, body, notificationDetails, payload: payload);
  }
}