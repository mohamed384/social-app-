import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/shared/constants/constants.dart';



var meInfo = [{
  'name': '',
  'email': '',
  'profilePhotoUrl': '',
  'status': 'Offline',
  'bio': '',
  'uid': '',
  'token': '',
  'privateAccount': false,
  'isTrusted': false
}];

var userInfo = [{
  'name': '',
  'email': '',
  'profilePhotoUrl': '',
  'status': 'Offline',
  'bio': '',
  'uid': '',
  'token': '',
  'privateAccount': false,
  'isTrusted': false
}];

getMeDetailsFromFirebase(context) async {
  HomeCubit.get(context).isLoaded = true;
  final ref = FirebaseFirestore.instance.collection('users').doc(user!.uid);
  await ref.get().then((value) {
    if (value['name'] != null) {
      meInfo[0]['name'] = value['name'].toString();
    }
    if (value['email'] != null) {
      meInfo[0]['email'] = value['email'].toString();
    }
    if (value['profilePhotoUrl'] != null) {
      meInfo[0]['profilePhotoUrl'] = value['profilePhotoUrl'].toString();
    }
    if (value['bio'] != null) {
      meInfo[0]['bio'] = value['bio'].toString();
    }
    if (value['uid'] != null) {
      meInfo[0]['uid'] = value['uid'].toString();
    }
    if (value['token'] != null) {
      meInfo[0]['token'] = value['token'].toString();
    }
    if (value['privateAccount']) {
      meInfo[0]['privateAccount'] = true;
    }
    if (value['isTrusted']) {
      meInfo[0]['isTrusted'] = true;
    }
  });
  HomeCubit.get(context).changeIsLoaded();
  return meInfo;
}

getUsersDetailsFromFirebase(context, uid) async {
  HomeCubit.get(context).isLoaded = true;

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);
  await ref.get().then((value) {
    if (value['name'] != null) {
      userInfo[0]['name'] = value['name'].toString();
    }
    if (value['email'] != null) {
      userInfo[0]['email'] = value['email'].toString();
    }
    if (value['profilePhotoUrl'] != null) {
      userInfo[0]['profilePhotoUrl'] = value['profilePhotoUrl'].toString();
    }
    if (value['bio'] != null) {
      userInfo[0]['bio'] = value['bio'].toString();
    }
    if (value['uid'] != null) {
      userInfo[0]['uid'] = value['uid'].toString();
    }
    if (value['token'] != null) {
      userInfo[0]['token'] = value['token'].toString();
    }
    if (value['privateAccount']) {
      userInfo[0]['privateAccount'] = true;
    }
    if (value['isTrusted']) {
      userInfo[0]['isTrusted'] = true;
    }
  });
  HomeCubit.get(context).changeIsLoaded();
  return userInfo;
}
