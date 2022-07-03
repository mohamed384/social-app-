import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/comment/states.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:translator/translator.dart';
import 'package:uuid/uuid.dart';

class CommentCubit extends Cubit<CommentStates> {
  CommentCubit() : super(CommentInitialState());

  static CommentCubit get(context) => BlocProvider.of(context);

  bool isReplyComment = false;

  void changeIsReplyComment(value) {
    isReplyComment = value;
    emit(ChangeIsReplyCommentState());
  }

  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'French':
        return 'fr';
      case 'Italian':
        return 'it';
      case 'Arabic':
        return 'ar';
      case 'Russian':
        return 'ru';
      case 'Spanish':
        return 'es';
      case 'German':
        return 'de';
      default:
        return 'en';
    }
  }
  final translator = GoogleTranslator();
  String translation='';
  String from='';
  translationMessage({required String message,required String to}) async {
    translation='';
    from = await translateApi(message);
    to=getLanguageCode(to);

    var translation1 = await translator.translate(message,from: from.toString(), to: to);
     translation= translation1.text;
     emit(ChangeTranslationCommentState());
  }

  bool isTranslate = false;

  void changeIsTranslate(value) {
    isTranslate = value;
    emit(ChangeIsTranslateCommentState());
  }

  String language2 = 'English';


  void changeLanguage2(lang) {
    language2 = lang;
    emit(ChangeLanguage2CommentState());
  }

  String languageRecord = 'English';
  String languageCode='en_US';
  static String getLanguageRecordCode(String language) {
    switch (language) {
      case 'English':
        return 'en_US';
      case 'French':
        return 'fr_FR';
      case 'Italian':
        return 'it_IT';
      case 'Arabic':
        return 'ar_EG';
      case 'Russian':
        return 'ru_RU';
      case 'Spanish':
        return 'es_ES';
      default:
        return 'en_US';
    }
  }
  void changeLanguageRecord(lang) {
    languageRecord = lang;
    languageCode=getLanguageRecordCode(lang);
    emit(ChangeLanguageRecordCommentState());
  }

  List selectedIndex = [];

  void changeSelectedIndex(index, {isRemove = false}) {
    if (isRemove) {
      selectedIndex.remove(index);
    } else {
      selectedIndex.add(index);
    }

    emit(ChangeSelectedIndexState());
  }

  bool selectedIndexMode = false;

  void changeSelectedIndexMode(value) {
    selectedIndexMode = value;
    emit(ChangeSelectedIndexModeState());
  }

  bool isLoadNewComment = false;

  void changeIsLoadNewComment() {
    isLoadNewComment = !isLoadNewComment;
    emit(ChangeIsLoadNewCommentState());
  }

  String textFieldComment = '';

  void changeTextFieldComment(value) {
    textFieldComment = value;
    emit(TextFieldCommentState());
  }

  int countListviewComment = 10;

  void changeCountListviewComment(value) {
    countListviewComment = value;
    emit(ChangeCountListviewCommentState());
  }

  int commentClickIndex = 0;

  void changeCommentClickIndex(value) {
    commentClickIndex = value;
    emit(ChangeCommentClickIndexState());
  }

  String commentClickId = '';

  void changeCommentClickId(value) {
    commentClickId = value;
    emit(ChangeCommentClickIdState());
  }

  String replayCommentClickId = '';

  void changeReplayCommentClickId(value) {
    replayCommentClickId = value;
    emit(ChangeReplayCommentClickIdState());
  }

  String replayCommentText = '';

  void changeReplayCommentText(value) {
    replayCommentText = value;
    emit(ChangeReplayCommentTextState());
  }

  bool isRecordLock = false;

  void changeIsRecordLock(value) {
    isRecordLock = value;
    emit(ChangeIsRecordLockState());
  }

  bool isRecordClose = false;

  void changeIsRecordClose(value) {
    isRecordClose = value;
    emit(ChangeIsRecordCloseState());
  }

  bool isRecording = false;

  void changeIsRecording(value) {
    isRecording = value;
    emit(ChangeIsRecordingState());
  }

  bool isPlayAudio = false;

  void changeIsPlayAudio() {
    isPlayAudio = !isPlayAudio;
    emit(ChangeIsPlayAudioState());
  }

  double upRecord = 0.0;

  void changeUpRecord(double value) {
    upRecord = value;
    emit(ChangeUpRecordState());
  }

  double leftRecord = 0.0;

  void changeLeftRecord(double value) {
    leftRecord = value;
    emit(ChangeLeftRecordState());
  }

  bool isUploadedComment = false;

  void changeIsUploadedComment() {
    isUploadedComment = !isUploadedComment;
    emit(IsUploadedCommentState());
  }

  uploadRecordToFirebase({
    String savePath = '',
    String filePath = '',
  }) async {
    changeIsUploadedComment();
    String url = '';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(savePath);
    UploadTask uploadTask = ref.putFile(File(filePath));
    await uploadTask.then((p0) async {
      await p0.ref.getDownloadURL().then((value) {
        url = value;
      }).catchError((error) {
        emit(GetUrlRecordFailedState());
      });
    }).catchError((error) {
      emit(UploadToFirebaseRecordFailedState());
    });
    emit(UploadToFirebaseRecordSuccessState());
    return url;
  }

  uploadToFirebase({String postId = '', String reference = ''}) async {
    changeIsUploadedComment();
    List url = [];

    // File anyFile = File(filePath);
    FirebaseStorage storage = FirebaseStorage.instance;
    for (var i in imagesPath) {
      if (reference == '') {
        reference =
            'users/${meInfo[0]['uid']}/CommentPhotos/Posts/$postId/${const Uuid().v4()}';
      } else {
        reference = reference + const Uuid().v4();
      }
      Reference ref = storage.ref().child(reference);
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
    emit(UploadToFirebaseSuccessState());
    return url;
  }

  createNewComment(
      {required String postId,
      required String profilePhoto,
      required String name,
      required String email,
      required String uid,
      required String comment,
      required String voice,
      required List mediaUrl}) async {
    return await FirebaseFirestore.instance
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .doc()
        .set({
      'profilePhotoUrl': profilePhoto,
      'name': name,
      'uid': uid,
      'postId': postId,
      'time': Timestamp.now(),
      'comment': comment,
      'voice': voice,
      'mediaUrl': mediaUrl,
      'likes': {},
    }).then((value) {
      changeIsUploadedComment();
      emit(CreateNewCommentSuccessState());
    }).catchError((error) {
      emit(CreateNewCommentFailedState());
    });
  }

  createReplyComment(
      {required String postId,
      required String commentId,
      required String profilePhoto,
      required String name,
      required String email,
      required String uid,
      required String comment,
      required String voice,
      required List mediaUrl}) async {
    return await FirebaseFirestore.instance
        .collection('userPosts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replyComment')
        .doc()
        .set({
      'profilePhotoUrl': profilePhoto,
      'name': name,
      'uid': uid,
      'postId': postId,
      'time': Timestamp.now(),
      'comment': comment,
      'voice': voice,
      'mediaUrl': mediaUrl,
      'likes': {},
    }).then((value) {
      changeIsUploadedComment();
      emit(CreateReplyCommentSuccessState());
    }).catchError((error) {
      emit(CreateReplyCommentFailedState());
    });
  }

  List imagesPath = [];

  void changeImagesPath(newImagesPath) {
    imagesPath = [];
    imagesPath.addAll(newImagesPath);
    emit(CommentChangeImagesPath());
  }

  void removeOneImagesPath(int index) {
    imagesPath.removeAt(index);
    emit(CommentRemoveOneImagesPath());
  }

  bool isEditComment = false;

  void changeIsEditComment(value) {
    isEditComment = value;
    emit(ChangeIsEditCommentState());
  }

  bool isFirstEditComment = false;

  void changeIsFirstEditComment(value) {
    isFirstEditComment = value;
    emit(ChangeIsFirstEditCommentState());
  }

  bool isCheckBox = false;

  void changeIsCheckBox(value) {
    isCheckBox = value;
    emit(ChangeIsCheckBoxState());
  }
}
