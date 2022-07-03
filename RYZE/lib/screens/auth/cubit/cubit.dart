import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(SocialLoginInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);


  void userLogin({
    required String email,
    required String password,
  }) {
    emit(SocialLoginLoadingState());

    auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      emit(SocialLoginSuccessState());
    }).catchError((error) {
      emit(SocialLoginErrorState(error.toString()));
    });
  }

  signUp({
    required String photo,
    required String name,
    required String email,
    required String password,
    required String token,
  }) async {
    emit(SocialRegisterLoadingState());
    auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      var photoUrl = await updatePhoto(image: photo);
      await addData(
          photo: photoUrl,
          name: name,
          email: email,
          password: password,
          token: token);
    }).catchError((e) {
      emit(SocialRegisterErrorState(e.toString()));
    });
  }

  Future<String> updatePhoto({required String image}) async {
    File imageFile;
    image == ''
        ? imageFile = await getImageFileFromAssets('images/user.png')
        : imageFile = File(image);
    String url = '';

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child('users/${auth.currentUser!.uid}/profilePhoto');
    await ref.putFile(imageFile).then((value) async {
      url = await (value).ref.getDownloadURL();
    }).catchError((e) {
      emit(SocialRegisterErrorState(e.toString()));
    });
    return url;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file =
        File('${(await getTemporaryDirectory()).path}/profilePhoto.jpg');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  addData({
    required String photo,
    required String name,
    required String email,
    required String password,
    required String token,
  }) async {
    final databaseRef = FirebaseFirestore.instance.collection('users');
    await databaseRef.doc(auth.currentUser!.uid).set({
      'profilePhotoUrl': photo,
      'name': name,
      'nameSearch':setSearchParam(name),
      'email': email,
      'bio': '',
      'password': password,
      'token': token,
      'isTrusted': false,
      'status': 'Offline',
      'uid': auth.currentUser!.uid,
      'blockUsers': [],
      'privateAccount': false,
      'time': Timestamp.now()
    }).then((value) {
      emit(SocialRegisterSuccessState());
    }).catchError((e) {
      emit(SocialRegisterErrorState(e.toString()));
    });
  }

  uploadToFirebase(
      {bool chatRooms = false, String postId = '', text = '',bool isStory=false}) async {
    changeIsUploadedPost();
    List url = [];
    String customPath='';
    if(isStory){
      customPath='Stories';
    }else{
      customPath='Posts';

    }
    // File anyFile = File(filePath);
    FirebaseStorage storage = FirebaseStorage.instance;
    for (var i in imagesPath) {
      if (i.runtimeType == XFile) {
        Reference ref = storage.ref().child(chatRooms
            ? 'chatRooms/users/${meInfo[0]['uid']}/Posts/$postId/${const Uuid().v4()}/${Timestamp.now()}'
            : 'users/${meInfo[0]['uid']}/$customPath/$postId/${const Uuid().v4()}');
        UploadTask uploadTask = ref.putFile(File(i.path));
        await uploadTask.then((p0) async {
          await p0.ref.getDownloadURL().then((value) {
            url.add(value);
          }).catchError((error) {
            emit(GetUrlFailedState());
          });
        }).catchError((error) {
          emit(UploadToFirebaseFailedState());
        });
      }
    }
    changeIsUploadedPost();
    emit(UploadToFirebaseSuccessState());
    return url;
  }

  createNewPost(
      {required String postId,
      name,
      profilePhotoUrl,
      required List mediaUrl,
      required String text}) async {
    return await FirebaseFirestore.instance
        .collection("userPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "uid": user!.uid,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      "mediaUrl": mediaUrl,
      "text": text,
      'postTextSearch':setSearchParam(text),
      "time": Timestamp.now(),
      'editTime':Timestamp.now(),
      "likes": {},
      'isUpdated':false,
    }).then((value) {
      emit(CreatePostSuccessState());
    }).catchError((error) {
      emit(CreatePostFailedState());
    });
  }
  createNewStory(
      {required String storyId,
      name,
      profilePhotoUrl,
      required List mediaUrl,
      required String text}) async {
    return await FirebaseFirestore.instance
        .collection("userStories")
        .doc(storyId)
        .set({
      "storyId": storyId,
      "uid": user!.uid,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
      "mediaUrl": mediaUrl,
      'storySeen':[],
      "time": Timestamp.now(),
    }).then((value) {
      emit(CreateStorySuccessState());
    }).catchError((error) {
      emit(CreateStoryFailedState());
    });
  }
  updatePost(
      {required String postId,
      required List mediaUrl,
      required String text}) async {
    return await FirebaseFirestore.instance
        .collection("userPosts")
        .doc(postId)
        .update({
      "mediaUrl": FieldValue.arrayUnion(mediaUrl),
      "text": text,
      'postTextSearch':setSearchParam(text),
      'isUpdated':true,
      'editTime':Timestamp.now(),
    }).then((value) {
      emit(UpdatePostSuccessState());
    }).catchError((error) {
      emit(UpdatePostFailedState());
    });
  }
  deletePostImage(
      {required String postId,url,
      }) async {
    return await FirebaseFirestore.instance
        .collection("userPosts")
        .doc(postId)
        .update({
      "mediaUrl": FieldValue.arrayRemove([url]),

    }).then((value) {
      emit(DeletePostImageSuccessState());
    }).catchError((error) {
      emit(DeletePostImageFailedState());
    });
  }

//for login icon visible
  IconData suffix = Icons.visibility_off_outlined;
  bool isPassword = true;
  bool isSignupScreen = false;

  void changeSingSection() {
    isSignupScreen = !isSignupScreen;
    emit(SocialChangeSignSectionState());
  }

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix =
        isPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(SocialChangePasswordVisibilityState());
  }

//for signUp icon visible
  IconData suffixSign = Icons.visibility_off_outlined;
  bool isPasswordSign = true;

  void changePasswordVisibilitySign() {
    isPasswordSign = !isPasswordSign;
    suffixSign = isPasswordSign
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
    emit(SocialRegisterChangePasswordVisibilityState());
  }

  List imagesPath = [];

  void changeImagesPath(newImagesPath) {
    imagesPath = [];
    imagesPath.addAll(newImagesPath);
    emit(SocialChangeImagesPath());
  }

  int index = 0;

  void removeOneImagesPath() {
    imagesPath.removeAt(index);
    emit(RemoveOneImagesPathState());
  }

  void addImagesPath(newImagesPath) {
    imagesPath.addAll(newImagesPath);
    emit(SocialChangeImagesPath());
  }

  String textFieldPost = '';

  void changeTextField(value) {
    textFieldPost = value;
    emit(TextFieldPostState());
  }

  bool isUploadedPost = false;

  void changeIsUploadedPost() {
    isUploadedPost = !isUploadedPost;
    emit(IsUploadedPostState());
  }
//search
  setSearchParam(String caseNumber) {
    List<String> caseSearchList =[];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
  String textFieldSearch = '';

  void changeTextFieldSearch(value) {
    textFieldSearch = value;
    emit(ChangeTextFieldSearch());
  }

  int tabSearchIndex = 0;

  void changeTabSearchIndex(int index) {
    tabSearchIndex=index;
    emit(ChangeTabSearchIndexState());
  }
}
