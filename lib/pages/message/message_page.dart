import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/message/message_data.dart';
import 'package:delivery_food_app/pages/message/chat_page.dart';
import 'package:delivery_food_app/providers/notification_service.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../generated/assets.dart';
import '../../models/message/main_message.dart';
import '../../models/user_master_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/utils.dart';
import '../../widgets/auth_widget/text_widget.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/message_widget.dart';

final AppServices getService = AppServices();

class MessagePageMenu extends StatefulWidget {
  const MessagePageMenu({Key? key}) : super(key: key);

  @override
  State<MessagePageMenu> createState() => _MessagePageMenuState();
}

class _MessagePageMenuState extends State<MessagePageMenu> {
  late String collectionMsg = "chat-${MainAppPage.groupNameGet.toLowerCase()}";

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
            elevation: 2,
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconBackground(
                    icon: Icons.more_vert,
                    color: Colors.white,
                    onTap: () {

                    },
                  ),
                ),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: getService.fbStore.collection(collectionMsg).where("userId", arrayContains: MainAppPage.setUserId).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshotMsg) {
              if (snapshotMsg.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshotMsg.hasData) {
                return const Center(
                  child: Text("Data tidak ditemukan!",)
                );
              }else{
                var getDocs = snapshotMsg.data!.docs;
                if(getDocs.isEmpty){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Selamat datang di",),
                        BigText(text: "We Gallery Chat 👋"),
                      ]
                    ),
                  );
                }else{
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: getDocs.length,
                    itemBuilder: (context, index){
                      Map<String, dynamic> getMap = getDocs[index].data() as Map<String, dynamic>;
                      MainMessage getMainMsg =  MainMessage.fromMap(getMap);
                      return _MessageTitle(getMainMsg: getMainMsg,);
                    },
                  );
                }
              }
            }
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "newChat",
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return const NewChatRoom();
                  }
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.perm_contact_cal_sharp),
          ),
        ),
      ),
    );
  }
}

class _MessageTitle extends StatefulWidget {
  final MainMessage getMainMsg;
  const _MessageTitle({Key? key, required this.getMainMsg}) : super(key: key);

  @override
  State<_MessageTitle> createState() => _MessageTitleState();
}

class _MessageTitleState extends State<_MessageTitle> {
  late String collectionMsg = "chat-${MainAppPage.groupNameGet.toLowerCase()}";

