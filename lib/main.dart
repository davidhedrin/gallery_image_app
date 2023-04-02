import 'dart:convert';

import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/pages/message/chat_page.dart';
import 'package:delivery_food_app/providers/auth_provider.dart';
import 'package:delivery_food_app/providers/notification_service.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HalperNotification().initialize();

  if(!kIsWeb){
    channel = const AndroidNotificationChannel(
      Collections.androidChanId,
      Collections.androidChanName,
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp()
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final HalperNotification helpNotif = HalperNotification();

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification != null && android != null && !kIsWeb){
        String? title = message.notification!.title;
        String? body = message.notification!.body;
        String payload = message.data["some_data"];
        helpNotif.showNotification(title: title!, body: body!, payload: payload);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      Map<String, dynamic> decodedMap = jsonDecode(message.data["some_data"]);

      Get.to(() => ChatMessagePage(userId: decodedMap["from_id"], chatId: decodedMap["room_id"],));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: RouteHalper.getsplashScreen(),
      getPages: RouteHalper.routes,
    );
  }
}
// ScreenHeight 781.0909090909091
// ScreenWidth 392.7272727272727