import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/data_not_found.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../providers/app_services.dart';
import '../../utils/utils.dart';
import '../../widgets/app_icon.dart';

class AccountPageMenu extends StatefulWidget {
  final String uid;
  const AccountPageMenu({Key? key, required this.uid}) : super(key: key);

  @override
  State<AccountPageMenu> createState() => _AccountPageMenuState();
}

class _AccountPageMenuState extends State<AccountPageMenu> {
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;
  final FirebaseAuth userAuth = FirebaseAuth.instance;
  final AppServices getService = AppServices();

  @override
  Widget build(BuildContext context) {
    double coverHeight = Dimentions.imageSize180;
    double profileSize = Dimentions.screenHeight/14.5;

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
        body: Column(
            children: <Widget> [
              StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
                  stream: getService.streamBuilderGetDoc(collection: "users", docId: widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Container(child: CircularProgressIndicator()));
                    }
                    if(!snapshot.hasData){
                      return DataNotFoundWidget(msgTop: "Data tidak ditemukan!",);
                    }
                    else{
                      var data = snapshot.data;
                      return Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: profileSize + Dimentions.height15),
                                color: Colors.grey,
                                child: data!.data()!.containsKey("img_cover_url") ? data.get("img_cover_url").toString().isNotEmpty ? Image.network(
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

                              // Icons Widget
                              Positioned(
                                top: Dimentions.height45,
                                left: Dimentions.width20,
                                right: Dimentions.width20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Get.toNamed(RouteHalper.getEditAccountPage(uid: widget.uid));
                                      },
                                      child: AppIcon(icon: Icons.edit),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: coverHeight - profileSize,
                                child: CircleAvatar(
                                  radius: profileSize + 5,
                                  backgroundColor: Colors.white,
                                  child: data.data()!.containsKey("img_profil_url") ? data.get("img_profil_url").toString().isNotEmpty ? CircleAvatar(
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
                              ),
                            ],
                          ),
                          SizedBox(height: Dimentions.height10,),
                          Text(data.get("nama_lengkap"), style: TextStyle(fontSize: Dimentions.font22, fontWeight: FontWeight.bold)),
                          SmallText(text: data.get("phone"), color: Colors.black87, size: Dimentions.font16,),
                        ],
                      );
                    }
                  }
              ),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 3, // number of columns in the grid
                  children: [
                    Padding(
                      padding: EdgeInsets.all(Dimentions.height2),
                      child: Image.asset(
                        Assets.imageMakanan,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Dimentions.height2),
                      child: Image.asset(
                        Assets.imageMakanan,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Dimentions.height2),
                      child: Image.asset(
                        Assets.imageMakanan,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Dimentions.height2),
                      child: Image.asset(
                        Assets.imageMakanan,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ]
        ),

      ),
    );
  }
}
