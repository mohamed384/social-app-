import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:uuid/uuid.dart';

class MessageRecordClick extends StatefulWidget {
  final FocusNode focusNode;
  final CommentCubit cubit;
  final String email;

  const MessageRecordClick({
    Key? key,
    required this.focusNode,
    required this.cubit,
    required this.email,
  }) : super(key: key);

  @override
  State<MessageRecordClick> createState() => _MessageRecordClickState();
}

class _MessageRecordClickState extends State<MessageRecordClick>
    with WidgetsBindingObserver {
  final StopWatchTimer stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    recorder.init();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online

    } else {
      // offline
      if (stopWatchTimer.rawTime.value > 0) {
        stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) async {
        stopWatchTimer.onExecute.add(StopWatchExecute.start);
        await recorder.toggleRecording('', false);
        widget.focusNode.canRequestFocus = true;
        widget.cubit.changeIsRecording(true);
        widget.cubit.changeIsRecordClose(false);
        widget.cubit.changeUpRecord(0.0);
        widget.cubit.changeLeftRecord(0.0);
      },
      onLongPressUp: widget.cubit.isRecordLock || widget.cubit.isRecordClose
          ? null
          : () async {
              if (stopWatchTimer.rawTime.value > 1600) {
                stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                var recPath = await recorder.toggleRecording('', true);
                var voiceUrl = await widget.cubit.uploadRecordToFirebase(
                    savePath:
                        'users/${meInfo[0]['uid']}/Records/${const Uuid().v4()}',
                    filePath: recPath);
                !widget.cubit.isReplyComment
                    ? await addMessage(
                        email: widget.email,
                        message: '',
                        voice: voiceUrl,
                        mediaUrl: [])
                    : await addMessage(
                        email: widget.email,
                        message: '',
                        voice: voiceUrl,
                        mediaUrl: []);
              }
              stopWatchTimer.onExecute.add(StopWatchExecute.reset);
              widget.cubit.changeIsRecording(false);
              widget.cubit.changeIsRecordLock(false);
              widget.cubit.changeUpRecord(0.0);
              widget.cubit.changeLeftRecord(0.0);
            },
      onLongPressMoveUpdate: (details) async {
        if (details.offsetFromOrigin.dy < 0 && widget.cubit.leftRecord == 0.0) {
          widget.cubit.changeUpRecord(-details.offsetFromOrigin.dy);
          if (details.offsetFromOrigin.dy < -70) {
            // Up Swipe
            widget.cubit.changeUpRecord(0.0);
            widget.cubit.changeLeftRecord(0.0);
            widget.cubit.changeIsRecordLock(true);
          }
        } else if (details.offsetFromOrigin.dx < 0 &&
            widget.cubit.upRecord == 0.0) {
          widget.cubit.changeLeftRecord(-details.offsetFromOrigin.dx);
          if (details.offsetFromOrigin.dx < -90) {
            // left Swipe
            stopWatchTimer.onExecute.add(StopWatchExecute.reset);
            await recorder.stopRecord();
            widget.cubit.changeUpRecord(0.0);
            widget.cubit.changeLeftRecord(0.0);
            widget.cubit.changeIsRecording(false);
            widget.cubit.changeIsRecordClose(true);
          }
        } else {
          widget.cubit.changeUpRecord(0.0);
          widget.cubit.changeLeftRecord(0.0);
        }
      },
      child: widget.cubit.isRecording
          ? Stack(
              alignment: Alignment.bottomRight,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints:
                          const BoxConstraints(maxHeight: 45, minHeight: 45),
                      width: MediaQuery.of(context).size.width / 1.19,
                      padding: const EdgeInsets.only(left: 10, right: 25),
                      decoration: BoxDecoration(
                        color: HexColor('#f2f0f2'),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50.0)),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mic),
                              const SizedBox(
                                width: 10,
                              ),
                              StreamBuilder<int>(
                                  stream: stopWatchTimer.rawTime,
                                  initialData: stopWatchTimer.rawTime.value,
                                  builder: (context, snapshot) {
                                    final value = snapshot.data!;
                                    final displayTime =
                                        StopWatchTimer.getDisplayTime(value,
                                            milliSecond: false);
                                    return Text(
                                      displayTime,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          Row(
                            children: [
                              widget.cubit.isRecordLock
                                  ? const SizedBox()
                                  : const Icon(Icons.arrow_left),
                              TextButton(
                                onPressed: widget.cubit.isRecordLock
                                    ? () async {
                                        stopWatchTimer.onExecute
                                            .add(StopWatchExecute.reset);
                                        await recorder.stopRecord();
                                        widget.cubit.changeIsRecording(false);
                                        widget.cubit.changeIsRecordLock(false);
                                        widget.cubit.changeUpRecord(0);
                                        widget.cubit.changeLeftRecord(0);
                                      }
                                    : null,
                                child: Text(
                                  widget.cubit.isRecordLock
                                      ? 'cancel'.tr
                                      : 'slide_cancel'.tr,
                                  style: TextStyle(
                                    color: widget.cubit.isRecordLock
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 80,
                    ),
                    widget.cubit.isRecordLock
                        ? Container(
                            constraints: const BoxConstraints(
                                maxWidth: 45, minWidth: 45),
                          )
                        : widget.cubit.isUploadedComment
                            ? Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 45, minWidth: 45),
                              )
                            : Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 45, minWidth: 45),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 25, bottom: 10, top: 10),
                                decoration: BoxDecoration(
                                  color: HexColor('#f2f0f2'),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(widget.cubit.isRecordLock
                                        ? Icons.lock_open
                                        : Icons.lock),
                                    const SizedBox(height: 5),
                                    const Icon(Icons.arrow_drop_up),
                                  ],
                                ),
                                height: 150,
                              ),
                  ],
                ),
                Positioned(
                  bottom:
                      widget.cubit.isRecordLock ? null : widget.cubit.upRecord,
                  right: widget.cubit.isRecordLock
                      ? null
                      : widget.cubit.leftRecord,
                  child: Container(
                    constraints: const BoxConstraints(
                        maxHeight: 45, maxWidth: 45, minWidth: 45),
                    width: MediaQuery.of(context).size.width / 15,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: widget.cubit.isRecordLock ? 8.0 : 0),
                        child: widget.cubit.isUploadedComment
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Image.asset(
                                widget.cubit.isRecordLock
                                    ? 'assets/images/send_gradiant.png'
                                    : 'assets/images/microphone.png',
                                width: widget.cubit.isRecordLock
                                    ? MediaQuery.of(context).size.width / 12
                                    : MediaQuery.of(context).size.width / 5),
                      ),
                      onTap: () async {
                        if (stopWatchTimer.rawTime.value > 1600) {
                          stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                          var recPath =
                              await recorder.toggleRecording('', true);
                          if (recPath != null) {
                            var voiceUrl = await widget.cubit
                                .uploadRecordToFirebase(
                                    savePath:
                                        'users/${meInfo[0]['uid']}/Records/${const Uuid().v4()}',
                                    filePath: recPath);
                            !widget.cubit.isReplyComment
                                ? await addMessage(
                                email: widget.email,
                                    message: '',
                                    voice: voiceUrl,
                                    mediaUrl: [])
                                : await addMessage(
                                email: widget.email,
                                    message: '',
                                    voice: voiceUrl,
                                    mediaUrl: []);
                          }
                        }
                        stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                        widget.cubit.changeIsRecording(false);
                        widget.cubit.changeIsRecordLock(false);
                        widget.cubit.changeUpRecord(0.0);
                        widget.cubit.changeLeftRecord(0.0);
                      },
                    ),
                  ),
                ),
              ],
            )
          : Image.asset('assets/images/microphone.png',
              fit: BoxFit.fill, width: MediaQuery.of(context).size.width / 13),
    );
  }
}
