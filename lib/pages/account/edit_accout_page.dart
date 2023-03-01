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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController newco_passwordController = TextEditingController();

  bool _isLoading = false;

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
              return Center(child: Container(child: CircularProgressIndicator()));
            }
            if(!snapshot.hasData){
              return DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
            }else{
              var data = snapshot.data;
              namaController.text = data!.get("nama_lengkap");
              emailController.text = data.get("email");
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
                              ) : data.data()!.containsKey("img_cover_url") ? data.get("img_cover_url").toString().isNotEmpty ? Image.network(
                                data.get("img_cover_url"),
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
                            data.data()!.containsKey("img_cover_url") ? data.get("img_cover_url").toString().isNotEmpty ? Positioned(
                              left: Dimentions.heightSize130,
                              top: Dimentions.height40,
                              child: Center(
                                child: FutureBuilder(
                                    future: precacheImage(NetworkImage(data.get("img_cover_url"),), context),
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
                                child: AppIcon(icon: Icons.close),
                              ),
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
                                ) : data.data()!.containsKey("img_profil_url") ?  data.get("img_profil_url").toString().isNotEmpty ? CircleAvatar(
                                  radius: profileSize,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: NetworkImage(data.get("img_profil_url")),
                                ) : CircleAvatar(
                                  radius: profileSize,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: AssetImage(Assets.imagePrifil),
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
                                    GestureDetector(
                                      onTap: () async {
                                        var image = await pickImageCrop(context);
                                        setState(() {
                                          imageProfile = image;
                                        });
                                      },
                                      child: AppIcon(icon: Icons.edit),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SmallText(text: data.get("phone"), color: Colors.black87, size: Dimentions.font17,),

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

                            SizedBox(height: Dimentions.height15,),
                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: SmallText(text: "Form ganti password", color: Colors.black54,),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: Divider(height: 1, color: Colors.black87),
                            ),
                            SizedBox(height: Dimentions.height15,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MyTextFieldReg(
                                controller: passwordController,
                                hintText: "Masukkan Password Lama",
                                obscureText: true,
                              ),
                            ),

                            SizedBox(height: Dimentions.height15,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MyTextFieldReg(
                                controller: newpasswordController,
                                hintText: "Masukkan Password Baru",
                                obscureText: true,
                              ),
                            ),

                            SizedBox(height: Dimentions.height15,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MyTextFieldReg(
                                controller: newco_passwordController,
                                hintText: "Konfirmasi Password Baru",
                                obscureText: true,
                              ),
                            ),

                            SizedBox(height: Dimentions.height20,),

                            Padding(
                              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                onPressed: () {
                                  BuildContext dialogcontext = context;
                                  void hitUpdate() async {
                                    if(_formKey.currentState!.validate()){
                                      getService.loading(dialogcontext);

                                      if(imageProfile != null){
                                        if(data.data()!.containsKey("img_profil_url")){
                                          getService.deleteFileStorage(context: context, imagePath: "imageProfile/${widget.uid}");
                                        }
                                      }
                                      if(imageCover != null){
                                        if(data.data()!.containsKey("img_cover_url")){
                                          getService.deleteFileStorage(context: context, imagePath: "imageCover/${widget.uid}");
                                        }
                                      }

                                      String imgProfileUrl = imageProfile != null ? await getService.uploadImageToStorage(ref: "imageProfile/${widget.uid}", file: imageProfile!, context: context) : data.get("img_profil_url");
                                      String imgCoverUrl = imageCover != null ? await getService.uploadImageToStorage(ref: "imageCover/${widget.uid}", file: imageCover!, context: context) : data.get("img_cover_url");
                                      var userModel = UserModel(
                                        nama_lengkap: namaController.text,
                                        email: emailController.text,
                                        password: newpasswordController.text.isEmpty ? data.get("password") : newpasswordController.text,
                                        img_profil_url: imgProfileUrl,
                                        img_cover_url: imgCoverUrl,
                                      );

                                      getService.updateDataDb(data: userModel.toMapUpdate(), context: context, collection: Collections.users, guid: widget.uid);

                                      Navigator.of(dialogcontext).pop();
                                      showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil memperbaharui data", title: "Update");
                                    }
                                  }
                                  if(passwordController.text.isEmpty && newpasswordController.text.isEmpty && newco_passwordController.text.isEmpty){
                                    hitUpdate();
                                  }else{
                                    if(passwordController.text == data.get("password")){
                                      if(newpasswordController.text.isNotEmpty && newco_passwordController.text.isNotEmpty){
                                        if(newpasswordController.text == newco_passwordController.text){
                                          hitUpdate();
                                        }else{
                                          showAwsBar(context: context, contentType: ContentType.help, msg: "Password baru dan konfirmasi password tidak sama!", title: "Opss...");
                                        }
                                      }else{
                                        showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan password baru!", title: "Opss...");
                                      }
                                    }else{
                                      showAwsBar(context: context, contentType: ContentType.warning, msg: "Password lama tidak sesuai!", title: "Opss...");
                                    }
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
