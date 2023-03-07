import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/models/message/message_data.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/message_widget.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message/main_message.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/dimentions.dart';
import '../../widgets/glowing_action_button.dart';

late String idUserGet;
final AppServices getService = AppServices();
late String collectionMsg = "chat-${MainAppPage.groupNameGet.toLowerCase()}";

class ChatMessagePage extends StatefulWidget {
  final String? userId;
  final String? chatId;

  const ChatMessagePage({Key? key, this.userId, this.chatId}) : super(key: key);

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  late String charRoomId;

  @override
  Widget build(BuildContext context) {
    idUserGet = widget.userId!.isNotEmpty ? widget.userId! : "";
    charRoomId = widget.chatId != null ? widget.chatId! : "";

    print(charRoomId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _AppBarTitle(uid: idUserGet),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera_front, color: Colors.black87, size: Dimentions.iconSize24,),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: Dimentions.width8),
            child: IconButton(
              icon: Icon(Icons.phone, color: Colors.black87, size: Dimentions.iconSize24,),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: Dimentions.height2,),
          Expanded(
            child: charRoomId.isNotEmpty ? StreamBuilder<QuerySnapshot>(
              stream: getService.streamGetCollecInColect(collection1: collectionMsg, collection2: Collections.message, docId: widget.chatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Pesan tidak ditemukan!"),);
                }else{
                  var data = snapshot.data!.docs;
                  List<MessageData> getListFromMap = data.map((item) {
                    Map<String, dynamic> getMap = item.data() as Map<String, dynamic>;
                    MessageData fromMap = MessageData.fromMap(getMap);
                    return fromMap;
                  }).toList();
                  getListFromMap.sort((a,b) => b.messageDate!.compareTo(a.messageDate!));

                  return _DemoMessageList(listMsgData: getListFromMap,);
                }
              }
            ) : const Center(child: Text("Selamat chattigan... 😇")),
          ),
          ChatInput(context),
        ],
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();
  Widget ChatInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height10, horizontal: Dimentions.width10),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimentions.radius15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {

                      },
                      icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: Dimentions.iconSize25)
                  ),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: 'Type Something...',
                            border: InputBorder.none
                        ),
                      )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                      },
                      icon: Icon(Icons.image,color: Colors.blueAccent, size: Dimentions.iconSize26)
                  ),

                  IconButton(
                      onPressed: () async {
                      },
                      icon: Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: Dimentions.iconSize26)
                  ),

                  SizedBox(width: Dimentions.width3),
                ],
              ),
            ),
          ),

          SizedBox(width: Dimentions.width3),
          GlowingActionButton(
            color: AppColors.secondary,
            icon: Icons.send_rounded,
            size: Dimentions.height45,
            onPressed: (){
              if(_textController.text.isNotEmpty){
                MessageData msgData = MessageData(
                  toId: idUserGet,
                  fromId: MainAppPage.setUserId,
                  msg: _textController.text,
                  read: "N",
                  type: Type.text,
                  messageDate: DateTime.now(),
                );

                if(charRoomId.isEmpty){
                  String chatId = "${MainAppPage.setUserId}$idUserGet";
                  MainMessage mainMsg = MainMessage(
                    chatId: chatId,
                    userId: [MainAppPage.setUserId, idUserGet],
                  );

                  getService.sendMessage(
                    data: mainMsg.toMap(),
                    collection: collectionMsg,
                    chatId: chatId,
                    dataMsg: msgData.toMap(),
                  );
                }else{
                  getService.saveMessage(dataMsg: msgData.toMap(), collection: collectionMsg, chatId: charRoomId);
                }

                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatefulWidget {
  final String uid;
  const _AppBarTitle({Key? key, required this.uid}) : super(key: key);

  @override
  State<_AppBarTitle> createState() => _AppBarTitleState();
}

class _AppBarTitleState extends State<_AppBarTitle> {
  final AppServices getService = AppServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
      stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: widget.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if(!snapshot.hasData){
          return const Text("");
        }else{
          var data = snapshot.data;
          Map<String, dynamic> getMapUser = data!.data() as Map<String, dynamic>;
          UserModel getUser = UserModel.fromMap(getMapUser);

          return Row(
            children: [
              Avatar.small(url: getUser.img_profil_url,),
              SizedBox(width: Dimentions.width15,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(text: getUser.nama_lengkap, size: Dimentions.font14,),
                    SizedBox(height: Dimentions.height2,),
                    SmallText(text: "Online", color: Colors.green, fontWeight: FontWeight.bold,),
                  ],
                ),
              )
            ],
          );
        }
      }
    );
  }
}

class _DemoMessageList extends StatefulWidget {
  final List<MessageData> listMsgData;
  const _DemoMessageList({Key? key, required this.listMsgData}) : super(key: key);

  @override
  State<_DemoMessageList> createState() => _DemoMessageListState();
}

class _DemoMessageListState extends State<_DemoMessageList> {
  @override
  Widget build(BuildContext context) {
    List<MessageData> listMsg = widget.listMsgData;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimentions.height8),
      child: ListView(
        reverse: true,
        children: listMsg.map((msgData){
          MessageData msg = msgData;
          bool checkIdMsg = MainAppPage.setUserId == msg.toId;
          DateTime dt = msg.messageDate!;
          String msgTime = DateFormat('HH:mm').format(dt);

          if(checkIdMsg){
            return _MessageTile(
              message: msg.msg,
              messageDate: msgTime,
            );
          }else{
            return   _MessageOwnTile(
              message: msg.msg,
              messageDate: msgTime,
            );
          }
        }).toList(),
        // [
        //   _DataTable(lable: "Yesterday"),
        // ],
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({Key? key, required this.lable}) : super(key: key);

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimentions.height15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(Dimentions.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Dimentions.height4, horizontal: Dimentions.width12),
            child: Text(
              lable,
              style: TextStyle(
                fontSize: Dimentions.font12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({Key? key, required this.message, required this.messageDate}) : super(key: key);

  final String message;
  final String messageDate;

  static double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.textFaded,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_borderRadius),
                    topRight: Radius.circular(_borderRadius),
                    bottomRight: Radius.circular(_borderRadius),
                  )
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width12),
                child: Text(
                  message,
                  style: TextStyle(
                      color: AppColors.textLigth
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: Dimentions.height8),
              child: Text(
                messageDate,
                style: TextStyle(
                  fontSize: Dimentions.font10,
                  color: AppColors.textFaded,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({Key? key, required this.message, required this.messageDate}) : super(key: key);

  final String message;
  final String messageDate;

  static double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                )
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width12),
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textLigth
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: Dimentions.height8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    messageDate,
                    style: TextStyle(
                      fontSize: Dimentions.font10,
                      color: AppColors.textFaded,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: Dimentions.width5,),
                  Icon(Icons.done_all, size: Dimentions.iconSize13, color: Colors.green,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}




