import 'dart:io';

import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class AccountPageMenu extends StatefulWidget {
  const AccountPageMenu({Key? key}) : super(key: key);

  @override
  State<AccountPageMenu> createState() => _AccountPageMenuState();
}

class _AccountPageMenuState extends State<AccountPageMenu> {
  @override
  Widget build(BuildContext context) {
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/13.84;

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
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget> [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: profileSize + Dimentions.height15),
                  color: Colors.grey,
                  child: Image.asset(
                    Assets.imageLandscape,
                    width: double.infinity,
                    height: coverHeight,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: coverHeight - profileSize,
                  child: CircleAvatar(
                    radius: profileSize + 5,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: profileSize,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: AssetImage(Assets.imageMakanan),
                    ),
                  ),
                ),
              ],
            ),

            Column(
              children: [
                Text("David Simbolon", style: TextStyle(fontSize: Dimentions.font20, fontWeight: FontWeight.bold)),
                SmallText(text: "+6282110863133", color: Colors.black87,)
              ],
            ),
          ]
        ),
      ),
    );
  }
}
