import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MainAppPage(),
        getPages: RouteHalper.routes,
      );
  }
}