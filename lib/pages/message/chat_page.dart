// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/models/message/message_data.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/message_widget.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/message/main_message.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/dimentions.dart';
import '../../widgets/glowing_action_button.dart';

late String idUserGet;
final AppServices getService = AppServices();
String collectionMsg = "chat-${MainAppPage.groupNameGet.toLowerCase()}";

class ChatMessagePage extends StatefulWidget {
  final String? userId;
  final String? chatId;

  const ChatMessagePage({Key? key, this.userId, this.chatId}) : super(key: key);

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusInput = FocusNode();
  late String chatRoomId = "";
  bool showEmoji = false;

  @override
  Widget build(BuildContext context) {
    idUserGet = widget.userId!.isNotEmpty ? widget.userId! : "";
    chatRoomId = chatRoomId.isNotEmpty ? chatRoomId : widget.chatId != null ? widget.chatId! : "";

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: (){
            if(showEmoji){
              setState(() => showEmoji = !showEmoji);
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: _AppBarTitle(uid: idUserGet),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87,),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Column(
              children: [
                SizedBox(height: Dimentions.height2,),
                Expanded(
                  child: chatRoomId.isNotEmpty ? StreamBuilder<QuerySnapshot>(
                    stream: getService.streamGetCollecInColect(collection1: collectionMsg, collection2: Collections.message, docId: chatRoomId),
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

                        return _DemoMessageList(listMsgData: getListFromMap, chatId: chatRoomId,);
                      }
                    }
                  ) : const Center(child: Text("Mulai tinggalkan pesan... 😇")),
                ),
                chatInput(context),
                if(showEmoji)
                  SizedBox(
                    height: Dimentions.heightSize270,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 8,
                        emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chatInput(BuildContext context) {
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
                        FocusScope.of(context).unfocus();
                        setState(() {
                          if(showEmoji == false){
                            showEmoji = true;
                          }else{
                            showEmoji = false;
                            _focusInput.requestFocus();
                          }
                        });
                      },
                      icon: Icon(!showEmoji ? Icons.emoji_emotions : Icons.keyboard_alt_outlined, color: Colors.blueAccent, size: Dimentions.iconSize25)
                  ),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusInput,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: (){
                          if(showEmoji) {setState(() => showEmoji = !showEmoji );}
                        },
                        decoration: const InputDecoration(
                            hintText: 'Type Something...',
                            border: InputBorder.none
                        ),
                      )),

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
            onPressed: () async {
              if(_textController.text.isNotEmpty){
                DateTime dt = DateTime.now();
                String docIdMsg = dt.millisecond.toString()+dt.second.toString()+dt.minute.toString()+dt.hour.toString()+dt.day.toString()+dt.month.toString()+dt.year.toString();

                var getUserTo = await getService.fbStore.collection(Collections.users).doc(idUserGet).get();
                Map<String, dynamic> getMap = getUserTo.data() as Map<String, dynamic>;
                UserModel userTo = UserModel.fromMap(getMap);

                MessageData msgData = MessageData(
                  id: docIdMsg,
                  toId: idUserGet,
                  fromId: MainAppPage.setUserId,
                  msg: _textController.text,
                  read: "N",
                  type: Type.text,
                  messageDate: DateTime.now(),
                );

                if(chatRoomId.isEmpty){
                  String chatId = "${MainAppPage.setUserId}$idUserGet";
                  MainMessage mainMsg = MainMessage(
                    chatId: chatId,
                    userId: [MainAppPage.setUserId, idUserGet],
                  );

                  getService.sendMessage(
                    data: mainMsg.toMap(),
                    collection: collectionMsg,
                    chatId: chatId,
                    docIdMsg: docIdMsg,
                    dataMsg: msgData.toMap(),
                    forUser: userTo,
                  );

                  setState(() {
                    chatRoomId = chatId;
                  });
                }
                else{
                  getService.saveMessage(dataMsg: msgData.toMap(), collection: collectionMsg, chatId: chatRoomId, docIdMsg: docIdMsg, forUser: userTo);
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
          String gSt = getUser.statusLog;
          String lastSeen = Jiffy(getUser.lastOnline).fromNow();

          return Row(
            children: [
              Avatar.small(url: getUser.imgProfilUrl,),
              SizedBox(width: Dimentions.width15,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BigText(text: getUser.namaLengkap, size: Dimentions.font14,),
                    SizedBox(height: Dimentions.height2,),
                    SmallText(text: gSt == "1" ? "Online" : "Last seen $lastSeen", color: gSt == "1" ? Colors.green : Colors.grey, fontWeight: FontWeight.bold,),
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
  final String chatId;
  const _DemoMessageList({Key? key, required this.listMsgData, required this.chatId}) : super(key: key);

  @override
  State<_DemoMessageList> createState() => _DemoMessageListState();
}

class _DemoMessageListState extends State<_DemoMessageList> {

  void updateNotReadMsg(List<MessageData> listMsg, String chatId) {
    List<MessageData> allListMsg = listMsg.where((msg) => msg.toId == MainAppPage.setUserId && msg.read == "N").toList();
    for(var msg in allListMsg){
      getService.fbStore.collection(collectionMsg).doc(chatId).collection(Collections.message).doc(msg.id).update({
        'read': 'Y'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MessageData> listMsg = widget.listMsgData;

    updateNotReadMsg(listMsg, widget.chatId);

    bool haveDateTable = false;

    MessageData checkFirstOfDate(DateTime curentDate){
      final startOfDay = DateTime(curentDate.year, curentDate.month, curentDate.day);
      List<MessageData> setListOfDate = listMsg.where((msg) => DateTime(msg.messageDate!.year, msg.messageDate!.month, msg.messageDate!.day) == startOfDay).toList();
      MessageData firstMsg = setListOfDate.last;
      return firstMsg;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimentions.height8),
      child: ListView(
        reverse: true,
        children: listMsg.map((msgData){
          MessageData msg = msgData;
          bool checkIdMsg = MainAppPage.setUserId == msg.toId;

          MessageData getFirstOfDate = checkFirstOfDate(msg.messageDate!);
          String getDateMsg = DateFormat('dd MMMM yyyy').format(getFirstOfDate.messageDate!);

          if(msg.id != getFirstOfDate.id){
            haveDateTable = true;
          }else{
            haveDateTable = false;
          }

          if(checkIdMsg){
            return Column(
              children: [
                haveDateTable == false ? _DataTable(lable: getDateMsg) : const SizedBox(),
                _MessageTile(msgData: msg,),
              ],
            );
          }else{
            return Column(
              children: [
                haveDateTable == false ? _DataTable(lable: getDateMsg) : const SizedBox(),
                _MessageOwnTile(msgData: msg,),
              ],
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
        padding: EdgeInsets.symmetric(vertical: Dimentions.height10),
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
  const _MessageTile({Key? key, required this.msgData}) : super(key: key);

  final MessageData msgData;

  static final double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    DateTime dt = msgData.messageDate!;
    String msgTime = DateFormat('HH:mm').format(dt);

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
                  msgData.msg,
                  style: TextStyle(
                      color: AppColors.textLigth
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: Dimentions.height8),
              child: Text(
                msgTime,
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
  const _MessageOwnTile({Key? key, required this.msgData, }) : super(key: key);

  final MessageData msgData;

  static final double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    DateTime dt = msgData.messageDate!;
    String msgTime = DateFormat('HH:mm').format(dt);

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
                  msgData.msg,
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
                    msgTime,
                    style: TextStyle(
                      fontSize: Dimentions.font10,
                      color: AppColors.textFaded,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: Dimentions.width3,),
                  Icon(Icons.done_all, size: Dimentions.iconSize13, color: msgData.read == "Y" ? Colors.green : Colors.grey,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}




