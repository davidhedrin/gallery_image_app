import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../widgets/loading_progres.dart';

class AppServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;

  CollectionReference userCollec = FirebaseFirestore.instance.collection('users');

  void loading(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          context = context;
          return const LoadingProgress();
        }
    );
  }

  Future<String> loginWithEmail(BuildContext context, String email, String password) async {
    String result = "";
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      result = "200";
    } on FirebaseAuthException catch(e) {
      result = "400";
      print("David:"+e.message.toString());
    }
    return result;
  }

  Future<Map<String, dynamic>> loginWithEmailRetMap(BuildContext context, String email, String password) async {
    Map<String, dynamic> result = {};
    try{
      UserCredential userEmail = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uidEm = userEmail.user!.uid;

      DocumentSnapshot docUser = await getDocumentByColumn("users", "uidEmail", uidEm);
      String uid = docUser.id;

      result["status"] = "200";
      result["uid"] = uid;
    } on FirebaseAuthException catch(e) {
      result["status"] = "400";
      print("David:"+e.message.toString());
    }
    return result;
  }

  //create new user
  Future<void> createDataToDb({
    required Map<String, dynamic>values,
    required BuildContext context,
    required String collection,
    required String guid
  }) async {
    try{
      await _fbStore.collection(collection).doc(guid).set(values);
    } on FirebaseException catch (e){
      showAwsBar(context: context, contentType: ContentType.warning, msg: "Gagal mengunggah data! Ulangi beberapa saat lagi", title: "");
    }
  }

  Future<DocumentSnapshot?> getDocUidByColumn({
    required BuildContext context,
    required String collection,
    required String column,
    required String param,
  }) async {
    DocumentSnapshot? result;

    try{
      QuerySnapshot snapshot = await _fbStore.collection(collection).where(column, isEqualTo: param).get();
      if(snapshot.docs.isNotEmpty){
        String dataId = snapshot.docs.first.id;
        DocumentSnapshot dataSnap = await _fbStore.collection(collection).doc(dataId).get();
        if(dataSnap.exists){
          result = dataSnap;
        }
      }
    }catch(e){
      showSnackBar(context, "ErrorDocIdByColumn | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }

    return result;
  }

  Future<DocumentSnapshot?> getDocDataByDocId({
    required BuildContext context,
    required String collection,
    required String docId
  }) async {
    DocumentSnapshot?  result;
    try{
      DocumentSnapshot snapshot = await _fbStore.collection(collection).doc(docId).get();
      result = snapshot;
    } on FirebaseException catch (e){
      showSnackBar(context, "ErrorGetDataByDocId | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }
    return result;
  }

  // Get the document from the collection with a specific condition
  Future<DocumentSnapshot> getDocumentByColumn(String collectionName, String column, String value) async {
    DocumentSnapshot document = await _fbStore
        .collection(collectionName)
        .where(column, isEqualTo: value).get()
        .then((QuerySnapshot snap) {
      return snap.docs.first;
    });
    return document;
  }
}