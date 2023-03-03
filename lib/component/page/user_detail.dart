import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/function_halpers.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';
import '../../halper/route_halper.dart';
import '../../models/posting_image.dart';
import '../../models/user_group.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/loading_progres.dart';

class UserDetailPage extends StatefulWidget {
  final UserModel userModel;
  final int userSee;
  final UserGroupModel? groupModel;
  const UserDetailPage({Key? key, required this.userModel, required this.userSee, this.groupModel}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final AppServices getService = AppServices();
  final FunHelp getHelp = FunHelp();
  File? imageProfile, imageCover;

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.userModel;
    UserGroupModel setGroup = UserGroupModel();
    setGroup = widget.groupModel!;

    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

    int setType = getHelp.checkStatusUser(user.user_type);

    print(widget.userSee);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BigText(text: user.nama_lengkap),
              SmallText(text: user.phone),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            widget.userSee < 3 ? IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.redAccent, size: Dimentions.iconSize32,),
              onPressed: () {
              },
            ) : const Text(""),
          ],
        ),
        body: Column(
            children: <Widget> [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: profileSize + Dimentions.height15),
                        color: Colors.grey,
                        child: imageCover != null ? Image.file(
                          imageCover!,
                          width: double.infinity,
                          height: coverHeight,
                          fit: BoxFit.cover,
                        ) : user.img_cover_url.isNotEmpty ? Image.network(
                          user.img_cover_url,
                          width: double.infinity,
                          height: coverHeight,
                          fit: BoxFit.cover,
                        ) : Image.asset(
                          Assets.imageBackgroundProfil,
                          width: double.infinity,
                          height: coverHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      user.img_cover_url.isNotEmpty ? Positioned(
                        left: Dimentions.heightSize130,
                        top: Dimentions.height40,
                        child: Center(
                          child: FutureBuilder(
                              future: precacheImage(NetworkImage(user.img_cover_url,), context),
                              builder: (BuildContext context, AsyncSnapshot snapshot){
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return const SizedBox.shrink();
                                } else {
                                  return const LoadingProgress();
                                }
                              }
                          ),
                        ),
                      ) : const Text(""),
                    ],
                  ),

                  // Icons Widget
                  widget.userSee == 1 ? Positioned(
                    top: Dimentions.height20,
                    left: Dimentions.width20,
                    right: Dimentions.width20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            var image = await pickImageNoCrop(context);
                            setState(() {
                              imageCover = image;
                            });
                          },
                          child: AppIcon(icon: Icons.image),
                        ),
                      ],
                    ),
                  ) : const Text(""),

                  Positioned(
                    top: coverHeight - profileSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: profileSize + 5,
                          backgroundColor: Colors.white,
                          child: imageProfile != null ? CircleAvatar(
                            radius: profileSize,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: FileImage(imageProfile!),
                          ) : user.img_profil_url.isNotEmpty ? CircleAvatar(
                            radius: profileSize,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: NetworkImage(user.img_profil_url),
                          ) : CircleAvatar(
                            radius: profileSize,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: AssetImage(Assets.imagePrifil),
                          ),
                        ),
                        Positioned(
                          top: profileSize + Dimentions.height25,
                          left: profileSize + Dimentions.height25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              widget.userSee == 1 ?GestureDetector(
                                onTap: () async {
                                  var image = await pickImageCrop(context);
                                  setState(() {
                                    imageProfile = image;
                                  });
                                },
                                child: AppIcon(icon: Icons.edit),
                              ) : const Text(""),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimentions.width5, vertical: Dimentions.height2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(Dimentions.radius12),
                ),
                child: Text(
                  setType == 1 ? "M.Admin" : setType == 2 ? "Admin" : "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: Dimentions.width8, right: Dimentions.width8),
                  child: widget.userSee == 1 ? FutureBuilder<List<PostingImageModel>>(
                    future: getAllDocuments(uid: user.id, phone: user.phone),
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
                                msgTop: 'Belum pernah upload gambar...',
                                msgButton: 'Tidak ada gambar yang diposting!',
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
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Get.toNamed(RouteHalper.getDetailImage(image.imageId, image.imageGroup));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
                                        image: DecorationImage(
                                          image: NetworkImage(image.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Center(
                                      child: FutureBuilder(
                                          future: precacheImage(NetworkImage(image.imageUrl,), context),
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
                              );
                            },
                          );
                        }
                      }
                    },
                  )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: getService.streamGetDocByColumn(collection: setGroup.nama_group.toLowerCase(), collName: Collections.collColumnuserById, value: user.id),
                      builder: (context, snapshotImage) {
                        if (snapshotImage.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshotImage.hasError) {
                          return Center(child: DataNotFoundWidget(msgTop: 'Error: ${snapshotImage.error}'));
                        }
                        if (!snapshotImage.hasData) {
                          return const Center(child: DataNotFoundWidget(msgTop: 'Data tidak ditemukan!'));
                        }else{
                          var data = snapshotImage.data!.docs;
                          List<PostingImageModel> allImage = data.map((item) {
                            Map<String, dynamic> getMap = item.data() as Map<String, dynamic>;
                            PostingImageModel getImage = PostingImageModel.fromMap(getMap);
                            return getImage;
                          }).toList();

                          if(allImage.isEmpty){
                            return const Center(
                                child: DataNotFoundWidget(
                                  msgTop: 'Belum pernah upload gambar...',
                                  msgButton: 'Tidak ada gambar yang diposting!',
                                )
                            );
                          }else{
                            return Padding(
                              padding: EdgeInsets.only(top: Dimentions.height20),
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: Dimentions.height6,
                                  mainAxisSpacing: Dimentions.height6,
                                ),
                                itemCount: allImage.length, // number of columns in the grid
                                itemBuilder: (context, index){
                                  PostingImageModel image = allImage[index];
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Get.toNamed(RouteHalper.getDetailImage(image.imageId, image.imageGroup));
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
                                            image: DecorationImage(
                                              image: NetworkImage(image.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: FutureBuilder(
                                              future: precacheImage(NetworkImage(image.imageUrl,), context),
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
                                  );
                                },
                              ),
                            );
                          }
                        }
                      }
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Future<List<PostingImageModel>> getAllDocuments({required String uid, required String phone}) async {
    var getUserMaster = await getService.getDocDataByDocId(context: context, collection: Collections.usermaster, docId: phone);
    List<Map<String, dynamic>> groupArray = List.from(getUserMaster!.get("group"));
    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
      UserGroupModel getGroup = UserGroupModel.fromMap(res);
      return getGroup;
    }).toList();

    List<Future<QuerySnapshot>> futures = toModelGroup.map((model) {
      return getService.fbStore.collection(model.nama_group.toLowerCase()).get();
    }).toList();

    List<QuerySnapshot> snapshots = await Future.wait(futures);

    List<PostingImageModel> documents = snapshots.expand((snapshot) {
      return snapshot.docs.where((item) => item.get(Collections.collColumnuserById) == uid).map((doc) {
        Map<String, dynamic> getMap = doc.data() as Map<String, dynamic>;
        PostingImageModel fromMap = PostingImageModel.fromMap(getMap);
        return fromMap;
      });
    }).toList();

    return documents;
  }
}
