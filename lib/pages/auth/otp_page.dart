import 'package:animate_do/animate_do.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../generated/assets.dart';
import '../../widgets/app_bar_widget.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Color accentPurpleColor = Color(0xFF6A53A1);
  final TextEditingController otp_number = TextEditingController();

  TextStyle? createStyle() {
    TextStyle theme = TextStyle(
      fontSize: Dimentions.font25,
      fontWeight: FontWeight.w500,
      color: Colors.white
    );
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    List<TextStyle?> otpTextStyles = [
      createStyle(),
      createStyle(),
      createStyle(),
      createStyle(),
      createStyle(),
      createStyle(),
    ];
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      appBar: MyAppBar(
        appBar: AppBar(),
        leading:  GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            size: Dimentions.font30,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: BounceInDown(
              child: Padding(
                padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
                child: Column(
                  children: [
                    Image.asset(
                      Assets.imageSecurity,
                      width: Dimentions.imageSize160,
                    ),
                    SizedBox(
                      height: Dimentions.height25,
                    ),
                    Text(
                      'VERIFICATION',
                      style: TextStyle(
                        fontSize: Dimentions.font25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    SizedBox(
                      height: Dimentions.height10,
                    ),
                    Text(
                      "Enter your OTP code number",
                      style: TextStyle(
                        fontSize: Dimentions.font14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: Dimentions.height28, horizontal: Dimentions.width28),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(Dimentions.radius12),
                      ),
                      child: Column(
                        children: [
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: accentPurpleColor,
                            focusedBorderColor: accentPurpleColor,
                            styles: otpTextStyles,
                            showFieldAsBox: false,
                            fieldWidth: Dimentions.height35,
                            autoFocus: true,
                            borderWidth: 3.0,
                            onSubmit: (String verCode) {
                              otp_number.text = verCode;
                            },
                          ),
                          SizedBox(
                            height: Dimentions.height20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {

                              },
                              style: ButtonStyle(
                                foregroundColor:MaterialStateProperty.all<Color>(Colors.white),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimentions.screenHeight/90.0),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width15),
                                child: Text(
                                  'Verify',
                                  style: TextStyle(fontSize: Dimentions.font20),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Text(
                      "Didn't you receive any code?",
                      style: TextStyle(
                        fontSize: Dimentions.font13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Text(
                      "Resend New Code",
                      style: TextStyle(
                        fontSize: Dimentions.font17,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
