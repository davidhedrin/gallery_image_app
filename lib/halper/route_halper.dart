import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/pages/auth/login_page.dart';
import 'package:delivery_food_app/pages/auth/otp_page.dart';
import 'package:delivery_food_app/pages/auth/register_page.dart';
import 'package:delivery_food_app/pages/auth/register_with_phone.dart';
import 'package:delivery_food_app/splashScreen/on_board_screen.dart';
import 'package:delivery_food_app/splashScreen/splash_screen.dart';
import 'package:get/get.dart';

import '../component/page/popular_image_detail.dart';
import '../component/page/recommended_food_detail.dart';

class RouteHalper{
  static int intId(String id){
    return int.parse(id);
  }

  static const String initial = "/";

  static const String loginPage = "/login-page";
  static const String registerPage = "/register-page";
  static const String registerWithPhonePage = "/register-with-phone-page";
  static const String otpPage = "/otp-page";

  static const String popularFood = "/popular-food";
  static const String recommendedFood = "/recommended-food";
  static const String onBoardScreen = "/on-board-screen";
  static const String splashScreen = "/splash-screen";

  static String getInitial() => '$initial';

  static String getLoginPage() => '$loginPage';
  static String getRegisterPage() => '$registerPage';
  static String getRegisterWithPhonePage() => '$registerWithPhonePage';
  static String getOtpPage(String? passOtp) => '$otpPage?passOtp=$passOtp';

  static String getPopularFood(int pageId) => '$popularFood?pageId=$pageId';
  static String getRecommendedFood() => '$recommendedFood';
  static String getOnBoardScreen() => '$onBoardScreen';
  static String getsplashScreen() => '$splashScreen';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => MainAppPage(), transition: Transition.native),
    GetPage(name: splashScreen, page: () => SplashScerenApp(), transition: Transition.native),
    GetPage(name: onBoardScreen, page: () => OnBoardScreenApp(), transition: Transition.native),

    GetPage(name: loginPage, page: () => LoginPage()),
    GetPage(name: registerPage, page: () => RegisterPage()),
    GetPage(name: registerWithPhonePage, page: () => RegisterWithPhoneNumber()),
    GetPage(name: otpPage, page: () {
      String? passOtp = Get.parameters['passOtp'].toString();
      if(passOtp.isNotEmpty && passOtp != null){
        return OtpPage();
      }else{
        return LoginPage();
      }
    }),

    GetPage(name: popularFood, transition: Transition.fadeIn, page: (){
      int id = intId(Get.parameters['pageId'].toString()) ;
      return PopularFoodDetail(id: id);
    }),
    GetPage(name: recommendedFood, transition: Transition.fadeIn, page: (){
      return RecommendedFoodDetail();
    }),
  ];
}