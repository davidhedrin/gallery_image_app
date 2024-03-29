import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../providers/app_services.dart';
import '../providers/notification_service.dart';

class SplashScerenApp extends StatefulWidget {
  const SplashScerenApp({Key? key}) : super(key: key);

  @override
  State<SplashScerenApp> createState() => _SplashScerenAppState();
}

class _SplashScerenAppState extends State<SplashScerenApp> {
  final store = GetStorage();
  final AppServices getService = AppServices();
  final HalperNotification helpHotif = HalperNotification();
  final AppServices getServ = AppServices();

  @override
  void initState(){
    super.initState();
    Timer(
      const Duration(
        seconds: 4,
      ),() async {
        bool? boarding = store.read('onBoarding');
        ConnectivityResult resultCon = await Connectivity().checkConnectivity();

        if(resultCon != ConnectivityResult.none){
          if(boarding == null){
            Get.toNamed(RouteHalper.getOnBoardScreen());
          }else{
            getService.fbAuth.authStateChanges().listen((User? user) async {
              getService.loading(context);
              if (user != null && user.uid.isNotEmpty) {
                try{
                  DocumentSnapshot? docUser = await getService.getDocumentByColumn("users", "uidEmail", user.uid);
                  String uid = docUser!.id;
                  await setLoginUser(uid);

                  Navigator.of(context).pop();
                  Get.toNamed(RouteHalper.getInitial(uid: uid));
                }catch(e){
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    print("Error checkUserLogin Splash Screen");
                    print(e);
                  }
                }
              } else {
                Navigator.of(context).pop();
                Get.toNamed(RouteHalper.getLoginPage());
              }
            });
          }

          boarding == null ? Get.toNamed(RouteHalper.getOnBoardScreen()):
          boarding == true ? Get.toNamed(RouteHalper.getLoginPage()):
          Get.toNamed(RouteHalper.getLoginPage());
        }else{
          Get.toNamed(RouteHalper.noInternetPage());
        }
      }
    );
  }

  Future<void> setLoginUser(String userId) async {
    await getServ.getUserLoginModel(userId);
    helpHotif.initialize();
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
                child: Image.asset(Assets.imageAppIcon, width: Dimentions.height70,)
              ),
              SizedBox(height: Dimentions.height4,),
              Text("We Gallery's", style: TextStyle(fontSize: Dimentions.screenHeight/43.39, fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ),
    );
  }
}
