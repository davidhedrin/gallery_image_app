import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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