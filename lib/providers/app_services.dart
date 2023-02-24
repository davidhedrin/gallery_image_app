import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../widgets/loading_progres.dart';

class AppServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;
  final FirebaseStorage _fbStorage = FirebaseStorage.instance;

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

  String generateGuid(){
    return const Uuid().v1();
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
  void createDataToDb({
    required Map<String, dynamic>data,
    required BuildContext context,
    required String collection,
    required String guid,
  }) async {
    try{
      await _fbStore.collection(collection).doc(guid).set(data);
    } on FirebaseException catch (e){
      showSnackBar(context, "CreateDataToDb | $e");
    }
  }

  void updateDataDb({
    required Map<String, dynamic>data,
    required BuildContext context,
    required String collection,
    required String guid
  }) async {
    try{
      await _fbStore.collection(collection).doc(guid).update(data);
    } on FirebaseException catch (e){
      showSnackBar(context, "UpdateDataDb | $e");
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

  Future<DocumentSnapshot?> getDocDataByDocIdNoCon({
    required String collection,
    required String docId
  }) async {
    DocumentSnapshot?  result;
    try{
      DocumentSnapshot snapshot = await _fbStore.collection(collection).doc(docId).get();
      result = snapshot;
    } on FirebaseException catch (e){
      print(e);
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamBuilderGetDoc({required String collection, required String docId}){
    return _fbStore.collection(collection).doc(docId).snapshots();
  }

  Future<Map<String, dynamic>> getColumnReferencedDoc(DocumentReference<Map<String, dynamic>> reference) async {
    Map<String, dynamic>? getData = await reference.get().then((DocumentSnapshot<Map<String, dynamic>> data) => data.data());
    return getData!;
  }

  Future<String> uploadImageToStorage({required BuildContext context, required String ref, required File file}) async {
    String result = "";

    try{
      UploadTask uploadTask = _fbStorage.ref().child(ref).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      result = downloadUrl;
    }on FirebaseException catch(e){
      showSnackBar(context, "uploadImageToStorage | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }

    return result;
  }

  void deleteFileStorage({required BuildContext context, required String imagePath}) async {
    try{
      await _fbStorage.ref().child(imagePath).delete();
    }on FirebaseException catch(e){
      showSnackBar(context, "deleteFileStorage | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }
  }

  Future<bool> checkFieldExist(String coll, String docId, String field) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection(coll)
        .doc(docId)
        .get();
    final data = docSnapshot.data();
    return data != null && data.containsKey(field);
  }

  Stream<QuerySnapshot<Object?>> streamObjGetCollection({required String collection}) {
    return _fbStore.collection(collection).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamGetCollecInColect({required String collection1, required String collection2, required String docId}) {
    return _fbStore.collection(collection1).doc(docId).collection(collection2).snapshots();
  }
}