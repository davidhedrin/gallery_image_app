import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class IconBackground extends StatelessWidget {
  const IconBackground({
    Key? key,
    required this.icon,
    required this.onTap,
    this.color,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.buttonBackgroundColor,
      borderRadius: BorderRadius.circular(Dimentions.radius6),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimentions.radius6),
        splashColor: AppColors.secondary,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(Dimentions.height6),
          child: Icon(
            icon,
            size: Dimentions.iconSize22,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    Key? key,
    this.url,
    required this.radius,
    this.onTap,
  }) : super(key: key);

  Avatar.small({
    Key? key,
    this.url,
    this.onTap,
  })  : radius = Dimentions.radius18,
        super(key: key);

  Avatar.medium({
    Key? key,
    this.url,
    this.onTap,
  })  : radius = Dimentions.radius26,
        super(key: key);

  Avatar.large({
    Key? key,
    this.url,
    this.onTap,
  })  : radius = Dimentions.radius34,
        super(key: key);

  final double radius;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _avatar(context),
    );
  }

  Widget _avatar(BuildContext context) {
    if (url != null) {
      return url!.isNotEmpty ? CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(url!),
        backgroundColor: Theme.of(context).cardColor,
      ) : CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: Image.asset(
            Assets.imagePrifil,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        child: ClipOval(
          child: Image.asset(
            Assets.imagePrifil,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
}