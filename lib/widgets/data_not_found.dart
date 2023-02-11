import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';

class DataNotFoundWidget extends StatelessWidget {
  final String msgTop;
  const DataNotFoundWidget({Key? key, required this.msgTop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.imageNotFound, width: Dimentions.imageSize190,),
              SizedBox(height: Dimentions.height10,),
              Text(
                "$msgTop, \n Ulangi beberapa saat lagi!",
                style: TextStyle(fontSize: Dimentions.font16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
