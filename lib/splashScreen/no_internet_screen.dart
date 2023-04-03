import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.imageCloudLighning, width: Dimentions.heightSize90,),
            SizedBox(height: Dimentions.height15,),
            BigText(text: "Tidak ada Internet", size: Dimentions.font17,),
            SizedBox(height: Dimentions.height4,),
            SmallText(text: "Mohon periksa sambungan koneksi internet", size: Dimentions.font14, color: Colors.black45,),
            SizedBox(height: Dimentions.height15,),
            InkWell(
              onTap: (){
                Restart.restartApp();
              },
              child: BigText(text: "Coba Lagi", size: Dimentions.font17, color: Colors.blue,)
            ),
          ],
        ),
      ),
    );
  }
}
