import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:delivery_food_app/widgets/big_text.dart';
import 'package:delivery_food_app/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
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
  String TitleBar = '^-^';
  if(title.isEmpty){
    if(contentType == ContentType.success){
      TitleBar = "Success";
    }else if(contentType == ContentType.help){
      TitleBar = "Help";
    }else if(contentType == ContentType.warning){
      TitleBar = "Warning";
    }else if(contentType == ContentType.failure){
      TitleBar = "Error";
    }
  }else{
    TitleBar = title;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: TitleBar,
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
    } catch (e) {}

    image = getCompress;
  } catch (e) {
    showSnackBar(context, e.toString());
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
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1  ),
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
    } catch (e) {}

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
            child: Text("No"),
            onPressed: (){
              result = false;
              Navigator.of(context).pop(false);
            },
          ),
          CupertinoDialogAction(
            child: Text("Yes"),
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