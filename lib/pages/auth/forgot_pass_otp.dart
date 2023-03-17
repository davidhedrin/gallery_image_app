// ignore_for_file: use_build_context_synchronously, unused_local_variable
import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';
import '../../halper/route_halper.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';

class ForgotPassOtpPage extends StatefulWidget {
  final String verificationId;
  final String phone;
  const ForgotPassOtpPage({Key? key, required this.verificationId, required this.phone}) : super(key: key);

  @override
  State<ForgotPassOtpPage> createState() => _ForgotPassOtpPageState();
}

class _ForgotPassOtpPageState extends State<ForgotPassOtpPage> {
  late String verId;
  final AppServices getServ = AppServices();
  final FirebaseAuth authLog = FirebaseAuth.instance;
  Color accentPurpleColor = const Color(0xFF6A53A1);
  final TextEditingController otpNumber = TextEditingController();

  final int timerOtp = 60;
  int start = 60;
  bool wait = true;

  TextStyle? createStyle() {
    TextStyle theme = TextStyle(
        fontSize: Dimentions.font25,
        fontWeight: FontWeight.w500,
        color: Colors.white
    );
    return theme;
  }

  void startTimer() {
    setState(() {
      start = timerOtp;
      wait = true;
    });
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    startTimer();
    verId = widget.verificationId;
    super.initState();
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

    return WillPopScope(
      onWillPop: () async {
        bool check = false;
        await onBackButtonPressYesNo(context: context, text: "Batalkan Verifikasi", desc: "Yakin ingin membatakan verifikasi?").then((value){
          check = value;
        });
        if(check){
          Get.toNamed(RouteHalper.getLoginPage());
        }
        return check;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF181A20),
          body: BounceInDown(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.imageSecurity,
                  width: Dimentions.imageSize150,
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
                const SizedBox(
                  height: 28,
                ),
                Padding(
                  padding: EdgeInsets.only(left: Dimentions.width20, right: Dimentions.width20),
                  child: Container(
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
                            otpNumber.text = verCode;
                          },
                        ),
                        SizedBox(
                          height: Dimentions.height20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(otpNumber.text.length > 5){
                                getServ.loading(context);
                                try{
                                  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber.text);
                                  UserCredential userPhone = await authLog.signInWithCredential(credential);
                                  String uidPhone = userPhone.user!.uid;

                                  var getUser = await getServ.getDocumentByColumn(Collections.users, Collections.collColumnuidphone, uidPhone);

                                  if(getUser != null){
                                    Map<String, dynamic> toMap = getUser.data() as Map<String, dynamic>;
                                    UserModel setUser = UserModel.fromMap(toMap);

                                    Navigator.of(context).pop();
                                    Get.toNamed(RouteHalper.getForgotChangePassPage(userId: setUser.id));
                                  }else{
                                    Navigator.of(context).pop();
                                    authLog.signOut();
                                    showAwsBar(context: context, contentType: ContentType.help, msg: "Akun dengan indetitas tidak ditemukan", title: "OTP!");
                                    Get.toNamed(RouteHalper.getLoginPage());
                                  }
                                }on FirebaseAuthException catch(e){
                                  Navigator.of(context).pop();
                                  showAwsBar(context: context, contentType: ContentType.failure, msg: "Kode OTP Tidak Sesuai", title: "");
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              }else{
                                showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan 6 digit kode OTP", title: "OTP!");
                              }
                              otpNumber.clear();
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
                ),
                SizedBox(
                  height: Dimentions.height15,
                ),
                Text(
                  "Belum menerima kode otp?",
                  style: TextStyle(
                    fontSize: Dimentions.font13,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: Dimentions.height2,
                ),
                InkWell(
                  onTap:  wait == false ? () async {
                    getServ.loading(context);
                    String phone = "+${widget.phone}";

                    await authLog.verifyPhoneNumber(
                      phoneNumber: phone,
                      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
                        await authLog.signInWithCredential(phoneAuthCredential);
                      },
                      verificationFailed: (error) {
                        showAwsBar(context: context, contentType: ContentType.warning, msg: error.message.toString(), title: "");
                      },
                      codeSent: (verificationId, forceResendingToken) {
                        Navigator.of(context).pop();
                        setState(() {
                          verId = verificationId;
                        });
                        startTimer();
                        showAwsBar(context: context, contentType: ContentType.success, msg: "Kode OTP telah dikirim, silahkan masukkan", title: "Success OTP");
                      },
                      codeAutoRetrievalTimeout: (verificationId) {},
                    );
                  } : null,
                  child: Text(
                    "Kirim ulang OTP",
                    style: TextStyle(
                      fontSize: Dimentions.font17,
                      fontWeight: FontWeight.bold,
                      color: wait == false ? Colors.purple : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if(wait == true)
                  SizedBox(
                    height: Dimentions.height4,
                  ),
                if(wait == true)
                  Text(
                    "00:${start < 10 ? "0" : ""}$start",
                    style: TextStyle(fontSize: Dimentions.font16, color: Colors.pinkAccent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
