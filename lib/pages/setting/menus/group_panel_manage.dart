import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/user_group.dart';
import '../../../models/user_master_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/collections.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimentions.dart';
import '../../../widgets/auth_widget/text_widget.dart';
import '../../../widgets/big_text.dart';
import '../../../widgets/data_not_found.dart';
import '../../../widgets/icon_and_text_widget.dart';
import '../../../widgets/loading_progres.dart';
import '../../../widgets/small_text.dart';

class GroupPanelManage extends StatefulWidget {
  final UserGroupModel groupModel;
  const GroupPanelManage({Key? key, required this.groupModel}) : super(key: key);

  @override
  State<GroupPanelManage> createState() => _GroupPanelManagState();
}

class _GroupPanelManagState extends State<GroupPanelManage> {
  final AppServices getService = AppServices();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserGroupModel getGroup = widget.groupModel;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Group "${getGroup.nama_group}"', style: const TextStyle(color: Colors.black87),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87,),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            getGroup.status == "ADM" ? IconButton(
              icon: Icon(Icons.add, color: Colors.black87, size: Dimentions.iconSize32,),
              onPressed: () {

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

                        List<UserMasterModel> getUser = getListGroup.expand((parent) => parent.group!).where((child) => child.group_id == getGroup.group_id).map((child) => getListGroup.firstWhere((parent) => parent.group!.contains(child))).toList();

                        if(getUser.isEmpty){
                          return Padding(
                            padding: EdgeInsets.only(top: Dimentions.height45),
                            child: const DataNotFoundWidget(msgTop: "Belum ada user didaftarkan", msgButton: "Tambahkan user kedalam group anda!",),
                          );
                        }else{
                          return ListView.builder(
                              padding: EdgeInsets.only(top: Dimentions.height15),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: getUser.length,
                              itemBuilder: (context, index){
                                UserMasterModel getDataUser = getUser[index];
                                return GestureDetector(
                                  onTap: (){
                                  },
                                  child: StreamBuilder<QuerySnapshot>(
                                      stream: getService.streamGetDocByColumn(collection: Collections.users, collName: "phone", value: getDataUser.phone),
                                      builder: (context, snapshotUser) {
                                        if (snapshotUser.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if(!snapshotUser.hasData){
                                          return const Text("Data tidak ditemukan!",);
                                        }else{
                                          var data = snapshotUser.data!.docs.first;
                                          Map<String, dynamic> getMap = data.data() as Map<String, dynamic>;
                                          UserModel userModel = UserModel.fromMap(getMap);
                                          String userType = userModel.user_type.toLowerCase();
                                          int setType = userType == "mdm" ? 1 : userType == "adm" ? 2 : 3;

                                          var month = DateFormat('MMMM').format(userModel.create_date!);

                                          return Container(
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
                                                          color: index.isEven ? Color(0xFF69c5df) : Color(0xFF9294cc),
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(userModel.img_profil_url,),
                                                          )
                                                      ),
                                                    ),
                                                    Positioned.fill(
                                                      child: Center(
                                                        child: FutureBuilder(
                                                            future: precacheImage(NetworkImage(userModel.img_profil_url,), context),
                                                            builder: (BuildContext context, AsyncSnapshot snapshot){
                                                              if (snapshot.connectionState == ConnectionState.done) {
                                                                return SizedBox.shrink();
                                                              } else {
                                                                return LoadingProgress(size: Dimentions.height15,);
                                                              }
                                                            }
                                                        ),
                                                      ),
                                                    ),
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
                                                              Flexible(child: BigText(text: userModel.nama_lengkap)),
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
                                                          SmallText(text: userModel.phone),
                                                          SizedBox(height: Dimentions.height6,),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              IconAndTextWidget(
                                                                icon: Icons.account_circle,
                                                                text: userModel.flag_active == "N" ? "Blokir" : "Aktif",
                                                                iconColor: AppColors.iconColor1
                                                              ),
                                                              IconAndTextWidget(
                                                                icon: Icons.calendar_month_outlined,
                                                                text: "${userModel.create_date!.day} $month ${userModel.create_date!.year}",
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
                                          );
                                        }
                                      }
                                  ),
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
}
