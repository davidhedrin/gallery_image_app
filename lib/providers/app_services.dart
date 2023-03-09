import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:delivery_food_app/models/message/message_data.dart';
import 'package:delivery_food_app/models/posting_image.dart';
import 'package:delivery_food_app/models/user_master_model.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../component/main_app_page.dart';
import '../halper/route_halper.dart';
import '../models/user_group.dart';
import '../widgets/loading_progres.dart';

class AppServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;
  final FirebaseStorage _fbStorage = FirebaseStorage.instance;

  FirebaseFirestore get fbStore => _fbStore;

  CollectionReference userCollec = FirebaseFirestore.instance.collection(Collections.users);

  static late UserModel loginUser;
  UserModel get getUserLogin => loginUser;
  static FirebaseMessaging fbNotif = FirebaseMessaging.instance;

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

  void logout(){
    MainAppPage.groupNameGet = "";
    MainAppPage.groupCodeId = "";
    MainAppPage.setUserId = "";

    FirebaseAuth.instance.signOut();
    Get.toNamed(RouteHalper.getLoginPage());
  }

  void setStatus({required String status, required String userId}) async {
    Map<String, dynamic> setUpdate = {
      Collections.collColumnstatus : status,
      Collections.collColumnpushtoken : await getNotifToken(),
    };
    if(status == "2"){
      setUpdate[Collections.collColumnlastonline] = DateTime.now();
    }

    await _fbStore.collection(Collections.users).doc(userId).update(setUpdate);
  }

  Future<String> getNotifToken() async {
    return await fbNotif.getToken().then((token) {
      String result = "";
      if(token != null){
        result = token;
      }
      return result;
    });
  }

  static Future<void> sendPushNotif({required UserModel getUser, required String from, required String msg, required String roomId}) async {
    try{
      final body = <String, dynamic>{
        "to": getUser.pushToken,
        "priority": "high",
        "notification": <String, dynamic>{
          "title": from,
          "body": msg,
          "android_channel_id": Collections.androidChanId
        },
        "data": <String, dynamic>{
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "status": "done",
          "title": from,
          "body": msg,
          "some_data" : "$roomId",
        },
      };
      Map<String, String> header = {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "key=${Collections.bearerTokenNotif}",
      };

      var url = Uri.parse(Collections.hostUrlNotif);
      var res = await post(
          url,
          headers: header,
          body: jsonEncode(body)
      );
      
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> getUserLoginModel(String userId) async {
    await _fbStore.collection(Collections.users).doc(userId).get().then((user) {
      if(user.exists){
        Map<String, dynamic> getMap = user.data() as Map<String, dynamic>;
        UserModel fromMap = UserModel.fromMap(getMap);
        loginUser = fromMap;
      }else{
        logout();
      }
    });

    setStatus(status: "1", userId: userId);
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

      DocumentSnapshot docUser = await getDocumentByColumn(Collections.users, "uidEmail", uidEm);
      String uid = docUser.id;

      result["status"] = "200";
      result["uid"] = uid;
    } on FirebaseAuthException catch(e) {
      result["status"] = "400";
      print("David:"+e.message.toString());
    }
    return result;
  }

  //create new data coll
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

  //create coll in coll
  void createDataToDbInCollec({
    required Map<String, dynamic>data,
    required BuildContext context,
    required String collection1,
    required String collection2,
    required String guid1,
    required String guid2,
  }) async {
    try{
      await _fbStore.collection(collection1).doc(guid1).collection(collection2).doc(guid2).set(data);
    } on FirebaseException catch (e){
      showSnackBar(context, "CreateDataToDbInCollec | $e");
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

  void deleteFullUserAccount({required BuildContext context, required String uid, required String phone}) async {
    try{
      DocumentReference<Map<String, dynamic>> getUser = fbStore.collection(Collections.users).doc(uid);
      DocumentReference<Map<String, dynamic>> getUserMaster = fbStore.collection(Collections.usermaster).doc(phone);

      DocumentSnapshot<Map<String, dynamic>> getUM = await getUserMaster.get();
      DocumentSnapshot<Map<String, dynamic>> getUs = await getUser.get();

      // Start delete user from firebase Autheticate
      Map<String, dynamic> mapUser = getUs.data() as Map<String, dynamic>;
      UserModel fromMapUs = UserModel.fromMap(mapUser);
      // End delete user

      // Start delete posted image
      Map<String, dynamic> mapUserMaster = getUM.data() as Map<String, dynamic>;
      UserMasterModel fromMapUM = UserMasterModel.fromMap(mapUserMaster);

      List<Map<String, dynamic>> groupArray = fromMapUM.groupMap!;
      List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
        UserGroupModel getGroup = UserGroupModel.fromMap(res);
        return getGroup;
      }).toList();

      List<Future<QuerySnapshot>> futures = toModelGroup.map((model) {
        return fbStore.collection(model.nama_group.toLowerCase()).get();
      }).toList();

      List<QuerySnapshot> snapshots = await Future.wait(futures);

      for (var snapshot in snapshots){
        var docsSnap = snapshot.docs.where((item) => item.get(Collections.collColumnuserById) == uid);
        if(docsSnap.isNotEmpty){
          for(var element in docsSnap){
            Map<String, dynamic> getMapImage = element.data() as Map<String, dynamic>;
            PostingImageModel fromMapImage = PostingImageModel.fromMap(getMapImage);

            await _fbStorage.ref().child("${fromMapImage.imageGroup}/${fromMapImage.imageId}").delete();
            await element.reference.delete();
          }
        }
      }
      // End delete posted image

      await getUserMaster.delete();
      await getUser.delete();
    } catch (e) {
      showAwsBar(context: context, contentType: ContentType.warning, msg: e.toString(), title: "Delete!");
      return;
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

  Future<bool> downloadFile(Reference refStorage, String fileName, BuildContext context) async {
    bool finish = false;

    final tempDir = await getTemporaryDirectory();
    final path = "${tempDir.path}/$fileName.jpg";

    try{
      String imageUrl = await refStorage.getDownloadURL();
      await Dio().download(
          imageUrl,
          path,
          onReceiveProgress: (reciv, total){
            double progress = reciv/total;
            if(progress == 1.0){
              finish = true;
            }
          }
      );
    }catch(e){
      finish == false;
    }

    if(finish == false){
      showSnackBar(context, "downloadFile | Terjadi kesalahan, Ulangi beberapa saat lagi!");
    }
    await GallerySaver.saveImage(path, toDcim: true);

    return finish;
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

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamGetDocById({required String collection, required String docId}) {
    return _fbStore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot<Object?>> streamGetCollecInColect({required String collection1, required String collection2, required String docId}) {
    return _fbStore.collection(collection1).doc(docId).collection(collection2).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamGetDocByColumn({required String collection, required String collName, required String value}){
    return _fbStore.collection(collection).where(collName, isEqualTo: value).snapshots();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> streamColNotEqualById({required String collection, required String value}){
    return _fbStore.collection(collection).where(FieldPath.documentId, isNotEqualTo: value).snapshots();
  }

  //delete doc coll in coll
  void deleteDataCollecInCollec({
    required BuildContext context,
    required String collection1,
    required String collection2,
    required String guid1,
    required String guid2,
  }) async {
    try{
      await _fbStore.collection(collection1).doc(guid1).collection(collection2).doc(guid2).delete();
    } on FirebaseException catch (e){
      showSnackBar(context, "DeleteDataCollecInCollec | $e");
    }
  }

  Future<QuerySnapshot<Object?>> getAllDocuments(String collection) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
    return snapshot;
  }

  Future<List<PostingImageModel>> getAllDocFromListColl(List<dynamic> models) async {
    List<Future<QuerySnapshot>> futures = models.map((model) {
      return FirebaseFirestore.instance.collection(model.nama_group.toLowerCase()).get();
    }).toList();

    List<QuerySnapshot> snapshots = await Future.wait(futures);

    List<PostingImageModel> documents = snapshots.expand((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> getMap = doc.data() as Map<String, dynamic>;
        PostingImageModel fromMap = PostingImageModel.fromMap(getMap);
        return fromMap;
      });
    }).toList();

    return documents;
  }

  Future<bool> checkExistDocById({required String collection, required String uid}) async {
    bool result = false;

    try{
      DocumentSnapshot snapshot = await _fbStore.collection(collection).doc(uid).get();

      if(snapshot.exists){
        result = true;
      }
    } on FirebaseException catch (e){
      print(e.message);
    }

    return result;
  }

  void sendMessage({
    required Map<String, dynamic>data,
    required Map<String, dynamic>dataMsg,
    required String collection,
    required String chatId,
    required String docIdMsg,

    required UserModel forUser,
  }) async {
    try{
      MessageData msgData = MessageData.fromMapNotif(dataMsg);

      await _fbStore.collection(collection).doc(chatId).set(data); //Add Master Chat
      final DocumentReference setMessage = FirebaseFirestore.instance.collection(collection).doc(chatId); //Add message chat
      setMessage.collection(Collections.message).doc(docIdMsg).set(dataMsg)
      .then((value) => sendPushNotif(getUser: forUser, from: loginUser.nama_lengkap, msg: msgData.type == Type.text ? msgData.msg : "Image", roomId: chatId));
    }catch(e){
      print(e.toString());
    }
  }
  void saveMessage({
    required Map<String, dynamic>dataMsg,
    required String collection,
    required String chatId,
    required String docIdMsg,

    required UserModel forUser,
  }) async {
    try{
      MessageData msgData = MessageData.fromMapNotif(dataMsg);

      final DocumentReference setMessage = FirebaseFirestore.instance.collection(collection).doc(chatId); //Add message chat
      setMessage.collection(Collections.message).doc(docIdMsg).set(dataMsg)
      .then((value) => sendPushNotif(getUser: forUser, from: loginUser.nama_lengkap, msg: msgData.type == Type.text ? msgData.msg : "Image", roomId: chatId));
    }catch(e){
      print(e.toString());
    }
  }
}