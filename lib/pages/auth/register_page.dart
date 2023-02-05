import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/auth_widget/button_widget.dart';
import '../../widgets/auth_widget/text_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final co_passController = TextEditingController();
  final no_phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: Dimentions.height10),

                // welcome back, you've been missed!
                BigText(text: "Welcome to Register Our Gallery's", color: Colors.white,),

                SizedBox(height: Dimentions.height25),

                MyTextField(
                  controller: no_phoneController,
                  hintText: 'Phone Number',
                  obscureText: false,
                  typeText: TextInputType.number,
                ),

                SizedBox(height: Dimentions.height15),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  obscureText: false,
                  typeText: TextInputType.emailAddress,
                ),

                SizedBox(height: Dimentions.height15),

                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                SizedBox(height: Dimentions.height15),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  typeText: TextInputType.visiblePassword,
                ),

                SizedBox(height: Dimentions.height15),

                MyTextField(
                  controller: co_passController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  typeText: TextInputType.visiblePassword,
                ),

                SizedBox(height: Dimentions.height20),
                SizedBox(height: Dimentions.height15),

                // sign in button
                MyButton(
                  onTap: (){},
                  textBtn: "Register Now",
                  colorBtn: Colors.blueAccent,
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
                          'Already have account?',
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

                SizedBox(height: Dimentions.height15),

                GestureDetector(
                  onTap: (){
                    Get.toNamed(RouteHalper.getLoginPage());
                  },
                  child: BigText(text: "Login Here", color: Colors.blueAccent, size: Dimentions.font16,)
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
