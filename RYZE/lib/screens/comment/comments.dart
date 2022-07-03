import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:intl/intl.dart' as numberformatted;
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/screens/comment/reply_comment.dart';
import 'package:ryze/screens/comment/states.dart';
import 'package:ryze/shared/component/bottom_textF.dart';

import 'package:ryze/shared/constants/constants.dart';

class CommentsPage extends StatefulWidget {
  final dynamic postItems, commentItems;

  const CommentsPage({
    Key? key,
    required this.postItems,
    required this.commentItems,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FocusNode commentFocusNode = FocusNode();
  late CommentCubit cubit;

  bool isFinishScroll = false;

  @override
  void initState() {
    cubit = CommentCubit.get(context);
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    cubit.changeIsEditComment(false);
    cubit.imagesPath.clear();
    imagesPaths.clear();
    commentFocusNode.dispose();
    cubit.changeIsReplyComment(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentCubit, CommentStates>(
        listener: (context, state) {},
        builder: (context, state) {
          if (cubit.isFirstEditComment) {
            if (cubit.isReplyComment) {
              commentController.text = cubit.replayCommentText;
            } else {
              commentController.text =
                  widget.commentItems[cubit.commentClickIndex]['comment'];
            }

            commentFocusNode.requestFocus();
            cubit.changeIsFirstEditComment(false);
          }

          return Dismissible(
            direction: DismissDirection.vertical,
            key: const Key('Comments'),
            onDismissed: (direction) {
              Navigator.of(context).pop();
            },
            child: Scaffold(
              appBar: !cubit.isReplyComment
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(
                          MediaQuery.of(context).size.height / 16),
                      child: AppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        flexibleSpace: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      widget.postItems['likes'].length != 0
                                          ? Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  size: 18,
                                                ),
                                                Image.asset(
                                                  'assets/images/heart_fill.png',
                                                  height: 22,
                                                  width: 22,
                                                ),
                                                Text(
                                                    ' ${numberformatted.NumberFormat.compact().format(widget.postItems['likes'].length)}')
                                              ],
                                            )
                                          : Text('no_Like'.tr)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 60,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 1,
                                child: Container(
                                    color: Theme.of(context).dividerColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : PreferredSize(
                      preferredSize: Size.fromHeight(
                          MediaQuery.of(context).size.height / 16),
                      child: AppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        flexibleSpace: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, right: 8, left: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        cubit.changeIsEditComment(false);
                                        commentController.text = '';
                                        cubit.changeIsReplyComment(false);
                                      },
                                      child: const Icon(Icons.arrow_back_ios),
                                    ),
                                    Text('replies'.tr,
                                        style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                10)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 60,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 1,
                                child: Container(
                                    color: Theme.of(context).dividerColor),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
              body: WillPopScope(
                onWillPop: () {
                  if (cubit.isReplyComment) {
                    cubit.changeIsReplyComment(false);
                    return Future<bool>.value(false);
                  } else {
                    return Future<bool>.value(true);
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      decoration:Get.isDarkMode?null: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                            HexColor('#EDE7FF'),
                            HexColor('#E5EBFF'),
                          ])),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 13),
                        child: SafeArea(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('userPosts')
                                    .doc(widget.postItems['postId'])
                                    .collection('comments')
                                    .orderBy('time', descending: true)
                                    .snapshots(),
                                builder: (_, snapshot) {
                                  if (snapshot.hasData) {
                                    var commentItems = snapshot.data!.docs;
                                    if (commentItems.isEmpty) {
                                      return Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 15),
                                            Text(
                                              'no_comment'.tr,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 15),
                                            Image.asset(
                                              'assets/images/no_comment.png',
                                              height: 150,
                                              width: 150,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return !cubit.isReplyComment
                                          ? Column(
                                              children: [
                                                ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: commentItems.length >
                                                          10
                                                      ? cubit
                                                          .countListviewComment
                                                      : commentItems.length,
                                                  itemBuilder:
                                                      (_, commentIndex) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Column(
                                                        children: [
                                                          CommentThatRelay(
                                                            commentItems:
                                                                commentItems,
                                                            commentIndex:
                                                                commentIndex,
                                                            ownerUid: widget
                                                                    .postItems[
                                                                'uid'],
                                                            postId: widget
                                                                    .postItems[
                                                                'postId'],
                                                            isLongPress: true,
                                                          ),
                                                          StreamBuilder<
                                                                  QuerySnapshot>(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'userPosts')
                                                                  .doc(widget
                                                                          .postItems[
                                                                      'postId'])
                                                                  .collection(
                                                                      'comments')
                                                                  .doc(commentItems[
                                                                          commentIndex]
                                                                      .id)
                                                                  .collection(
                                                                      'replyComment')
                                                                  .orderBy(
                                                                      'time',
                                                                      descending:
                                                                          true)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshot2) {
                                                                if (snapshot2
                                                                    .hasData) {
                                                                  var commentReplyItems =
                                                                      snapshot2
                                                                          .data!
                                                                          .docs;
                                                                  return Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            55,
                                                                        right:
                                                                            55),
                                                                    child: ListView
                                                                        .builder(
                                                                      physics:
                                                                          const NeverScrollableScrollPhysics(),
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount:
                                                                          commentReplyItems.isEmpty
                                                                              ? 0
                                                                              : 1,
                                                                      itemBuilder:
                                                                          (_, replayIndexOne) =>
                                                                              Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 10.0),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            cubit.changeIsReplyComment(true);
                                                                            CommentCubit.get(context).changeCommentClickIndex(commentIndex);
                                                                            CommentCubit.get(context).changeCommentClickId(commentItems[commentIndex].id);
                                                                          },
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 26,
                                                                                    height: 26,
                                                                                    decoration: BoxDecoration(
                                                                                        borderRadius: const BorderRadius.all(Radius.circular(7)),
                                                                                        image: DecorationImage(
                                                                                          fit: BoxFit.cover,
                                                                                          alignment: FractionalOffset.center,
                                                                                          image: CachedNetworkImageProvider(commentReplyItems[replayIndexOne]['profilePhotoUrl']),
                                                                                        )),
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.all(5.0),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              commentReplyItems[replayIndexOne]['name'],
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              softWrap: false,
                                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                                                                                            ),
                                                                                            flex: 2,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: Text(
                                                                                              commentReplyItems[replayIndexOne]['comment'],
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                              softWrap: false,
                                                                                            ),
                                                                                            flex: 3,
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              if (commentReplyItems.length > 1)
                                                                                const SizedBox(height: 8),
                                                                              if (commentReplyItems.length > 1)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                                                                  child: Text(
                                                                                    'view'.tr + ' ${numberformatted.NumberFormat.compact().format(commentReplyItems.length - 1)} ' + 'more_reply',
                                                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return const Center(
                                                                      child:
                                                                          CircularProgressIndicator());
                                                                }
                                                              })
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (cubit.countListviewComment <
                                                    commentItems.length)
                                                  TextButton(
                                                      onPressed: () {
                                                        if (cubit.countListviewComment +
                                                                10 >
                                                            commentItems
                                                                .length) {
                                                          cubit
                                                              .changeCountListviewComment(
                                                                  commentItems
                                                                      .length);
                                                        } else {
                                                          cubit.changeCountListviewComment(
                                                              cubit.countListviewComment +
                                                                  10);
                                                        }
                                                      },
                                                      child: Text(
                                                          'view_prev_comment'
                                                              .tr)),
                                              ],
                                            )
                                          : ReplayComment(
                                              commentItems: commentItems,
                                              commentIndex:
                                                  CommentCubit.get(context)
                                                      .commentClickIndex,
                                              ownerUid: widget.postItems['uid'],
                                              postId:
                                                  widget.postItems['postId'],
                                              commentText:
                                                  commentController.text,
                                            );
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ),
                        ),
                      ),
                    ),
                    BottomTextF(
                      onSendTap: sendCommentBtn,
                      cubit: cubit,
                      textController: commentController,
                      focusNode: commentFocusNode,
                      postItems: widget.postItems,
                      isComment: true,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> sendCommentBtn() async {
    cubit.changeIsLoadNewComment();
    List mediaUrl = [];
    if (cubit.isEditComment) {
      if (!cubit.isReplyComment) {
        await FirebaseFirestore.instance
            .collection('userPosts')
            .doc(widget.postItems['postId'])
            .collection('comments')
            .doc(widget.commentItems[cubit.commentClickIndex].id)
            .update({'comment': commentController.text}).then((value) {
          cubit.changeIsEditComment(false);
        });
      } else {
        await FirebaseFirestore.instance
            .collection('userPosts')
            .doc(widget.postItems['postId'])
            .collection('comments')
            .doc(widget.commentItems[cubit.commentClickIndex].id)
            .collection('replyComment')
            .doc(CommentCubit.get(context).replayCommentClickId)
            .update({'comment': commentController.text}).then((value) {
          cubit.changeIsEditComment(false);
        });
      }
    } else {
      if (cubit.imagesPath.isNotEmpty) {
        mediaUrl =
            await cubit.uploadToFirebase(postId: widget.postItems['postId']);
      }
      if (!cubit.isReplyComment) {
        await cubit.createNewComment(
          postId: widget.postItems['postId'],
          profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
          name: meInfo[0]['name'].toString(),
          email: meInfo[0]['email'].toString(),
          uid: meInfo[0]['uid'].toString(),
          comment: commentController.text,
          voice: '',
          mediaUrl: mediaUrl,
        );
        await addToActivityFeed(
            type: 'comment',
            uid: widget.postItems['uid'],
            postId: widget.postItems['postId'],
            postText: widget.postItems['text'],
            profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
            name: meInfo[0]['name'].toString(),
            mediaUrl: mediaUrl);
      } else {
        await cubit.createReplyComment(
          postId: widget.postItems['postId'],
          commentId: CommentCubit.get(context).commentClickId,
          profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
          name: meInfo[0]['name'].toString(),
          email: meInfo[0]['email'].toString(),
          uid: meInfo[0]['uid'].toString(),
          comment: commentController.text,
          voice: '',
          mediaUrl: mediaUrl,
        );
        await addToActivityFeed(
            type: 'replyComment',
            uid: widget.postItems['uid'],
            postId: widget.postItems['postId'],
            postText: widget.postItems['text'],
            profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
            name: meInfo[0]['name'].toString(),
            mediaUrl: mediaUrl);
      }
    }
    commentController.text = '';
    cubit.textFieldComment = '';
    cubit.imagesPath.clear();
    imagesPaths.clear();
    cubit.changeIsLoadNewComment();
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
    commentFocusNode.unfocus();
  }
}
