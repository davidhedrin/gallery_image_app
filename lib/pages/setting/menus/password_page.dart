import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:delivery_food_app/generated/assets.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../providers/app_services.dart';
import '../../../utils/dimentions.dart';
import '../../../utils/utils.dart';
import '../../../widgets/auth_widget/text_widget.dart';
import '../../../widgets/small_text.dart';

class ChangePasswordPage extends StatefulWidget {
  final UserModel setUser;
  const ChangePasswordPage({Key? key, required this.setUser}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final AppServices getService = AppServices();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  final TextEditingController newCoPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserModel getUser = widget.setUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Atur Password', style: TextStyle(color: Colors.black87),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: const Divider(height: 1, color: Colors.black87),
            ),
            SizedBox(height: Dimentions.height15,),

            Image.asset(Assets.imagePasswordChange),

            SizedBox(height: Dimentions.height15,),

            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: MyTextFieldReg(
                controller: passwordController,
                hintText: "Masukkan Password Lama",
                obscureText: true,
              ),
            ),

            SizedBox(height: Dimentions.height15,),

            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: MyTextFieldReg(
                controller: newpasswordController,
                hintText: "Masukkan Password Baru",
                obscureText: true,
              ),
            ),

            SizedBox(height: Dimentions.height15,),

            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: MyTextFieldReg(
                controller: newCoPasswordController,
                hintText: "Konfirmasi Password Baru",
                obscureText: true,
              ),
            ),

            SizedBox(height: Dimentions.height20,),

            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: MaterialButton(
                minWidth: double.infinity,
                onPressed: () async {
                  bool check = false;
                  await onBackButtonPressYesNo(context: context, text: "Konfirmasi Password", desc: "Yakin ingin mengubah password?").then((value){
                    check = value;
                  });
                  String changePassword = newpasswordController.text.isEmpty ? getUser.password : newpasswordController.text;

                  if(check == true){
                    getService.loading(context);

                    if(passwordController.text.isNotEmpty){
                      if(passwordController.text == getUser.password){
                        if(newpasswordController.text.isNotEmpty && newCoPasswordController.text.isNotEmpty){
                          if(newpasswordController.text == newCoPasswordController.text){
                            // Sign in with the user's email and old password
                            try {
                              await getService.fbAuth.signInWithEmailAndPassword(email: getUser.email, password: getUser.password);
                            } on FirebaseAuthException catch (e) {
                              // Handle sign-in errors here
                              if (kDebugMode) {
                                print('Error signing in: ${e.message}');
                              }
                              return;
                            }

                            try {
                              await getService.fbAuth.currentUser!.updatePassword(changePassword).then((value) async {
                                await getService.fbStore.collection(Collections.users).doc(getUser.id).update({
                                  Collections.collColumnpassword : changePassword
                                });
                              });

                              getService.logout();
                            } on FirebaseAuthException catch (e) {
                              Navigator.of(context).pop();
                              showAwsBar(context: context, contentType: ContentType.help, msg: "Gagal memperbaharui password. Hubungi admin!", title: "Opss...");
                              if (kDebugMode) {
                                print('Error changing password: ${e.message}');
                              }
                              return;
                            }

                            Navigator.of(context).pop();
                            showAwsBar(context: context, contentType: ContentType.success, msg: "Berhasil memperbaharui password. Silahkan login kembali menggunakan password baru.", title: "Password");
                          }else{
                            showAwsBar(context: context, contentType: ContentType.help, msg: "Password baru dan konfirmasi password tidak sama!", title: "Opss...");
                          }
                        }else{
                          showAwsBar(context: context, contentType: ContentType.help, msg: "Masukkan password baru!", title: "Opss...");
                        }
                      }else{
                        showAwsBar(context: context, contentType: ContentType.warning, msg: "Password lama tidak sesuai!", title: "Opss...");
                      }
                    }
                  }
                },
                color: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimentions.screenHeight/156.21)
                ),
                padding: EdgeInsets.symmetric(vertical: Dimentions.font16, horizontal: Dimentions.width30),
                child: Text("Simpan", style: TextStyle(fontSize: Dimentions.font16, color: Colors.white),),
              ),
            ),

            SizedBox(height: Dimentions.height10,),

            Padding(
              padding: EdgeInsets.only(left: Dimentions.width25, right: Dimentions.width25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SmallText(text: "* pastikan anda mengingat kata sandi baru yang telah diubah!", color: Colors.black54, fontStyle: FontStyle.italic,)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
