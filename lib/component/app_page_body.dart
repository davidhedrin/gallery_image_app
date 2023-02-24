import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/app_column.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/icon_and_text_widget.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../generated/assets.dart';
import '../models/posting_image.dart';
import '../providers/app_services.dart';

class AppPageBody extends StatefulWidget {
  final String groupImage;
  const AppPageBody({Key? key, required this.groupImage}) : super(key: key);

  @override
  State<AppPageBody> createState() => _AppPageBodyState();
}

class _AppPageBodyState extends State<AppPageBody> {
  final AppServices getService = AppServices();
  PageController pageController = PageController();
  int _currPageValue = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Banner/Slider Carousel
        Container(
          // color: Colors.redAccent,
          height: Dimentions.pageView,
          child: StreamBuilder<QuerySnapshot>(
            stream: getService.streamObjGetCollection(collection: widget.groupImage.toLowerCase()),
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
          stream: getService.streamObjGetCollection(collection: widget.groupImage.toLowerCase()),
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
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index){
              return GestureDetector(
                onTap: (){
                  Get.toNamed(RouteHalper.getPopularFood(index));
                },
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
                              image: AssetImage(Assets.imageMakanan),
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
                                BigText(text: "Nutritious fruit meal in China"),
                                SizedBox(height: Dimentions.height10,),
                                SmallText(text: "With chinese characteristics"),
                                SizedBox(height: Dimentions.height10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconAndTextWidget(icon: Icons.circle_sharp, text: "Normal", iconColor: AppColors.iconColor1),
                                    IconAndTextWidget(icon: Icons.location_on, text: "1.7km", iconColor: AppColors.mainColor),
                                    IconAndTextWidget(icon: Icons.access_time_rounded, text: "32min", iconColor: AppColors.iconColor2),
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
        ),
      ],
    );
  }

  Widget _buildPageItem(PostingImageModel docImage, int index){
    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            Get.toNamed(RouteHalper.getPopularFood(index));
          },
          child: Container(
            height: Dimentions.pageViewContainer,
            margin: EdgeInsets.only(left: Dimentions.width10, right: Dimentions.width10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimentions.radius30),
              color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    docImage.imageUrl,
                  ),
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
}
