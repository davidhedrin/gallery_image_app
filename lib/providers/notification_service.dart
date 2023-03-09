// ignore_for_file: prefer_const_constructors

import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../pages/message/chat_page.dart';

class HalperNotification{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging fbNotif = FirebaseMessaging.instance;


  initialize() async {
    var androidInit = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInit = const DarwinInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("..................Message..................");
      print("On Message: ${message.notification?.title}/${message.notification?.body}");
      
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
      
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title, message.notification!.body, notificationDetails, payload: message.data["body"]);
    });
  }

  void requestPermition() async {
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

  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    try{
      final String? payload = notificationResponse.payload;// getId
      if(payload != null && payload.isNotEmpty){
        if (notificationResponse.payload != null) {
          // Get.to(() => ChatMessagePage(userId: AppServices().getUserLogin.id, chatId: payload,));
          print('notification payload: $payload');
        }
      }
    }catch(e){

    }
  }
}