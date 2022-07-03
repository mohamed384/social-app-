import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/models/sound_recorder.dart';
import 'package:ryze/shared/component/toast.dart';
import 'package:http/http.dart' as http;

//firebase
final FirebaseAuth auth = FirebaseAuth.instance;
 User? user = auth.currentUser;

 //voice&call
String appIdAgora = 'f4af577efa8f4437a7c9bfd56118a96d';
String tokenAgora = '006f4af577efa8f4437a7c9bfd56118a96dIAC8PRAqm0nceBQtCY+b1+KyI+7wVYhKdJAE6Lg3fQc1x3/gWlMAAAAAEAB/xs3WaUKGYgEAAQBfQoZi';
//record

final recorder = SoundRecorder();

//colors
const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const Color iconColor = Color(0xFFB6C7D1);
const MaterialColor mainColor = Colors.blue;
const Color activeColor = Color(0xFF09126C);
const Color textColor1 = Color(0XFFA7BCC7);
const Color textColor2 = Color(0XFF9BB3C0);
const Color facebookColor = Color(0xFF3B5999);
const Color googleColor = Color(0xFFDE4B39);
const Color backgroundColor = Color(0xFFECF3F9);
const Color textColor = Colors.black;

//functions
List<XFile> imagesPaths = [];

Future getImage(
    {required ImageSource source,
    int? imageQuality = 100,
    bool clearList = false,
    double? maxWidth}) async {
  if (clearList) {
    imagesPaths = [];
  }
  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
      source: source, imageQuality: imageQuality, maxWidth: maxWidth);
  if (pickedFile != null) {
    imagesPaths.add(pickedFile);
  } else {
    showToast(text: 'No image selected', state: ToastStates.warning);
  }
  return imagesPaths;
}

Future getImageMulti({int? imageQuality = 100, double? maxWidth}) async {
  final picker = ImagePicker();
  final List<XFile>? pickedFile = await picker.pickMultiImage(
      imageQuality: imageQuality, maxWidth: maxWidth);
  if (pickedFile != null) {
    imagesPaths.addAll(pickedFile);
  } else {
    showToast(text: 'No image selected', state: ToastStates.warning);
  }
  return imagesPaths;
}

Future<bool> isToxicComment(String comment, String type, String ownerUid,
    String postId, String commentID, {bool isPost = false}) async {
  if (comment.isEmpty) {
    return false;
  }
  var url = Uri.parse('https://for-social-app.herokuapp.com/comment_toxic?comment=' + comment);
  try {
    await http
        .get(url)
        .timeout(
          const Duration(seconds: 15),
        )
        .then((value) async {
      if (type == 'insult') {
        if (double.parse(jsonDecode(value.body)['insult']
                    .toString()
                    .replaceAll('%', '')) >
                70 ||
            double.parse(jsonDecode(value.body)['toxic']
                    .toString()
                    .replaceAll('%', '')) >
                70 ||
            double.parse(jsonDecode(value.body)['severe_toxic']
                    .toString()
                    .replaceAll('%', '')) >
                70) {
          showToast(
              text: 'this Comment is $type and will delete',
              state: ToastStates.success);
          if(isPost){
            FirebaseFirestore.instance

                .collection('userPosts')
                .doc(postId)
                .delete();
          }
          else{
            FirebaseFirestore.instance

                .collection('userPosts')
                .doc(postId)
                .collection('comments')
                .doc(commentID)
                .delete();
          }

          return true;
        } else {
          showToast(
              text: 'this Comment is not $type',
              state: ToastStates.error);
          return false;
        }
      } else if (double.parse(
              jsonDecode(value.body)[type].toString().replaceAll('%', '')) >
          70) {
        showToast(
            text: 'this Comment is $type and will delete',
            state: ToastStates.success);
        if(isPost){
          FirebaseFirestore.instance

              .collection('userPosts')
              .doc(postId)
              .delete();
        }
        else{
          FirebaseFirestore.instance

              .collection('userPosts')
              .doc(postId)
              .collection('comments')
              .doc(commentID)
              .delete();
        }
        return true;
      } else {
        showToast(
            text: 'this Comment is not $type',
            state: ToastStates.error);
        return false;
      }
    });
  } on TimeoutException catch (_) {
    showToast(text: 'failed!! try again...', state: ToastStates.error);
    return true;
  }
  return false;
}


translateApi(String message) async {
  String result='';
  var url = Uri.parse('https://for-social-app.herokuapp.com/lang_detection?text=' + message);

  try {
    var hhtr=
    await http
        .get(url)
        .timeout(
          const Duration(seconds: 15),
        );

    if(jsonDecode(hhtr.body)['result']=='English'){
      result= 'en';
    }if(jsonDecode(hhtr.body)['result']=='French'){
      result= 'fr';
    }if(jsonDecode(hhtr.body)['result']=='Italian'){
      result= 'it';
    }if(jsonDecode(hhtr.body)['result']=='Russian'){
      result= 'ru';
    }if(jsonDecode(hhtr.body)['result']=='Arabic'){
      result= 'ar';
    }if(jsonDecode(hhtr.body)['result']=='Spanish'){
      result= 'es';
    }if(jsonDecode(hhtr.body)['result']=='German'){
      result= 'de';
    }
  } on TimeoutException catch (_) {
    showToast(text: 'error try again', state: ToastStates.error);
    result= 'en';
  }
  return result;
}

sentimentPost(String postText, HomeCubit cubit, BuildContext context) async {
  cubit=HomeCubit.get(context);

  if (postText.isEmpty) {
    cubit.changeIsSentimentPost(true);

  }
  var url = Uri.parse('https://for-social-app.herokuapp.com/sentiment_train?post=' + postText);
  try {
    await http
        .get(url)
        .timeout(
      const Duration(seconds: 15),
    )
        .then((value) async {
      if(jsonDecode(value.body)['result']=='Positive'){
        cubit.changeIsSentimentPost(true);
      }else{
        cubit.changeIsSentimentPost(false);
      }

    });
  } on TimeoutException catch (_) {
    cubit.changeIsSentimentPost(true);
  }
}
