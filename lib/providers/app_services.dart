// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:delivery_food_app/models/posting_image.dart';
import 'package:delivery_food_app/models/user_master_model.dart';
import 'package:delivery_food_app/models/user_model.dart';
import 'package:delivery_food_app/utils/collections.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart' as getdart;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_food_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

import '../component/main_app_page.dart';
import '../halper/route_halper.dart';
import '../models/user_group.dart';
import '../models/user_group_master_model.dart';
import '../widgets/loading_progres.dart';

class AppServices{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fbStore = FirebaseFirestore.instance;
  final FirebaseStorage _fbStorage = FirebaseStorage.instance;

  FirebaseFirestore get fbStore => _fbStore;
  FirebaseAuth get fbAuth => _auth;

  CollectionReference userCollec = FirebaseFirestore.instance.collection(Collections.users);

  static late UserModel loginUser;
  UserModel get getUserLogin => loginUser;

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

  void logout() async {
    MainAppPage.groupNameGet = "";
    MainAppPage.groupCodeId = "";
    MainAppPage.setUserId = "";


    Map<String, dynamic> setUpdate = {Collections.collColumnpushtoken : "-"};
    await _fbStore.collection(Collections.users).doc(loginUser.id).update(setUpdate);
    setStatus(status: "2", userId: loginUser.id);
    _auth.signOut();
    loginUser = UserModel();
    getdart.Get.toNamed(RouteHalper.getLoginPage());
  }

  void setStatus({required String status, required String userId}) async {
    Map<String, dynamic> setUpdate = {
      Collections.collColumnstatus : status,
    };
    if(status == "1"){
      String? pushToken = await FirebaseMessaging.instance.getToken();
      setUpdate[Collections.collColumnpushtoken] = pushToken;
    }
    if(status == "2"){
      setUpdate[Collections.collColumnlastonline] = DateTime.now();
    }

    await _fbStore.collection(Collections.users).doc(userId).update(setUpdate);
  }

