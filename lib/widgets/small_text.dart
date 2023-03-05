import 'package:flutter/cupertino.dart';

class SmallText extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  FontWeight? fontWeight;
  SmallText({
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

class SmallTextOvr extends StatelessWidget {
  Color? color;
  final String text;
  double size;
  double height;
  SmallTextOvr({
    Key? key,
    this.color = const Color(0xFFccc7c5),
    this.size = 12,
    this.height = 1.2,
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
      ),
    );
  }
}
