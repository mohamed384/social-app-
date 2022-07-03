import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/screens/comment/states.dart';
import 'package:ryze/shared/component/bottom_textF.dart';
import 'package:ryze/shared/component/conversation.dart';
import 'package:ryze/shared/component/title_widget.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:flutter_speech/flutter_speech.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key, required this.userData}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
  final dynamic userData;
}

class _ChatRoomState extends State<ChatRoom> {
  late CommentCubit cubit;
  TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String dropdownValue = 'English';
  late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';

  //String _currentLocale = 'en_US';

  @override
  void initState() {
    cubit = CommentCubit.get(context);
    cubit.selectedIndex.clear();
    cubit.changeIsTranslate(false);
    activateSpeechRecognizer();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      return createChatRoom(widget.userData['uid'], widget.userData['email']);
    });
    super.initState();
  }
  void activateSpeechRecognizer() {

    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('ar_EG').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }
  void start() => _speech.activate(cubit.languageCode).then((_) {
    return _speech.listen().then((result) {

      setState(() {
        _isListening = result;
      });
    });
  });
  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
    setState(() => _isListening = false);
  });
  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);
  void onCurrentLocale(String locale) {

    setState(
            () =>  cubit.languageCode);
  }
  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }
  void onRecognitionResult(String text) {

    setState(() => transcription = text);
    messageController.text=text;
    cubit.changeTextFieldComment(text);
  }

  void onRecognitionComplete(String text) {

    setState(() => _isListening = false);
  }

  void errorHandler() => activateSpeechRecognizer();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentCubit, CommentStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRoom')
                  .doc(getChatRoomIdByEmail(widget.userData['email']))
                  .collection('chats')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Object?>> messageItem =
                      snapshot.data!.docs;

                  return Scaffold(
                    appBar: AppBar(
                      backgroundColor: const Color(0xff1b65a8),
                      toolbarHeight: 70,
                      centerTitle: false,
                      title: cubit.isTranslate
                          ? Row(
                              children: [
                                TitleWidget(
                                  cubit: cubit,
                                  onChangedLanguage1: (newLanguage) =>
                                      cubit.changeLanguage2(newLanguage),
                                  onChangedLanguage2: (newLanguage) =>
                                      cubit.changeLanguage2(newLanguage),
                                ),
                                const Spacer(),
                                IconButton(
                                    icon: const Icon(
                                      Icons.done,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await cubit.translationMessage(
                                        message:
                                            messageItem[cubit.selectedIndex[0]]
                                                ['message'],
                                        to: cubit.language2,
                                      );
                                    }),
                              ],
                            )
                          : Row(
                              children: [
                                if (!cubit.selectedIndexMode) ...[
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: CachedNetworkImageProvider(
                                      widget.userData['profilePhotoUrl'],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    widget.userData['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),

                                ] else ...[
                                  if (messageItem[cubit.selectedIndex[0]]
                                              ['message'] !=
                                          '' &&
                                      cubit.selectedIndex.length == 1)
                                    IconButton(
                                        icon: const Icon(
                                          Icons.translate,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          cubit.changeIsTranslate(true);

                                          await cubit.translationMessage(
                                              message: messageItem[cubit
                                                  .selectedIndex[0]]['message'],
                                              to: cubit.language2);
                                        }),
                                ]
                              ],
                            ),
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                          icon: Icon(
                            cubit.selectedIndexMode
                                ? Icons.close
                                : Icons.arrow_back,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (cubit.selectedIndexMode) {
                              cubit.changeIsTranslate(false);
                              cubit.changeSelectedIndexMode(false);
                              cubit.selectedIndex.clear();
                            } else {
                              Navigator.pop(context);
                            }
                          }),
                      actions: [
                        if (!cubit.selectedIndexMode)

                          Row(
                          children: [
                            DropDownWidget(
                              value: cubit.languageRecord,
                              onChangedLanguage: (newLanguage) =>
                                  cubit.changeLanguageRecord(newLanguage),
                            ),
                            AvatarGlow(
                              endRadius: 40.0,
                              animate: _isListening,

                              child: IconButton(
                                icon: const Icon(
                                  Icons.mic,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                onPressed:_speechRecognitionAvailable && !_isListening
                                    ? () => start()
                                    : null,),
                            )
                          ],
                        ),

                      ],
                    ),
                    body: InkWell(
                      onTap: () {
                        messageFocusNode.unfocus();
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: const Color(0xff1b65a8),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 7,
                                  right: 7,
                                  bottom: MediaQuery.of(context).size.height *
                                      0.003,
                                ),
                                decoration:  BoxDecoration(
                                  color:Get.isDarkMode?Colors.grey.shade700: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  child: Conversation(
                                    cubit: cubit,
                                    messageItem: messageItem,
                                    scrollController: _scrollController,
                                    userData: widget.userData,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          BottomTextF(
                            onSendTap: sendMessageBtn,
                            cubit: cubit,
                            textController: messageController,
                            focusNode: messageFocusNode,
                            email: widget.userData['email'].toString(),
                            isComment: false,
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              });
        });
  }

  Future<void> sendMessageBtn() async {
    cubit.changeIsLoadNewComment();
    List mediaUrl = [];
    if (cubit.imagesPath.isNotEmpty) {
      mediaUrl =
          await cubit.uploadToFirebase(reference: 'users/${user!.uid}/chat/');
    }
    if (!cubit.isReplyComment) {
      await addMessage(
          email: widget.userData['email'].toString(),
          message: messageController.text,
          voice: '',
          mediaUrl: mediaUrl);
    } else {}

    messageController.text = '';
    cubit.textFieldComment = '';
    cubit.imagesPath.clear();
    imagesPaths.clear();
    cubit.changeIsLoadNewComment();
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }
}
