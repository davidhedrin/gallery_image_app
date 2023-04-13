// ignore_for_file: use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/edit_posting_page.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/posting_image.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:delivery_food_app/widgets/app_icon.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../generated/assets.dart';
import '../../models/likes_model.dart';
import '../../providers/app_services.dart';
import '../../providers/firebase_dynamic_link.dart';
import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/loading_progres.dart';
import '../../widgets/small_text.dart';
import '../full_screen_image_page.dart';
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

  late String firstHalf;
  late String secoundHalf;

  bool hiddenText = true;
  double textHeight = Dimentions.screenHeight/5.63;

  bool _isLoading = false;

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

            if(getData.keterangan!.length > textHeight){
              firstHalf = getData.keterangan!.substring(0, textHeight.toInt());
              secoundHalf = getData.keterangan!.substring(textHeight.toInt()+1, getData.keterangan!.length);
            }else{
              firstHalf = getData.keterangan!;
              secoundHalf = "";
            }

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
                    imageBuilder: (context, imageProvider) => GestureDetector(
                      onTap: () {
                        RouteHalper().redirectMaterialPage(context, FullScreenImagePage(imgUrl: getData.imageUrl,));
                      },
                      child: Container(
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
                        child: const AppIcon(icon: Icons.arrow_back_ios_new),
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
                            child: getData.keterangan!.isNotEmpty? Container(
                              child: secoundHalf.isEmpty ? SmallText(text: firstHalf, size: Dimentions.font16, color: AppColors.paraColor,) : Column(
                                children: [
                                  SmallText(text: hiddenText ? ("$firstHalf...") : (firstHalf + secoundHalf), size: Dimentions.font16, color: AppColors.paraColor, height: 1.8,),
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        hiddenText = !hiddenText;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        SmallText(text: "Show more", color: AppColors.mainColor,),
                                        Icon(hiddenText ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: AppColors.mainColor,)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ) : Text("Keterangan gambar tidak dicantumkan",
                              style: TextStyle(fontSize: Dimentions.font16, fontStyle: FontStyle.italic, color: AppColors.paraColor,),
                            ),
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
      bottomNavigationBar: _isLoading == false ? Container(
        height: Dimentions.heightSize85,
        padding: EdgeInsets.only(top: Dimentions.height10, bottom: Dimentions.height10, left: Dimentions.width20, right: Dimentions.width20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimentions.radius15*2),
            topRight: Radius.circular(Dimentions.radius15*2)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                    stream: getService.streamBuilderGetDoc(collection: widget.groupName!, docId: widget.imageId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      if(!snapshot.hasData){
                        return const SizedBox();
                      }else{
                        var data = snapshot.data;
                        Map<String, dynamic> mapData = data!.data() as Map<String, dynamic>;
                        PostingImageModel getData = PostingImageModel.fromMap(mapData);

                        if(getData.userById == MainAppPage.setUserId){
                          return Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: Dimentions.width10),
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimentions.radius20),
                                      color: Colors.white,
                                    ),
                                    child: Icon(Icons.edit, color: Colors.orangeAccent.shade200,),
                                  ),
                                  onTap: () {
                                    Get.to(() => EditPostingPage(uid: getData.userById, groupId: MainAppPage.groupCodeId!, postData: getData,));
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: Dimentions.width10),
                                child: GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimentions.radius20),
                                      color: Colors.white,
                                    ),
                                    child: Icon(Icons.delete_forever, color: Colors.redAccent.shade200,),
                                  ),
                                  onTap: () async {
                                    bool check = false;
                                    await onBackButtonPressYesNo(context: context, text: "Hapus Posting!", desc: "Yakin ingin menghapus postingan ini?").then((value){
                                      check = value;
                                    });

                                    if(check == true){
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      Navigator.pop(context);
                                      getService.loading(context);

                                      String namaPostingan = getData.title;
                                      getService.deleteCollecInCollec(collection1: getData.imageGroup, collection2: Collections.likes, guid1: getData.imageId);

                                      getService.deleteDocById(collection: getData.imageGroup, docId: getData.imageId);

                                      Navigator.of(context).pop();
                                      showAwsBar(context: context, contentType: ContentType.success, msg: 'Berhasil menghapus Postingan "$namaPostingan"', title: "Posting");
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }else{
                          return const SizedBox();
                        }
                      }
                    }
                ),
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
                    child: Icon(Icons.cloud_download, color: AppColors.mainColor,),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: (){
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimentions.radius15*2), topRight: Radius.circular(Dimentions.radius15*2)),
                  ),
                  builder: (BuildContext contextX){
                    return SizedBox(
                      height: Dimentions.heightSize90,
                      child: Padding(
                        padding: EdgeInsets.only(left: Dimentions.width12, right: Dimentions.width10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Share for chat we gallery
                            // GestureDetector(
                            //   onTap: (){},
                            //   child: Container(
                            //     padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(Dimentions.radius30),
                            //       color: Colors.white,
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         BigText(text: "Chat", color: Colors.black45,),
                            //         SizedBox(width: Dimentions.width5,),
                            //         Image.asset(Assets.imageAppIcon, width: Dimentions.iconSize22,),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: () async {
                                String imageId = widget.imageId;
                                String groupName = widget.groupName!;
                                String generateLink = await DynamicLinkService.createDynamicLink(true, RouteHalper.getDetailImage(imageId, groupName));

                                Clipboard.setData(ClipboardData(text: generateLink));

                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(contextX).showSnackBar(
                                  const SnackBar(
                                    content: Text('Alamat posting telah berhasil disalin'),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: Dimentions.font11, bottom: Dimentions.font11, left: Dimentions.font11, right: Dimentions.font11),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimentions.radius30),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    BigText(text: "Copy", color: Colors.black45,),
                                    SizedBox(width: Dimentions.width5,),
                                    const Icon(Icons.copy, color: Colors.black45,),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: Dimentions.heightSize130,),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                String imageId = widget.imageId;
                                String groupName = widget.groupName!;
                                String generateLink = await DynamicLinkService.createDynamicLink(true, RouteHalper.getDetailImage(imageId, groupName));

                                await Share.share(generateLink);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.all(Dimentions.height12),
                                backgroundColor: Colors.blue
                              ),
                              child: const Icon(Icons.share, color: Colors.white,)
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              },
              child: Container(
                padding: EdgeInsets.only(top: Dimentions.height12, bottom: Dimentions.height12, left: Dimentions.height12, right: Dimentions.height12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimentions.radius20),
                  color: AppColors.mainColor,
                ),
                child: Row(
                  children: [
                    BigText(text: "Share", color: Colors.white,),
                    Image.asset(Assets.imageForwardIcon, width: Dimentions.font22, color: Colors.white,),
                  ],
                ),
              ),
            )
          ],
        ),
      ) : const LinearProgressIndicator(),
    );
  }
}
