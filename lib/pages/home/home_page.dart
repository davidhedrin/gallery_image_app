import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_group.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/app_page_body.dart';
import '../../generated/assets.dart';
import '../../utils/colors.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/big_text.dart';
import '../../component/main_app_page.dart';

class HomePageMenu extends StatefulWidget {
  final String uid;
  const HomePageMenu({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

class _HomePageMenuState extends State<HomePageMenu> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();
  String? _selectedItem = "";
  String? _selectedItemChane = "";

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
            margin: EdgeInsets.only(top: Dimentions.height40, bottom: Dimentions.height15),
            padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(child: BigText(text: document!.get('nama_lengkap'), color: AppColors.mainColor,)),
                            StreamBuilder(
                                stream: getService.streamBuilderGetDoc(collection: "user-master", docId: document.get("phone")),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                                  if (snapshotGroup.connectionState == ConnectionState.waiting) {
                                    return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                                  }
                                  if (!snapshotGroup.hasData) {
                                    return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                                  }else{
                                    var dataGroup = snapshotGroup.data!.data();
                                    List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                                    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                                      UserGroupModel getGroup = UserGroupModel.fromMap(res);
                                      return getGroup;
                                    }).toList();

                                    if(_selectedItem!.isEmpty){
                                      if(MainAppPage.groupCodeId!.isNotEmpty){
                                        _selectedItem = MainAppPage.groupCodeId;
                                      }else{
                                        _selectedItem = toModelGroup.first.id.toString();
                                      }
                                      MainAppPage.groupCodeId = _selectedItem;
                                    }

                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isDense: true,
                                        value: _selectedItem,
                                        icon: Icon(Icons.arrow_drop_down),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedItem = value;
                                            MainAppPage.groupCodeId = value;
                                            _selectedItemChane = value;
                                          });
                                        },
                                        items: toModelGroup.map((value) {
                                          return DropdownMenuItem(
                                            value: value.id.toString(),
                                            child: Text(value.nama_group.toString()),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  }
                                }
                            ),
                          ],
                        );
                      }
                    }
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

          // Body Page
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                  stream: getService.streamBuilderGetDoc(collection: "users", docId: widget.uid),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }else{
                      var document = snapshot.data;
                      return StreamBuilder(
                            stream: getService.streamBuilderGetDoc(collection: "user-master", docId: document!.get("phone")),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                              if (snapshotGroup.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (!snapshotGroup.hasData) {
                                return CircularProgressIndicator();
                              }else{
                                var dataGroup = snapshotGroup.data!.data();
                                List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                                List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                                  UserGroupModel getGroup = UserGroupModel.fromMap(res);
                                  return getGroup;
                                }).toList();

                                UserGroupModel getSelectedGroup = UserGroupModel();
                                if(_selectedItemChane!.isNotEmpty){
                                  getSelectedGroup = toModelGroup.firstWhere((group) => group.id == _selectedItemChane);
                                }

                                return AppPageBody(
                                  groupImage: _selectedItemChane!.isEmpty ? toModelGroup.first.nama_group.toLowerCase() : getSelectedGroup.nama_group.toLowerCase(),
                                );
                              }
                            }
                        );
                    }
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
