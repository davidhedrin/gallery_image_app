import 'dart:io';

import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:flutter/cupertino.dart';

import '../../utils/utils.dart';

class MessagePageMenu extends StatefulWidget {
  const MessagePageMenu({Key? key}) : super(key: key);

  @override
  State<MessagePageMenu> createState() => _MessagePageMenuState();
}

class _MessagePageMenuState extends State<MessagePageMenu> {
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
            child: BigText(text: "Message Page Menu"),
          )
        ],
      ),
    );
  }
}
