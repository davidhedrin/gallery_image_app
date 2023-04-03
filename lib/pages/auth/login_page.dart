// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/providers/auth_provider.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/dimentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../widgets/auth_widget/button_widget.dart';
import '../../widgets/auth_widget/text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final noPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final AppServices services = AppServices();
  bool obscureText = true;

  Country selectCountry = Country(
      phoneCode: "62",
      countryCode: "ID",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Indonesia",
      example: "Indonesia",
      displayName: "Indonesia",
      displayNameNoCountryCode: "ID",
      e164Key: ""
  );
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AuthProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        bool check = false;
        await onBackButtonPressYesNo(context: context, text: "Keluar Aplikasi!", desc: "Yakin ingin keluar dari aplikasi?").then((value){
          check = value;
        });
        if(check){
          exit(0);
        }
        return check;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ElasticIn(
                delay: const Duration(milliseconds: 100),
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

                     SizedBox(height: Dimentions.height15),

                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                      child: TextFormField(
                        controller: noPhoneController,
                        validator: (value){
                          if(value!.isEmpty){
                            return '*masukkan nomor ponsel';
                          }
                          if(value.length < 10){
                            return '*nomor ponsel tidak sah';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'\d'),
                          ),
                          FilteringTextInputFormatter.deny(
                            RegExp(r'^0+'),
                          ),
                        ],
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        style: TextStyle(
                          fontSize: Dimentions.font20,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(right: Dimentions.width15, top: Dimentions.height15, bottom: Dimentions.height15),
                          enabledBorder:  const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: "812-xxxx-xxxx",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: Dimentions.font20),
                          suffixIcon: const Icon(Icons.phone_android),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: Dimentions.width15, top: Dimentions.screenHeight/62, right: Dimentions.width5),
                            child: InkWell(
                              onTap: (){
                                showCountryPicker(
                                    context: context,
                                    countryListTheme:  CountryListThemeData(
                                      bottomSheetHeight: Dimentions.heightSize400,
                                    ),
                                    onSelect: (value){
                                      setState(() {
                                        selectCountry = value;
                                      });
                                    }
                                );
                              },
                              child: Text(
                                "${selectCountry.flagEmoji} +${selectCountry.phoneCode}",
                                style: TextStyle(
                                    fontSize: Dimentions.font20,
                                    color: Colors.black87
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),


                    // password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                    ),

                     SizedBox(height: Dimentions.height20),

                    // forgot password?
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: (){
                              Get.toNamed(RouteHalper.getForgotPassNumberPage());
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.white, fontSize: Dimentions.font12),
                            ),
                          ),
                        ],
                      ),
                    ),

                     SizedBox(height: Dimentions.height25),

                    // sign in button
                    MyButton(
                      onTap: () async {
                        BuildContext dialogcontext = context;

                        if(noPhoneController.text.isNotEmpty && passwordController.text.isNotEmpty){
                          services.loading(dialogcontext);

                          final String phone = "+${selectCountry.phoneCode}${noPhoneController.text}";
                          final String password = passwordController.text.trim();

                          await app.getDataDocumentByColumn(context: context, collection: Collections.users, column: "phone", param: phone).then((result) async {
                            if(result){
                              QuerySnapshot snap = await FirebaseFirestore.instance.collection(Collections.users).where("phone", isEqualTo: phone).get();
                              final String email = snap.docs.first.get('email');
                              final String pass = snap.docs.first.get('password').trim();

                              if(password == pass){
                                await services.loginWithEmailRetMap(context, email, password).then((Map<String, dynamic> status) async {
                                  if(status["status"] == "200"){
                                    String userId = status["uid"];

                                    noPhoneController.clear();
                                    passwordController.clear();

                                    await services.getUserLoginModel(userId);
                                    services.setStatus(status: "1", userId: userId);
                                    Navigator.of(dialogcontext).pop();
                                    Get.toNamed(RouteHalper.getInitial(uid: userId));
                                  }else{
                                    Navigator.of(dialogcontext).pop();
                                    showAwsBar(context: context, contentType: ContentType.warning, msg: "Terjadi kesalahan. Ulangi beberapa saat lagi", title: "Login");
                                  }
                                });
                              }else{
                                Navigator.of(dialogcontext).pop();
                                showAwsBar(context: context, contentType: ContentType.help, msg: "Password anda tidak sesuai", title: "Password");
                              }

                            }else{
                              Navigator.of(dialogcontext).pop();
                              showAwsBar(context: context, contentType: ContentType.warning, msg: "Nomor anda tidak terdaftar", title: "Login");
                            }
                          });
                        }else{
                          showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan No Ponsel dan Password", title: "Validasi");
                        }

                      },
                      textBtn: "Sign In",
                      colorBtn: Colors.black87,
                    ),

                     SizedBox(height: Dimentions.height25),

                    // or continue with
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.symmetric(horizontal: Dimentions.height10),
                            child: const Text(
                              'Not have account?',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          const Expanded(
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
      ),
    );
  }
}