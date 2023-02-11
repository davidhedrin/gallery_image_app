import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.dart';
import '../../utils/dimentions.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/auth_widget/text_widget.dart';

class EditAccountPage extends StatefulWidget {
  final String uid;
  const EditAccountPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  File? imageProfile, imageCover;

  final TextEditingController namaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

    return Scaffold(
      body: FadeInDown(
        child: Column(
            children: <Widget> [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: profileSize + Dimentions.height15),
                    color: Colors.grey,
                    child: Image.asset(
                      Assets.imageBackgroundProfil,
                      width: double.infinity,
                      height: coverHeight,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Icons Widget
                  Positioned(
                    top: Dimentions.height45,
                    left: Dimentions.width20,
                    right: Dimentions.width20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: AppIcon(icon: Icons.arrow_back_ios_new),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: coverHeight - profileSize,
                    child: CircleAvatar(
                      radius: profileSize + 5,
                      backgroundColor: Colors.white,
                      child: InkWell(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (context){
                                return Text("Select Image");
                              }
                          );
                        },
                        child: imageProfile != null ? CircleAvatar(
                          radius: profileSize,
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage: FileImage(imageProfile!),
                        ) : CircleAvatar(
                          radius: profileSize,
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage: AssetImage(Assets.imagePrifil),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Dimentions.height10,),
              Divider(height: 1, color: Colors.black87),

              new Expanded(
                child: Form(
                  key: _formKey,
                  child: new ListView(
                    shrinkWrap: true,
                    children: <Widget>[
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
        ),
      ),
    );
  }
}
