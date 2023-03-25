// ignore_for_file: use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

import '../../models/message/main_message.dart';
import '../../models/message/message_data.dart';
import '../../models/user_group_master_model.dart';
import '../../models/user_master_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';
import '../../widgets/loading_progres.dart';
import '../../widgets/message_widget.dart';
import 'chat_page.dart';

class SearchUseridPage extends StatefulWidget {
  const SearchUseridPage({Key? key}) : super(key: key);

  @override
  State<SearchUseridPage> createState() => _SearchUseridPageState();
}

class _SearchUseridPageState extends State<SearchUseridPage> {
  final AppServices getService = AppServices();
  final TextEditingController userIdController = TextEditingController();

  bool searchLoading = false;
  bool searchFound = false;

  MainMessage setForMainMsg = MainMessage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Temukan user', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: Dimentions.height12,),
          Image.asset(Assets.imageSearchUserChat),
          SizedBox(height: Dimentions.height12,),

          SmallText(
            text: "Temukan user lain dari group berbeda",
            size: Dimentions.font14,
            color: Colors.grey,
          ),
          SmallText(
            text: "dan mulai lah tinggalkan pesan",
            size: Dimentions.font14,
            color: Colors.grey,
          ),
          
          SizedBox(height: Dimentions.height20,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimentions.width20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(Dimentions.radius12)
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimentions.width10),
                          child: Icon(Icons.account_box, size: Dimentions.height30, color: Colors.grey,),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: Dimentions.width12),
                            child: TextFormField(
                              controller: userIdController,
                              style: TextStyle(fontSize: Dimentions.font16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Temuka user-1234abcd-****-...",
                                hintStyle: TextStyle(fontSize: Dimentions.font15)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Dimentions.width10,),
                InkWell(
                  child: Container(
                    height: Dimentions.height45,
                    width: Dimentions.height45,
                    padding: EdgeInsets.all(Dimentions.height12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(Dimentions.radius12)
                    ),
                    child: const Icon(Icons.search, color: Colors.white,),
                  ),
                  onTap: () async {
                    setState(() {
                      searchLoading = true;
                    });

                    bool loopingGroup = false;
                    bool userFound = false;
                    String searchUid = userIdController.text;
                    String currentUid = MainAppPage.setUserId;
                    MainMessage setMM = MainMessage();

                    var allGroups = await getService.getAllDocuments(Collections.usergroup);
                    var allDocs = allGroups.docs;
                    List<UserGroupMasterModel> allGroupMaster = allDocs.map((e){
                      Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                      UserGroupMasterModel fromMap = UserGroupMasterModel.fromMap(getMap);
                      return fromMap;
                    }).toList();
                    allGroupMaster.sort((a, b) => a.namaGroup.compareTo(b.namaGroup));
                    for(var item in allGroupMaster){
                      String collectionMsg = "chat-${item.namaGroup.toLowerCase()}";
                      var getAllChatsUser = getService.fbStore.collection(collectionMsg)
                          .where(Collections.collColumnuserId, whereIn: [
                            [searchUid, currentUid],
                            [currentUid, searchUid],
                          ]);
                      var getQuery = await getAllChatsUser.get();
                      var docsAllChats = getQuery.docs;
                      if(docsAllChats.isNotEmpty){
                        Map<String, dynamic> getMap = docsAllChats.first.data();
                        setMM = MainMessage.fromMap(getMap);
                        loopingGroup = true;
                        break;
                      }
                    }

                    if(loopingGroup == false){
                      var getCurrentUser = await getService.getDocDataByDocIdNoCon(collection: Collections.users, docId: currentUid);
                      var getSearchUser = await getService.getDocDataByDocIdNoCon(collection: Collections.users, docId: searchUid);

                      if(getSearchUser != null && getSearchUser.exists){
                        UserModel modelCurrentUser = UserModel.fromMap(getCurrentUser!.data() as Map<String, dynamic>);
                        UserModel modelSearchUser = UserModel.fromMap(getSearchUser.data() as Map<String, dynamic>);

                        var getCurMaster = await getService.getDocDataByDocIdNoCon(collection: Collections.usermaster, docId: modelCurrentUser.phone);
                        var getSerMaster = await getService.getDocDataByDocIdNoCon(collection: Collections.usermaster, docId: modelSearchUser.phone);

                        UserMasterModel modelCurUserMaster = UserMasterModel.fromMap(getCurMaster!.data() as Map<String, dynamic>);
                        UserMasterModel modelSerUserMaster = UserMasterModel.fromMap(getSerMaster!.data() as Map<String, dynamic>);

                        MainMessage setMMLoop = MainMessage();
                        bool getSameGroup = false;
                        for(var x in modelCurUserMaster.group!){
                          for(var y in modelSerUserMaster.group!){
                            if(x.groupId == y.groupId){
                              String collectionMsg = "chat-${x.namaGroup.toLowerCase()}";
                              setMMLoop.chatGroup = collectionMsg;
                              getSameGroup = true;
                              break;
                            }
                          }
                        }

                        if(getSameGroup == false){
                          String getGroupRandom = modelCurUserMaster.group!.first.namaGroup;
                          String collectionMsg = "chat-${getGroupRandom.toLowerCase()}";
                          setMMLoop.chatGroup = collectionMsg;
                        }
                        userFound = true;
                        setMM = setMMLoop;
                      }else{
                        userFound = false;
                        showAwsBar(context: context, contentType: ContentType.help, msg: "User id tidak terdaftar", title: "Not Found!");
                      }
                    }

                    setState(() {
                      setForMainMsg = setMM;
                      searchLoading = false;
                      searchFound = userFound;
                    });
                  },
                )
              ],
            ),
          ),

          SizedBox(height: Dimentions.height12,),
          searchLoading == true ? Column(
            children: [
              LoadingProgress(color: Colors.grey[600], size: Dimentions.iconSize28,),
              SmallText(
                text: "Sedang mencari...",
                size: Dimentions.font14,
                color: Colors.grey[400],
              ),
            ],
          ) : const SizedBox(),

          if(setForMainMsg.chatGroup.isNotEmpty)
            InkWell(
            onTap: (){
              Navigator.pop(context);
              Get.to(() => ChatMessagePage(userId: userIdController.text, chatId: setForMainMsg.chatId, collectionMsg: setForMainMsg.chatGroup,));
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
                        stream: getService.streamGetDocById(collection: Collections.users, docId: userIdController.text),
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
                            return Avatar.medium(url: getMainMsg.imgProfilUrl,);
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
                              stream: getService.streamGetDocById(collection: Collections.users, docId: userIdController.text),
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
                                  return BigText(text: getMainMsg.namaLengkap);
                                }
                              }
                          ),
                        ),
                        SizedBox(
                          height: Dimentions.height15,
                          child: setForMainMsg.chatId.isNotEmpty ? StreamBuilder<QuerySnapshot>(
                            stream: getService.streamGetCollecInColect(collection1: setForMainMsg.chatGroup, collection2: Collections.message, docId: setForMainMsg.chatId),
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
                          ) : SmallText(
                            text: "Tinggalkan pesan...",
                            size: Dimentions.font13,
                            color:  const Color(0xFFccc7c5),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: Dimentions.width20),
                    child: setForMainMsg.chatId.isNotEmpty ?  StreamBuilder<QuerySnapshot>(
                      stream: getService.streamGetCollecInColect(collection1: setForMainMsg.chatGroup, collection2: Collections.message, docId: setForMainMsg.chatId),
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
                    ) : Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimentions.height6, vertical: Dimentions.height2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(Dimentions.radius6),
                      ),
                      child: Text(
                        "New",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimentions.font12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(searchFound == false && userIdController.text.isNotEmpty && searchLoading == false)
            Container(
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
                    child: Avatar.medium(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
                          child: BigText(text: '"${userIdController.text}"'),
                        ),
                        SizedBox(
                          height: Dimentions.height15,
                          child: SmallText(
                              text: 'UserId "${userIdController.text}" tidak ditemukan...',
                              size: Dimentions.font13,
                              color:  const Color(0xFFccc7c5),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: Dimentions.width20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimentions.height6, vertical: Dimentions.height2),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(Dimentions.radius6),
                      ),
                      child: Text(
                        "!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Dimentions.font12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
