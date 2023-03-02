import 'dart:io';

import 'package:delivery_food_app/halper/function_halpers.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';
import '../../models/user_model.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/loading_progres.dart';

class UserDetailPage extends StatefulWidget {
  final UserModel userModel;
  final int userSee;
  const UserDetailPage({Key? key, required this.userModel, required this.userSee}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final FunHelp getHelp = FunHelp();
  File? imageProfile, imageCover;

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.userModel;
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

    int setType = getHelp.checkStatusUser(user.user_type);

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
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                    ],
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }
}
