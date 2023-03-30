import 'package:delivery_food_app/component/page/popular_image_detail.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DynamicLinkService{
  static final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  static Future<String> createDynamicLink(bool short, String link) async {
    String linkMessage;

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Collections.uriPrefix,
      link: Uri.parse("${Collections.uriPrefix}$link"),
      androidParameters: const AndroidParameters(
        packageName: Collections.appPackageNameAndroid,
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: Collections.appPackageNameIos,
        minimumVersion: "0",
        appStoreId: "123456789",
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }

    linkMessage = url.toString();
    return linkMessage;
  }

  static Future<void> initDynamicLink(BuildContext context) async {
    dynamicLinks.onLink.listen((dynamicLink) {
      final Uri deepLink = dynamicLink.link;
      final queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        String? imageId = queryParams["imageId"];
        String? groupName = queryParams["groupName"];

        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailImagePage(imageId: imageId!, groupName: groupName!,)));
      }
      // else {
      //   Get.toNamed(RouteHalper.getsplashScreen());
      // }
    }).onError((error) {
      if (kDebugMode) {
        print('Error: initDynamicLink()');
        print(error.message);
      }
    });

    final PendingDynamicLinkData? data = await dynamicLinks.getInitialLink();
    if(data != null){
      final Uri deepLink = data.link;
      final queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        String? imageId = queryParams["imageId"];
        String? groupName = queryParams["groupName"];
        if(imageId != null && groupName != null){
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailImagePage(imageId: imageId, groupName: groupName,)));
        }else{
          return;
        }
      }else{
        return;
      }
    }
  }
}