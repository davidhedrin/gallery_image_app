import 'package:delivery_food_app/halper/function_convert.dart';
import 'package:delivery_food_app/pages/food/popular_food_detail.dart';
import 'package:delivery_food_app/pages/home/main_app_page.dart';
import 'package:get/get.dart';

import '../pages/food/recommended_food_detail.dart';

class RouteHalper{
  static int intId(String id){
    return int.parse(id);
  }

  static const String initial = "/";
  static const String popularFood = "/popular-food";
  static const String recommendedFood = "/recommended-food";

  static String getInitial() => '$initial';
  static String getPopularFood(int pageId) => '$popularFood?pageId=$pageId';
  static String getRecommendedFood() => '$recommendedFood';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => MainAppPage(), transition: Transition.native),
    GetPage(name: popularFood, transition: Transition.fadeIn, page: (){
      int id = intId(Get.parameters['pageId'].toString()) ;
      return PopularFoodDetail(id: id);
    }),
    GetPage(name: recommendedFood, transition: Transition.fadeIn, page: (){
      return RecommendedFoodDetail();
    }),
  ];
}