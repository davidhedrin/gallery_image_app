import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/app_column.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/icon_and_text_widget.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

import '../generated/assets.dart';
import '../models/likes_model.dart';
import '../models/posting_image.dart';
import '../models/user_model.dart';
import '../providers/app_services.dart';
import '../widgets/loading_progres.dart';
import 'main_app_page.dart';

class AppPageBody extends StatefulWidget {
  final String groupImage;
  const AppPageBody({Key? key, required this.groupImage}) : super(key: key);

  @override
  State<AppPageBody> createState() => _AppPageBodyState();
}

class _AppPageBodyState extends State<AppPageBody> {
  final AppServices getService = AppServices();
  PageController pageController = PageController();

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
    return Column(
      children: [
        // Section Banner/Slider Carousel
        SizedBox(height: Dimentions.height2,),
        Container(
          // color: Colors.redAccent,
          height: Dimentions.pageView,
          child: StreamBuilder<QuerySnapshot>(
            stream: getService.streamObjGetCollection(collection: widget.groupImage.toLowerCase()).take(6),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return noImageBanner();
              }
              if (!snapshot.hasData) {
                return noImageBanner();
              }else{
                var imageGroup = snapshot.data!.docs;
                List<PostingImageModel> getListImage = imageGroup.map((e){
                  Map<String, dynamic> getImage = e.data() as Map<String, dynamic>;
                  PostingImageModel images = PostingImageModel.fromMap(getImage);
                  return images;
                }).toList();

                if(getListImage.isNotEmpty){
                  return PageView.builder(
                      controller: pageController,
                      itemCount: getListImage.length,
                      itemBuilder: (context, index){
                        PostingImageModel docImage = getListImage[index];
                        return _buildPageItem(docImage, index);
                      }
                  );
                }else{
                  return noImageBanner();
                }
              }
            },
          ),
        ),

        SizedBox(height: Dimentions.width8,),

