import 'package:delivery_food_app/models/message_data.dart';
import 'package:delivery_food_app/utils/colors.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/message_widget.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/material.dart';

import '../../utils/dimentions.dart';
import '../../widgets/glowing_action_button.dart';

class ChatMessagePage extends StatefulWidget {
  const ChatMessagePage({Key? key, required this.messageData}) : super(key: key);

  final MessageData messageData;

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _AppBarTitle(msgData: widget.messageData),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera_front, color: Colors.black87, size: Dimentions.iconSize24,),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: Dimentions.width8),
            child: IconButton(
              icon: Icon(Icons.phone, color: Colors.black87, size: Dimentions.iconSize24,),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: _DemoMessageList()
          ),
          _ActionBar()
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({Key? key, required this.msgData}) : super(key: key);

  final MessageData msgData;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Avatar.small(url: msgData.profilePicture,),
        SizedBox(width: Dimentions.width15,),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BigText(text: msgData.senderName, size: Dimentions.font14,),
              SizedBox(height: Dimentions.height2,),
              SmallText(text: "Online", color: Colors.green, fontWeight: FontWeight.bold,),
            ],
          ),
        )
      ],
    );
  }
}

class _DemoMessageList extends StatelessWidget {
  const _DemoMessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimentions.height8),
      child: ListView(
        children: [
          _DataTable(lable: "Yesterday"),
          _MessageTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
          _MessageOwnTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
          _MessageTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
          _MessageOwnTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
          _MessageTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
          _MessageOwnTile(
            message: "Hai jesika marata, I love you",
            messageDate: "12:00 AM",
          ),
        ],
      ),
    );
  }
}

class _DataTable extends StatelessWidget {
  const _DataTable({Key? key, required this.lable}) : super(key: key);

  final String lable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimentions.height15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(Dimentions.radius12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Dimentions.height4, horizontal: Dimentions.width12),
            child: Text(
              lable,
              style: TextStyle(
                fontSize: Dimentions.font12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({Key? key, required this.message, required this.messageDate}) : super(key: key);

  final String message;
  final String messageDate;

  static double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: AppColors.textFaded,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_borderRadius),
                    topRight: Radius.circular(_borderRadius),
                    bottomRight: Radius.circular(_borderRadius),
                  )
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width12),
                child: Text(
                  message,
                  style: TextStyle(
                      color: AppColors.textLigth
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: Dimentions.height8),
              child: Text(
                messageDate,
                style: TextStyle(
                    fontSize: Dimentions.font10,
                    color: AppColors.textFaded,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({Key? key, required this.message, required this.messageDate}) : super(key: key);

  final String message;
  final String messageDate;

  static double _borderRadius = Dimentions.radius26;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                )
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width12),
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textLigth
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: Dimentions.height8),
              child: Text(
                messageDate,
                style: TextStyle(
                  fontSize: Dimentions.font10,
                  color: AppColors.textFaded,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatefulWidget {
  const _ActionBar({Key? key}) : super(key: key);

  @override
  __ActionBarState createState() => __ActionBarState();
}

class __ActionBarState extends State<_ActionBar> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: Dimentions.width2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimentions.width15),
              child: Icon(
                Icons.photo_camera_back_outlined,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: Dimentions.width15),
              child: TextField(
                controller: controller,
                style: TextStyle(fontSize: Dimentions.font15),
                decoration: const InputDecoration(
                  hintText: "Masukkan pesan...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_){},
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: Dimentions.width12,
              right: Dimentions.radius20,
            ),
            child: GlowingActionButton(
              color: AppColors.secondary,
              icon: Icons.send_rounded,
              size: Dimentions.height45,
              onPressed: (){},
            ),
          ),
        ],
      ),
    );
  }
}



