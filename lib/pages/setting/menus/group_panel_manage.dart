// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:delivery_food_app/component/page/user_detail.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../halper/function_halpers.dart';
import '../../../models/user_group.dart';
import '../../../models/user_master_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/collections.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimentions.dart';
import '../../../utils/utils.dart';
import '../../../widgets/auth_widget/text_widget.dart';
import '../../../widgets/big_text.dart';
import '../../../widgets/data_not_found.dart';
import '../../../widgets/icon_and_text_widget.dart';
import '../../../widgets/loading_progres.dart';
import '../../../widgets/small_text.dart';

class GroupPanelManage extends StatefulWidget {
  final UserGroupModel groupModel;
  final UserModel currentUser;
  const GroupPanelManage({Key? key, required this.groupModel, required this.currentUser}) : super(key: key);

  @override
  State<GroupPanelManage> createState() => _GroupPanelManagState();
}

class _GroupPanelManagState extends State<GroupPanelManage> {
  final AppServices getService = AppServices();
  final FunHelp getHelp = FunHelp();
  final TextEditingController searchController = TextEditingController();

  late UserModel lateCurrentUser = UserModel();

  @override
  Widget build(BuildContext context) {
    UserGroupModel getGroup = widget.groupModel;
    UserModel curUser = widget.currentUser;
    lateCurrentUser = curUser;
    int status = getHelp.checkStatusUser(getGroup.status);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Group "${getGroup.namaGroup}"', style: const TextStyle(color: Colors.black87),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            status < 3 ? IconButton(
              icon: Icon(Icons.add, color: Colors.black87, size: Dimentions.iconSize32,),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AddNewUser(groupModel: getGroup, currentUser: curUser,);
                    }
                );
              },
            ) : const Text(""),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15),
              child: MyTextFieldReg(
                controller: searchController,
                hintText: "Temukan Group...",
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: getService.streamObjGetCollection(collection: Collections.usermaster),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if(!snapshot.hasData){
                        return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
                      }else{
                        var userGroup = snapshot.data!.docs;
                        List<UserMasterModel> getListGroup = userGroup.map((e){
                          Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                          UserMasterModel images = UserMasterModel.fromMap(getMap);
                          return images;
                        }).toList();

                        List<UserMasterModel> getUser = getListGroup.expand((parent) => parent.group!).where((child) => child.groupId == getGroup.groupId).map((child) => getListGroup.firstWhere((parent) => parent.group!.contains(child))).toList();
                        getUser.sort((a, b) => a.createDate!.compareTo(b.createDate!));

                        if(getUser.isEmpty){
                          return Padding(
                            padding: EdgeInsets.only(top: Dimentions.height45),
                            child: const DataNotFoundWidget(msgTop: "Belum ada user didaftarkan", msgButton: "Tambahkan user kedalam group anda!",),
                          );
                        }else{
                          return ListView.builder(
                              padding: EdgeInsets.only(top: Dimentions.height15),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getUser.length,
                              itemBuilder: (context, index){
                                UserMasterModel getDataUser = getUser[index];
                                GroupModel getCurrentGroup = getDataUser.group!.firstWhere((group) => group.groupId == getGroup.groupId);
                                return StreamBuilder<QuerySnapshot>(
                                    stream: getService.streamGetDocByColumn(collection: Collections.users, collName: "phone", value: getDataUser.phone),
                                    builder: (context, snapshotUser) {
                                      if (snapshotUser.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if(!snapshotUser.hasData){
                                        return const Text("Data tidak ditemukan!",);
                                      }else{
                                        var getDocs = snapshotUser.data!.docs;
                                        if(getDocs.isNotEmpty){
                                          var data = getDocs.first;
                                          Map<String, dynamic> getMap = data.data() as Map<String, dynamic>;
                                          UserModel userModel = UserModel.fromMap(getMap);
                                          userModel.userType = getCurrentGroup.status;

                                          return generateUserCard(index: index, usrModel: userModel, groupModel: getGroup);
                                        }else{
                                          UserModel userModel = UserModel(
                                            namaLengkap: getDataUser.nama,
                                            phone: getDataUser.phone,
                                            userType: getCurrentGroup.status
                                          );
                                          return generateUserCard(index: index, usrModel: userModel, groupModel: getGroup);
                                        }
                                      }
                                    }
                                );
                              }
                          );
                        }
                      }
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget generateUserCard({required int index, UserModel? usrModel, UserGroupModel? groupModel}){
    UserModel userModel = usrModel!;
    String? userType = userModel.userType.isNotEmpty ? userModel.userType.toLowerCase() : "";
    int? setType = userType.isNotEmpty ? getHelp.checkStatusUser(userType) : 0;
    String? month = userModel.createDate != null ? DateFormat('MMMM').format(userModel.createDate!) : "";

    int currentUser = getHelp.checkStatusUser(lateCurrentUser.userType);

    return GestureDetector(
      onTap: (){
        Get.to(() => UserDetailPage(userModel: userModel, userSee: currentUser, groupModel: groupModel,));
      },
      child: Container(
        margin: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height15),
        child: Row(
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  width: Dimentions.heightSize90,
                  height: Dimentions.heightSize90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimentions.radius30),
                      color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                      image: userModel.imgProfilUrl.isNotEmpty ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(userModel.imgProfilUrl,),
                      ) : const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(Assets.imagePrifil),
                      ),
                  ),
                ),
                userModel.imgProfilUrl.isNotEmpty ? Positioned.fill(
                  child: Center(
                    child: FutureBuilder(
                        future: precacheImage(NetworkImage(userModel.imgProfilUrl,), context),
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          if (snapshot.connectionState == ConnectionState.done) {
                            return const SizedBox.shrink();
                          } else {
                            return LoadingProgress(size: Dimentions.height10,);
                          }
                        }
                    ),
                  ),
                ) : const Text(""),
              ],
            ),

            // Text Container
            Expanded(
              child: Container(
                height: Dimentions.heightSize85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Dimentions.radius20),
                      bottomRight: Radius.circular(Dimentions.radius20)
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: Dimentions.width10, right: Dimentions.width10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: BigText(text: userModel.namaLengkap.isNotEmpty ? userModel.namaLengkap : "")),
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
                          )
                        ],
                      ),
                      SizedBox(height: Dimentions.height6,),
                      SmallText(text: userModel.phone.isNotEmpty ? userModel.phone : ""),
                      SizedBox(height: Dimentions.height6,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconAndTextWidget(
                              icon: Icons.account_circle,
                              text: userModel.flagActive.isNotEmpty ? userModel.flagActive == "N" ? "Blokir" : "Aktif" : "(not-regist)",
                              iconColor: AppColors.iconColor1
                          ),
                          IconAndTextWidget(
                              icon: Icons.calendar_month_outlined,
                              text: userModel.createDate != null ? "${userModel.createDate!.day} $month ${userModel.createDate!.year}" : "",
                              iconColor: AppColors.iconColor2
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ModelStatus{
  String value;
  String id;

  ModelStatus({this.value = "",  this.id = ""});
}
class AddNewUser extends StatefulWidget {
  final UserGroupModel groupModel;
  final UserModel currentUser;
  const AddNewUser({Key? key, required this.groupModel, required this.currentUser}) : super(key: key);

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final AppServices getService = AppServices();
  final FunHelp getHalp = FunHelp();
  final TextEditingController namaUserController = TextEditingController();
  final TextEditingController noPhoneController = TextEditingController();
  final PageController pageController = PageController();

  int indexPage = 0;

  Color generateRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  Country selectCountry = Country(
    phoneCode: "62",
    countryCode: "ID",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Indonesia",
    example: "Indonesia",
    displayName: "Indonesia",
    displayNameNoCountryCode: "ID",
    e164Key: ""
  );

  List<UserModel> userFor = [];
  String _selectedUser = "";

  List<ModelStatus> statusFor = [];
  String _selectedStatus = "";
  _AddNewUserState(){
    statusFor = [
      ModelStatus(id: "USR", value: "User"),
      ModelStatus(id: "ADM", value: "Admin"),
    ];
    _selectedStatus = statusFor[0].id;
  }

  @override
  Widget build(BuildContext context) {
    UserGroupModel getGroup = widget.groupModel;
    UserModel curUser = widget.currentUser;

    int setType = getHalp.checkStatusUser(curUser.userType);

    return AlertDialog(
      title: const Text("Tambah Group Baru", textAlign: TextAlign.center,),
      icon: Icon(Icons.person, size: Dimentions.height45, color: generateRandomColor()),
      content: setType == 1 ? SizedBox(
        width: Dimentions.heightSize300,
        height: indexPage == 0 ? Dimentions.heightSize270 : Dimentions.heightSize200,
        child: PageView(
          controller: pageController,
          onPageChanged: (int idx){
            setState(() {
              indexPage = idx;
            });
          },
          children: [
            indexPage == 0 ? Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                      value: _selectedStatus,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.cyan,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(_selectedStatus == "1" ? Icons.people_outline : Icons.lock),
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
                      items: statusFor.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.value, style: TextStyle(fontSize: Dimentions.font20),),
                        );
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          _selectedStatus = value as String;
                        });
                      }
                  ),

                  SizedBox(height: Dimentions.height15,),

                  MyTextFieldReg(
                    controller: namaUserController,
                    hintText: "Nama User",
                    prefixIcon: const Icon(Icons.supervised_user_circle),
                    validator: (value){
                      if(value!.isEmpty){
                        return "*masukkan nama user";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Dimentions.height15,),
                  TextFormField(
                    controller: noPhoneController,
                    validator: (value){
                      if(value!.isEmpty){
                        return '*masukkan nomor ponsel';
                      }
                      if(value.length < 10){
                        return '*nomor ponsel tidak sah';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'\d'),
                      ),
                      FilteringTextInputFormatter.deny(
                        RegExp(r'^0+'),
                      ),
                    ],
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    style: TextStyle(
                      fontSize: Dimentions.font20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
                      enabledBorder:  const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: "812-xxxx-xxxx",
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20),
                      suffixIcon: const Icon(Icons.phone_android),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: Dimentions.width15, top: Dimentions.screenHeight/62, right: Dimentions.width5),
                        child: InkWell(
                          onTap: (){
                            showCountryPicker(
                                context: context,
                                countryListTheme:  CountryListThemeData(
                                  bottomSheetHeight: Dimentions.heightSize400,
                                ),
                                onSelect: (value){
                                  setState(() {
                                    selectCountry = value;
                                  });
                                }
                            );
                          },
                          child: Text(
                            "${selectCountry.flagEmoji} +${selectCountry.phoneCode}",
                            style: TextStyle(
                                fontSize: Dimentions.font20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: Dimentions.height15,),
                  SizedBox(
                    width: double.infinity,
                    height: Dimentions.height40,
                    child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                          getService.loading(context);

                          String number = "+${selectCountry.phoneCode}${noPhoneController.text}";

                          List<Map<String, dynamic>> listGroupUser = [
                            GroupModel(status: _selectedStatus, namaGroup: getGroup.namaGroup, groupId: getGroup.groupId).toMapUpload(),
                          ];

                          UserMasterModel setUser = UserMasterModel(
                            phone: number,
                            nama: namaUserController.text,
                            createDate: DateTime.now(),
                            groupMap: listGroupUser,
                          );

                          getService.createDataToDb(data: setUser.toMapUpload(), context: context, collection: Collections.usermaster, guid: number);

                          Navigator.of(context).pop();
                          Navigator.pop(context);
                          showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil menambahkan user", title: "New User");
                        }
                      },
                      child: BigText(text: "Tambah", color: Colors.white,),
                    ),
                  ),

                  SizedBox(height: Dimentions.height10,),
                  SmallText(text: "Tambah dari user terdaftar ->", color: Colors.black87, size: Dimentions.font14,),
                ],
              ),
            ) : const Text(""),
            indexPage == 1 ? Form(
              key: _formKey2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                      value: _selectedStatus,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.cyan,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(_selectedStatus == "1" ? Icons.people_outline : Icons.lock),
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
                      items: statusFor.map((e) {
                        return DropdownMenuItem(
                          value: e.id,
                          child: Text(e.value, style: TextStyle(fontSize: Dimentions.font20),),
                        );
                      }).toList(),
                      onChanged: (value){
                        setState(() {
                          _selectedStatus = value as String;
                        });
                      }
                  ),
                  SizedBox(height: Dimentions.height15,),
                  StreamBuilder<QuerySnapshot>(
                      stream: getService.streamObjGetCollection(collection: Collections.users),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData) {
                          return const DataNotFoundWidget(msgTop: "User Tidak Ditemukan");
                        }else{
                          var groupsDoc = snapshot.data!.docs;
                          List<UserModel> getListUserControl = [
                            UserModel(id: ""),
                          ];

                          List<UserModel> getListUser = groupsDoc.map((e){
                            Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                            UserModel group = UserModel.fromMap(getMap);
                            return group;
                          }).toList();

                          getListUserControl.addAll(getListUser);
                          userFor.addAll(getListUser);

                          if(getListUser.isNotEmpty){
                            return DropdownButtonFormField(
                                  value: _selectedUser,
                                  isDense: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down_circle,
                                    color: Colors.cyan,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.people_outline),
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
                                  items: getListUserControl.map((e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.id.isNotEmpty ? e.namaLengkap : "Pilih User", style: TextStyle(fontSize: Dimentions.font20),),
                                    );
                                  }).toList(),
                                  onChanged: (value){
                                    setState(() {
                                      _selectedUser = value as String;
                                    });
                                  }
                              );
                          }else{
                            return const DataNotFoundWidget(msgTop: "User Tidak Ditemukan");
                          }
                        }
                      }
                  ),
                  SizedBox(height: Dimentions.height15,),
                  SizedBox(
                    width: double.infinity,
                    height: Dimentions.height40,
                    child: ElevatedButton(
                      onPressed: () async {
                        if(_formKey2.currentState!.validate()){
                          getService.loading(context);

                          UserModel getSelectedUser = userFor.firstWhere((user) => user.id == _selectedUser);

                          String number = getSelectedUser.phone;

                          bool checkUserRegis = await getService.checkExistDocById(collection: Collections.usermaster, uid: number);

                          if(checkUserRegis == false){
                            List<Map<String, dynamic>> listGroupUser = [
                              GroupModel(status: _selectedStatus, namaGroup: getGroup.namaGroup, groupId: getGroup.groupId).toMapUpload(),
                            ];

                            UserMasterModel setUser = UserMasterModel(
                              phone: number,
                              nama: getSelectedUser.namaLengkap,
                              createDate: DateTime.now(),
                              groupMap: listGroupUser,
                            );

                            getService.createDataToDb(data: setUser.toMapUpload(), context: context, collection: Collections.usermaster, guid: number);
                          }else{
                            var getUserMaster = await getService.getDocDataByDocIdNoCon(collection: Collections.usermaster, docId: number);
                            Map<String, dynamic> getMap = getUserMaster!.data() as Map<String, dynamic>;
                            UserMasterModel setMasterUser = UserMasterModel.fromMap(getMap);

                            List<Map<String, dynamic>> listGroupUser = List<Map<String, dynamic>>.from(setMasterUser.groupMap!);
                            Map<String, dynamic> setNewGroup = GroupModel(status: _selectedStatus, namaGroup: getGroup.namaGroup, groupId: getGroup.groupId).toMapUpload();
                            listGroupUser.add(setNewGroup);

                            final documentRef = getService.fbStore.collection(Collections.usermaster).doc(number);
                            documentRef.update({
                              Collections.collColumngroup : FieldValue.arrayUnion(listGroupUser),
                            });
                          }

                          Navigator.of(context).pop();
                          Navigator.pop(context);
                          showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil menambahkan user", title: "New User");
                        }
                      },
                      child: BigText(text: "Tambah", color: Colors.white,),
                    ),
                  ),
                ],
              ),
            ) : const Text(""),
          ],
        ),
      ) :
      SizedBox(
        width: Dimentions.heightSize300,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                  value: _selectedStatus,
                  isDense: true,
                  icon: const Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.cyan,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(_selectedStatus == "1" ? Icons.people_outline : Icons.lock),
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
                  items: statusFor.map((e) {
                    return DropdownMenuItem(
                      value: e.id,
                      child: Text(e.value, style: TextStyle(fontSize: Dimentions.font20),),
                    );
                  }).toList(),
                  onChanged: (value){
                    setState(() {
                      _selectedStatus = value as String;
                    });
                  }
              ),

              SizedBox(height: Dimentions.height15,),

              MyTextFieldReg(
                controller: namaUserController,
                hintText: "Nama User",
                prefixIcon: const Icon(Icons.supervised_user_circle),
                validator: (value){
                  if(value!.isEmpty){
                    return "*masukkan nama user";
                  }
                  return null;
                },
              ),
              SizedBox(height: Dimentions.height15,),
              TextFormField(
                controller: noPhoneController,
                validator: (value){
                  if(value!.isEmpty){
                    return '*masukkan nomor ponsel';
                  }
                  if(value.length < 10){
                    return '*nomor ponsel tidak sah';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'\d'),
                  ),
                  FilteringTextInputFormatter.deny(
                    RegExp(r'^0+'),
                  ),
                ],
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: TextStyle(
                  fontSize: Dimentions.font20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
                  enabledBorder:  const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText: "812-xxxx-xxxx",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20),
                  suffixIcon: const Icon(Icons.phone_android),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: Dimentions.width15, top: Dimentions.screenHeight/62, right: Dimentions.width5),
                    child: InkWell(
                      onTap: (){
                        showCountryPicker(
                            context: context,
                            countryListTheme:  CountryListThemeData(
                              bottomSheetHeight: Dimentions.heightSize400,
                            ),
                            onSelect: (value){
                              setState(() {
                                selectCountry = value;
                              });
                            }
                        );
                      },
                      child: Text(
                        "${selectCountry.flagEmoji} +${selectCountry.phoneCode}",
                        style: TextStyle(
                            fontSize: Dimentions.font20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Dimentions.height15,),
              SizedBox(
                width: double.infinity,
                height: Dimentions.height40,
                child: ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                      getService.loading(context);

                      String number = "+${selectCountry.phoneCode}${noPhoneController.text}";

                      List<Map<String, dynamic>> listGroupUser = [
                        GroupModel(status: _selectedStatus, namaGroup: getGroup.namaGroup, groupId: getGroup.groupId).toMapUpload(),
                      ];

                      UserMasterModel setUser = UserMasterModel(
                        phone: number,
                        nama: namaUserController.text,
                        createDate: DateTime.now(),
                        groupMap: listGroupUser,
                      );

                      getService.createDataToDb(data: setUser.toMapUpload(), context: context, collection: Collections.usermaster, guid: number);

                      Navigator.of(context).pop();
                      Navigator.pop(context);
                      showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil menambahkan user", title: "New User");
                    }
                  },
                  child: BigText(text: "Tambah", color: Colors.white,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}