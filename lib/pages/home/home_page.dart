import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_group.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/app_page_body.dart';
import '../../component/search/custom_search_delegate.dart';
import '../../utils/colors.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/big_text.dart';
import '../../component/main_app_page.dart';
import '../../widgets/data_not_found.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({Key? key}) : super(key: key);

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

class _HomePageMenuState extends State<HomePageMenu> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();
  final String _userId = MainAppPage.setUserId;
  String? _selectedItem = "";

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
                    stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: _userId),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return BigText(text: "-", color: AppColors.mainColor,);
                      }
                      if (!snapshot.hasData) {
                        return BigText(text: "-", color: AppColors.mainColor,);
                      }else{
                        var document = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BigText(text: document!.get('nama_lengkap'), color: AppColors.mainColor,),
                            StreamBuilder(
                                stream: getService.streamBuilderGetDoc(collection: Collections.usermaster, docId: document.get("phone")),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                                  if (snapshotGroup.connectionState == ConnectionState.waiting) {
                                    return BigText(text: "-", color: AppColors.mainColor,);
                                  }
                                  if (!snapshotGroup.hasData) {
                                    return BigText(text: "-", color: AppColors.mainColor,);
                                  }else{
                                    List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                                    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                                      UserGroupModel getGroup = UserGroupModel.fromMap(res);
                                      return getGroup;
                                    }).toList();

                                    if(_selectedItem!.isEmpty){
                                      if(MainAppPage.groupCodeId!.isNotEmpty){
                                        _selectedItem = MainAppPage.groupCodeId;
                                      }else{
                                        _selectedItem = toModelGroup.first.groupId.toString();
                                      }
                                      MainAppPage.groupCodeId = _selectedItem;
                                    }

                                    if(MainAppPage.groupNameGet.isEmpty){
                                      MainAppPage.groupNameGet = toModelGroup.first.namaGroup.toLowerCase();
                                    }else{
                                      UserGroupModel getGroup = toModelGroup.firstWhere((group) => group.groupId == _selectedItem);
                                      MainAppPage.groupNameGet = getGroup.namaGroup.toLowerCase();
                                    }

                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isDense: true,
                                        value: _selectedItem,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        onChanged: (value) {
                                          UserGroupModel getGroup = toModelGroup.firstWhere((group) => group.groupId == _selectedItem);
                                          setState(() {
                                            _selectedItem = value;
                                            MainAppPage.groupCodeId = value;
                                            MainAppPage.groupNameGet = getGroup.namaGroup.toLowerCase();
                                          });
                                        },
                                        items: toModelGroup.map((value) {
                                          return DropdownMenuItem(
                                            value: value.groupId.toString(),
                                            child: Text(value.namaGroup.toString()),
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
                Center(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          showSearch(
                            context: context,
                            delegate: CustomSearchDelegate(searchFor: Collections.collSearchForPost),
                          );
                        },
                        child: Icon(Icons.search, color: Colors.black45, size: Dimentions.iconSize32,)
                      ),
                      SizedBox(width: Dimentions.width3,),
                      GestureDetector(
                          onTap: (){
                            Get.toNamed(RouteHalper.getBookmarkPage());
                          },
                          child: Icon(Icons.bookmark, color: AppColors.mainColor, size: Dimentions.iconSize32,)
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Body Page
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: _userId),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData) {
                    return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
                  }else{
                    var document = snapshot.data;
                    return StreamBuilder(
                      stream: getService.streamBuilderGetDoc(collection: Collections.usermaster, docId: document!.get("phone")),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                        if (snapshotGroup.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshotGroup.hasData) {
                          return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
                        }else{
                          return AppPageBody(groupImage: MainAppPage.groupNameGet.toLowerCase(),);
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
