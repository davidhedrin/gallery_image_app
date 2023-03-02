import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../generated/assets.dart';
import '../splashScreen//fade_animation.dart';

class OnBoardScreenApp extends StatefulWidget {
  const OnBoardScreenApp({Key? key}) : super(key: key);

  @override
  State<OnBoardScreenApp> createState() => _OnBoardScreenAppState();
}

class _OnBoardScreenAppState extends State<OnBoardScreenApp> {
  final store = GetStorage();
  late PageController _pageController = PageController();
  int totalPage = 4;

  void _onScroll() {
  }
  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(
      initialPage: 0,
    )..addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          makePage(
              page: 1,
              image: Assets.onBoard1,
              title: 'Selamat Datang DiFamilly Gallery',
              description: 'Hal terbaik mengenai sebuah gambar adalah gambar itu tidak pernah berubah, bahkan ketika orang-orang yang ada di dalamnya sudah berubah. Akan selalu ada suka atau tidak suka dalam fotografi, tetapi tidak akan pernah ada benar atau salah dalam fotografi'
          ),
          makePage(
              page: 2,
              image: Assets.onBoard2,
              title: 'Kenangan Besar Tersayang',
              description: 'Cahaya membuat apa yang tidak terlihat menjadi terlihat dan gambar memberikan apa yang orang lain inginkan untuk dilihat. Dan dibalik sebuah foto, mengajarkan kita bahwa selamanya senyuman itu indah dan marah itu buruk'
          ),
          makePage(
              page: 3,
              image: Assets.onBoard3,
              title: 'Memori Yang Tersimpan',
              description: "Kita tidak dapat memaksakan semua orang untuk menyukai hasil karya kita. Yang dapat kita lakukan adalah menyukai karya foto yang telah kita buat. Sebuah foto adalah rahasia tentang rahasia. Semakin ia memberitahu Anda makin sedikit Anda tahu."
          ),
          makePage(
              page: 4,
              image: Assets.onBoard4,
              title: 'Tersenyumlah Bersama',
              description: "Gambar-gambar yang terbaik adalah gambar yang dapat mempertahankan kekuatannya dan memiliki dampak selama bertahun-tahun, terlepas dari berapa kali gambar itu dilihat. Sebab foto adalah cara di mana kita merasa, menyentuh, dan mencintai."
          ),
        ],
      ),
    );
  }

  Widget makePage({image, title, description, page}) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover
          )
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                stops: const [0.3, 0.9],
                colors: [
                  Colors.black.withOpacity(.9),
                  Colors.black.withOpacity(.2),
                ]
            )
        ),
        child: Padding(
          padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, bottom: Dimentions.height20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: Dimentions.height40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wallet_membership_sharp,
                          color: Colors.white,
                        ),
                        SizedBox(width: Dimentions.width5,),
                        Text("Gallery", style: TextStyle(color: Colors.white, fontSize: Dimentions.font15),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        FadeAnimation(0.3, Text(page.toString(), style: TextStyle(color: Colors.white, fontSize: Dimentions.font30, fontWeight: FontWeight.bold),)),
                        Text('/$totalPage', style: TextStyle(color: Colors.white, fontSize: Dimentions.font15),)
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FadeAnimation(1,
                          Text(title, style: TextStyle(color: Colors.white, fontSize: Dimentions.font50, height: Dimentions.height1kom2, fontWeight: FontWeight.bold),)
                      ),
                      SizedBox(height: Dimentions.height20,),
                      FadeAnimation(1.5, Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: Dimentions.width3),
                            child: Icon(Icons.star, color: Colors.yellow, size: Dimentions.iconSize15,),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: Dimentions.width3),
                            child: Icon(Icons.star, color: Colors.yellow, size: Dimentions.iconSize15,),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: Dimentions.width3),
                            child: Icon(Icons.star, color: Colors.yellow, size: Dimentions.iconSize15,),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: Dimentions.width3),
                            child: Icon(Icons.star, color: Colors.yellow, size: Dimentions.iconSize15,),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: Dimentions.width5),
                            child: Icon(Icons.star, color: Colors.yellow, size: Dimentions.iconSize15,),
                          ),
                          Text('5.0', style: TextStyle(color: Colors.white70),),
                        ],
                      )),
                      SizedBox(height: Dimentions.height10,),
                      FadeAnimation(2, Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Text(description, style: TextStyle(color: Colors.white.withOpacity(.7), height: Dimentions.height1kom9, fontSize: Dimentions.font15),),
                      )),
                      SizedBox(height: Dimentions.height15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(page == 4 ? "Lanjutkan -->" : "Geser berikutnya >>", style: TextStyle(color: Colors.white, fontSize: Dimentions.font15),),
                          page == 4 ? ElevatedButton(
                            onPressed: (){
                              Get.toNamed(RouteHalper.loginPage);
                              store.write('onBoarding', true);
                            },
                            child: Text('Login', style: TextStyle(color: Colors.white, fontSize: Dimentions.font15),),
                          ) : const Text(""),
                        ],
                      ),
                    ],
                  ),
                )
              ]
          ),
        ),
      ),
    );
  }
}