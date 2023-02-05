import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../component/app_page_body.dart';
import '../../utils/colors.dart';
import '../../utils/dimentions.dart';
import '../../widgets/big_text.dart';
import '../../widgets/small_text.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({Key? key}) : super(key: key);

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

class _HomePageMenuState extends State<HomePageMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header search and name
        Container(
          child: Container(
            margin: EdgeInsets.only(top: Dimentions.height45, bottom: Dimentions.height15),
            padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    BigText(text: "Indonesia", color: AppColors.mainColor,),
                    Row(
                      children: [
                        SmallText(text: "Bekasi Timur", color: Colors.black54,),
                        Icon(Icons.arrow_drop_down_circle_rounded),
                      ],
                    )
                  ],
                ),
                Center(
                  child: Container(
                    width: Dimentions.height45,
                    height: Dimentions.height45,
                    child: Icon(Icons.search, color: Colors.white, size: Dimentions.iconSize24,),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimentions.radius15),
                      color: AppColors.mainColor,
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
    );
  }
}
