import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../providers/app_services.dart';

class SplashScerenApp extends StatefulWidget {
  const SplashScerenApp({Key? key}) : super(key: key);

  @override
  State<SplashScerenApp> createState() => _SplashScerenAppState();
}

class _SplashScerenAppState extends State<SplashScerenApp> {
  final store = GetStorage();
  final AppServices getService = AppServices();

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
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null) {
            DocumentSnapshot docUser = await getService.getDocumentByColumn("users", "uidEmail", user.uid);
            String uid = docUser.id;
            Get.toNamed(RouteHalper.getInitial(uid: uid));
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
