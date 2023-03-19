// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  FontWeight? fontWeight;
  FontStyle? fontStyle;
  SmallText({
    Key? key,
    this.color = const Color(0xFFccc7c5),
    this.size = 12,
    this.height = 1.2,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'sans-serif',
        color: color,
        fontSize: size,
        height: height,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
    );
  }
}

class SmallTextOvr extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  FontWeight? fontWeight;
  SmallTextOvr({
    Key? key,
    this.color = const Color(0xFFccc7c5),
    this.size = 12,
    this.height = 1.2,
    this.fontWeight = FontWeight.normal,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'sans-serif',
        color: color,
        fontSize: size,
        height: height,
          fontWeight: fontWeight
      ),
    );
  }
}
