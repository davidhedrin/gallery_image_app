import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: Dimentions.height15, right: Dimentions.height15, top: Dimentions.height6),
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
                              Flexible(child: BigText(text: "David Simbolon", size: Dimentions.font22,)),
                              SizedBox(width: Dimentions.width10,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: Dimentions.height6, vertical: Dimentions.height2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(Dimentions.radius6),
                                ),
                                child: Text(
                                  "M. Admin",
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
                          BigText(text: "+6282110863133", size: Dimentions.font16,),
                          SizedBox(height: Dimentions.height2,),
                          BigText(text: "davidhedrin123@gmail.com", size: Dimentions.font16,),
                          SizedBox(height: Dimentions.height15,),
                          Row(
                            children: [
                              Flexible(child: BigText(text: "user-8494c080-ab83-****-***....", size: Dimentions.font14, fontWeight: FontWeight.bold,)),
                              SizedBox(width: Dimentions.width10,),
                              Icon(Icons.copy, size: Dimentions.iconSize20,),
                              SizedBox(width: Dimentions.width5,),
                              Icon(Icons.remove_red_eye, size: Dimentions.iconSize20,),
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
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/flutter-gallery-app-45b50.appspot.com/o/imageProfile%2Fuser-8494c080-ab83-11ed-bc26-057ccc836471?alt=media&token=51bfd54b-0df6-44fa-8e1d-d453065b70b1"),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: Dimentions.height12,),
              const Divider(height: 1, color: Colors.black87),
              SizedBox(height: Dimentions.height12,),

              setInfos(
                desc: "Tanggal terdaftar: ",
                text: "${DateTime.now().day} ${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().year}",
                icon: Icons.calendar_month_outlined
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget setInfos({required String desc, required String text, IconData? icon}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SmallText(text: desc, size: Dimentions.font16,),
            BigText(text: text, size: Dimentions.font16,),
          ],
        ),
        icon != null ? Icon(icon) : const SizedBox(),
      ],
    );
  }
}
