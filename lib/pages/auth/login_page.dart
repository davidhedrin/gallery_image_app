import 'package:animate_do/animate_do.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/auth_widget/button_widget.dart';
import '../../widgets/auth_widget/text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ElasticIn(
              delay: Duration(milliseconds: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Assets.imageWelcomeCat, width: Dimentions.screenHeight/3.1,),

                   SizedBox(height: Dimentions.height15),

                  // welcome back, you've been missed!
                  Text(
                    'Welcome back you\'ve been missed!',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: Dimentions.font17,
                    ),
                  ),

                   SizedBox(height: Dimentions.height25),

                  // username textfield
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),

                   SizedBox(height: Dimentions.height15),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                   SizedBox(height: Dimentions.height20),

                  // forgot password?
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white, fontSize: Dimentions.font12),
                        ),
                      ],
                    ),
                  ),

                   SizedBox(height: Dimentions.height25),

                  // sign in button
                  MyButton(
                    onTap: (){},
                    textBtn: "Sign In",
                    colorBtn: Colors.black87,
                  ),

                   SizedBox(height: Dimentions.height25),

                  // or continue with
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: Dimentions.height10),
                          child: Text(
                            'Not have account?',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                   SizedBox(height: Dimentions.height25),

                  MyButton(
                    onTap: (){
                      Get.toNamed(RouteHalper.getRegisterWithPhonePage());
                    },
                    textBtn: "Register Here",
                    colorBtn: Colors.blueAccent,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}