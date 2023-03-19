import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String? title;
  final List<Widget>? widgets;
  final Widget? leading;

  /// you can add more fields that meet your needs

  const MyAppBar({
    Key? key,
    required this.appBar,
    this.title = "",
    this.widgets,
    this.leading
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(title!),
      actions: widgets,
      backgroundColor: Colors.transparent,
      elevation: 0.0
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}