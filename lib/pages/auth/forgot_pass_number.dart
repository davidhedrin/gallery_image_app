// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:country_picker/country_picker.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';
import '../../providers/app_services.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';

class ForgotPassNumberPage extends StatefulWidget {
  const ForgotPassNumberPage({Key? key}) : super(key: key);

  @override
  State<ForgotPassNumberPage> createState() => _ForgotPassNumberPageState();
}

class _ForgotPassNumberPageState extends State<ForgotPassNumberPage> {
  final noPhoneController = TextEditingController();
  final AppServices getServ = AppServices();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Lupa Password', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeInDown(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.imageOtpForgot, height: Dimentions.imageSize180,),
            SizedBox(height: Dimentions.height25,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimentions.width20),
              child: Text('Kode OTP akan dikirim ke nomor untuk melanjutkan proses pengaturan kata sandi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Dimentions.font14, color: Colors.white70),),
            ),

            SizedBox(height: Dimentions.height15,),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
              child: Form(
                key: formKey,
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
            ),

            SizedBox(height: Dimentions.height6,),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if(noPhoneController.text.isNotEmpty){
                      if(formKey.currentState!.validate()){
                        getServ.loading(context);

                        final String phone = "+${selectCountry.phoneCode}${noPhoneController.text}";

                        var getUser = await getServ.getDocumentByColumn(Collections.users, Collections.collColumnphone, phone);
                        if(getUser != null){
                          await auth.verifyPhoneNumber(
                            phoneNumber: phone,
                            verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
                              await auth.signInWithCredential(phoneAuthCredential);
                            },
                            verificationFailed: (error) {
                              showAwsBar(context: context, contentType: ContentType.warning, msg: error.message.toString(), title: "");
                            },
                            codeSent: (verificationId, forceResendingToken) {
                              Navigator.of(context).pop();
                              Get.toNamed(RouteHalper.getForgotPassOtpPage(verId: verificationId, phone: phone));
                              showAwsBar(context: context, contentType: ContentType.success, msg: "Kode OTP telah dikirim, silahkan masukkan", title: "Success OTP");
                            },
                            codeAutoRetrievalTimeout: (verificationId) {},
                          );
                        }else{
                          Navigator.of(context).pop();
                          showAwsBar(context: context, contentType: ContentType.warning, msg: "Nomor tidak terdaftar/tidak dikenal", title: "Not Found!");
                        }
                      }
                    }else{
                      showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan No Ponsel untuk otp", title: "Validasi");
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor:MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimentions.screenHeight/150.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width15),
                    child: Text(
                      'Verifikasi',
                      style: TextStyle(fontSize: Dimentions.font20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
