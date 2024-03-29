import 'package:animate_do/animate_do.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

import '../generated/assets.dart';

class LoadingProgress extends StatefulWidget {
  final double? size;
  final Color? color;
  const LoadingProgress({Key? key, this.size, this.color = Colors.white}) : super(key: key);

  @override
  State<LoadingProgress> createState() => _LoadingProgressState();
}

class _LoadingProgressState extends State<LoadingProgress> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 800),
      curve: Curves.fastLinearToSlowEaseIn,
      child: Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Bounce(
              infinite: true,
              child: Image.asset(Assets.imageAppIcon, width: widget.size == null ? Dimentions.height40 : widget.size!,)
            ),
            // SpinKitWave(
            //   color: widget.color,
            //   size: widget.size == null ? Dimentions.height40 : widget.size!,
            // ),
          ],
        ),
      ),
    );
  }
}