  static Future<void> sendPushNotif({required String token, required String from, required String msg, required String roomId}) async {
    try{
      final body = <String, dynamic>{
        "to": token,
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
          "some_data" : <String, dynamic> {
            "room_id" : roomId,
            "from_id" : AppServices().getUserLogin.id
          },
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

      String responseStat = 'Response status: ${res.statusCode}';
      if (kDebugMode) {
        print(responseStat);
        print('Response body: ${res.body}');
      }
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
      if (kDebugMode) {
        print("loginWithEmail: ${e.message}");
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> loginWithEmailRetMap(BuildContext context, String email, String password) async {
    Map<String, dynamic> result = {};
    try{
      UserCredential userEmail = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uidEm = userEmail.user!.uid;

      DocumentSnapshot? docUser = await getDocumentByColumn(Collections.users, "uidEmail", uidEm);
      String uid = docUser!.id;

      result["status"] = "200";
      result["uid"] = uid;
    } on FirebaseAuthException catch(e) {
      result["status"] = "400";
      if (kDebugMode) {
        print("loginWithEmailRetMap: ${e.message}");
      }
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
      // DocumentSnapshot<Map<String, dynamic>> getUs = await getUser.get();

      Map<String, dynamic> mapUserMaster = getUM.data() as Map<String, dynamic>;
      UserMasterModel fromMapUM = UserMasterModel.fromMap(mapUserMaster);

      List<Map<String, dynamic>> groupArray = fromMapUM.groupMap!;
      List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
        UserGroupModel getGroup = UserGroupModel.fromMap(res);
        return getGroup;
      }).toList();

      // Start delete posted image
      List<Future<QuerySnapshot>> futures = toModelGroup.map((model) {
        return fbStore.collection(model.namaGroup.toLowerCase()).get();
      }).toList();

      List<QuerySnapshot> snapshots = await Future.wait(futures);

      for (var snapshot in snapshots){
        var docsSnap = snapshot.docs.where((item) => item.get(Collections.collColumnuserById) == uid);
        if(docsSnap.isNotEmpty){
          for(var elementLike in snapshot.docs){
            Map<String, dynamic> getMapImage = elementLike.data() as Map<String, dynamic>;
            PostingImageModel fromMapImage = PostingImageModel.fromMap(getMapImage);

            await _fbStore.collection(fromMapImage.imageGroup.toLowerCase()).doc(fromMapImage.imageId).collection(Collections.likes).doc(uid).delete();
          }

          for(var element in docsSnap){
            Map<String, dynamic> getMapImage = element.data() as Map<String, dynamic>;
            PostingImageModel fromMapImage = PostingImageModel.fromMap(getMapImage);

            await _fbStorage.ref().child("${fromMapImage.imageGroup}/${fromMapImage.imageId}").delete();
            await element.reference.delete();
          }
        }
      }
      // End delete posted image

      // Start delete user chat
      List<Future<QuerySnapshot>> futuresChat = toModelGroup.map((model) {
        return fbStore.collection("chat-${model.namaGroup.toLowerCase()}").get();
      }).toList();

      List<QuerySnapshot> snapshotsChat = await Future.wait(futuresChat);

      for (var snapshot in snapshotsChat){
        var docsChat = snapshot.docs.where((doc) => doc.get('userId').contains(uid));
        if(docsChat.isNotEmpty){
          for(var itemChat in docsChat){
            var msgData = await itemChat.reference.collection(Collections.message).get();
            for (var doc in msgData.docs) {
              await doc.reference.delete();
            }
            await itemChat.reference.delete();
          }
        }
      }
      // End delete user chat

      await getUserMaster.delete();
      await getUser.delete();
      // Start delete user from firebase Autheticate
      // Map<String, dynamic> mapUser = getUs.data() as Map<String, dynamic>;
      // UserModel fromMapUs = UserModel.fromMap(mapUser);
      //
      // final FirebaseAuth authLog = FirebaseAuth.instance;
      // await authLog.signInWithEmailAndPassword(email: fromMapUs.email, password: fromMapUs.password);
      // User setUser = authLog.currentUser!;
      // await setUser.delete();
      // authLog.signOut();
      // End delete user
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
      if (kDebugMode) {
        print("getDocDataByDocId: $e");
      }
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
      if (kDebugMode) {
        print("getDocDataByDocIdNoCon: $e");
      }
    }
    return result;
  }

  // Get the document from the collection with a specific condition
  Future<DocumentSnapshot?> getDocumentByColumn(String collectionName, String column, String value) async {
    DocumentSnapshot? document;

    try{
      document = await _fbStore
          .collection(collectionName)
          .where(column, isEqualTo: value).get()
          .then((QuerySnapshot snap) {
        return snap.docs.first;
      });
    }catch(e){
      if (kDebugMode) {
        print("getDocumentByColumn: $e");
      }
    }

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
      if (kDebugMode) {
        print("uploadImageToStorage: $e");
      }
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
      if (kDebugMode) {
        print("downloadFile: $e");
      }
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
      if (kDebugMode) {
        print("deleteFileStorage: $e");
      }
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

  void deleteDocById({required String collection, required docId}) async {
    await fbStore.collection(collection).doc(docId).delete();
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

  //delete coll in coll
  void deleteCollecInCollec({
    required String collection1,
    required String collection2,
    required String guid1,
  }) async {
    try{
      await _fbStore.collection(collection1).doc(guid1).collection(collection2).get().then((querySnapshot){
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    } on FirebaseException catch (e){
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<QuerySnapshot<Object?>> getAllDocuments(String collection) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
    return snapshot;
  }

  Future<List<PostingImageModel>> getAllDocFromListColl(List<dynamic> models) async {
    List<Future<QuerySnapshot>> futures = models.map((model) {
      return FirebaseFirestore.instance.collection(model.namaGroup.toLowerCase()).get();
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
      if (kDebugMode) {
        print("checkExistDocById: $e");
      }
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
      await _fbStore.collection(collection).doc(chatId).set(data); //Add Master Chat
      final DocumentReference setMessage = FirebaseFirestore.instance.collection(collection).doc(chatId); //Add message chat
      setMessage.collection(Collections.message).doc(docIdMsg).set(dataMsg).then((value){
        String from = loginUser.namaLengkap;
        String msg = dataMsg["msg"];
        sendPushNotif(token: forUser.pushToken, from: from, msg: msg, roomId: chatId);
      });
    }catch(e){
      if (kDebugMode) {
        print("sendMessage: $e");
      }
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
      final DocumentReference setMessage = FirebaseFirestore.instance.collection(collection).doc(chatId); //Add message chat
      setMessage.collection(Collections.message).doc(docIdMsg).set(dataMsg).then((value){
        String from = loginUser.namaLengkap;
        String msg = dataMsg["msg"];
        sendPushNotif(token: forUser.pushToken, from: from, msg: msg, roomId: chatId);
      });
    }catch(e){
      if (kDebugMode) {
        print("saveMessage: $e");
      }
    }
  }

  Future<UserGroupModel> getFirstGroupUser(String phone) async {
    UserGroupModel group = UserGroupModel();

    var getGroup = await streamBuilderGetDoc(collection: Collections.usermaster, docId: phone).first;
    Map<String, dynamic> listMap = List.from(getGroup.get("group")).first;
    group = UserGroupModel.fromMap(listMap);

    return group;
  }

  Future<List<PostingImageModel>> getAllDocImagePosting({required BuildContext context, required String phone, required String userId}) async {
    var getUserMaster = await getDocDataByDocId(context: context, collection: Collections.usermaster, docId: phone);
    List<Map<String, dynamic>> groupArray = List.from(getUserMaster!.get("group"));
    List<UserGroupModel> toModelGroup = groupArray.map((Map<String, dynamic> res){
      UserGroupModel getGroup = UserGroupModel.fromMap(res);
      return getGroup;
    }).toList();

    List<Future<QuerySnapshot>> futures = toModelGroup.map((model) {
      return FirebaseFirestore.instance.collection(model.namaGroup.toLowerCase()).get();
    }).toList();

    List<QuerySnapshot> snapshots = await Future.wait(futures);

    List<PostingImageModel> documents = snapshots.expand((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> getMap = doc.data() as Map<String, dynamic>;
        PostingImageModel fromMap = PostingImageModel.fromMap(getMap);
        return fromMap;
      });
    }).toList();

    return documents.where((item) => item.userById == userId).toList();
  }

  Stream<QuerySnapshot> streamSearchItemWithColumn({
    required String collection,
    required String column,
    required String value
  }) {
    return  _fbStore.collection(collection).where(column, isGreaterThanOrEqualTo: value).where(column, isLessThanOrEqualTo: '$value\uf8ff').snapshots();
  }

  Stream<List<dynamic>> getAllCollectionMessages(List<UserGroupMasterModel> groups) {
    final List<Stream<List<dynamic>>> collectionStreams = [];

    for (var item in groups) {
      String collectionMsg = "chat-${item.namaGroup.toLowerCase()}";
      final CollectionReference collectionRef = FirebaseFirestore.instance.collection(collectionMsg);
      final stream = collectionRef.where(Collections.collColumnuserId, arrayContains: MainAppPage.setUserId).snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) => doc.data()).toList();
      });
      collectionStreams.add(stream);
    }

    var x = Rx.combineLatest(collectionStreams, (list) {
      final List<dynamic> result = [];
      for (List<dynamic> subList in list) {
        result.addAll(subList);
      }
      return result;
    });

    return x;
  }
}