import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:flutter/cupertino.dart';

class MessagePageMenu extends StatefulWidget {
  const MessagePageMenu({Key? key}) : super(key: key);

  @override
  State<MessagePageMenu> createState() => _MessagePageMenuState();
}

class _MessagePageMenuState extends State<MessagePageMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BigText(text: "Message Page Menu"),
        )
      ],
    );
  }
}
