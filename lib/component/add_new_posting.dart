import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/models/posting_image.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/user_group.dart';
import '../models/user_model.dart';
import '../providers/app_services.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/app_icon.dart';
import '../widgets/auth_widget/text_widget.dart';

class ModelPermirsa{
  String value;
  String id;

  ModelPermirsa({this.value = "",  this.id = ""});
}

class AddNewPostingPage extends StatefulWidget {
  final String uid;
  final String groupId;
  const AddNewPostingPage({Key? key, required this.uid, required this.groupId}) : super(key: key);

  @override
  State<AddNewPostingPage> createState() => _AddNewPostingPageState();
}

class _AddNewPostingPageState extends State<AddNewPostingPage> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();

  final _formKey = GlobalKey<FormState>();

  File? image;
  final TextEditingController titleImageController = TextEditingController();
  final TextEditingController vdateImageController = TextEditingController();
  final TextEditingController ketImageController = TextEditingController();
  DateTime? dateImage;

  String? _selectedItem = "";
  List<UserGroupModel> toModelGroupList = [];
  List<ModelPermirsa> contentFor = [];
  String _selectedContent = "";

  _AddNewPostingPageState(){
    contentFor = [
      ModelPermirsa(id: "1", value: "Public"),
      ModelPermirsa(id: "2", value: "Private"),
    ];
    _selectedContent = contentFor[0].id;
  }

  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context) {
    if(_selectedItem!.isEmpty){
      _selectedItem = widget.groupId;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Column(
        children: <Widget>[
          Stack(
            children: [
              Container(
                height: Dimentions.heightSize230,
                child: image != null ? Image.file(
                  image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ) : Image.asset(
                  Assets.imageBackgroundProfil,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

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
                      child: AppIcon(icon: Icons.close),
                    ),
                  ],
                ),
              ),
            ]
          ),

          SizedBox(height: Dimentions.height10,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimentions.width30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmallText(text: "Familiy Gallery", color: Colors.black45, size: Dimentions.font12,),
                    StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                        stream: getService.streamBuilderGetDoc(collection: "users", docId: widget.uid),
                        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                          }
                          if (!snapshot.hasData) {
                            return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                          }else{
                            var document = snapshot.data;
                            Map<String, dynamic> userData = document!.data() as Map<String, dynamic>;
                            userModel = UserModel.fromMap(userData);
                            return StreamBuilder(
                                stream: getService.streamBuilderGetDoc(collection: "user-master", docId: document.get("phone")),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                                  if (snapshotGroup.connectionState == ConnectionState.waiting) {
                                    return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                                  }
                                  if (!snapshotGroup.hasData) {
                                    return Container(child: BigText(text: "-", color: AppColors.mainColor,));
                                  }else{
                                    var dataGroup = snapshotGroup.data!.data();
                                    List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                                    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                                      UserGroupModel getGroup = UserGroupModel.fromMap(res);
                                      return getGroup;
                                    }).toList();

                                    toModelGroupList.addAll(toModelGroup);

                                    if(toModelGroup.length < 2){
                                      return BigText(
                                        text: toModelGroup.first.nama_group.toString(),
                                        size: Dimentions.font20,
                                      );
                                    }else{
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isDense: true,
                                          value: _selectedItem,
                                          icon: Icon(Icons.arrow_drop_down),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedItem = value;
                                            });
                                          },
                                          items: toModelGroup.map((value) {
                                            return DropdownMenuItem(
                                                value: value.id.toString(),
                                                child: BigText(
                                                  text: value.nama_group.toString(),
                                                  size: Dimentions.font20,
                                                )
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                  }
                                }
                            );
                          }
                        }
                    ),
                  ],
                ),
              ],
            )
          ),
          Divider(height: Dimentions.height15, thickness: 1.5),
          SizedBox(height: Dimentions.height10,),

          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width30, bottom: Dimentions.height2),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SmallText(text: "Tanggal Image:", color: Colors.black45, size: Dimentions.font16,)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                      child: MyTextFieldReg(
                        controller: vdateImageController,
                        hintText: "Pilih Tanggal Image",
                        prefixIcon: InkWell(
                            onTap: (){
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1945),
                                lastDate: DateTime(3000),
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                              ).then((value) {
                                if(!value.isNull){
                                  var day = DateFormat('EEEE').format(value!);
                                  var month = DateFormat('MMMM').format(value);
                                  setState(() {
                                    vdateImageController.text = "$day, ${value.day} $month ${value.year}";
                                    dateImage = value;
                                  });
                                }else{
                                  vdateImageController.clear();
                                  dateImage = null;
                                }
                              });
                            },
                            child: Icon(Icons.calendar_month_outlined, color: Colors.lightBlue,)
                        ),
                        readOnly: true,
                        validator: (value){
                          if(value!.isEmpty){
                            return '*masukkan tanggal image';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: Dimentions.height15,),

                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width30, bottom: Dimentions.height2),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SmallText(text: "Judul Image:", color: Colors.black45, size: Dimentions.font16,)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                      child: MyTextFieldReg(
                        controller: titleImageController,
                        hintText: "Masukkan Judul Image",
                        validator: (value){
                          if(value!.isEmpty){
                            return '*masukkan judul image';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: Dimentions.height15,),

                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width30, bottom: Dimentions.height2),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SmallText(text: "Keterangan Image:", color: Colors.black45, size: Dimentions.font16,)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                      child: MyTextFieldReg(
                        controller: ketImageController,
                        hintText: "Masukkan Keteragan Image",
                        maxLines: 6,
                      ),
                    ),

                    SizedBox(height: Dimentions.height15,),

                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width30, bottom: Dimentions.height2),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: SmallText(text: "Pemirsa:", color: Colors.black45, size: Dimentions.font16,)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25, bottom: Dimentions.height2),
                      child: DropdownButtonFormField(
                        value: _selectedContent,
                        isDense: true,
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colors.cyan,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(_selectedContent == "1" ? Icons.people_outline : Icons.lock),
                          enabledBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          isDense: true,
                        ),
                        items: contentFor.map((e) {
                          return DropdownMenuItem(
                            value: e.id,
                            child: Text(e.value, style: TextStyle(fontSize: Dimentions.font20),),
                          );
                        }).toList(),
                        onChanged: (value){
                          setState(() {
                            _selectedContent = value as String;
                          });
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.onBackground,
        child: Padding(
          padding: EdgeInsets.only(left: Dimentions.width8, right: Dimentions.width15, bottom: Dimentions.height6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(Dimentions.radius50))
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Dimentions.height12),
                  child: Row(
                    children: [
                      Text("Pilih ", style: TextStyle(color: Colors.white, fontSize: Dimentions.font17),),
                      const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  var isImage = await pickImageCrop(context);
                  setState(() {
                    image = isImage;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  BuildContext dialogcontext = context;
                  if(image != null){
                    if(_formKey.currentState!.validate()){

                      bool check = false;
                      await onBackButtonPressYesNo(context: context, text: "Upload Posting", desc: "Apakah postingan sudah sesuai?").then((value){
                        check = value;
                      });
                      if(check){
                        getService.loading(dialogcontext);

                        String guid = getService.generateGuid();
                        UserGroupModel getGroup = toModelGroupList.firstWhere((group) => group.id == _selectedItem);
                        String collectionImage = getGroup.nama_group.toLowerCase();

                        UserGroupModel getGroupFilter = toModelGroupList.firstWhere((group) => group.id == _selectedItem);
                        String imgUrl = await getService.uploadImageToStorage(ref: "$collectionImage/$guid", file: image!, context: context);
                        String getImgUrl = imgUrl;

                        PostingImageModel imageModel = PostingImageModel(
                          title: titleImageController.text,
                          imageUrl: getImgUrl,
                          imageId: guid,
                          keterangan: ketImageController.text,
                          pemirsa: _selectedContent,
                          tanggal: dateImage,
                          uploadDate: DateTime.now(),
                          userByName: userModel.nama_lengkap,
                          userById: userModel.id,
                          imageGroup: collectionImage,
                        );

                        getService.createDataToDb(data: imageModel.toMapUpload(), context: context, collection: collectionImage, guid: guid);

                        Navigator.of(dialogcontext).pop();
                        Navigator.pop(context);
                        showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil mengunggah postingan", title: "Posting");
                      }
                    }
                  }else{
                    showAwsBar(context: context, contentType: ContentType.warning, msg: "Pilih gambar terlebih dahulu", title: "Image!");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyan,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(Dimentions.radius15),
                ),
                child: const Icon(Icons.save_rounded),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
