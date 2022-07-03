import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:random_color/random_color.dart';
import 'package:readmore/readmore.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/timeAgo_display.dart';
import 'package:intl/intl.dart' as numberformatted;
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/shared/component/bottom_dialog.dart';
import 'package:ryze/shared/component/post_carousel.dart';
import 'package:ryze/shared/component/toast.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:just_audio/just_audio.dart';

class ReplayComment extends StatelessWidget {
  final List<QueryDocumentSnapshot<Object?>> commentItems;

  final String postId, ownerUid, commentText;
  final int commentIndex;

  const ReplayComment({
    Key? key,
    required this.commentItems,
    required this.commentIndex,
    required this.postId,
    required this.ownerUid,
    required this.commentText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 8.0, left: 8.0),
          child: CommentThatRelay(
            commentItems: commentItems,
            commentIndex: commentIndex,
            ownerUid: ownerUid,
            postId: postId,
            isLongPress: false,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('userPosts')
                .doc(postId)
                .collection('comments')
                .doc(commentItems[commentIndex].id)
                .collection('replyComment')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var commentReplyItems = snapshot.data!.docs;
                return Padding(
                  padding: EdgeInsets.only(
                      right: Get.locale.toString() == 'en_US' ? 0 : 37,
                      left: Get.locale.toString() == 'en_US' ? 37 : 0),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: commentReplyItems.length,
                        itemBuilder: (_, commentReplayIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, right: 8.0, left: 8.0),
                            child: CommentThatRelay(
                              commentItems: commentReplyItems,
                              commentIndex: commentReplayIndex,
                              postId: postId,
                              ownerUid: ownerUid,
                              isLongPress: true,
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
      ],
    );
  }
}

class CommentThatRelay extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> commentItems;
  final int commentIndex;
  final String ownerUid, postId;
  final bool isLongPress;

  const CommentThatRelay(
      {Key? key,
      required this.commentItems,
      required this.commentIndex,
      required this.ownerUid,
      required this.postId,
      required this.isLongPress})
      : super(key: key);

  @override
  State<CommentThatRelay> createState() => _CommentThatRelayState();
}

class _CommentThatRelayState extends State<CommentThatRelay> {
  bool isPlaying = false;
  double speedValue = 1.0;
  late AudioPlayer player;

  late Stream<DurationState> _durationState;

  @override
  void initState() {
    player = AudioPlayer();
    _durationState =
        rx.Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
            player.positionStream,
            player.playbackEventStream,
            (position, playbackEvent) => DurationState(
                  progress: position,
                  buffered: playbackEvent.bufferedPosition,
                  total: playbackEvent.duration,
                )).asBroadcastStream();

    _init();