  @override
  Widget build(BuildContext context) {
    MainMessage setMM = widget.getMainMsg;
    String idUserLoad = MainAppPage.setUserId == setMM.userId![0] ? setMM.userId![1] : setMM.userId![0];

    return InkWell(
      onTap: (){
        Get.to(() => ChatMessagePage(userId: idUserLoad, chatId: setMM.chatId,));
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: getService.streamGetDocById(collection: Collections.users, docId: idUserLoad),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Avatar.medium(url: "",);
                  }else{
                    var data = snapshot.data!.data();
                    Map<String, dynamic> getMap = data as Map<String, dynamic>;
                    UserModel getMainMsg =  UserModel.fromMap(getMap);
                    return Avatar.medium(url: getMainMsg.img_profil_url,);
                  }
                }
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: getService.streamGetDocById(collection: Collections.users, docId: idUserLoad),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: LinearProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return BigText(text: "-");
                        }else{
                          var data = snapshot.data!.data();
                          Map<String, dynamic> getMap = data as Map<String, dynamic>;
                          UserModel getMainMsg =  UserModel.fromMap(getMap);
                          return BigText(text: getMainMsg.nama_lengkap);
                        }
                      }
                    ),
                  ),
                  SizedBox(
                    height: Dimentions.height15,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: getService.streamGetCollecInColect(collection1: collectionMsg, collection2: Collections.message, docId: setMM.chatId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return BigText(text: "-", color: Colors.black45,);
                        }
                        if (!snapshot.hasData) {
                          return BigText(text: "-", color: Colors.black45,);
                        }else{
                          var data = snapshot.data!.docs;
                          if(data.isNotEmpty){
                            List<MessageData> getListFromMap = data.map((item) {
                              Map<String, dynamic> getMap = item.data() as Map<String, dynamic>;
                              MessageData fromMap = MessageData.fromMap(getMap);
                              return fromMap;
                            }).toList();
                            getListFromMap.sort((a,b) => b.messageDate!.compareTo(a.messageDate!));

                            MessageData latestMsg = getListFromMap.first;
                            int msgNotRead = getListFromMap.where((msg) => msg.read == "N" && msg.toId == MainAppPage.setUserId).length;
                            int msgNotReadStatus = getListFromMap.where((msg) => msg.read == "N" && msg.fromId == MainAppPage.setUserId).length;

                            // if(MainAppPage.setUserId == latestMsg.toId && msgNotRead > 0){
                            //   HalperNotification.showNotification(title: "David", body: "Hello Everyone!", payload: setMM.chatId);
                            // }
                            return Row(
                              children: [
                                MainAppPage.setUserId == latestMsg.fromId ? Icon(Icons.done_all, size: Dimentions.iconSize15, color: msgNotReadStatus > 0 ? const Color(0xFFccc7c5) : Colors.green,) : const SizedBox(),
                                SizedBox(width: MainAppPage.setUserId == latestMsg.fromId ? msgNotReadStatus > 0 ? Dimentions.width5 : Dimentions.width5 : 0.0,),
                                SmallTextOvr(
                                  text: latestMsg.msg,
                                  size: Dimentions.font13,
                                  color:  MainAppPage.setUserId == latestMsg.toId ? msgNotRead > 0 ? Colors.black : const Color(0xFFccc7c5) : const Color(0xFFccc7c5),
                                  fontWeight: MainAppPage.setUserId == latestMsg.toId ? msgNotRead > 0 ? FontWeight.bold : FontWeight.normal : FontWeight.normal,
                                ),
                              ],
                            );
                          }else{
                            return BigText(text: "", color: Colors.black45,);
                          }
                        }
                      }
                    )
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: Dimentions.width20),
              child: StreamBuilder<QuerySnapshot>(
                stream: getService.streamGetCollecInColect(collection1: collectionMsg, collection2: Collections.message, docId: setMM.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return BigText(text: "-", color: Colors.black45,);
                  }
                  if (!snapshot.hasData) {
                    return BigText(text: "-", color: Colors.black45,);
                  }else{
                    var data = snapshot.data!.docs;
                    if(data.isNotEmpty){
                      List<MessageData> getListFromMap = data.map((item) {
                        Map<String, dynamic> getMap = item.data() as Map<String, dynamic>;
                        MessageData fromMap = MessageData.fromMap(getMap);
                        return fromMap;
                      }).toList();
                      getListFromMap.sort((a,b) => b.messageDate!.compareTo(a.messageDate!));

                      MessageData latestMsg = getListFromMap.first;
                      String latestDateMsg = Jiffy(latestMsg.messageDate).fromNow();

                      int msgNotRead = getListFromMap.where((msg) => msg.read == "N" && msg.toId == MainAppPage.setUserId).length;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: Dimentions.height4,),
                          Text(
                            latestDateMsg,
                            style: TextStyle(
                                fontSize: Dimentions.font11,
                                letterSpacing: -0.2,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey
                            ),
                          ),
                          SizedBox(height: Dimentions.height8,),
                          msgNotRead > 0 ?Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(msgNotRead.toString(), style: TextStyle(fontSize: Dimentions.height10, color: Colors.white),),
                              )
                          ) : const SizedBox(),
                        ],
                      );
                    }else{
                      return BigText(text: "", color: Colors.black45,);
                    }
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewChatRoom extends StatefulWidget {
  const NewChatRoom({Key? key}) : super(key: key);

  @override
  State<NewChatRoom> createState() => _NewChatRoomState();
}

