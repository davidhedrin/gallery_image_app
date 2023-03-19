// ignore_for_file: use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/models/posting_image.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:delivery_food_app/widgets/app_icon.dart';
import 'package:delivery_food_app/widgets/expandable_text_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';
import '../../models/likes_model.dart';
import '../../providers/app_services.dart';
import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/loading_progres.dart';
import '../main_app_page.dart';

class DetailImagePage extends StatefulWidget {
  final String imageId;
  final String? groupName;
  const DetailImagePage({Key? key, required this.imageId, this.groupName}) : super(key: key);

  @override
  State<DetailImagePage> createState() => _DetailImagePageState();
}

class _DetailImagePageState extends State<DetailImagePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final AppServices getService = AppServices();

  bool containsDocId(List<QueryDocumentSnapshot<Object?>> querySnapshot) {
    for (QueryDocumentSnapshot docSnapshot in querySnapshot) {
      if (docSnapshot.id == widget.imageId) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
        stream: getService.streamBuilderGetDoc(collection: widget.groupName!, docId: widget.imageId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(!snapshot.hasData){
            return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
          }else{
            var data = snapshot.data;
            Map<String, dynamic> mapData = data!.data() as Map<String, dynamic>;
            PostingImageModel getData = PostingImageModel.fromMap(mapData);
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  child: CachedNetworkImage(
                    imageUrl: getData.imageUrl,
                    placeholder: (context, url) => const LoadingProgress(),
                    errorWidget: (context, url, error){
                      return Container(
                        width: double.maxFinite,
                        height: Dimentions.popularFoodImgSize,
                        decoration: const BoxDecoration(
                          color: Color(0xFF69c5df),
                          image: DecorationImage(
                            image: AssetImage(Assets.imageBackgroundProfil),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) => Container(
                      width: double.maxFinite,
                      height: Dimentions.popularFoodImgSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF69c5df),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: Dimentions.height45,
                  left: Dimentions.width20,
                  right: Dimentions.width20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: AppIcon(icon: Icons.arrow_back_ios_new),
                      ),
                      StreamBuilder<QuerySnapshot>(
                          stream: getService.streamGetCollecInColect(collection1: Collections.users, collection2: Collections.bookmark, docId: MainAppPage.setUserId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return BigText(text: "-", color: Colors.black45,);
                            }
                            if (!snapshot.hasData) {
                              return BigText(text: "-", color: Colors.black45,);
                            }else{
                              var likeData = snapshot.data!.docs;
                              bool idLikeExists = containsDocId(likeData);
                              return GestureDetector(
                                onTap: () async {
                                  LikesModel likeData = LikesModel(
                                    id: getData.imageId,
                                    by: widget.groupName!.toLowerCase(),
                                  );

                                  if(idLikeExists == true){
                                    getService.deleteDataCollecInCollec(context: context, collection1: Collections.users, collection2: Collections.bookmark, guid1: MainAppPage.setUserId, guid2: getData.imageId);
                                  }else{
                                    getService.createDataToDbInCollec(data: likeData.toMapBookmark(), context: context, collection1: Collections.users, collection2: Collections.bookmark, guid1: MainAppPage.setUserId, guid2: getData.imageId);
                                  }
                                },
                                child: Container(
                                    width: Dimentions.height40,
                                    height: Dimentions.height40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimentions.radius50),
                                      color: idLikeExists == true ? AppColors.mainColor : Colors.grey,
                                    ),
                                    child: idLikeExists == true ? Icon(Icons.bookmark_added, color: Colors.white, size: Dimentions.iconSize24,) : Icon(Icons.bookmark_add, color: Colors.white, size: Dimentions.iconSize24,)
                                ),
                              );
                            }
                          }
                      ),
                    ],
                  ),
                ),

                // Description Introduction Product
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: Dimentions.popularFoodImgSize-Dimentions.height70,
                  child: Container(
                    padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, top: Dimentions.height20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(Dimentions.radius20),
                          topLeft: Radius.circular(Dimentions.radius20)
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppColumn(dataImage: getData, groupName: widget.groupName),
                        SizedBox(height: Dimentions.height20,),
                        BigText(text: "Ket Gambar:"),
                        SizedBox(height: Dimentions.height20,),
                        Expanded(
                          child: SingleChildScrollView(
                              child: ExpandableTextWidget(text: getData.keterangan!)
                          ),
                        )
                      ],
                    ),
                  ),
                )

                // Expandable Text Widget

              ],
            );
          }
        }
      ),
      bottomNavigationBar: Container(
        height: Dimentions.heightSize85,
        padding: EdgeInsets.only(top: Dimentions.height10, bottom: Dimentions.height10, left: Dimentions.width20, right: Dimentions.width20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimentions.radius20*2),
            topRight: Radius.circular(Dimentions.radius20*2)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                getService.loading(context);

                Reference refStorage = storage.ref().child("${widget.groupName!.toLowerCase()}/${widget.imageId}");
                bool finishDown = await getService.downloadFile(refStorage, "${widget.groupName!}-${DateTime.now().millisecond}", context);

                Navigator.of(context).pop();
                if(finishDown == true){
                  showAwsBar(context: context, contentType: ContentType.success, msg: "Gambar berhasil diUnduh!", title: "Download");
                }
              },
              child: Container(
                padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimentions.radius20),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    BigText(text: "Unduh", color: Colors.black87,),
                    SizedBox(width: Dimentions.width5,),
                    Icon(Icons.cloud_download, color: AppColors.mainColor,),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimentions.radius20),
                color: AppColors.mainColor,
              ),
              child: Row(
                children: [
                  BigText(text: "Share", color: Colors.white,),
                  const Icon(Icons.share, color: Colors.white,)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
