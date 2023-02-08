import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class SplashScerenApp extends StatefulWidget {
  const SplashScerenApp({Key? key}) : super(key: key);

  @override
  State<SplashScerenApp> createState() => _SplashScerenAppState();
}

class _SplashScerenAppState extends State<SplashScerenApp> {
  final store = GetStorage();

  @override
  void initState(){
    Timer(
        const Duration(
          seconds: 4,
        ),(){
      bool? _boarding = store.read('onBoarding');

      if(_boarding == null){
        Get.toNamed(RouteHalper.getOnBoardScreen());
      }else{
        FirebaseAuth.instance.authStateChanges().listen((User? user){
          if (user != null) {
            Get.toNamed(RouteHalper.getInitial());
          } else {
            Get.toNamed(RouteHalper.getLoginPage());
          }
        });
      }

      _boarding == null ? Get.toNamed(RouteHalper.getOnBoardScreen()):
      _boarding == true ? Get.toNamed(RouteHalper.getLoginPage()):
      Get.toNamed(RouteHalper.getLoginPage());
    }
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Bounce(
                infinite: true,
                child: Image.asset(Assets.imageCika, width: Dimentions.screenHeight/3.9,)
              ),
              Text('Cips.Jeis Gallery', style: TextStyle(fontSize: Dimentions.screenHeight/43.39, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
