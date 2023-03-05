import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../../widgets/message_widget.dart';

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
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Message', style: TextStyle(color: Colors.black87),),
            leadingWidth: Dimentions.height50,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: Dimentions.width15),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider("https://firebasestorage.googleapis.com/v0/b/flutter-gallery-app-45b50.appspot.com/o/imageProfile%2Fuser-8494c080-ab83-11ed-bc26-057ccc836471?alt=media&token=51bfd54b-0df6-44fa-8e1d-d453065b70b1"),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: Dimentions.width20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconBackground(
                    icon: Icons.search,
                    onTap: () {

                    },
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [

            ],
          ),
        ),
      ),
    );
  }
}
