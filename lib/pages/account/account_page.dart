import 'package:flutter/cupertino.dart';

import '../../widgets/big_text.dart';

class AccountPageMenu extends StatefulWidget {
  const AccountPageMenu({Key? key}) : super(key: key);

  @override
  State<AccountPageMenu> createState() => _AccountPageMenuState();
}

class _AccountPageMenuState extends State<AccountPageMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BigText(text: "Account Page Menu"),
        )
      ],
    );
  }
}