class _NewChatRoomState extends State<NewChatRoom> {
  final TextEditingController searchController = TextEditingController();
  late String collectionMsg = "chat-${MainAppPage.groupNameGet.toLowerCase()}";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: MyTextFieldReg(
        controller: searchController,
        hintText: "Temukan User...",
        prefixIcon: const Icon(Icons.search),
      ),
      titlePadding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, top: Dimentions.height12),
      contentPadding: EdgeInsets.only(bottom: Dimentions.height10),
      content: IntrinsicWidth(
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: getService.streamObjGetCollection(collection: Collections.usermaster),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if(!snapshot.hasData){
                            return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
                          }else{
                            var userGroup = snapshot.data!.docs;
                            List<UserMasterModel> getListGroup = userGroup.map((e){
                              Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                              UserMasterModel images = UserMasterModel.fromMap(getMap);
                              return images;
                            }).toList();

                            List<UserMasterModel> getUser = getListGroup.expand((parent) => parent.group!).where((child) => child.group_id == MainAppPage.groupCodeId).map((child) => getListGroup.firstWhere((parent) => parent.group!.contains(child))).toList();
                            getUser.sort((a, b) => a.create_date!.compareTo(b.create_date!));

                            if(getUser.isEmpty){
                              return Padding(
                                padding: EdgeInsets.only(top: Dimentions.height45),
                                child: const DataNotFoundWidget(msgTop: "Belum ada user didaftarkan", msgButton: "Tambahkan user kedalam group anda!",),
                              );
                            }else{
                              return ListView.builder(
                                  padding: EdgeInsets.only(top: Dimentions.height15),
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: getUser.length,
                                  itemBuilder: (context, index){
                                    UserMasterModel getDataUser = getUser[index];
                                    return StreamBuilder<QuerySnapshot>(
                                        stream: getService.streamGetDocByColumn(collection: Collections.users, collName: "phone", value: getDataUser.phone),
                                        builder: (context, snapshotUser) {
                                          if (snapshotUser.connectionState == ConnectionState.waiting) {
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                          if(!snapshotUser.hasData){
                                            return const Text("Data tidak ditemukan!",);
                                          }else{
                                            var getDocs = snapshotUser.data!.docs;
                                            if(getDocs.isEmpty){
                                              return const SizedBox();
                                            }else{
                                              var data = getDocs.first;
                                              Map<String, dynamic> getMap = data.data() as Map<String, dynamic>;
                                              UserModel userModel = UserModel.fromMap(getMap);

                                              if(userModel.id != MainAppPage.setUserId){
                                                return Container(
                                                  margin: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, bottom: Dimentions.height10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.08),
                                                  ),
                                                  child: ListTile(
                                                    leading: Avatar.small(url: userModel.img_profil_url.isNotEmpty ? userModel.img_profil_url : ""),
                                                    title: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        BigText(text: userModel.nama_lengkap, size: Dimentions.font15, fontWeight: FontWeight.w500,),
                                                        SmallText(text: "+6282110863133"),
                                                      ],
                                                    ),
                                                    trailing: Icon(Icons.circle, size: Dimentions.iconSize12,color: userModel.statusLog == "1" ? Colors.green : Colors.red,),
                                                    onTap: () async {
                                                      String docIdChat = "${MainAppPage.setUserId}${userModel.id}";
                                                      var checkUserMsg = await getService.getAllDocuments(collectionMsg);
                                                      var allDoc = checkUserMsg.docs;

                                                      List<MainMessage> listMsgDoc = allDoc.map((doc){
                                                        Map<String, dynamic> getMap = doc.data() as Map<String, dynamic>;
                                                        MainMessage fromMap = MainMessage.fromMap(getMap);
                                                        return fromMap;
                                                      }).where((item) => item.userId!.contains(MainAppPage.setUserId) && item.userId!.contains(userModel.id)).toList();

                                                      MainMessage getCurrentMainMsg = MainMessage();
                                                      if(listMsgDoc.isNotEmpty){
                                                        getCurrentMainMsg = listMsgDoc.first;
                                                      }

                                                      Navigator.of(context).pop();
                                                      if(getCurrentMainMsg.chatId.isEmpty){
                                                        Get.toNamed(RouteHalper.getUserChatPage(userId: userModel.id));
                                                      }else{
                                                        MainMessage mainMsg = getCurrentMainMsg;
                                                        Get.to(() => ChatMessagePage(userId: userModel.id, chatId: mainMsg.chatId,));
                                                      }
                                                    },
                                                  ),
                                                );
                                              }
                                              else{
                                                if(getUser.length > 1){
                                                  return const SizedBox();
                                                }else{
                                                  return Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(top: Dimentions.height4, bottom: Dimentions.height10),
                                                      child: Column(
                                                        children: [
                                                          Image.asset(Assets.imageNotFound, width: Dimentions.heightSize120,),
                                                          SmallText(text: "Group gallery masih kosong"),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          }
                                        }
                                    );
                                  }
                              );
                            }
                          }
                        }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
