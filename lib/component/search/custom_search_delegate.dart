// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../../halper/route_halper.dart';
import '../../models/likes_model.dart';
import '../../models/message/main_message.dart';
import '../../models/message/main_message_search.dart';
import '../../models/message/message_data.dart';
import '../../models/posting_image.dart';
import '../../models/user_group_master_model.dart';
import '../../models/user_model.dart';
import '../../pages/message/chat_page.dart';
import '../../utils/collections.dart';
import '../../utils/colors.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/loading_progres.dart';
import '../../widgets/message_widget.dart';
import '../../widgets/small_text.dart';
import '../main_app_page.dart';

final AppServices getService = AppServices();

class CustomSearchDelegate extends SearchDelegate{
  CustomSearchDelegate({required this.searchFor});

  String searchFor;

  @override
  List<Widget> buildActions(BuildContext context){
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context){
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(searchFor == Collections.collSearchForMsg){
      return SuggestionsResultMsg(query: query,);
    }
    else if(searchFor == Collections.collSearchForPost){
      return SuggestionsResultPost(query: query);
    }
    else{
      return const SuggestionsDefault();
    }
  }

  @override
  Widget buildSuggestions(BuildContext context){
    if(searchFor == Collections.collSearchForMsg){
      return SuggestionsResultMsg(query: query,);
    }
    else if(searchFor == Collections.collSearchForPost){
      return SuggestionsResultPost(query: query);
    }
    else{
      return const SuggestionsDefault();
    }
  }
}

class SuggestionsDefault extends StatelessWidget {
  const SuggestionsDefault({super.key,});

  @override
  Widget build(BuildContext context) {
    return Center(child: BigText(text: "Search Data", size: Dimentions.font15,),);
  }
}

class SuggestionsResultPost extends StatelessWidget {
  const SuggestionsResultPost({super.key, required this.query,});

  final String query;

