import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/pages/setting/menus/group_page.dart';
import 'package:delivery_food_app/pages/setting/menus/group_panel_manage.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/main_app_page.dart';
import '../../halper/function_halpers.dart';
import '../../models/user_group.dart';
import '../../models/user_group_master_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/colors.dart';
import '../../utils/utils.dart';
import '../../widgets/big_text.dart';
import '../../widgets/data_not_found.dart';
import '../../widgets/small_text.dart';

class SettingPageMenu extends StatefulWidget {
  const SettingPageMenu({Key? key}) : super(key: key);

  @override
  State<SettingPageMenu> createState() => _SettingPageMenuState();
}

class _SettingPageMenuState extends State<SettingPageMenu> {
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();
  final FunHelp getHelp = FunHelp();
  final String _userId = MainAppPage.setUserId;

  late UserModel lateCurrentUser = UserModel();

  Color generateRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool check = false;
        await onBackButtonPressYesNo(context: context, text: "Keluar Aplikasi!", desc: "Yakin ingin keluar dari aplikasi?").then((value){
          check = value;
        });
        if(check){
          exit(0);
        }
        return check;
      },
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
            stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: _userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if(!snapshot.hasData){
                return const DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
              }else{
                var data = snapshot.data;
                Map<String, dynamic> userMap = data!.data() as Map<String, dynamic>;
                UserModel getUser = UserModel.fromMap(userMap);
                String userType = getUser.user_type.toLowerCase();
                int setType = getHelp.checkStatusUser(userType);

                lateCurrentUser = getUser;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.only(top: Dimentions.height15, left: Dimentions.height20, right: Dimentions.height20),
                      leading: data.data()!.containsKey("img_cover_url") ? data.get("img_cover_url").toString().isNotEmpty ? CircleAvatar(
                        radius: Dimentions.radius30,
                        backgroundImage: CachedNetworkImageProvider(getUser.img_profil_url),
                      ) : CircleAvatar(
                        radius: Dimentions.radius30,
                        backgroundImage: const AssetImage(Assets.imageBackgroundProfil),
                      ) : CircleAvatar(
                        radius: Dimentions.radius30,
                        backgroundImage: const AssetImage(Assets.imageBackgroundProfil),
                      ),
                      title: BigText(text: getUser.nama_lengkap, size: Dimentions.font20),
                      subtitle: Text(getUser.phone),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimentions.width8, vertical: Dimentions.width5),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          setType == 1 ? "M. Admin" : setType == 2 ? "Admin" : "User",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Dimentions.font16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, top: Dimentions.height10),
                      child: Divider(thickness: 1.5, height: Dimentions.height6,),
                    ),

                    Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              iconTitle(
                                  icon: Icons.person,
                                  iconColor: Colors.blue,
                                  boxColor: Colors.green,
                                  text: "Personal",
                                  action: (){

                                  }
                              ),
                              iconTitle(
                                  icon: Icons.password,
                                  iconColor: Colors.green,
                                  boxColor: Colors.blue,
                                  text: "Password",
                                  action: (){

                                  }
                              ),
                              iconTitle(
                                  icon: Icons.logout_outlined,
                                  iconColor: Colors.redAccent,
                                  boxColor: Colors.deepPurple,
                                  text: "Keluar",
                                  action: () async {
                                    bool check = false;
                                    await onBackButtonPressYesNo(context: context, text: "Putuskan Koneksi!", desc: "Yakin ingin memutuskan koneksi?").then((value){
                                      check = value;
                                    });
                                    if(check){
                                      getService.setStatus(status: "2", userId: _userId);
                                      getService.logout();
                                    }
                                  },
                              ),

                              SizedBox(height: Dimentions.height25,),
                              Padding(
                                padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height2),
                                child: Align(alignment: Alignment.centerLeft, child: SmallText(text: "Group Panel", color: Colors.black54,)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
                                child: Divider(thickness: 1.5, height: Dimentions.height6,),
                              ),

                              setType == 1 ? StreamBuilder<QuerySnapshot>(
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
                                        return Column(
                                          children: getListGroup.map((UserGroupMasterModel group) {
                                            UserGroupModel setGroupMaster = UserGroupModel(
                                              group_id: group.group_id,
                                              nama_group: group.nama_group,
                                              status: 'MDM'
                                            );

                                            return iconTitle(
                                                icon: Icons.group,
                                                iconColor: generateRandomColor(),
                                                boxColor: generateRandomColor(),
                                                text: setGroupMaster.nama_group,
                                                action: (){
                                                  Get.to(() => GroupPanelManage(groupModel: setGroupMaster, currentUser: getUser,));
                                                }
                                            );
                                          }).toList(),
                                        );
                                      }else{
                                        return const DataNotFoundWidget(msgTop: "Group Tidak Ditemukan");
                                      }
                                    }
                                  }
                              ) : StreamBuilder<DocumentSnapshot>(
                                stream: getService.streamBuilderGetDoc(collection: Collections.usermaster, docId: getUser.phone),
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

                                    return Column(
                                      children: toModelGroup.map((UserGroupModel group) {
                                        return iconTitle(
                                            icon: Icons.group,
                                            iconColor: generateRandomColor(),
                                            boxColor: generateRandomColor(),
                                            text: group.nama_group,
                                            action: (){
                                              Get.to(() => GroupPanelManage(groupModel: group, currentUser: getUser));
                                            }
                                        );
                                      }).toList(),
                                    );
                                  }
                                }
                              ),

                              setAdmMaster(setType),
                            ],
                          ),
                        )
                    ),
                  ],
                );
              }
            }
          ),
        ),
      )
    );
  }

  Widget setAdmMaster(int type){
    if(type ==  1){
      return Column(
        children: [
          SizedBox(height: Dimentions.height25,),
          Padding(
            padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height2),
            child: Align(alignment: Alignment.centerLeft, child: SmallText(text: "Master Panel", color: Colors.black54,)),
          ),
          Padding(
            padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
            child: Divider(thickness: 1.5, height: Dimentions.height6,),
          ),

          iconTitle(
              icon: Icons.supervised_user_circle_sharp,
              iconColor: Colors.black87,
              boxColor: Colors.purple,
              text: "Group",
              action: (){
                Get.to(() => GroupSettingPage(currentUser: lateCurrentUser));
              }
          ),
          iconTitle(
              icon: Icons.people_alt_outlined,
              iconColor: Colors.black87,
              boxColor: Colors.orangeAccent,
              text: "User",
              action: (){
                Get.toNamed(RouteHalper.getUserSettingPage());
              }
          ),
        ],
      );
    }else{
      return const Text("");
    }
  }

  Widget iconTitle({required IconData icon, required Color boxColor, required Color iconColor, required String text, void Function()? action}){
    return GestureDetector(
      onTap: action,
      child: ListTile(
        contentPadding: EdgeInsets.only(top: Dimentions.height15, left: Dimentions.width20, right: Dimentions.width20),
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
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black87, size: Dimentions.font20,),
      ),
    );
  }
}
