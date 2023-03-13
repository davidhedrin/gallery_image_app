// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/pages/account/account_page.dart';
import 'package:delivery_food_app/pages/home/home_page.dart';
import 'package:delivery_food_app/pages/message/message_page.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/setting/setting_page.dart';
import '../widgets/tab_button_navbar.dart';

class MainAppPage extends StatefulWidget {
  final String Userid;
  static String? groupCodeId = "";
  static String setUserId = "";
  static String groupNameGet = "";
  const MainAppPage({Key? key, required this.Userid}) : super(key: key);

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> with WidgetsBindingObserver {
  final AppServices getServ = AppServices();
  int index = 0;

  void onChangeTab(int index){
    setState(() {
      this.index = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.resumed){
      // Online
      getServ.setStatus(status: "1", userId: widget.Userid);
    }else{
      // Offline
      getServ.setStatus(status: "2", userId: widget.Userid);
    }
  }

  final List<Widget> pages = <Widget> [
    HomePageMenu(),
    MessagePageMenu(),
    SettingPageMenu(),
    AccountPageMenu()
  ];

  @override
  Widget build(BuildContext context) {
    MainAppPage.setUserId = widget.Userid;

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: TabBarNavigationMaterial(
        index: index,
        onChangeTab: onChangeTab,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: Dimentions.iconSize36,),
        onPressed: (){
          Get.toNamed(RouteHalper.getAddNewPostingPage(uid: widget.Userid, groupId: MainAppPage.groupCodeId));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