  bool containsDocId(List<QueryDocumentSnapshot<Object?>> querySnapshot) {
    for (QueryDocumentSnapshot docSnapshot in querySnapshot) {
      if (docSnapshot.id == MainAppPage.setUserId) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String groupName = MainAppPage.groupNameGet.toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream: getService.streamObjGetCollection(collection: groupName),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if(query.isEmpty){
          return Center(
            child: Text("Temukan postingan...", style: TextStyle(fontSize: Dimentions.font17, fontStyle: FontStyle.italic, color: Colors.grey),),
          );
        }
        if (!snapshot.hasData) {
          return Center(
              child: DataNotFoundWidget(msgTop: 'Postingan "$query" tidak ditemukan!', msgButton: "Keyword yang anda masukkan tidak ditemukan",)
          );
        }else{
          var imageGroup = snapshot.data!.docs;
          List<PostingImageModel> getListImage = imageGroup.map((e){
            Map<String, dynamic> getImage = e.data() as Map<String, dynamic>;
            PostingImageModel images = PostingImageModel.fromMap(getImage);
            return images;
          }).toList();

          getListImage = getListImage.where((PostingImageModel data) =>
          data.title.toLowerCase().contains(query.toLowerCase()) ||
              data.title.toLowerCase().startsWith(query.toLowerCase()) ||
              data.title.toLowerCase().endsWith(query.toLowerCase())
          ).toList();

          if(getListImage.isNotEmpty){
            return ListView.builder(
                padding: EdgeInsets.only(top: Dimentions.height15),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: getListImage.length,
                itemBuilder: (context, index){
                  PostingImageModel getData = getListImage[index];

                  var month = DateFormat('MMMM').format(getData.tanggal!);
                  var setDiffDate = DateTime.now().difference(getData.uploadDate!);
                  var diffMin = setDiffDate.inMinutes < 60 ? "${setDiffDate.inMinutes}min" : "";
                  var diffDayUpload = setDiffDate.inDays.toString() != "0" ? "${setDiffDate.inDays}h" : "";
                  var difference = "$diffDayUpload ${setDiffDate.inHours}j $diffMin";

                  List<String> splitByName = getData.userByName.split(" ");
                  String firstChar2nd = splitByName[1].substring(0, 1);

                  String fixByName = "${splitByName[0]} $firstChar2nd";

                  return GestureDetector(
                    onTap: (){
                      Get.toNamed(RouteHalper.getDetailImage(getData.imageId, getData.imageGroup));
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height15),
                      child: Row(
                        children: [
                          // Image Section
                          Stack(
                            children: [
                              Container(
                                width: Dimentions.listViewImgSize,
                                height: Dimentions.listViewImgSize,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimentions.radius30),
                                    color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(getData.imageUrl,),
                                    )
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: FutureBuilder(
                                      future: precacheImage(NetworkImage(getListImage[index].imageUrl,), context),
                                      builder: (BuildContext context, AsyncSnapshot snapshot){
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          return const SizedBox.shrink();
                                        } else {
                                          return LoadingProgress(size: Dimentions.height25,);
                                        }
                                      }
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Text Container
                          Expanded(
                            child: Container(
                              height: Dimentions.listViewTextContSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(Dimentions.radius20),
                                    bottomRight: Radius.circular(Dimentions.radius20)
                                ),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(left: Dimentions.width10, right: Dimentions.width10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: BigText(text: getData.title)),
                                        StreamBuilder<QuerySnapshot>(
                                            stream: getService.streamGetCollecInColect(collection1: groupName, collection2: "likes", docId: getData.imageId),
                                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return BigText(text: "-", color: Colors.black45,);
                                              }
                                              if (!snapshot.hasData) {
                                                return BigText(text: "-", color: Colors.black45,);
                                              }else{
                                                var likeData = snapshot.data!.docs;
                                                bool idLikeExists = containsDocId(likeData);
                                                return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    BigText(text: likeData.length.toString(), color: Colors.black45,),
                                                    SizedBox(width: Dimentions.height2,),
                                                    InkWell(
                                                        onTap: () async {
                                                          UserModel getUserClick = await getService.getDocDataByDocId(context: context, collection: Collections.users, docId: MainAppPage.setUserId).then((value){
                                                            Map<String, dynamic> getMap = value!.data() as Map<String, dynamic>;
                                                            return UserModel.fromMap(getMap);
                                                          });

                                                          LikesModel likeData = LikesModel(
                                                            id: MainAppPage.setUserId,
                                                            by: getUserClick.namaLengkap,
                                                          );

                                                          if(idLikeExists == true){
                                                            getService.deleteDataCollecInCollec(context: context, collection1: groupName, collection2: Collections.likes, guid1: getData.imageId, guid2: MainAppPage.setUserId);
                                                          }else{
                                                            getService.createDataToDbInCollec(data: likeData.toMapUpload(), context: context, collection1: groupName, collection2: Collections.likes, guid1: getData.imageId, guid2: MainAppPage.setUserId);
                                                          }
                                                        },
                                                        child: Icon(Icons.thumb_up, color: idLikeExists == true ? Colors.blue : Colors.grey,)
                                                    ),
                                                  ],
                                                );
                                              }
                                            }
                                        )
                                      ],
                                    ),
                                    SizedBox(height: Dimentions.height10,),
                                    Row(
                                      children: [
                                        SmallText(text: "Tanggal Foto: "),
                                        SmallText(text: "${getData.tanggal!.day} $month ${getData.tanggal!.year}"),
                                      ],
                                    ),
                                    SizedBox(height: Dimentions.height10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconAndTextWidget(icon: Icons.account_circle, text: fixByName, iconColor: AppColors.iconColor1),
                                        IconAndTextWidget(
                                            icon: getData.pemirsa == "1" ? Icons.people_outline : Icons.lock,
                                            text: getData.pemirsa == "1" ? "Public" : "Private",
                                            iconColor: AppColors.mainColor
                                        ),
                                        IconAndTextWidget(icon: Icons.access_time_rounded, text: difference, iconColor: AppColors.iconColor2),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          }else{
            return Center(
              child: DataNotFoundWidget(msgTop: 'Postingan "$query" tidak ditemukan!', msgButton: "Keyword yang anda masukkan tidak ditemukan",)
            );
          }
        }
      },
    );
  }
}

class SuggestionsResultMsg extends StatelessWidget {
  const SuggestionsResultMsg({super.key, required this.query,});

