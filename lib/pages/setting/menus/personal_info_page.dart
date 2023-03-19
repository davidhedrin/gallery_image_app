// ignore_for_file: depend_on_referenced_packages

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../generated/assets.dart';
import '../../../halper/function_halpers.dart';
import '../../../halper/route_halper.dart';
import '../../../models/posting_image.dart';
import '../../../models/user_group.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/collections.dart';
import '../../../widgets/data_not_found.dart';
import '../../../widgets/loading_progres.dart';

class PersonalInfoPage extends StatefulWidget {
  final String uid;
  const PersonalInfoPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final AppServices getService = AppServices();
  final FunHelp getHelp = FunHelp();
  late String userId;

  @override
  void initState() {
    // TODO: implement initState
    userId = widget.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Personal Info', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: Dimentions.height10, right: Dimentions.height10, top: Dimentions.height2),
        child: StreamBuilder<DocumentSnapshot <Map <String, dynamic>>>(
          stream: getService.streamBuilderGetDoc(collection: Collections.users, docId: userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if(!snapshot.hasData){
              return const Center(child: DataNotFoundWidget(msgTop: "Data tidak ditemukan!",));
            }else{
              var data = snapshot.data;
              Map<String, dynamic> userMap = data!.data() as Map<String, dynamic>;
              UserModel getUser = UserModel.fromMap(userMap);
              String userType = getUser.userType.toLowerCase();
              int setType = getHelp.checkStatusUser(userType);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(Dimentions.height10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Dimentions.radius12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(child: BigText(text: getUser.namaLengkap, size: Dimentions.font22,)),
                                    SizedBox(width: Dimentions.width10,),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: Dimentions.height6, vertical: Dimentions.height2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(Dimentions.radius6),
                                      ),
                                      child: Text(
                                        setType == 1 ? "M. Admin" : setType == 2 ? "Admin" : "User",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Dimentions.font12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimentions.height10,),
                                BigText(text: getUser.phone, size: Dimentions.font16,),
                                SizedBox(height: Dimentions.height2,),
                                BigText(text: getUser.email, size: Dimentions.font16,),
                                SizedBox(height: Dimentions.height15,),
                                Row(
                                  children: [
                                    Flexible(child: BigText(text: "${getUser.id.substring(0, 23)}-****....", size: Dimentions.font14, fontWeight: FontWeight.bold,)),
                                    SizedBox(width: Dimentions.width10,),
                                    InkWell(
                                      onTap: (){
                                        Clipboard.setData(ClipboardData(text: getUser.id));

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('ID user telah berhasil disalin'),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.copy, size: Dimentions.iconSize20,)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: Dimentions.heightSize90,
                            width: Dimentions.heightSize90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimentions.radius20),
                              color: const Color(0xFF9294cc),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: getUser.imgProfilUrl,
                              placeholder: (context, url) => LoadingProgress(size: Dimentions.height10,),
                              errorWidget: (context, url, error){
                                return Image.asset(
                                  Assets.imageBackgroundProfil,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                              imageBuilder: (context, imageProvider) => Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimentions.radius20),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimentions.height12,),
                    const Divider(height: 1, color: Colors.black87),

                    setInfos(
                      desc: "Tanggal terdaftar   : ",
                      text: "${getUser.createDate!.day} ${DateFormat('MMMM').format(getUser.createDate!)} ${getUser.createDate!.year}",
                      icon: Icons.calendar_month_outlined
                    ),
                    StreamBuilder(
                      stream: getService.streamBuilderGetDoc(collection: Collections.usermaster, docId: getUser.phone),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshotGroup) {
                        if (snapshotGroup.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshotGroup.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }else{
                          List<Map<String, dynamic>> groupArray = List.from(snapshotGroup.data!.get("group"));
                          List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
                            UserGroupModel getGroup = UserGroupModel.fromMap(res);
                            return getGroup;
                          }).toList();

                          return setInfos(
                              desc: "Group's terdaftar   : ",
                              icon: Icons.group,
                              column: toModelGroup.map((e) => e.namaGroup).toList(),
                          );
                        }
                      }
                    ),

                    SizedBox(height: Dimentions.height10,),
                    BigText(text: "Postingan: ", size: Dimentions.font14,),
                    SizedBox(height: Dimentions.height4,),
                    SizedBox(
                      height: Dimentions.heightSize420,
                      child: FutureBuilder<List<PostingImageModel>>(
                        future: getService.getAllDocImagePosting(context: context, phone: getUser.phone, userId: userId),
                        builder: (BuildContext context, AsyncSnapshot<List<PostingImageModel>> snapshotImage) {
                          if (snapshotImage.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshotImage.hasError) {
                            return Center(child: DataNotFoundWidget(msgTop: 'Error: ${snapshotImage.error}'));
                          }
                          if (!snapshotImage.hasData) {
                            return const Center(child: DataNotFoundWidget(msgTop: 'Data tidak ditemukan!'));
                          } else {
                            List<PostingImageModel> documents = snapshotImage.data!;
                            if(documents.isEmpty){
                              return const Center(
                                  child: DataNotFoundWidget(
                                    msgTop: 'Belum pernah upload nichh...',
                                    msgButton: 'Silahkan Upload gambar anda sekarang!',
                                  )
                              );
                            }else{
                              return GridView.builder(
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: Dimentions.height6,
                                  mainAxisSpacing: Dimentions.height6,
                                ),
                                itemCount: documents.length,
                                itemBuilder: (context, index){
                                  PostingImageModel image = documents[index];
                                  return GestureDetector(
                                    onTap: (){
                                      Get.toNamed(RouteHalper.getDetailImage(image.imageId, image.imageGroup));
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: image.imageUrl,
                                      placeholder: (context, url) => LoadingProgress(size: Dimentions.height25,),
                                      errorWidget: (context, url, error){
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                                            image: const DecorationImage(
                                              image: AssetImage(Assets.imageBackgroundProfil),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          color: index.isEven ? const Color(0xFF69c5df) : const Color(0xFF9294cc),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          }
        ),
      ),
    );
  }

  Widget setInfos({required String desc, String? text, IconData? icon, List<String>? column}){
    return Container(
      margin: EdgeInsets.only(top: Dimentions.height15),
      padding: EdgeInsets.all(Dimentions.height10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimentions.radius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallText(text: desc, size: Dimentions.font14,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(text != null && text.isNotEmpty)
                    BigText(text: text, size: Dimentions.font14,),
                  if(column != null && column.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: column.map((e) =>
                          Padding(
                            padding: EdgeInsets.only(bottom: column.last != e ? Dimentions.height4 : 0.0),
                            child: BigText(text: "- $e", size: Dimentions.font14,),
                          ),
                      ).toList(),
                    ),
                ],
              ),
            ],
          ),
          icon != null ? Icon(icon) : const SizedBox(),
        ],
      ),
    );
  }
}
