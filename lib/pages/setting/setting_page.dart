import 'package:flutter/cupertino.dart';

import '../../widgets/big_text.dart';

class SettingPageMenu extends StatefulWidget {
  const SettingPageMenu({Key? key}) : super(key: key);

  @override
  State<SettingPageMenu> createState() => _SettingPageMenuState();
}

class _SettingPageMenuState extends State<SettingPageMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BigText(text: "Setting Page Menu"),
        )
      ],
    );
  }
}
