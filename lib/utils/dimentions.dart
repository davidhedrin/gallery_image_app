import 'package:get/get.dart';

class Dimentions{
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double pageView= screenHeight/2.64;
  static double pageViewContainer = screenHeight/3.84;
  static double pageTextContainer = screenHeight/7.03;

  // dynemic height padding and margin
  static double height10 = screenHeight/84.4;
  static double height15 = screenHeight/56.27;
  static double height20 = screenHeight/42.2;
  static double height30 = screenHeight/28.13;
  static double height45 = screenHeight/17.76;

  // dynemic width padding and margin
  static double width10 = screenHeight/84.4;
  static double width15 = screenHeight/56.27;
  static double width20 = screenHeight/42.2;
  static double width30 = screenHeight/28.13;

  // fonts size
  static double font16 = screenHeight/52.75;
  static double font20 = screenHeight/42.2;
  static double font26 = screenHeight/32.46;

  // radius size
  static double radius15 = screenHeight/56.27;
  static double radius20 = screenHeight/42.2;
  static double radius30 = screenHeight/28.13;

  // icons size
  static double iconSize36 = screenHeight/23.0;
  static double iconSize32 = screenHeight/27.0;
  static double iconSize24 = screenHeight/35.17;
  static double iconSize16 = screenHeight/42.75;

  // List view size 390
  static double listViewImgSize = screenWidth/3.25;
  static double listViewTextContSize = screenWidth/3.9;

  // Popular Food Detail
  static double popularFoodImgSize = screenHeight/2.41;

  // Bottom height
  static double bottomHeightbar = screenHeight/7.03;

  // NotcMargin Navbar
  static double notcMarginNavbar8 = screenHeight/97.60;
}