  final String query;

  Future<List<MainMessageSearch>> getCurrentChatGroup() async {
    List<MainMessageSearch> allChatsResult = [];

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
      var getAllChatsUser = await getService.fbStore.collection(collectionMsg).where(Collections.collColumnuserId, arrayContains: MainAppPage.setUserId).get();
      var docsAllChats = getAllChatsUser.docs;
      for(var x in docsAllChats){
        Map<String, dynamic> chatMap = x.data();
        MainMessage setMM = MainMessage.fromMap(chatMap);
        String idUserLoad = MainAppPage.setUserId == setMM.userId![0] ? setMM.userId![1] : setMM.userId![0];

        var getUserMap = await getService.getDocDataByDocIdNoCon(collection: Collections.users, docId: idUserLoad);
        UserModel getUser = UserModel.fromMap(getUserMap!.data() as Map<String, dynamic>);

        MainMessageSearch setMsgSearch = MainMessageSearch(
            chatId: setMM.chatId,
            userId: setMM.userId,
            chatGroup: setMM.chatGroup,
            namaLengkap: getUser.namaLengkap
        );
        allChatsResult.add(setMsgSearch);
      }
    }

    return allChatsResult;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MainMessageSearch>>(
        future: getCurrentChatGroup(),
        builder: (BuildContext context, AsyncSnapshot<List<MainMessageSearch>> snapshotMsg) {
          if (snapshotMsg.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshotMsg.hasData) {
            return const Center(
                child: Text("Data tidak ditemukan!",)
            );
          }else{
            List<MainMessageSearch> getDocsMsg = snapshotMsg.data!;
            getDocsMsg = getDocsMsg.where((MainMessageSearch data) =>
              data.namaLengkap.toLowerCase().contains(query.toLowerCase()) ||
              data.namaLengkap.toLowerCase().startsWith(query.toLowerCase()) ||
              data.namaLengkap.toLowerCase().endsWith(query.toLowerCase())
            ).toList();

            if(getDocsMsg.isEmpty){
              return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(query.isEmpty ? "Belum ada history" : 'Chat dengen "$query" tidak ditemukan di',),
                      BigText(text: "We Gallery Chat 👋"),
                    ]
                ),
              );
            }else{
              return ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: getDocsMsg.length,
                itemBuilder: (context, index){
                  MainMessageSearch getCurrentMsg =  getDocsMsg[index];
                  return _MessageTitle(getMainMsg: getCurrentMsg,);
                },
              );
            }
          }
        }
    );
  }
}

class _MessageTitle extends StatefulWidget {
  final MainMessageSearch getMainMsg;
  const _MessageTitle({Key? key, required this.getMainMsg}) : super(key: key);

  @override
  State<_MessageTitle> createState() => _MessageTitleState();
}

class _MessageTitleState extends State<_MessageTitle> {
  @override
  Widget build(BuildContext context) {
    MainMessageSearch setMM = widget.getMainMsg;
    String idUserLoad = MainAppPage.setUserId == setMM.userId![0] ? setMM.userId![1] : setMM.userId![0];
    String collectionMsg = setMM.chatGroup.toLowerCase();

    return InkWell(
      onTap: (){
        Navigator.of(context).pop();
        Get.to(() => ChatMessagePage(userId: idUserLoad, chatId: setMM.chatId, collectionMsg: setMM.chatGroup,));
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
                            return BigText(text: getMainMsg.namaLengkap);
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