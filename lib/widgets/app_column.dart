import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/posting_image.dart';
import '../providers/app_services.dart';
import '../utils/colors.dart';
import '../utils/dimentions.dart';
import 'big_text.dart';
import 'icon_and_text_widget.dart';

class AppColumn extends StatefulWidget {
  final String? groupName;
  final PostingImageModel? dataImage;
  const AppColumn({Key? key, this.dataImage, this.groupName}) : super(key: key);

  @override
  State<AppColumn> createState() => _AppColumnState();
}

class _AppColumnState extends State<AppColumn> {
  final AppServices getService = AppServices();

  @override
  Widget build(BuildContext context) {
    var month = DateFormat('MMMM').format(widget.dataImage.isNull ? DateTime.now() : widget.dataImage!.tanggal!);
    var setDiffDate = widget.dataImage.isNull ? DateTime.now().difference(DateTime.now()) : DateTime.now().difference(widget.dataImage!.uploadDate!);
    var diffDayUpload = setDiffDate.inDays.toString() != "0" ? "${setDiffDate.inDays}h" : "";
    var difference = widget.dataImage.isNull ? "-" : "$diffDayUpload ${setDiffDate.inHours}j";

    bool containsDocId(List<QueryDocumentSnapshot<Object?>> querySnapshot) {
      for (QueryDocumentSnapshot docSnapshot in querySnapshot) {
        if (docSnapshot.id == MainAppPage.setUserId) {
          return true;
        }
      }
      return false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: BigText(text: widget.dataImage.isNull ? "Title Image" : widget.dataImage!.title, size: Dimentions.font26,)),
            widget.dataImage.isNull ? BigText(
              text: "-", color: Colors.black45,
            ) : StreamBuilder<QuerySnapshot>(
                stream: getService.streamGetCollecInColect(collection1: widget.groupName!, collection2: "likes", docId: widget.dataImage!.imageId),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return BigText(text: "-", color: Colors.black45,);
                  }
                  if (!snapshot.hasData) {
                    return BigText(text: "-", color: Colors.black45,);
                  }else{
                    var likeData = snapshot.data!.docs;
                    bool idLikeExists = containsDocId(likeData);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BigText(text: likeData.length.toString(), color: Colors.black45,),
                        SizedBox(width: Dimentions.height2,),
                        InkWell(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Icon(Icons.thumb_up, color: idLikeExists == true ? Colors.blue : Colors.grey,)
                        ),
                      ],
                    );
                  }
                }
            ),

          ],
        ),
        SizedBox(height: Dimentions.height6,),
        Row(
          children: [
            // Wrap(
            //   children: List.generate(5, (index) {
            //     return Icon(Icons.star, color: AppColors.mainColor, size: 15,);
            //   }),
            // ),
            SizedBox(width: Dimentions.height6,),
            SmallText(text: widget.dataImage.isNull ? "upload date" : "${widget.dataImage!.tanggal!.day} $month ${widget.dataImage!.tanggal!.year}"),
            // SizedBox(width: Dimentions.height10,),
            // SmallText(text: "1287"),
            // SizedBox(width: Dimentions.height10,),
            // SmallText(text: "Comments"),
          ],
        ),
        SizedBox(height: Dimentions.height6,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconAndTextWidget(icon: Icons.account_circle, text: widget.dataImage.isNull ? "-" : widget.dataImage!.userByName, iconColor: AppColors.iconColor1),
            IconAndTextWidget(
              icon: widget.dataImage.isNull ? Icons.remove_red_eye : widget.dataImage!.pemirsa == "1" ? Icons.people_outline : Icons.lock,
              text: widget.dataImage.isNull ? "-" : widget.dataImage!.pemirsa == "1" ? "Public" : "Private",
              iconColor: AppColors.mainColor
            ),
            IconAndTextWidget(icon: Icons.access_time_rounded, text: difference, iconColor: AppColors.iconColor2),
          ],
        )
      ],
    );
  }
}
