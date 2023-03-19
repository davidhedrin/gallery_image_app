// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../generated/assets.dart';
import '../../halper/route_halper.dart';
import '../../models/user_model.dart';
import '../../providers/app_services.dart';
import '../../utils/collections.dart';
import '../../utils/dimentions.dart';
import '../../utils/utils.dart';
import '../../widgets/auth_widget/text_widget.dart';

class ForgotChangePassPage extends StatefulWidget {
  final String userId;
  const ForgotChangePassPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ForgotChangePassPage> createState() => _ForgotChangePassPageState();
}

class _ForgotChangePassPageState extends State<ForgotChangePassPage> {
  final formKey = GlobalKey<FormState>();
  final AppServices getService = AppServices();
  final FirebaseAuth authLog = FirebaseAuth.instance;
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController newCoPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool check = false;
        await onBackButtonPressYesNo(context: context, text: "Batalkan password", desc: "Yakin ingin membatakan ubah password?").then((value){
          check = value;
        });
        if(check){
          Get.toNamed(RouteHalper.getLoginPage());
        }
        return check;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text('Atur Ulang Password', style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () async {
              bool check = false;
              await onBackButtonPressYesNo(context: context, text: "Batalkan password", desc: "Yakin ingin membatakan ubah password?").then((value){
                check = value;
              });
              if(check){
                Get.toNamed(RouteHalper.getLoginPage());
              }
            },
          ),
        ),
        body: FadeInDown(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.imageChangePassword, width: Dimentions.imageSize240,),
              SizedBox(height: Dimentions.height10,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimentions.width25),
                child: Text('Ingat dan simpan password baru. Dan pastikan tidak memberikan kepada siapapun!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: Dimentions.font14, color: Colors.white70),),
              ),

              SizedBox(height: Dimentions.height15,),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                      child: MyTextFieldReg(
                        controller: newpasswordController,
                        hintText: "Masukkan Password Baru",
                        obscureText: true,
                        validator: (value){
                          if(newpasswordController.text != newCoPasswordController.text){
                            return '*password tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: Dimentions.height15,),

                    Padding(
                      padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
                      child: MyTextFieldReg(
                        controller: newCoPasswordController,
                        hintText: "Konfirmasi Password Baru",
                        obscureText: true,
                        validator: (value){
                          if(newCoPasswordController.text != newpasswordController.text){
                            return '*password tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Dimentions.height20,),

              Padding(
                padding:  EdgeInsets.symmetric(horizontal: Dimentions.height25),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(newpasswordController.text.isNotEmpty && newCoPasswordController.text.isNotEmpty){
                        if(formKey.currentState!.validate()){
                          bool check = false;
                          await onBackButtonPressYesNo(context: context, text: "Kofirmasi Password", desc: "Lanjutkan untuk mengubah password").then((value){
                            check = value;
                          });
                          if(check ==  true){
                            getService.loading(context);

                            var getUser = await getService.getDocDataByDocId(context: context, collection: Collections.users, docId: widget.userId);

                            Map<String, dynamic> toMap = getUser!.data() as Map<String, dynamic>;
                            UserModel setUser = UserModel.fromMap(toMap);

                            String changePassword = newpasswordController.text;

                            try {
                              await authLog.signInWithEmailAndPassword(email: setUser.email, password: setUser.password);
                              await authLog.currentUser!.updatePassword(changePassword);
                              await getService.fbStore.collection(Collections.users).doc(widget.userId).update({
                                Collections.collColumnpassword : changePassword
                              });
                              showAwsBar(context: context, contentType: ContentType.success, msg: 'Berhasil memperbaharui password. Selamat datang kembali "${setUser.namaLengkap}"', title: "Welcome!");
                            } on FirebaseAuthException catch (e) {
                              Navigator.of(context).pop();
                              showAwsBar(context: context, contentType: ContentType.help, msg: "Gagal memperbaharui password. Hubungi admin!", title: "Opss...");
                              if (kDebugMode) {
                                print('Error signing in: ${e.message}');
                              }
                              return;
                            }
                          }
                        }
                      }else{
                        showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan password baru", title: "Validasi!");
                      }
                    },
                    style: ButtonStyle(
                      foregroundColor:MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimentions.screenHeight/150.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimentions.height15, horizontal: Dimentions.width15),
                      child: Text(
                        'Simpan',
                        style: TextStyle(fontSize: Dimentions.font20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
