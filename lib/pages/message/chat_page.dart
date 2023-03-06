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
        children: [
          const Expanded(
            child: _DemoMessageList()
          ),
          _ChatInput()
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

class _ChatInput extends StatelessWidget {
  _ChatInput({Key? key}) : super(key: key);

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimentions.height10, horizontal: Dimentions.width10),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimentions.radius15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.emoji_emotions, color: Colors.blueAccent, size: Dimentions.iconSize25)
                  ),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: () {

                        },
                        decoration: const InputDecoration(
                          hintText: 'Type Something...',
                          border: InputBorder.none
                        ),
                      )),

                  //pick image from gallery button
                  IconButton(
                    onPressed: () async {
                    },
                    icon: Icon(Icons.image,color: Colors.blueAccent, size: Dimentions.iconSize26)
                  ),

                  IconButton(
                    onPressed: () async {
                    },
                    icon: Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: Dimentions.iconSize26)
                  ),

                  SizedBox(width: Dimentions.width3),
                ],
              ),
            ),
          ),

          SizedBox(width: Dimentions.width3),
          GlowingActionButton(
            color: AppColors.secondary,
            icon: Icons.send_rounded,
            size: Dimentions.height45,
            onPressed: (){},
          ),
          // MaterialButton(
          //   onPressed: () {
          //   },
          //   minWidth: 0,
          //   padding: EdgeInsets.only(top: Dimentions.height10, bottom: Dimentions.height10, right: Dimentions.width5, left: Dimentions.width10),
          //   shape: const CircleBorder(),
          //   color: AppColors.secondary,
          //   child: Icon(Icons.send, color: Colors.white, size: Dimentions.iconSize28),
          // )
        ],
      ),
    );
  }
}




