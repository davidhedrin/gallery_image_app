import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/halper/route_halper.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/providers/app_services.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../widgets/loading_progres.dart';

class AuthProvider extends ChangeNotifier{
  AppServices appProvider = AppServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;

  late String smsOtp;
  late String verificationId;
  late UserModel _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isValidPhone = false;
  bool get isValidPhone => _isValidPhone;

  Future<bool> verifyPhone({required BuildContext context, required String number, required UserModel data}) async {
    bool result = false;
    BuildContext dialogcontext = context;
    try {
      _isLoading = true;
      showLoading(dialogcontext);

      bool existUser = await getDataDocumentByColumn(context: context, collection: Collections.users, column: "phone", param: number);
      if(existUser == false){
        bool checkUser = await checkNumberUser(context: context, number: number);
        if(checkUser){
          _userModel = data;
          await _auth.verifyPhoneNumber(
            phoneNumber: number,
            verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
              await _auth.signInWithCredential(phoneAuthCredential);
            },
            verificationFailed: (error) {
              showAwsBar(context: context, contentType: ContentType.warning, msg: error.message.toString(), title: "");
            },
            codeSent: (verificationId, forceResendingToken) {
              Get.toNamed(RouteHalper.getOtpPage(verId: verificationId));
              showAwsBar(context: context, contentType: ContentType.success, msg: "Kode OTP telah dikirim, silahkan masukkan", title: "Success OTP");
            },
            codeAutoRetrievalTimeout: (verificationId) {},
          );
          result = true;
        }else{
          result = false;
          Navigator.of(dialogcontext).pop();
          showAwsBar(context: context, contentType: ContentType.warning, msg: "Nomor tidak dapat digunakan", title: "");
        }
      }else{
        result = false;
        Navigator.of(dialogcontext).pop();
        showAwsBar(context: context, contentType: ContentType.help, msg: "Nomor sudah terdaftar", title: "");
      }

      _isLoading = false;
    } on FirebaseAuthException catch(e){
      _isLoading = false;
      showSnackBar(context, "ErrorVerifyPhone | Terjadi kesalahan, Ulangi beberapa saat lagi!");
      notifyListeners();
      Navigator.of(dialogcontext).pop();
    }

    return result;
  }

  Future<void> verifyOtp({required BuildContext context, required String verId, required String otp}) async {
    _isLoading = true;
    notifyListeners();

    late UserCredential userPhone;
    late UserCredential userEmail;
    BuildContext dialogcontext = context;

    try{
      showLoading(dialogcontext);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verId, smsCode: otp);

      String guid = "user-${AppServices().generateGuid()}";
      String email = _userModel.email;
      String password = _userModel.password;

      userPhone = await _auth.signInWithCredential(credential);
      String uidPhone = userPhone.user!.uid;

      _auth.signOut();

      userEmail = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uidEmail = userEmail.user!.uid;

      _userModel.id = guid;
      _userModel.uidPhone = uidPhone;
      _userModel.uidEmail = uidEmail;

     appProvider.createDataToDb(
        data: _userModel.toMap(),
        guid: guid,
        context: context,
        collection: Collections.users,
      );

      _isLoading = false;
      notifyListeners();
      Navigator.of(dialogcontext).pop();
      Get.toNamed(RouteHalper.getInitial(uid: guid));
    } on FirebaseAuthException catch(e){
      showAwsBar(context: context, contentType: ContentType.failure, msg: "Kode OTP Tidak Sesuai", title: "");
      _isLoading = false;
      notifyListeners();
      Navigator.of(dialogcontext).pop();
    }
  }

  Future<bool> checkNumberUser({required BuildContext context, required String number}) async {
    bool result = false;

    try{
      DocumentSnapshot  snapshot = await _fbStore.collection(Collections.usermaster).doc(number).get();
      if(snapshot.exists){
        result = true;
      }
    } on FirebaseException catch (e){
      print(e.message);
      showSnackBar(context, "ErrorCheckNumberUser | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }

    return result;
  }

  Future<bool> checkExistUser({required BuildContext context, required String uid}) async {
    bool result = false;

    try{
      DocumentSnapshot snapshot = await _fbStore.collection(Collections.users).doc(uid).get();

      if(snapshot.exists){
        result = true;
      }
    } on FirebaseException catch (e){
      showSnackBar(context, "ErrorCheckExistsUser | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }

    return result;
  }

  Future<bool> getDataDocumentByColumn({required BuildContext context, required String collection, required String column, required String param}) async {
    bool result = false;

    try{
      QuerySnapshot snapshot = await _fbStore.collection(collection).where(column, isEqualTo: param).get();
      if(snapshot.docs.isNotEmpty){
        String dataId = snapshot.docs.first.id;
        DocumentSnapshot dataSnap = await _fbStore.collection(collection).doc(dataId).get();
        if(dataSnap.exists){
          result = true;
        }
      }
    } on FirebaseException catch(e){
      showSnackBar(context, "ErrorGetDataByID | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }

    return result;
  }

  Future<User?> getCurrentUserLogin() async {
    return _auth.currentUser;
  }

  showLoading(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          context = context;
          return const LoadingProgress();
        }
    );
  }
}