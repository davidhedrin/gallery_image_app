// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../halper/route_halper.dart';
import '../../models/likes_model.dart';
import '../../models/posting_image.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/colors.dart';
import '../../widgets/auth_widget/text_widget.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/loading_progres.dart';
import '../../widgets/small_text.dart';
import '../main_app_page.dart';

class HomeSearchComponent extends StatefulWidget {
  const HomeSearchComponent({Key? key}) : super(key: key);

  @override
  State<HomeSearchComponent> createState() => _HomeSearchComponentState();
}

class _HomeSearchComponentState extends State<HomeSearchComponent> {
  final AppServices getService = AppServices();
  final TextEditingController searchController = TextEditingController();
  late String searchKey = "";
  final FocusNode _searchFocusNode = FocusNode();

  final String groupName = MainAppPage.groupNameGet.toLowerCase();

  bool containsDocId(List<QueryDocumentSnapshot<Object?>> querySnapshot) {
    for (QueryDocumentSnapshot docSnapshot in querySnapshot) {
      if (docSnapshot.id == MainAppPage.setUserId) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimentions.height70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: MyTextFieldReg(
          controller: searchController,
          hintText: "Temukan Postingan...",
          prefixIcon: const Icon(Icons.search),
          focusNode: _searchFocusNode,
          onChanged: (value){
            setState(() {
              searchKey = value;
            });
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: searchKey.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: getService.streamObjGetCollection(collection: groupName),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if(searchKey.isEmpty){
                return Center(child: Text("Temukan postingan...", style: TextStyle(fontSize: Dimentions.font17, fontStyle: FontStyle.italic, color: Colors.grey),),);
              }
              if (!snapshot.hasData) {
                return Center(child: DataNotFoundWidget(msgTop: 'Postingan "$searchKey" tidak ditemukan!', msgButton: "Keyword yang anda masukkan tidak ditemukan",));
              }else{
                var imageGroup = snapshot.data!.docs;
                List<PostingImageModel> getListImage = imageGroup.map((e){
                  Map<String, dynamic> getImage = e.data() as Map<String, dynamic>;
                  PostingImageModel images = PostingImageModel.fromMap(getImage);
                  return images;
                }).toList();

                getListImage = getListImage.where((PostingImageModel data) =>
                  data.title.toLowerCase().contains(searchKey.toLowerCase()) ||
                  data.title.toLowerCase().startsWith(searchKey.toLowerCase()) ||
                  data.title.toLowerCase().endsWith(searchKey.toLowerCase())
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
                  return DataNotFoundWidget(msgTop: 'Postingan "$searchKey" tidak ditemukan!', msgButton: "Keyword yang anda masukkan tidak ditemukan",);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
