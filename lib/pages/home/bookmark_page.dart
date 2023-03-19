// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/models/likes_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../generated/assets.dart';
import '../../halper/route_halper.dart';
import '../../models/posting_image.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/colors.dart';
import '../../utils/dimentions.dart';
import '../../widgets/auth_widget/text_widget.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/loading_progres.dart';
import '../../widgets/small_text.dart';
import '../../component/main_app_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final AppServices getService = AppServices();
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Your Bookmark Image', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, bottom: Dimentions.height10),
            child: MyTextFieldReg(
              controller: searchController,
              hintText: "Temukan...",
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getService.streamGetCollecInColect(collection1: Collections.users, collection2: Collections.bookmark, docId: MainAppPage.setUserId),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return noListImage();
              }
              if (!snapshot.hasData) {
                return noListImage();
              }else{
                var imageGroup = snapshot.data!.docs;
                List<LikesModel> getListImage = imageGroup.map((e){
                  Map<String, dynamic> getImage = e.data() as Map<String, dynamic>;
                  LikesModel images = LikesModel.fromMapBook(getImage);
                  return images;
                }).where((list) => list.by == MainAppPage.groupNameGet).toList();

                if(getListImage.isNotEmpty){
                  return ListView.builder(
                      padding: EdgeInsets.only(top: Dimentions.height15),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: getListImage.length,
                      itemBuilder: (context, index){
                        LikesModel getDataBook = getListImage[index];
                        return GestureDetector(
                          onTap: (){
                            Get.toNamed(RouteHalper.getDetailImage(getDataBook.id, getDataBook.by.toLowerCase()));
                          },
                          child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                            stream: getService.streamBuilderGetDoc(collection: getDataBook.by.toLowerCase(), docId: getDataBook.id),
                            builder: (context, snapshotImg) {
                              if (snapshotImg.connectionState == ConnectionState.waiting) {
                                return const Text("...",);
                              }
                              if(!snapshotImg.hasData){
                                return const Text("Data tidak ditemukan!",);
                              }else{
                                var data = snapshotImg.data;
                                Map<String, dynamic> mapData = data!.data() as Map<String, dynamic>;
                                PostingImageModel getData = PostingImageModel.fromMap(mapData);

                                var month = DateFormat('MMMM').format(getData.tanggal!);
                                var setDiffDate = DateTime.now().difference(getData.uploadDate!);
                                var diffMin = setDiffDate.inMinutes < 60 ? "${setDiffDate.inMinutes}min" : "";
                                var diffDayUpload = setDiffDate.inDays.toString() != "0" ? "${setDiffDate.inDays}h" : "";
                                var difference = "$diffDayUpload ${setDiffDate.inHours}j $diffMin";

                                List<String> splitByName = getData.userByName.split(" ");
                                String firstChar2nd = splitByName[1].substring(0, 1);

                                String fixByName = "${splitByName[0]} $firstChar2nd";
                                return Container(
                                  margin: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height15),
                                  child: Row(
                                    children: [
                                      // Image Section
                                      Stack(
                                        children: [
                                          Container(
                                            width: Dimentions.heightSize100,
                                            height: Dimentions.heightSize100,
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
                                                  future: precacheImage(NetworkImage(getData.imageUrl,), context),
                                                  builder: (BuildContext context, AsyncSnapshot snapshot){
                                                    if (snapshot.connectionState == ConnectionState.done) {
                                                      return const SizedBox.shrink();
                                                    } else {
                                                      return LoadingProgress(size: Dimentions.height20,);
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
                                                Flexible(child: BigText(text: getData.title)),
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
                                );
                              }
                            }
                          ),
                        );
                      }
                  );
                }else{
                  return noListImage();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget noListImage(){
    return Container(
      margin: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height15),
      child: Row(
        children: [
          // Image Section
          Container(
            width: Dimentions.heightSize100,
            height: Dimentions.heightSize100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimentions.radius30),
                color: Colors.white38,
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(Assets.imageBackgroundProfil),
                )
            ),
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
                    BigText(text: "No Image"),
                    SizedBox(height: Dimentions.height10,),
                    SmallText(text: "No image found!"),
                    SizedBox(height: Dimentions.height10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconAndTextWidget(icon: Icons.account_circle, text: "-", iconColor: AppColors.iconColor1),
                        IconAndTextWidget(icon: Icons.remove_red_eye, text: "-", iconColor: AppColors.mainColor),
                        IconAndTextWidget(icon: Icons.access_time_rounded, text: "-", iconColor: AppColors.iconColor2),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
