// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/user_group.dart';
import '../../../models/user_group_master_model.dart';
import '../../../models/user_master_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/dimentions.dart';
import '../../../utils/utils.dart';
import '../../../widgets/auth_widget/text_widget.dart';
import 'group_panel_manage.dart';

class GroupSettingPage extends StatefulWidget {
  final UserModel currentUser;

  const GroupSettingPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<GroupSettingPage> createState() => _GroupSettingPageState();
}

class _GroupSettingPageState extends State<GroupSettingPage> {
  final AppServices getService = AppServices();
  final TextEditingController searchController = TextEditingController();
  late String searchKey = "";

  Color generateRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel curUser = widget.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Pengaturan Group', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black87, size: Dimentions.iconSize32,),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context){
                  return const AddNewGroup();
                }
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, bottom: Dimentions.height10),
            child: MyTextFieldReg(
              controller: searchController,
              hintText: "Temukan Group...",
              prefixIcon: const Icon(Icons.search),
              onChanged: (value){
                setState(() {
                  searchKey = value;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getService.streamObjGetCollection(collection: Collections.usergroup),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const DataNotFoundWidget(msgTop: "Group Tidak Ditemukan");
                }else{
                  var groupsDoc = snapshot.data!.docs;
                  List<UserGroupMasterModel> getListGroup = groupsDoc.map((e){
                    Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                    UserGroupMasterModel group = UserGroupMasterModel.fromMap(getMap);
                    return group;
                  }).toList();

                  getListGroup = getListGroup.where((UserGroupMasterModel data) =>
                    data.namaGroup.toLowerCase().contains(searchKey.toLowerCase()) ||
                    data.namaGroup.toLowerCase().startsWith(searchKey.toLowerCase()) ||
                    data.namaGroup.toLowerCase().endsWith(searchKey.toLowerCase())
                  ).toList();

                  if(getListGroup.isNotEmpty){
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: getListGroup.length,
                        itemBuilder: (context, index){
                          UserGroupMasterModel getGroup = getListGroup[index];
                          var month = DateFormat('MMMM').format(getGroup.createDate!);
                          return StreamBuilder<QuerySnapshot>(
                            stream: getService.streamObjGetCollection(collection: Collections.usermaster),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text("");
                              }
                              if (!snapshot.hasData) {
                                return const Text("");
                              }else{
                                var userGroup = snapshot.data!.docs;
                                List<UserMasterModel> getListGroup = userGroup.map((e){
                                  Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                                  UserMasterModel images = UserMasterModel.fromMap(getMap);
                                  return images;
                                }).toList();

                                var getCount = getListGroup.expand((parent) => parent.group!).where((child) => child.groupId == getGroup.groupId).map((child) => getListGroup.firstWhere((parent) => parent.group!.contains(child))).toList();

                                UserGroupModel groupModel = UserGroupModel(
                                  groupId: getGroup.groupId,
                                  namaGroup: getGroup.namaGroup,
                                  status: 'MDM'
                                );

                                return iconTitle(
                                  groupModel: groupModel,
                                  icon: Icons.supervised_user_circle_sharp,
                                  iconColor: generateRandomColor(),
                                  boxColor: generateRandomColor(),
                                  text: getGroup.namaGroup,
                                  count: getCount.length.toString(),
                                  subText: "${getGroup.createDate!.day} $month ${getGroup.createDate!.year}",
                                  action: (){
                                    Get.to(() => GroupPanelManage(groupModel: groupModel, currentUser: curUser,));
                                  }
                                );
                              }
                            }
                          );
                        }
                    );
                  }else{
                    return const DataNotFoundWidget(msgTop: "Group Tidak Ditemukan");
                  }
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget iconTitle({
    required UserGroupModel groupModel,
    required IconData icon,
    required Color boxColor,
    required Color iconColor,
    required String text,
    required String count,
    void Function()? action,
    String? subText = "",
  }){
    return GestureDetector(
      onTap: action,
      child: Container(
        margin: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, bottom: Dimentions.height10),
        padding: EdgeInsets.only(top: Dimentions.height6, bottom: Dimentions.height6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
        ),
        child: ListTile(
          leading: Container(
            height: Dimentions.height45,
            width: Dimentions.height45,
            decoration: BoxDecoration(
              color: boxColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(Dimentions.radius15),
            ),
            child: Icon(icon, color: iconColor,),
          ),
          title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500),),
          trailing: int.parse(count) > 0 ? GestureDetector(
            onTap: (){},
            child: Icon(Icons.delete_forever, color: Colors.grey.withOpacity(0.5),)
          ) : GestureDetector(
            onTap: () async {
              bool check = false;
              await onBackButtonPressYesNo(context: context, text: "Hapus User", desc: "Yakin ingin menghapus user dari aplikasi?").then((value){
                check = value;
              });
              if(check){
                getService.deleteDocById(collection: Collections.usergroup, docId: groupModel.groupId);
                showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil menghapus group", title: "Delete Group");
              }
            },
            child: const Icon(Icons.delete_forever, color: Colors.redAccent),
          ),
          subtitle: subText!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimentions.height2,),
              Text("Dibuat: $subText"),
              SizedBox(height: Dimentions.height2,),
              Text("Anggota: $count"),
            ],
          ) : null,
        ),
      ),
    );
  }
}

class AddNewGroup extends StatefulWidget {
  const AddNewGroup({Key? key}) : super(key: key);

  @override
  State<AddNewGroup> createState() => _AddNewGroupState();
}

class _AddNewGroupState extends State<AddNewGroup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaGroupController = TextEditingController();
  final AppServices getService = AppServices();

  Color generateRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Group Baru", textAlign: TextAlign.center,),
      icon: Icon(Icons.supervised_user_circle, size: Dimentions.height45, color: generateRandomColor()),
      content: IntrinsicWidth(
        child: SizedBox(
          width: Dimentions.heightSize300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextFieldReg(
                  controller: namaGroupController,
                  hintText: "Nama Group",
                  prefixIcon: const Icon(Icons.supervised_user_circle),
                  validator: (value){
                    if(value!.isEmpty){
                      return "*masukkan nama group";
                    }
                    return null;
                  },
                ),
                SizedBox(height: Dimentions.height15,),
                SizedBox(
                  width: double.infinity,
                  height: Dimentions.height40,
                  child: ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        getService.loading(context);

                        String getGuid = "group-${getService.generateGuid()}";
                        DateTime cretedDate = DateTime.now();

                        UserGroupMasterModel group = UserGroupMasterModel(
                          namaGroup: namaGroupController.text,
                          groupId: getGuid,
                          createDate: cretedDate,
                        );

                        getService.createDataToDb(data: group.toMapUpload(), context: context, collection: Collections.usergroup, guid: getGuid);
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                        showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil menambahkan group", title: "New Group");
                      }
                    },
                    child: BigText(text: "Tambah", color: Colors.white,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

