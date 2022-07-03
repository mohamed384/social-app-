import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/timeAgo_display.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/screens/comment/reply_comment.dart';
import 'package:ryze/shared/component/post_carousel.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:translator/translator.dart';

class Conversation extends StatefulWidget {
  const Conversation({
    Key? key,
    required this.messageItem,
    required this.cubit,
    required this.scrollController,
    required this.userData,
  }) : super(key: key);
  final ScrollController scrollController;
  final List<QueryDocumentSnapshot<Object?>> messageItem;
  final dynamic userData;
  final CommentCubit cubit;

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
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

    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    widget.cubit.changeSelectedIndexMode(false);
    widget.cubit.selectedIndex.clear();
    super.dispose();
  }

  Future<void> _init(message) async {
    try {
      await player.setUrl(message['voice'].toString());
    } catch (e) {
      debugPrint('An error occured $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        reverse: true,
        itemCount: widget.messageItem.length,
        itemBuilder: (context, int index) {
          final QueryDocumentSnapshot<Object?> message =
              widget.messageItem[index];
          if (message['voice'] != '') {
            _init(message);
          }
          bool isMe = message['sendBy'] == user!.uid;
          if (!message['isRead'] && !isMe) {
            FirebaseFirestore.instance
                .collection('chatRoom')
                .doc(getChatRoomIdByEmail(widget.userData['email']))
                .collection('chats')
                .where('isRead', isEqualTo: false)
                .get()
                .asStream()
                .forEach((element) {
              for (var element1 in element.docs) {
                element1.reference.update({'isRead': true});
              }
            });
          }
          return InkWell(
            onLongPress: () {
    if(widget.cubit.isTranslate){

    }else{

      widget.cubit.changeSelectedIndex(index);
      widget.cubit.changeSelectedIndexMode(true);
    }
            },
            onTap: () {
              if( widget.cubit.selectedIndexMode){
                if(widget.cubit.isTranslate){

                }else{
                  if( widget.cubit.selectedIndex.contains(index)){
                    widget.cubit.changeSelectedIndex(index,isRemove: true);
                    if(widget.cubit.selectedIndex.isEmpty){
                      widget.cubit.changeSelectedIndexMode(false);
                      widget.cubit.changeIsTranslate(false);

                    }
                  }else{
                    widget.cubit.changeSelectedIndex(index);
                  }
                }


              }


            },
            child: Container(
              color: widget.cubit.selectedIndex.contains(index)
                  ? Colors.blue.withOpacity(0.3)
                  : null,
              margin: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                            color: message['message'].isNotEmpty
                                ? isMe
                                    ? const Color(0xff4f96d5)
                                    : Colors.grey[300]
                                : null,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            )),
                        child: message['voice'] != ''
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft:
                                            Radius.circular(isMe ? 12 : 0),
                                        bottomRight:
                                            Radius.circular(isMe ? 0 : 12),
                                      ),
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
                            : message['mediaUrl'].isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: PostCarousel(
                                          listImage: message['mediaUrl'],
                                        ),
                                      ),
                                      if (message['message'] != '')
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      if (message['message'] != '')
                                        Text(
                                          message['message'],
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                    ],
                                  )
                                : Column(
                                  children: [
                                    if(widget.cubit.isTranslate&&widget.cubit.selectedIndex.contains(index))
                                    Text(
                                      widget.cubit.translation,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),

                                    Text(
                                        message['message'],
                                        style: TextStyle(
                                          fontSize: 18,

                                          color: isMe ? Colors.white : Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(TimeAgoExtention.displayTimeAgoFromTimestamp(
                          message['time'].toDate().toString(), true)),
                      if (isMe)
                        message['isRead']
                            ? const Icon(
                                Icons.done_all,
                                size: 20,
                              )
                            : const Icon(
                                Icons.done,
                                size: 20,
                              ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
