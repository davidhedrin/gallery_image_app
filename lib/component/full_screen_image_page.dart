import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:flutter/material.dart';

import '../utils/dimentions.dart';
import '../widgets/loading_progres.dart';

class FullScreenImagePage extends StatefulWidget {
  final String imgUrl;
  const FullScreenImagePage({Key? key, required this.imgUrl}) : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: CachedNetworkImage(
            imageUrl: widget.imgUrl,
            placeholder: (context, url) => const LoadingProgress(),
            errorWidget: (context, url, error){
              return Container(
                color: Colors.black,
                child: Center(
                  child: Image.asset(
                    Assets.imageBackgroundProfil,
                    width: double.infinity,
                    height: Dimentions.heightSize320,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            imageBuilder: (context, imageProvider) => Container(
              color: Colors.black,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
