import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';

class TabBarNavigationMaterial extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChangeTab;
  const TabBarNavigationMaterial({Key? key, required this.index, required this.onChangeTab}) : super(key: key);

  @override
  State<TabBarNavigationMaterial> createState() => _TabBarNavigationMaterialState();
}

class _TabBarNavigationMaterialState extends State<TabBarNavigationMaterial> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: Dimentions.notcMarginNavbar8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          builTabItem(index: 0, icon: Icon(Icons.home_rounded)),
          builTabItem(index: 1, icon: Icon(Icons.message_outlined)),
          SizedBox(width: Dimentions.width30,),
          builTabItem(index: 2, icon: Icon(Icons.settings)),
          builTabItem(index: 3, icon: Icon(Icons.account_circle_outlined)),
        ],
      ),
    );
  }

  Widget builTabItem({required int index, required Icon icon}){
    final isSelected = index == widget.index;
    return IconTheme(
      data: IconThemeData(
        color: isSelected ? Colors.blueAccent : AppColors.signColor2,
        size: isSelected ? Dimentions.iconSize36 : Dimentions.iconSize32,
      ),
      child: IconButton(
        icon: icon,
        onPressed: (){
          widget.onChangeTab(index);
        },
      ),
    );
  }
}
