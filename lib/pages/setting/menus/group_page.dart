import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/data_not_found.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../models/user_group_master_model.dart';
import '../../../models/user_master_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/dimentions.dart';
import '../../../utils/utils.dart';
import '../../../widgets/auth_widget/text_widget.dart';

class GroupSettingPage extends StatefulWidget {
  const GroupSettingPage({Key? key}) : super(key: key);

  @override
  State<GroupSettingPage> createState() => _GroupSettingPageState();
}

class _GroupSettingPageState extends State<GroupSettingPage> {
  final AppServices getService = AppServices();
  final TextEditingController searchController = TextEditingController();

  Color generateRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
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

                  if(getListGroup.isNotEmpty){
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: getListGroup.length,
                        itemBuilder: (context, index){
                          UserGroupMasterModel getGroup = getListGroup[index];
                          var month = DateFormat('MMMM').format(getGroup.create_date!);
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

                                var getCount = getListGroup.expand((parent) => parent.group!).where((child) => child.group_id == getGroup.group_id).map((child) => getListGroup.firstWhere((parent) => parent.group!.contains(child))).toList();

                                return iconTitle(
                                    icon: Icons.supervised_user_circle_sharp,
                                    iconColor: generateRandomColor(),
                                    boxColor: generateRandomColor(),
                                    text: getGroup.nama_group,
                                    count: getCount.length.toString(),
                                    subText: "${getGroup.create_date!.day} $month ${getGroup.create_date!.year}",
                                    action: (){}
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
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmallText(text: "Anggota"),
              BigText(text: count, size: Dimentions.font22,)
            ],
          ),
          subtitle: subText!.isNotEmpty ? Text("Dibuat: $subText") : null,
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
      title: Text("Tambah Group Baru", textAlign: TextAlign.center,),
      icon: Icon(Icons.supervised_user_circle, size: Dimentions.height45, color: generateRandomColor()),
      content: IntrinsicWidth(
        child: Container(
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
                          nama_group: namaGroupController.text,
                          group_id: getGuid,
                          create_date: cretedDate,
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

