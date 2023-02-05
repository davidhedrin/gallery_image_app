import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../generated/assets.dart';
import '../widgets/small_text.dart';

class OnBoardScreenApp extends StatefulWidget {
  const OnBoardScreenApp({Key? key}) : super(key: key);

  @override
  State<OnBoardScreenApp> createState() => _OnBoardScreenAppState();
}

class _OnBoardScreenAppState extends State<OnBoardScreenApp> {
  final store = GetStorage();
  double scrollerPosition = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(Assets.imageBg),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                PageView(
                  onPageChanged: (val){
                    setState(() {
                      scrollerPosition = val.toDouble();
                    });
                  },
                  children: [
                    OnBoardPage(
                      boardColumn: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(color: Colors.white, fontSize: Dimentions.screenHeight/16.03, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'U\'Gallery Image',
                            style: TextStyle(color: Colors.white, fontSize: Dimentions.screenHeight/32.03, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: Dimentions.height10,),
                          //Image.asset('assets/images/1.png', width: 220,),
                        ],
                      ),
                    ),
                    OnBoardPage(
                      boardColumn: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(Assets.image2, width: Dimentions.imageSize230,),
                          SizedBox(height: Dimentions.height10,),
                          Text(
                            'Dokumentasikan Kenangan',
                            style: TextStyle(color: Colors.white, fontSize: Dimentions.font25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('Kapanpun dan Dimanapun Itu.', style: TextStyle(color: Colors.white, fontSize: Dimentions.font16,),),
                        ],
                      ),
                    ),
                    OnBoardPage(
                      boardColumn: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(Assets.image3, width: Dimentions.imageSize220,),
                          SizedBox(height: Dimentions.height10,),
                          Text(
                            'Manajemen Berkulitas',
                            style: TextStyle(color: Colors.white, fontSize: Dimentions.font25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('Dengan kenyamanan dan kemudahan', style: TextStyle(color: Colors.white, fontSize: Dimentions.font16,),),
                        ],
                      ),
                    ),
                    OnBoardPage(
                      boardColumn: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(Assets.image4, width: Dimentions.imageSize240,),
                          SizedBox(height: Dimentions.height10,),
                          Text(
                            'Selamat bergabung',
                            style: TextStyle(color: Colors.white, fontSize: Dimentions.font25, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('Daftarkan galeri anda segera!', style: TextStyle(color: Colors.white, fontSize: Dimentions.font16,),),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: scrollerPosition == 3 ? false : true,
                        child: Text('Swipe To Login >>', style: TextStyle(color: Colors.white70),),
                      ),
                      SizedBox(height: Dimentions.height10,),
                      DotsIndicator(
                        dotsCount: 4,
                        position: scrollerPosition,
                        decorator: DotsDecorator(
                          activeColor: Colors.white,
                        ),
                      ),
                      scrollerPosition == 3 ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              child: Text('Login Now', style: TextStyle(fontSize: Dimentions.font17),),
                              onPressed: (){
                                Get.toNamed(RouteHalper.loginPage);
                                store.write('onBoarding', true);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              ),
                            ),
                          ),
                          SizedBox(height: Dimentions.screenHeight/80.18,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmallText(text: "Belum memiliki akun? ", color: Colors.white, size: Dimentions.font14,),
                              GestureDetector(
                                onTap: (){
                                  Get.toNamed(RouteHalper.getRegisterWithPhonePage());
                                  store.write('onBoarding', true);
                                },
                                child: Text("Daftar disini", style: TextStyle(color: Colors.blueAccent, fontSize: Dimentions.font14, decoration: TextDecoration.underline),)
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ) : TextButton(
                        child: Text('SKIP TO LOGIN', style: TextStyle(color: Colors.blue, fontSize: Dimentions.font17, fontWeight: FontWeight.bold),),
                        onPressed: (){
                          Get.toNamed(RouteHalper.loginPage);
                          store.write('onBoarding', true);
                        },
                      ),
                      SizedBox(height: Dimentions.height20,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({Key? key, this.boardColumn}) : super(key: key);
  final Column? boardColumn;

  @override
  Widget build(BuildContext context) {
    return Center(child: boardColumn);
  }
}