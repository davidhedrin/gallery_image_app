import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/data_not_found.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/full_screen_image_page.dart';
import '../../component/main_app_page.dart';
import '../../models/posting_image.dart';
import '../../providers/app_services.dart';
import '../../utils/utils.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/loading_progres.dart';

class AccountPageMenu extends StatefulWidget {
  const AccountPageMenu({Key? key}) : super(key: key);

  @override
  State<AccountPageMenu> createState() => _AccountPageMenuState();
}

class _AccountPageMenuState extends State<AccountPageMenu> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();
  final String _userId = MainAppPage.setUserId;

  @override
  Widget build(BuildContext context) {
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

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
      child: Scaffold(
        body: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
          stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: _userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if(!snapshot.hasData){
              return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
            }else{
              var data = snapshot.data;
              Map<String, dynamic> getMapUser = data!.data() as Map<String, dynamic>;
              UserModel getUser = UserModel.fromMap(getMapUser);

              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: profileSize + Dimentions.height15),
                        color: Colors.grey,
                        child: CachedNetworkImage(
                          imageUrl: getUser.imgCoverUrl,
                          placeholder: (context, url) => const LoadingProgress(),
                          errorWidget: (context, url, error){
                            return Image.asset(
                              Assets.imageBackgroundProfil,
                              width: double.infinity,
                              height: coverHeight,
                              fit: BoxFit.cover,
                            );
                          },
                          imageBuilder: (context, imageProvider) => GestureDetector(
                            onTap: () {
                              RouteHalper().redirectMaterialPage(context, FullScreenImagePage(imgUrl: getUser.imgCoverUrl,));
                            },
                            child: Container(
                              width: double.infinity,
                              height: coverHeight,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Icons Widget
                      Positioned(
                        top: Dimentions.height45,
                        left: Dimentions.width20,
                        right: Dimentions.width20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Get.toNamed(RouteHalper.getEditAccountPage(uid: _userId));
                              },
                              child: const AppIcon(icon: Icons.edit),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        top: coverHeight - profileSize,
                        child: CircleAvatar(
                          radius: profileSize + 5,
                          backgroundColor: Colors.white,
                          child: data.data()!.containsKey("img_profil_url") ? getUser.imgProfilUrl.isNotEmpty ? GestureDetector(
                            onTap: () {
                              RouteHalper().redirectMaterialPage(context, FullScreenImagePage(imgUrl: getUser.imgProfilUrl,));
                            },
                            child: CircleAvatar(
                              radius: profileSize,
                              backgroundColor: Colors.grey.shade800,
                              backgroundImage: CachedNetworkImageProvider(getUser.imgProfilUrl),
                            ),
                          ) : CircleAvatar(
                            radius: profileSize,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: const AssetImage(Assets.imagePrifil),
                          ) : CircleAvatar(
                            radius: profileSize,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: const AssetImage(Assets.imagePrifil),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimentions.height10,),
                  Text(getUser.namaLengkap, style: TextStyle(fontSize: Dimentions.font22, fontWeight: FontWeight.bold)),
                  SmallText(text: getUser.phone, color: Colors.black87, size: Dimentions.font16,),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: Dimentions.width8, right: Dimentions.width8),
                      child: FutureBuilder<List<PostingImageModel>>(
                        future: getService.getAllDocImagePosting(context: context, phone: getUser.phone, userId: _userId),
                        builder: (BuildContext context, AsyncSnapshot<List<PostingImageModel>> snapshotImage) {
                          if (snapshotImage.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshotImage.hasError) {
                            return Center(child: DataNotFoundWidget(msgTop: 'Error: ${snapshotImage.error}'));
                          }
                          if (!snapshotImage.hasData) {
                            return const Center(child: DataNotFoundWidget(msgTop: 'Data tidak ditemukan!'));
                          } else {
                            List<PostingImageModel> documents = snapshotImage.data!;
                            if(documents.isEmpty){
                              return const Center(
                                child: DataNotFoundWidget(
                                  msgTop: 'Belum pernah upload nichh...',
                                  msgButton: 'Silahkan Upload gambar anda sekarang!',
                                )
                              );
                            }else{
                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: Dimentions.height6,
                                  mainAxisSpacing: Dimentions.height6,
                                ),
                                itemCount: documents.length, // number of columns in the grid
                                itemBuilder: (context, index){
                                  PostingImageModel image = documents[index];
                                  return GestureDetector(
                                    onTap: (){
                                      Get.toNamed(RouteHalper.getDetailImage(image.imageId, image.imageGroup));
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: image.imageUrl,
                                      placeholder: (context, url) => LoadingProgress(size: Dimentions.height25,),
                                      errorWidget: (context, url, error){
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                                            image: const DecorationImage(
                                              image: AssetImage(Assets.imageBackgroundProfil),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          }
        ),
      ),
    );
  }
}