        StreamBuilder<QuerySnapshot>(
          stream: getService.streamObjGetCollection(collection: widget.groupImage.toLowerCase()).take(6),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("");
            }
            if (!snapshot.hasData) {
              return const Text("");
            }else{
              var imageGroup = snapshot.data!.docs;

              return SmoothPageIndicator(
                controller: pageController,
                count: imageGroup.length,
                effect: WormEffect(
                  activeDotColor: AppColors.mainColor,
                  dotHeight: Dimentions.height10,
                  dotWidth: Dimentions.width10
                ),
              );
            }
          },
        ),

        SizedBox(height: Dimentions.width8,),

        // Text Populer Category
        Container(
          margin: EdgeInsets.only(left: Dimentions.width30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BigText(text: "Semua"),
              SizedBox(width: Dimentions.width10,),
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                child: BigText(text: ".", color: Colors.black26,),
              ),
              SizedBox(width: Dimentions.width10,),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: SmallText(text: "Food pairing",),
              ),
            ],
          ),
        ),

        // List Food Category
        StreamBuilder<QuerySnapshot>(
          stream: getService.streamObjGetCollection(collection: widget.groupImage.toLowerCase()),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return noListImage();
            }
            if (!snapshot.hasData) {
              return noListImage();
            }else{
              var imageGroup = snapshot.data!.docs;
              List<PostingImageModel> getListImage = imageGroup.map((e){
                Map<String, dynamic> getImage = e.data() as Map<String, dynamic>;
                PostingImageModel images = PostingImageModel.fromMap(getImage);
                return images;
              }).toList();

              if(getListImage.isNotEmpty){
                return ListView.builder(
                  padding: EdgeInsets.only(top: Dimentions.height15),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: getListImage.length,
                  itemBuilder: (context, index){
                    PostingImageModel getData = getListImage[index];

                    var month = DateFormat('MMMM').format(getData.tanggal!);
                    var setDiffDate = DateTime.now().difference(getData.uploadDate!);
                    var diffMin = setDiffDate.inMinutes < 60 ? "${setDiffDate.inMinutes}min" : "";
                    var diffDayUpload = setDiffDate.inDays.toString() != "0" ? "${setDiffDate.inDays}h" : "";
                    var difference = "$diffDayUpload ${setDiffDate.inHours}j $diffMin";

                    List<String> SplitByName = getData.userByName.split(" ");
                    String firstChar2nd = SplitByName[1].substring(0, 1);

                    String fixByName = "${SplitByName[0]} $firstChar2nd";

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
                                      color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
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
                                            return SizedBox.shrink();
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
                                            stream: getService.streamGetCollecInColect(collection1: widget.groupImage.toLowerCase(), collection2: "likes", docId: getData.imageId),
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
                                                          by: getUserClick.nama_lengkap,
                                                        );

                                                        if(idLikeExists == true){
                                                          getService.deleteDataCollecInCollec(context: context, collection1: widget.groupImage.toLowerCase(), collection2: Collections.likes, guid1: getData.imageId, guid2: MainAppPage.setUserId);
                                                        }else{
                                                          getService.createDataToDbInCollec(data: likeData.toMapUpload(), context: context, collection1: widget.groupImage.toLowerCase(), collection2: Collections.likes, guid1: getData.imageId, guid2: MainAppPage.setUserId);
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
                return noListImage();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPageItem(PostingImageModel docImage, int index){
    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            Get.toNamed(RouteHalper.getDetailImage(docImage.imageId, docImage.imageGroup));
          },
          child: Stack(
            children: [
              Container(
                height: Dimentions.pageViewContainer,
                margin: EdgeInsets.only(left: Dimentions.width10, right: Dimentions.width10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimentions.radius30),
                  color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(docImage.imageUrl,),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: FutureBuilder(
                    future: precacheImage(NetworkImage(docImage.imageUrl,), context),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox.shrink();
                      } else {
                        return LoadingProgress();
                      }
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: Dimentions.pageTextContainer,
            margin: EdgeInsets.only(left: Dimentions.width30, right: Dimentions.width30, bottom: Dimentions.height2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimentions.radius20),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFe8e8e8),
                  blurRadius: 10.0,
                  offset: Offset(0, 5)
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-5, 0)
                ),
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(5, 0)
                ),
              ]
            ),
            child: Container(
              padding: EdgeInsets.only(top: Dimentions.height15, left: Dimentions.width15, right: Dimentions.width15),
                child: AppColumn(groupName: widget.groupImage,dataImage: docImage,),
            ),
          ),
        ),
      ],
    );
  }

  Widget noImageBanner(){
    return Stack(
      children: [
        GestureDetector(
          onTap: (){
          },
          child: Container(
            height: Dimentions.pageViewContainer,
            margin: EdgeInsets.only(left: Dimentions.width10, right: Dimentions.width10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimentions.radius30),
              color: const Color(0xFF69c5df),
              image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(Assets.imageBackgroundProfil)
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: Dimentions.pageTextContainer,
            margin: EdgeInsets.only(left: Dimentions.width30, right: Dimentions.width30, bottom: Dimentions.height2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimentions.radius20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xFFe8e8e8),
                      blurRadius: 10.0,
                      offset: Offset(0, 5)
                  ),
                  BoxShadow(
                      color: Colors.white,
                      offset: Offset(-5, 0)
                  ),
                  BoxShadow(
                      color: Colors.white,
                      offset: Offset(5, 0)
                  ),
                ]
            ),
            child: Container(
              padding: EdgeInsets.only(top: Dimentions.height15, left: Dimentions.width15, right: Dimentions.width15),
              child: const AppColumn(),
            ),
          ),
        ),
      ],
    );
  }
  Widget noListImage(){
    return Padding(
      padding: EdgeInsets.only(top: Dimentions.height15),
      child: Container(
        margin: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height15),
        child: Row(
          children: [
            // Image Section
            Container(
              width: Dimentions.listViewImgSize,
              height: Dimentions.listViewImgSize,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimentions.radius30),
                  color: Colors.white38,
                  image: DecorationImage(
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
      ),
    );
  }
}