    super.initState();
  }

  Future<void> _init() async {
    try {
      await player
          .setUrl(widget.commentItems[widget.commentIndex]['voice'].toString());
    } catch (e) {
      debugPrint('An error occured $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: widget.commentItems[widget.commentIndex]['voice'] == '' &&
          widget.commentItems[widget.commentIndex]['mediaUrl'].isEmpty,
      builder: (BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0, bottom: 25),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(13)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                    image: CachedNetworkImageProvider(widget
                        .commentItems[widget.commentIndex]['profilePhotoUrl']),
                  )),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Container(
                  decoration:  BoxDecoration(
                    color:Get.isDarkMode?Colors.grey.shade700: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomRight: Radius.circular(18)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commentItems[widget.commentIndex]['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: RandomColor().randomColor(
                                colorHue: ColorHue.multiple(
                                    colorHues: [ColorHue.red, ColorHue.blue])),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.794,
                            minWidth: MediaQuery.of(context).size.width * 0.2,
                          ),
                          child: ReadMoreText(
                            widget.commentItems[widget.commentIndex]['comment'],
                            trimLines: 2,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Show more',
                            trimExpandedText: 'Show less',
                            moreStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            lessStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            style: const TextStyle(
                                fontSize: 18, ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onLongPress: widget.isLongPress
                    ? () {
                        dialogBottomSheet(context: context, children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                if (widget.commentItems[widget.commentIndex]
                                        ['uid'] ==
                                    meInfo[0]['uid'])
                                  ListTile(
                                    dense: true,
                                    title: const Text(
                                      "Edit",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(Icons.edit_outlined),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      CommentCubit.get(context)
                                          .imagesPath
                                          .clear();
                                      CommentCubit.get(context)
                                          .changeIsFirstEditComment(true);
                                      CommentCubit.get(context)
                                          .changeIsEditComment(true);

                                      if (CommentCubit.get(context)
                                          .isReplyComment) {
                                        CommentCubit.get(context)
                                            .changeReplayCommentText(
                                                widget.commentItems[widget
                                                    .commentIndex]['comment']);

                                        CommentCubit.get(context)
                                            .changeReplayCommentClickId(widget
                                                .commentItems[
                                                    widget.commentIndex]
                                                .id);
                                      } else {
                                        CommentCubit.get(context)
                                            .changeCommentClickIndex(
                                                widget.commentIndex);
                                      }
                                    },
                                  ),
                                if (widget.commentItems[widget.commentIndex]
                                            ['uid'] ==
                                        meInfo[0]['uid'] ||
                                    widget.ownerUid == meInfo[0]['uid'])
                                  ListTile(
                                    dense: true,
                                    title: const Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    leading: const Icon(Icons.delete_outline),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      FirebaseFirestore.instance
                                          .collection('userPosts')
                                          .doc(widget.postId)
                                          .collection('comments')
                                          .doc(widget
                                              .commentItems[widget.commentIndex]
                                              .id)
                                          .delete()
                                          .then((value) {
                                        showToast(
                                            text: 'delete successful',
                                            state: ToastStates.success);
                                      }).catchError((error) {
                                        showToast(
                                            text: 'failed try again',
                                            state: ToastStates.error);
                                      });
                                    },
                                  ),
                                ListTile(
                                  dense: true,
                                  title: const Text(
                                    "Report",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  leading: const Icon(
                                      Icons.report_gmailerrorred_outlined),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    dialogBottomSheet(
                                        context: context,
                                        children: [
                                          ListTile(
                                            dense: true,
                                            horizontalTitleGap: 1,
                                            title: const Text(
                                              "identity hate",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: Image.asset(
                                              'assets/images/hate.png',
                                              height: 22,
                                              width: 22,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();

                                              isToxicComment(
                                                  widget.commentItems[widget
                                                      .commentIndex]['comment'],
                                                  'identity_hate',
                                                  widget.ownerUid,
                                                  widget.postId,
                                                  widget
                                                      .commentItems[
                                                          widget.commentIndex]
                                                      .id);
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            horizontalTitleGap: 1,
                                            title: const Text(
                                              "insult",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: Image.asset(
                                              'assets/images/insult.png',
                                              height: 22,
                                              width: 22,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              isToxicComment(
                                                  widget.commentItems[widget
                                                      .commentIndex]['comment'],
                                                  'insult',
                                                  widget.ownerUid,
                                                  widget.postId,
                                                  widget
                                                      .commentItems[
                                                          widget.commentIndex]
                                                      .id);
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            horizontalTitleGap: 1,
                                            title: const Text(
                                              "obscene",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: Image.asset(
                                              'assets/images/obscene.png',
                                              height: 22,
                                              width: 22,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              isToxicComment(
                                                  widget.commentItems[widget
                                                      .commentIndex]['comment'],
                                                  'obscene',
                                                  widget.ownerUid,
                                                  widget.postId,
                                                  widget
                                                      .commentItems[
                                                          widget.commentIndex]
                                                      .id);
                                            },
                                          ),
                                          ListTile(
                                            dense: true,
                                            horizontalTitleGap: 1,
                                            title: const Text(
                                              "threat",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: Image.asset(
                                              'assets/images/threat.png',
                                              height: 22,
                                              width: 22,
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();

                                              isToxicComment(
                                                  widget.commentItems[widget
                                                      .commentIndex]['comment'],
                                                  'threat',
                                                  widget.ownerUid,
                                                  widget.postId,
                                                  widget
                                                      .commentItems[
                                                          widget.commentIndex]
                                                      .id);
                                            },
                                          )
                                        ]);
                                  },
                                )
                              ],
                            ),
                          ),
                        ]);
                      }
                    : null,
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      InkWell(
                        child: Image.asset(
                          widget.commentItems[widget.commentIndex]['likes']
                                  .containsKey(user!.uid)
                              ? 'assets/images/heart_fill.png'
                              : 'assets/images/heart_outline.png',
                          height: 22,
                          width: 22,
                        ),
                        onTap: () async {
                          await likeClick(context, widget);
                        },
                      ),
                      Text(
                          ' ${numberformatted.NumberFormat.compact().format(widget.commentItems[widget.commentIndex]['likes'].length)}')
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      if (CommentCubit.get(context).isReplyComment) {
                      } else {
                        CommentCubit.get(context).changeIsReplyComment(true);
                        CommentCubit.get(context)
                            .changeCommentClickIndex(widget.commentIndex);
                        CommentCubit.get(context).changeCommentClickId(
                            widget.commentItems[widget.commentIndex].id);
                      }
                    },
                    child: Image.asset(
                      'assets/images/comment.png',
                      height: 22,
                      width: 22,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                      TimeAgoExtention.displayTimeAgoFromTimestamp(
                          widget.commentItems[widget.commentIndex]['time']
                              .toDate()
                              .toString(),
                          true),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
      fallback: (BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 3.0,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(13)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        alignment: FractionalOffset.center,
                        image: CachedNetworkImageProvider(
                            widget.commentItems[widget.commentIndex]
                                ['profilePhotoUrl']),
                      )),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration:  BoxDecoration(
                color:Get.isDarkMode?Colors.grey.shade700: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.commentItems[widget.commentIndex]['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: RandomColor().randomColor(
                            colorHue: ColorHue.multiple(
                                colorHues: [ColorHue.red, ColorHue.blue])),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.commentItems[widget.commentIndex]
                                    ['voice'] !=
                                ''
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReadMoreText(
                                    widget.commentItems[widget.commentIndex]
                                        ['comment'],
                                    trimLines: 2,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Show more',
                                    trimExpandedText: 'Show less',
                                    moreStyle: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    lessStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    style: const TextStyle(
                                        fontSize: 18, ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0)),
                                      color: HexColor('#E5EBFF'),
                                    ),
                                    child: Column(
                                      children: [
                                        StreamBuilder<DurationState>(
                                            stream: _durationState,
                                            builder: (context, snapshot) {
                                              final durationState =
                                                  snapshot.data;
                                              final progress =
                                                  durationState?.progress ??
                                                      Duration.zero;
                                              final buffered =
                                                  durationState?.buffered ??
                                                      Duration.zero;
                                              final total =
                                                  durationState?.total ??
                                                      Duration.zero;
                                              return SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.70,
                                                child: ProgressBar(
                                                  progress: progress,
                                                  buffered: buffered,
                                                  total: total,
                                                  progressBarColor:
                                                      Colors.deepPurpleAccent,
                                                  thumbColor:
                                                      Colors.deepPurpleAccent,
                                                  baseBarColor: Colors
                                                      .deepPurple
                                                      .withOpacity(0.2),
                                                  bufferedBarColor: Colors
                                                      .deepPurple
                                                      .withOpacity(0.3),
                                                  timeLabelTextStyle: const TextStyle(color: Colors.black),
                                                  timeLabelLocation:
                                                      TimeLabelLocation.sides,
                                                  onSeek: (duration) {
                                                    player.seek(duration);
                                                  },
                                                ),
                                              );
                                            }),
                                        StreamBuilder<PlayerState>(
                                            stream: player.playerStateStream,
                                            builder: (context, snapshot) {
                                              final playerState = snapshot.data;
                                              final processingState =
                                                  playerState?.processingState;
                                              final playing =
                                                  playerState?.playing;
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  (processingState ==
                                                              ProcessingState
                                                                  .loading ||
                                                          processingState ==
                                                              ProcessingState
                                                                  .buffering)
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          width: 22.0,
                                                          height: 22.0,
                                                          child:
                                                              const CircularProgressIndicator(
                                                            color: Colors
                                                                .deepPurple,
                                                          ),
                                                        )
                                                      : (playing != true)
                                                          ? IconButton(
                                                              icon: Image.asset(
                                                                'assets/images/play.png',
                                                                width: 22,
                                                                height: 22,
                                                              ),
                                                              onPressed:
                                                                  player.play,
                                                            )
                                                          : (processingState !=
                                                                  ProcessingState
                                                                      .completed)
                                                              ? IconButton(
                                                                  icon: Image
                                                                      .asset(
                                                                    'assets/images/pause.png',
                                                                    width: 22,
                                                                    height: 22,
                                                                  ),
                                                                  onPressed:
                                                                      player
                                                                          .pause,
                                                                )
                                                              : IconButton(
                                                                  icon: Image
                                                                      .asset(
                                                                    'assets/images/refresh.png',
                                                                    width: 22,
                                                                    height: 22,
                                                                  ),
                                                                  iconSize:
                                                                      22.0,
                                                                  onPressed: () =>
                                                                      player.seek(
                                                                          Duration
                                                                              .zero),
                                                                ),
                                                  InkWell(
                                                    onTap: () async {
                                                      if (player.speed == 1.0) {
                                                        await player
                                                            .setSpeed(1.5);
                                                      } else if (player.speed ==
                                                          1.5) {
                                                        await player
                                                            .setSpeed(2);
                                                      } else {
                                                        await player
                                                            .setSpeed(1);
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/speed.png',
                                                          width: 22,
                                                          height: 22,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          '${player.speed}x',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            letterSpacing: 0.5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : widget
                                    .commentItems[widget.commentIndex]
                                        ['mediaUrl']
                                    .isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.commentItems[
                                              widget.commentIndex]['comment'] !=
                                          '')
                                        ReadMoreText(
                                          widget.commentItems[
                                              widget.commentIndex]['comment'],
                                          trimLines: 2,
                                          trimMode: TrimMode.Line,
                                          trimCollapsedText: 'Show more',
                                          trimExpandedText: 'Show less',
                                          moreStyle: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          lessStyle: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              ),
                                        ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Center(
                                        child: PostCarousel(
                                          listImage: widget.commentItems[
                                              widget.commentIndex]['mediaUrl'],
                                          photoHeight: 250,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 100,
                                    ),
                                    child: ReadMoreText(
                                      widget.commentItems[widget.commentIndex]
                                          ['comment'],
                                      trimLines: 2,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Show more',
                                      trimExpandedText: 'Show less',
                                      moreStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      lessStyle: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      style: const TextStyle(
                                          fontSize: 18, ),
                                    ),
                                  ),
                      ),
                      onLongPress: widget.isLongPress
                          ? () {
                              dialogBottomSheet(context: context, children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      if (widget.commentItems[
                                              widget.commentIndex]['uid'] ==
                                          meInfo[0]['uid'])
                                        ListTile(
                                          dense: true,
                                          title: const Text(
                                            "Edit",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          leading:
                                              const Icon(Icons.edit_outlined),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            CommentCubit.get(context)
                                                .imagesPath
                                                .clear();
                                            CommentCubit.get(context)
                                                .changeIsFirstEditComment(true);
                                            CommentCubit.get(context)
                                                .changeIsEditComment(true);

                                            if (CommentCubit.get(context)
                                                .isReplyComment) {
                                              CommentCubit.get(context)
                                                  .changeReplayCommentText(
                                                      widget.commentItems[widget
                                                              .commentIndex]
                                                          ['comment']);

                                              CommentCubit.get(context)
                                                  .changeReplayCommentClickId(
                                                      widget
                                                          .commentItems[widget
                                                              .commentIndex]
                                                          .id);
                                            } else {
                                              CommentCubit.get(context)
                                                  .changeCommentClickIndex(
                                                      widget.commentIndex);
                                            }
                                          },
                                        ),
                                      if (widget.commentItems[
                                                  widget.commentIndex]['uid'] ==
                                              meInfo[0]['uid'] ||
                                          widget.ownerUid == meInfo[0]['uid'])
                                        ListTile(
                                          dense: true,
                                          title: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          leading:
                                              const Icon(Icons.delete_outline),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            FirebaseFirestore.instance
                                                .collection('userPosts')
                                                .doc(widget.postId)
                                                .collection('comments')
                                                .doc(widget
                                                    .commentItems[
                                                        widget.commentIndex]
                                                    .id)
                                                .delete()
                                                .then((value) {
                                              showToast(
                                                  text: 'delete successful',
                                                  state: ToastStates.success);
                                            }).catchError((error) {
                                              showToast(
                                                  text: 'failed try again',
                                                  state: ToastStates.error);
                                            });
                                          },
                                        ),
                                      ListTile(
                                        dense: true,
                                        title: const Text(
                                          "Report",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        leading: const Icon(Icons
                                            .report_gmailerrorred_outlined),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          dialogBottomSheet(
                                              context: context,
                                              children: [
                                                ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: 1,
                                                  title: const Text(
                                                    "identity hate",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  leading: Image.asset(
                                                    'assets/images/hate.png',
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();

                                                    isToxicComment(
                                                        widget.commentItems[widget
                                                                .commentIndex]
                                                            ['comment'],
                                                        'identity_hate',
                                                        widget.ownerUid,
                                                        widget.postId,
                                                        widget
                                                            .commentItems[widget
                                                                .commentIndex]
                                                            .id);
                                                  },
                                                ),
                                                ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: 1,
                                                  title: const Text(
                                                    "insult",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  leading: Image.asset(
                                                    'assets/images/insult.png',
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();

                                                    isToxicComment(
                                                        widget.commentItems[widget
                                                                .commentIndex]
                                                            ['comment'],
                                                        'insult',
                                                        widget.ownerUid,
                                                        widget.postId,
                                                        widget
                                                            .commentItems[widget
                                                                .commentIndex]
                                                            .id);
                                                  },
                                                ),
                                                ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: 1,
                                                  title: const Text(
                                                    "obscene",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  leading: Image.asset(
                                                    'assets/images/obscene.png',
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    isToxicComment(
                                                        widget.commentItems[widget
                                                                .commentIndex]
                                                            ['comment'],
                                                        'obscene',
                                                        widget.ownerUid,
                                                        widget.postId,
                                                        widget
                                                            .commentItems[widget
                                                                .commentIndex]
                                                            .id);
                                                  },
                                                ),
                                                ListTile(
                                                  dense: true,
                                                  horizontalTitleGap: 1,
                                                  title: const Text(
                                                    "threat",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  leading: Image.asset(
                                                    'assets/images/threat.png',
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    isToxicComment(
                                                        widget.commentItems[widget
                                                                .commentIndex]
                                                            ['comment'],
                                                        'threat',
                                                        widget.ownerUid,
                                                        widget.postId,
                                                        widget
                                                            .commentItems[widget
                                                                .commentIndex]
                                                            .id);
                                                  },
                                                ),
                                              ]);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ]);
                            }
                          : null,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              child: Image.asset(
                                widget.commentItems[widget.commentIndex]
                                            ['likes']
                                        .containsKey(user!.uid)
                                    ? 'assets/images/heart_fill.png'
                                    : 'assets/images/heart_outline.png',
                                height: 22,
                                width: 22,
                              ),
                              onTap: () async {
                                await likeClick(context, widget);
                              },
                            ),
                            Text(
                                ' ${numberformatted.NumberFormat.compact().format(widget.commentItems[widget.commentIndex]['likes'].length)}')
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (CommentCubit.get(context).isReplyComment) {
                            } else {
                              CommentCubit.get(context)
                                  .changeIsReplyComment(true);
                              CommentCubit.get(context)
                                  .changeCommentClickIndex(widget.commentIndex);
                              CommentCubit.get(context).changeCommentClickId(
                                  widget.commentItems[widget.commentIndex].id);
                            }
                          },
                          child: Image.asset(
                            'assets/images/comment.png',
                            height: 22,
                            width: 22,
                          ),
                        ),
                        Text(
                            TimeAgoExtention.displayTimeAgoFromTimestamp(
                                widget.commentItems[widget.commentIndex]['time']
                                    .toDate()
                                    .toString(),
                                true),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, this.total});

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

likeClick(context, widget) async {
  if (CommentCubit.get(context).isReplyComment) {
    if (widget.commentItems[widget.commentIndex]['likes']
        .containsKey(user!.uid)) {
      await FirebaseFirestore.instance
          .collection("userPosts")
          .doc(widget.commentItems[widget.commentIndex]['postId'])
          .collection('comments')
          .doc(CommentCubit.get(context).commentClickId)
          .collection('replyComment')
          .doc(widget.commentItems[widget.commentIndex].id)
          .set({
        'likes': {user!.uid: FieldValue.delete()}
      }, SetOptions(merge: true));
      await removeFromActivityUser(
          uid: widget.commentItems[widget.commentIndex]['uid']);
    } else {
      await FirebaseFirestore.instance
          .collection("userPosts")
          .doc(widget.commentItems[widget.commentIndex]['postId'])
          .collection('comments')
          .doc(CommentCubit.get(context).commentClickId)
          .collection('replyComment')
          .doc(widget.commentItems[widget.commentIndex].id)
          .set(
        {
          'likes': {user!.uid: 'like'}
        },
        SetOptions(merge: true),
      );
      await addToActivityFeed(
          type: 'likeComment',
          uid: widget.commentItems[widget.commentIndex]['uid'],
          postId: widget.commentItems[widget.commentIndex]['postId'],
          postText: widget.commentItems[widget.commentIndex]['comment'],
          profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
          name: meInfo[0]['name'].toString(),
          mediaUrl: widget.commentItems[widget.commentIndex]['mediaUrl']);
    }
  } else {
    if (widget.commentItems[widget.commentIndex]['likes']
        .containsKey(user!.uid)) {
      await FirebaseFirestore.instance
          .collection("userPosts")
          .doc(widget.commentItems[widget.commentIndex]['postId'])
          .collection('comments')
          .doc(widget.commentItems[widget.commentIndex].id)
          .set({
        'likes': {user!.uid: FieldValue.delete()}
      }, SetOptions(merge: true));
      await removeFromActivityUser(
          uid: widget.commentItems[widget.commentIndex]['uid']);
    } else {
      await FirebaseFirestore.instance
          .collection("userPosts")
          .doc(widget.commentItems[widget.commentIndex]['postId'])
          .collection('comments')
          .doc(widget.commentItems[widget.commentIndex].id)
          .set(
        {
          'likes': {user!.uid: 'like'}
        },
        SetOptions(merge: true),
      );
      await addToActivityFeed(
          type: 'likeComment',
          uid: widget.commentItems[widget.commentIndex]['uid'],
          postId: widget.commentItems[widget.commentIndex]['postId'],
          postText: widget.commentItems[widget.commentIndex]['comment'],
          profilePhoto: meInfo[0]['profilePhotoUrl'].toString(),
          name: meInfo[0]['name'].toString(),
          mediaUrl: widget.commentItems[widget.commentIndex]['mediaUrl']);
    }
  }
}
