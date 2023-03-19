// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void showAwsBar({required BuildContext context, required ContentType contentType, required String msg, required String title}){
  String titleBar = '^-^';
  if(title.isEmpty){
    if(contentType == ContentType.success){
      titleBar = "Success";
    }else if(contentType == ContentType.help){
      titleBar = "Help";
    }else if(contentType == ContentType.warning){
      titleBar = "Warning";
    }else if(contentType == ContentType.failure){
      titleBar = "Error";
    }
  }else{
    titleBar = title;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: titleBar,
        message: msg,
        contentType: contentType,
      ),
    )
  );
}


Future<File?> pickImageNoCrop(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    File? getCompress;
    try{
      getCompress = await customCompressedFile(context: context, image: File(pickedImage!.path));
    } catch (e) {
      if (kDebugMode) {
        print("pickImageNoCrop/customCompressedFile: $e");
      }
    }

    image = getCompress;
  } catch (e) {
    showSnackBar(context, e.toString());
    if (kDebugMode) {
      print("pickImageNoCrop: $e");
    }
  }

  return image;
}

Future<File?> pickImageCrop(BuildContext context) async {
  File? image;
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  CroppedFile? cropImage;
  if(pickedImage != null){
    try{
      cropImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1  ),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper Image',
              toolbarColor: Colors.blueAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true
          ),
          IOSUiSettings(
            title: 'Cropper Image',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
    } catch (e) {
      if (kDebugMode) {
        print("pickImageCrop/ImagePicker: $e");
      }
    }

    if(cropImage != null){
      image = File(cropImage.path);
    }
  }

  return image;
}

Future<File?> customCompressedFile({required BuildContext context, required File image, int quality = 100, int percentage = 10}) async {
  File? result;

  try{
    final pathImage = await FlutterNativeImage.compressImage(
      image.absolute.path,
      quality: quality,
      percentage: percentage,
    );
    
    result = pathImage;
  } catch (e) {
    showSnackBar(context, e.toString());
    if (kDebugMode) {
      print("customCompressedFile: $e");
    }
  }

  return result;
}

Future<bool> onBackButtonPressYesNo({required BuildContext context, required String text, required String desc,}) async {
  bool result = false;

  await showDialog(
    context: context,
    builder: (BuildContext context){
      return CupertinoAlertDialog(
        title: Column(
          children: [
            BigText(text: text),
          ],
        ),
        content: SmallText(text: desc, color: Colors.black,),
        actions: [
          CupertinoDialogAction(
            child: const Text("No"),
            onPressed: (){
              result = false;
              Navigator.of(context).pop(false);
            },
          ),
          CupertinoDialogAction(
            child: const Text("Yes"),
            onPressed: (){
              result = true;
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    }
  );

  return result;
}