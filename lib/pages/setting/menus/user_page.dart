// ignore_for_file: depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/function_halpers.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../halper/route_halper.dart';
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

class UserSettingPage extends StatefulWidget {
  const UserSettingPage({Key? key}) : super(key: key);

  @override
  State<UserSettingPage> createState() => _UserSettingPageState();
}

class _UserSettingPageState extends State<UserSettingPage> {
  final AppServices getService = AppServices();
  final FunHelp getHelp = FunHelp();
  final TextEditingController searchController = TextEditingController();
  late String searchKey = "";

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Pengaturan User', style: TextStyle(color: Colors.black87),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87,),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: Dimentions.width15, right: Dimentions.width15, bottom: Dimentions.height10),
              child: MyTextFieldReg(
                controller: searchController,
                hintText: "Temukan User...",
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
                stream: getService.streamObjGetCollection(collection: Collections.users),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const DataNotFoundWidget(msgTop: "User Tidak Ditemukan");
                  }else{
                    var groupsDoc = snapshot.data!.docs;
                    List<UserModel> getListUser = groupsDoc.map((e){
                      Map<String, dynamic> getMap = e.data() as Map<String, dynamic>;
                      UserModel group = UserModel.fromMap(getMap);
                      return group;
                    }).toList();

                    getListUser = getListUser.where((UserModel data) =>
                      data.namaLengkap.toLowerCase().contains(searchKey.toLowerCase()) ||
                      data.namaLengkap.toLowerCase().startsWith(searchKey.toLowerCase()) ||
                      data.namaLengkap.toLowerCase().endsWith(searchKey.toLowerCase())
                    ).toList();

                    if(getListUser.isNotEmpty){
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: getListUser.length,
                          itemBuilder: (context, index){
                            UserModel getUser = getListUser[index];
                            String userType = getUser.userType.toLowerCase();
                            int setType = getHelp.checkStatusUser(userType);

                            var month = DateFormat('MMMM').format(getUser.createDate!);

                            return GestureDetector(
                              onTap: (){
                                Get.toNamed(RouteHalper.getPersonalInfoPage(userId: getUser.id));
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
                                              image: getUser.imgProfilUrl.isNotEmpty ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: CachedNetworkImageProvider(getUser.imgProfilUrl,),
                                              ) : const DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(Assets.imagePrifil)
                                              ),
                                          ),
                                        ),
                                        getUser.imgProfilUrl.isNotEmpty ? Positioned.fill(
                                          child: Center(
                                            child: FutureBuilder(
                                                future: precacheImage(CachedNetworkImageProvider(getUser.imgProfilUrl,), context),
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
                                                  Flexible(child: BigText(text: getUser.namaLengkap)),
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
                                              SmallText(text: getUser.phone),
                                              SizedBox(height: Dimentions.height6,),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  IconAndTextWidget(
                                                      icon: Icons.account_circle,
                                                      text: getUser.flagActive == "N" ? "Blokir" : "Aktif",
                                                      iconColor: AppColors.iconColor1
                                                  ),
                                                  IconAndTextWidget(
                                                      icon: Icons.calendar_month_outlined,
                                                      text: "${getUser.createDate!.day} $month ${getUser.createDate!.year}",
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
                      );
                    }else{
                      return const DataNotFoundWidget(msgTop: "User Tidak Ditemukan");
                    }
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
