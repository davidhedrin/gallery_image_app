import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/app_page_body.dart';
import '../../utils/colors.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/big_text.dart';
import '../../widgets/small_text.dart';

class HomePageMenu extends StatefulWidget {
  final String uid;
  const HomePageMenu({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

class _HomePageMenuState extends State<HomePageMenu> {
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool check = false;
        await onBackButtonPressYesNo(context: context, text: "Keluar Aplikasi!", desc: "Yakin ingin keluar dari aplikasi?").then((value){
          check = value;
        });
        if(check){
          exit(0);
        }
        return check;
      },
      child: Column(
        children: [
          // Header search and name
          Container(
            child: Container(
              margin: EdgeInsets.only(top: Dimentions.height40, bottom: Dimentions.height15),
              padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                        stream: getService.streamBuilderGetDoc(collection: "users", docId: widget.uid),
                        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                          }
                          if (!snapshot.hasData) {
                            return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                          }else{
                            var document = snapshot.data;
                            return Container(child: BigText(text: document!.get('nama_lengkap'), color: AppColors.mainColor,));
                          }
                        }
                      ),
                      Row(
                        children: [
                          SmallText(text: "Bekasi Timur", color: Colors.black54,),
                          Icon(Icons.arrow_drop_down_circle_rounded),
                        ],
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      bool check = false;
                      await onBackButtonPressYesNo(context: context, text: "Putuskan Koneksi!", desc: "Yakin ingin memutuskan koneksi?").then((value){
                        check = value;
                      });
                      if(check){
                        FirebaseAuth.instance.signOut();
                        Get.toNamed(RouteHalper.getLoginPage());
                      }
                    },
                    child: Center(
                      child: Container(
                        width: Dimentions.height30,
                        height: Dimentions.height30,
                        child: Icon(Icons.power_settings_new, color: Colors.white, size: Dimentions.iconSize24,),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimentions.radius15),
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Body Page
          Expanded(
            child: SingleChildScrollView(
              child: AppPageBody(),
            ),
          ),
        ],
      ),
    );
  }
}
