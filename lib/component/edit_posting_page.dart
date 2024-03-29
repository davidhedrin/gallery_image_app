// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../generated/assets.dart';
import '../models/posting_image.dart';
import '../models/user_group.dart';
import '../models/user_model.dart';
import '../providers/app_services.dart';
import '../utils/colors.dart';
import '../utils/dimentions.dart';
import '../utils/utils.dart';
import '../widgets/app_icon.dart';
import '../widgets/auth_widget/text_widget.dart';
import '../widgets/big_text.dart';
import '../widgets/loading_progres.dart';
import '../widgets/small_text.dart';
import 'add_new_posting.dart';

class EditPostingPage extends StatefulWidget {
  final String uid;
  final String groupId;
  final PostingImageModel postData;
  const EditPostingPage({Key? key, required this.uid, required this.groupId, required this.postData}) : super(key: key);

  @override
  State<EditPostingPage> createState() => _EditPostingPageState();
}

class _EditPostingPageState extends State<EditPostingPage> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleImageController = TextEditingController();
  final TextEditingController vdateImageController = TextEditingController();
  final TextEditingController ketImageController = TextEditingController();
  DateTime? dateImage;

  String? _selectedItem = "";
  List<UserGroupModel> toModelGroupList = [];
  List<ModelPermirsa> contentFor = [];
  String _selectedContent = "";

  UserModel userModel = UserModel();

  PostingImageModel _postData = PostingImageModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postData = widget.postData;

    DateTime imageDate = _postData.tanggal!;
    var day = DateFormat('EEEE').format(imageDate);
    var month = DateFormat('MMMM').format(imageDate);
    vdateImageController.text = "$day, ${imageDate.day} $month ${imageDate.year}";
    dateImage = imageDate;
    titleImageController.text = _postData.title;
    ketImageController.text = _postData.keterangan ?? "";

    contentFor = [
      ModelPermirsa(id: "1", value: "Public"),
      ModelPermirsa(id: "2", value: "Private"),
    ];

    ModelPermirsa getContentFor = contentFor.firstWhere((item) => item.id == _postData.pemirsa);
    _selectedContent = getContentFor.id;
  }

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
                SizedBox(
                  height: Dimentions.heightSize230,
                  child: CachedNetworkImage(
                    imageUrl: _postData.imageUrl,
                    placeholder: (context, url) => LoadingProgress(size: Dimentions.height25,),
                    errorWidget: (context, url, error){
                      return Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(Assets.imageBackgroundProfil),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF9294cc),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: const AppIcon(icon: Icons.close),
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
                            return BigText(text: "-", color: AppColors.mainColor,);
                          }
                          if (!snapshot.hasData) {
                            return BigText(text: "-", color: AppColors.mainColor,);
                          }else{
                            var document = snapshot.data;
                            Map<String, dynamic> userData = document!.data() as Map<String, dynamic>;
                            userModel = UserModel.fromMap(userData);
                            return StreamBuilder(
                                stream: getService.streamBuilderGetDoc(collection: "user-master", docId: document.get("phone")),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup){
                                  if (snapshotGroup.connectionState == ConnectionState.waiting) {
                                    return BigText(text: "-", color: AppColors.mainColor,);
                                  }
                                  if (!snapshotGroup.hasData) {
                                    return BigText(text: "-", color: AppColors.mainColor,);
                                  }else{
                                    List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                                    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                                      UserGroupModel getGroup = UserGroupModel.fromMap(res);
                                      return getGroup;
                                    }).toList();

                                    toModelGroupList.addAll(toModelGroup);

                                    if(toModelGroup.length < 2){
                                      return BigText(
                                        text: toModelGroup.first.namaGroup.toString(),
                                        size: Dimentions.font20,
                                      );
                                    }else{
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isDense: true,
                                          value: _selectedItem,
                                          icon: const Icon(Icons.arrow_drop_down),
                                          onChanged: null,
                                          items: toModelGroup.map((value) {
                                            return DropdownMenuItem(
                                                value: value.groupId.toString(),
                                                child: BigText(
                                                  text: value.namaGroup.toString(),
                                                  size: Dimentions.font20,
                                                  color: Colors.black45,
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
            ),
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
                                if(value != null){
                                  var day = DateFormat('EEEE').format(value);
                                  var month = DateFormat('MMMM').format(value);
                                  setState(() {
                                    vdateImageController.text = "$day, ${value.day} $month ${value.year}";
                                    dateImage = value;
                                  });
                                }
                              });
                            },
                            child: const Icon(Icons.calendar_month_outlined, color: Colors.lightBlue,)
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
                          icon: const Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.cyan,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(_selectedContent == "1" ? Icons.people_outline : Icons.lock),
                            enabledBorder:  const OutlineInputBorder(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () async {
                  BuildContext dialogcontext = context;
                  if(_formKey.currentState!.validate()){

                    bool check = false;
                    await onBackButtonPressYesNo(context: context, text: "Update Posting", desc: "Apakah postingan sudah sesuai?").then((value){
                      check = value;
                    });
                    if(check){
                      getService.loading(dialogcontext);

                      PostingImageModel setDataUpdate = PostingImageModel(
                        title: titleImageController.text,
                        tanggal: dateImage,
                        keterangan: ketImageController.text,
                        pemirsa: _selectedContent
                      );

                      getService.updateDataDb(data: setDataUpdate.toMapUpdate(), context: context, collection: _postData.imageGroup, guid: _postData.imageId);

                      Navigator.of(dialogcontext).pop();
                      Navigator.pop(context);
                      showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil mengubah postingan", title: "Posting");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  shape: const CircleBorder(),
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
