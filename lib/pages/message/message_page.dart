import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_food_app/models/message_data.dart';
import 'package:delivery_food_app/pages/message/chat_page.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../utils/utils.dart';
import '../../widgets/message_widget.dart';

const String urlImage = "https://firebasestorage.googleapis.com/v0/b/flutter-gallery-app-45b50.appspot.com/o/imageProfile%2Fuser-8494c080-ab83-11ed-bc26-057ccc836471?alt=media&token=51bfd54b-0df6-44fa-8e1d-d453065b70b1";

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
            backgroundColor: Colors.white,
            leading: Align(
              alignment: Alignment.centerRight,
              child: IconBackground(
                icon: Icons.search,
                onTap: () {

                },
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: Dimentions.width20),
                child: Avatar.small(url: urlImage),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(_delegate),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "newChat",
            onPressed: () {
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add_comment_outlined),
          ),
        ),
      ),
    );
  }

  Widget _delegate(BuildContext context, int index){
    final Faker faker = Faker();
    final random = Random();
    final DateTime dateNow = DateTime.now();
    final getRandomDate = dateNow.subtract(Duration(seconds: random.nextInt(200000)));

    MessageData msgData = MessageData(
      senderName: faker.person.name(),
      message: faker.lorem.sentence(),
      messageDate: getRandomDate,
      dateMessage: Jiffy(getRandomDate).fromNow(),
      profilePicture: urlImage
    );
    return _MessageTitle(messageData: msgData);
  }
}

class _MessageTitle extends StatelessWidget {
  const _MessageTitle({Key? key, required this.messageData}) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Get.to(() => ChatMessagePage(messageData: messageData));
      },
      child: Container(
        height: Dimentions.height80,
        margin: EdgeInsets.symmetric(horizontal: Dimentions.width8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(Dimentions.height10),
              child: Avatar.medium(url: messageData.profilePicture,),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
                    child: BigText(text: messageData.senderName),
                  ),
                  SizedBox(
                    height: Dimentions.height15,
                    child: SmallTextOvr(text: messageData.message, size: Dimentions.font13,)
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: Dimentions.width20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: Dimentions.height4,),
                  Text(
                    messageData.dateMessage.toUpperCase(),
                    style: TextStyle(
                      fontSize: Dimentions.font11,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey
                    ),
                  ),
                  SizedBox(height: Dimentions.height8,),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text("1", style: TextStyle(fontSize: Dimentions.height10, color: Colors.white),),
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
