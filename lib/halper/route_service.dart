import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../component/page/popular_image_detail.dart';

class RouteServices {
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Page Not Found"),
        ),
      );
    });
  }

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    switch (routeSettings.name) {
      case "/detail-image":
        if (args is Map) {
          String imageId = args["imageId"];
          String groupName = args["groupName"];
          return CupertinoPageRoute(builder: (_) {
            return DetailImagePage(imageId: imageId, groupName: groupName,);
          });
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }
}