import 'package:flutter/material.dart';

import 'package:delivery_food_app/utils/dimentions.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String textBtn;
  final Color? colorBtn;
  final Color? colorText;

  const MyButton({
    super.key,
    required this.onTap,
    required this.textBtn,
    this.colorText = Colors.white,
    this.colorBtn = Colors.black
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:  EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20, top: Dimentions.height20, bottom: Dimentions.height20),
        margin:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
        decoration: BoxDecoration(
          color: colorBtn,
          borderRadius: BorderRadius.circular(Dimentions.screenHeight/97.63),
        ),
        child: Center(
          child: Text(
            textBtn,
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.bold,
              fontSize: Dimentions.font16,
            ),
          ),
        ),
      ),
    );
  }
}
