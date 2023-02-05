// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:delivery_food_app/pages/account/account_page.dart';
import 'package:delivery_food_app/pages/home/home_page.dart';
import 'package:delivery_food_app/pages/message/message_page.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/setting/setting_page.dart';
import '../widgets/tab_button_navbar.dart';

class MainAppPage extends StatefulWidget {
  const MainAppPage({Key? key}) : super(key: key);

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int index = 0;

  void onChangeTab(int index){
    setState(() {
      this.index = index;
    });
  }

  final pages = <Widget> [
    HomePageMenu(),
    MessagePageMenu(),
    SettingPageMenu(),
    AccountPageMenu()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: TabBarNavigationMaterial(
        index: index,
        onChangeTab: onChangeTab,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: Dimentions.iconSize36,),
        onPressed: (){

        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}