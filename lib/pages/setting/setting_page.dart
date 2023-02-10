import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../utils/utils.dart';
import '../../widgets/big_text.dart';

class SettingPageMenu extends StatefulWidget {
  const SettingPageMenu({Key? key}) : super(key: key);

  @override
  State<SettingPageMenu> createState() => _SettingPageMenuState();
}

class _SettingPageMenuState extends State<SettingPageMenu> {
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
          Center(
            child: BigText(text: "Setting Page Menu"),
          )
        ],
      ),
    );
  }
}
