// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:delivery_food_app/component/add_new_posting.dart';
import 'package:delivery_food_app/component/search/home_search.dart';
import 'package:delivery_food_app/pages/auth/forgot_change_pass.dart';
import 'package:delivery_food_app/pages/auth/forgot_pass_number.dart';
import 'package:delivery_food_app/pages/auth/forgot_pass_otp.dart';
import 'package:delivery_food_app/pages/home/bookmark_page.dart';
import 'package:delivery_food_app/component/main_app_page.dart';
import 'package:delivery_food_app/pages/account/edit_accout_page.dart';
import 'package:delivery_food_app/pages/auth/login_page.dart';
import 'package:delivery_food_app/pages/auth/otp_page.dart';
import 'package:delivery_food_app/pages/auth/register_page.dart';
import 'package:delivery_food_app/pages/auth/register_with_phone.dart';
import 'package:delivery_food_app/pages/message/chat_page.dart';
import 'package:delivery_food_app/pages/message/search_userid_page.dart';
import 'package:delivery_food_app/pages/setting/menus/personal_info_page.dart';
import 'package:delivery_food_app/pages/setting/menus/user_page.dart';
import 'package:delivery_food_app/splashScreen/no_internet_screen.dart';
import 'package:delivery_food_app/splashScreen/on_board_screen.dart';
import 'package:delivery_food_app/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../component/page/popular_image_detail.dart';
import '../component/page/recommended_food_detail.dart';

class RouteHalper{
  static int intId(String id){
    return int.parse(id);
  }

  void redirectMaterialPage(BuildContext context, Widget  toPage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => toPage,
      ),
    );
  }

  static const String initial = "/";

  static const String loginPage = "/login-page";
  static const String forgotPassNumberPage = "/forgot-pass-number-page";
  static const String forgotPassOtpPage = "/forgot-pass-otp-page";
  static const String forgotChangePassPage = "/forgot-change-pass-page";
  static const String registerPage = "/register-page";
  static const String registerWithPhonePage = "/register-with-phone-page";
  static const String otpPage = "/otp-page";
  static const String editAccountPage = "/edit-eccount-page";
  static const String addNewPostingPage = "/add-new-posting-page";
  static const String bookmarkPage = "/bookmark-page";

  static const String detailImage = "/detail-image";
  static const String recommendedFood = "/recommended-food";
  static const String onBoardScreen = "/on-board-screen";
  static const String splashScreen = "/splash-screen";

  static const String userSettingPage = "/user-setting-page";
  static const String userChatPage = "/user-chat-page";
  static const String userPersonalInfoPage = "/user-personal-info-page";

  static const String homeSearchComponent = "/home-search-component";
  static const String userIdPersonalSerach = "/userid-personal-search";

  static const String noInternatePage = "/no-internet-page";

  static String getInitial({String? uid}) => '$initial?uid=$uid';

  static String getLoginPage() => '$loginPage';
  static String getForgotPassNumberPage() => '$forgotPassNumberPage';
  static String getForgotPassOtpPage({String? verId, String? phone}) => '$forgotPassOtpPage?verId=$verId&phone=$phone';
  static String getForgotChangePassPage({String? userId}) => '$forgotChangePassPage?userId=$userId';
  static String getRegisterPage() => '$registerPage';
  static String getRegisterWithPhonePage() => '$registerWithPhonePage';
  static String getOtpPage({String? verId, String? phone}) => '$otpPage?verId=$verId&phone=$phone';
  static String getEditAccountPage({String? uid}) => '$editAccountPage?uid=$uid';
  static String getAddNewPostingPage({String? uid, String? groupId}) => '$addNewPostingPage?uid=$uid&groupId=$groupId';
  static String getBookmarkPage() => '$bookmarkPage';

  static String getDetailImage(String imageId, String groupName) => '$detailImage?imageId=$imageId&groupName=$groupName';
  static String getRecommendedFood() => '$recommendedFood';
  static String getOnBoardScreen() => '$onBoardScreen';
  static String getsplashScreen() => '$splashScreen';

  static String getUserSettingPage() => '$userSettingPage';
  static String getUserChatPage({String? userId}) => '$userChatPage?userId=$userId';
  static String getPersonalInfoPage({String? userId}) => '$userPersonalInfoPage?userId=$userId';

  static String getHomeSearchComponent() => '$homeSearchComponent';
  static String getUserIdPersonalSerach() => '$userIdPersonalSerach';

  static String noInternetPage() => '$noInternatePage';

  static List<GetPage> routes = [
    GetPage(name: initial, transition: Transition.native, page: (){
      String? uid = Get.parameters['uid'].toString();
      return MainAppPage(userId: uid,);
    }),

    GetPage(name: splashScreen, page: () => SplashScerenApp(), transition: Transition.native),
    GetPage(name: onBoardScreen, page: () => OnBoardScreenApp(), transition: Transition.native),

    GetPage(name: loginPage, page: () => LoginPage()),
    GetPage(name: forgotPassNumberPage, page: () => ForgotPassNumberPage()),
    GetPage(name: forgotPassOtpPage, page: () {
      String? verId = Get.parameters['verId'].toString();
      String? phone = Get.parameters['phone'].toString();
      return ForgotPassOtpPage(verificationId: verId, phone: phone,);
    }),
    GetPage(name: forgotChangePassPage, page: () {
      String? userId = Get.parameters['userId'].toString();
      return ForgotChangePassPage(userId: userId,);
    }),
    GetPage(name: registerPage, page: () => RegisterPage()),
    GetPage(name: registerWithPhonePage, page: () => RegisterWithPhoneNumber()),
    GetPage(name: otpPage, page: () {
      String? verId = Get.parameters['verId'].toString();
      String? phone = Get.parameters['phone'].toString();
      if(verId.isNotEmpty){
        return OtpPage(verificationId: verId, phone: phone,);
      }else{
        return LoginPage();
      }
    }),
    GetPage(name: editAccountPage, page: (){
      String uid = Get.parameters["uid"].toString();
      return EditAccountPage(uid: uid);
    }),
    GetPage(name: addNewPostingPage, page: (){
      String uid = Get.parameters["uid"].toString();
      String groupId = Get.parameters["groupId"].toString();
      return AddNewPostingPage(uid: uid, groupId: groupId,);
    }),
    GetPage(name: bookmarkPage, page: () => BookmarkPage()),

    GetPage(name: detailImage, transition: Transition.fadeIn, page: (){
      String id = Get.parameters['imageId'].toString() ;
      String groupName = Get.parameters['groupName'].toString() ;
      return DetailImagePage(imageId: id, groupName: groupName,);
    }),
    GetPage(name: recommendedFood, transition: Transition.fadeIn, page: (){
      return RecommendedFoodDetail();
    }),

    GetPage(name: userSettingPage, page: () => UserSettingPage()),
    GetPage(name: userChatPage, page: (){
      String userId = Get.parameters["userId"].toString();
      return ChatMessagePage(userId: userId);
    }),
    GetPage(name: userPersonalInfoPage, page: (){
      String userId = Get.parameters["userId"].toString();
      return PersonalInfoPage(uid: userId,);
    }),

    GetPage(name: homeSearchComponent, page: () => HomeSearchComponent()),
    GetPage(name: userIdPersonalSerach, page: () => SearchUseridPage()),

    GetPage(name: noInternatePage, page: () => NoInternetScreen()),
  ];
}