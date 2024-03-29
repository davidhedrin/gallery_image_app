// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';
import '../../providers/app_services.dart';
import '../../utils/dimentions.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/auth_widget/text_widget.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/loading_progres.dart';

class EditAccountPage extends StatefulWidget {
  final String uid;
  const EditAccountPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final AppServices getService = AppServices();
  final _formKey = GlobalKey<FormState>();
  File? imageProfile, imageCover;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

    return Scaffold(
      body: FadeInDown(
        child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
          stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: widget.uid),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if(!snapshot.hasData){
              return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
            }else{
              var data = snapshot.data;
              var dataData = data!.data();
              Map<String, dynamic> getMap = dataData as Map<String, dynamic>;
              UserModel userModel = UserModel.fromMap(getMap);
              namaController.text = userModel.namaLengkap;
              emailController.text = userModel.email;
              return Column(
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
                              ) : dataData.containsKey("img_cover_url") ? userModel.imgCoverUrl.isNotEmpty ? Image.network(
                                userModel.imgCoverUrl,
                                width: double.infinity,
                                height: coverHeight,
                                fit: BoxFit.cover,
                              ) : Image.asset(
                                Assets.imageBackgroundProfil,
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
                            dataData.containsKey("img_cover_url") ? userModel.imgCoverUrl.isNotEmpty ? Positioned(
                              left: Dimentions.heightSize130,
                              top: Dimentions.height40,
                              child: Center(
                                child: FutureBuilder(
                                    future: precacheImage(NetworkImage(userModel.imgCoverUrl,), context),
                                    builder: (BuildContext context, AsyncSnapshot snapshot){
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        return const SizedBox.shrink();
                                      } else {
                                        return const LoadingProgress();
                                      }
                                    }
                                ),
                              ),
                            ) : const Text("") : const Text(""),
                          ],
                        ),

                        // Icons Widget
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
                                child: const AppIcon(icon: Icons.close),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var image = await pickImageNoCrop(context);
                                  setState(() {
                                    imageCover = image;
                                  });
                                },
                                child: const AppIcon(icon: Icons.image),
                              ),
                            ],
                          ),
                        ),

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
                                ) : dataData.containsKey("img_profil_url") ? userModel.imgProfilUrl.isNotEmpty ? CircleAvatar(
                                  radius: profileSize,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: NetworkImage(userModel.imgProfilUrl),
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
                              Positioned(
                                top: profileSize + Dimentions.height25,
                                left: profileSize + Dimentions.height25,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        var image = await pickImageCrop(context);
                                        setState(() {
                                          imageProfile = image;
                                        });
                                      },
                                      child: const AppIcon(icon: Icons.edit),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SmallText(text: userModel.phone, color: Colors.black87, size: Dimentions.font17,),

                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MyTextFieldReg(
                                controller: emailController,
                                hintText: "Masukkan Email",
                                validator: (value){
                                  if(value!.isEmpty){
                                    return '*masukkan alamat email';
                                  }
                                  if(!EmailValidator.validate(value)){
                                    return '*alamat email tidak sesuai';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: Dimentions.height15,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MyTextFieldReg(
                                controller: namaController,
                                hintText: "Masukkan Nama",
                                validator: (value){
                                  if(value!.isEmpty){
                                    return '*masukkan nama lengkap';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: Dimentions.height20,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                onPressed: () async {
                                  BuildContext dialogcontext = context;
                                  UserModel userMdl = UserModel(
                                    namaLengkap: namaController.text,
                                    email: emailController.text,
                                  );

                                  if(_formKey.currentState!.validate()){
                                    getService.loading(dialogcontext);

                                    if(imageProfile != null){
                                      if(dataData.containsKey("img_profil_url")){
                                        getService.deleteFileStorage(context: context, imagePath: "${Collections.strgImageProfile}/${widget.uid}");
                                      }
                                    }
                                    if(imageCover != null){
                                      if(dataData.containsKey("img_cover_url")){
                                        getService.deleteFileStorage(context: context, imagePath: "${Collections.strgImageCover}/${widget.uid}");
                                      }
                                    }

                                    String imgProfileUrl = imageProfile != null ? await getService.uploadImageToStorage(ref: "${Collections.strgImageProfile}/${widget.uid}", file: imageProfile!, context: context) : dataData.containsKey("img_profil_url") ? data.get("img_profil_url") : "";
                                  String imgCoverUrl = imageCover != null ? await getService.uploadImageToStorage(ref: "${Collections.strgImageCover}/${widget.uid}", file: imageCover!, context: context) : dataData.containsKey("img_cover_url") ? data.get("img_cover_url") : "";

                                  userMdl.imgProfilUrl = imgProfileUrl;
                                  userMdl.imgCoverUrl = imgCoverUrl;

                                    getService.updateDataDb(data: userMdl.toMapUpdate(), context: context, collection: Collections.users, guid: widget.uid);

                                    Navigator.of(dialogcontext).pop();
                                    showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil memperbaharui data", title: "Update");
                                  }
                                },
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimentions.screenHeight/156.21)
                                ),
                                padding: EdgeInsets.symmetric(vertical: Dimentions.font16, horizontal: Dimentions.width30),
                                child: Text("Simpan", style: TextStyle(fontSize: Dimentions.font16, color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
              );
            }
          },
        ),
      ),
    );
  }
}
