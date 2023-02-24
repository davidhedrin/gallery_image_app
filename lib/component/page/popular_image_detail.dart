import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/app_icon.dart';
import 'package:delivery_food_app/widgets/expandable_text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_column.dart';
import '../../widgets/big_text.dart';

class PopularFoodDetail extends StatelessWidget {
  final int id;
  const PopularFoodDetail({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(id.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              width: double.maxFinite,
              height: Dimentions.popularFoodImgSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(Assets.imageMakanan),
                ),
              ),
            ),
          ),

          // Icons Widget
          Positioned(
            top: Dimentions.height45,
            left: Dimentions.width20,
            right: Dimentions.width20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: AppIcon(icon: Icons.arrow_back_ios_new),
                ),
                AppIcon(icon: Icons.shopping_cart_checkout_outlined),
              ],
            ),
          ),

          // Description Introduction Product
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: Dimentions.popularFoodImgSize-Dimentions.height70,
            child: Container(
              padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, top: Dimentions.height20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(Dimentions.radius20),
                  topLeft: Radius.circular(Dimentions.radius20)
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppColumn(),
                  SizedBox(height: Dimentions.height20,),
                  BigText(text: "Introduce"),
                  SizedBox(height: Dimentions.height20,),
                  Expanded(
                    child: SingleChildScrollView(
                        child: ExpandableTextWidget(text: "On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.")
                    ),
                  )
                ],
              ),
            ),
          )

          // Expandable Text Widget
          
        ],
      ),
      bottomNavigationBar: Container(
        height: Dimentions.bottomHeightbar,
        padding: EdgeInsets.only(top: Dimentions.height30, bottom: Dimentions.height30, left: Dimentions.width20, right: Dimentions.width20),
        decoration: BoxDecoration(
          color: AppColors.buttonBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimentions.radius20*2),
            topRight: Radius.circular(Dimentions.radius20*2)
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(top: Dimentions.height20, bottom: Dimentions.height20, left: Dimentions.width20, right: Dimentions.width20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimentions.radius20),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(Icons.remove, color: AppColors.signColor,),
                  SizedBox(width: Dimentions.width10/2,),
                  BigText(text: "0"),
                  SizedBox(width: Dimentions.width10/2,),
                  Icon(Icons.add, color: AppColors.signColor,)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: Dimentions.height20, bottom: Dimentions.height20, left: Dimentions.width20, right: Dimentions.width20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimentions.radius20),
                color: AppColors.mainColor,
              ),
              child: BigText(text: "\Rp. 5000/Unit", color: Colors.white,),
            )
          ],
        ),
      ),
    );
  }
}
