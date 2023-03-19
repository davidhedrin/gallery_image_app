// ignore_for_file: must_be_immutable

import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';

class BigText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  TextOverflow overflow;
  FontWeight? fontWeight;
  BigText({
    Key? key,
    this.color = const Color(0xFF332d2b),
    this.size = 0,
    required this.text,
    this.overflow = TextOverflow.ellipsis,
    this.fontWeight = FontWeight.w400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'sans-serif',
        color: color,
        fontSize: size == 0 ?  Dimentions.font20 : size,
        fontWeight: fontWeight
      ),
    );
  }
}
