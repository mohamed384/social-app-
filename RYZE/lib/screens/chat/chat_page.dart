import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/timeAgo_display.dart';
import 'package:ryze/screens/chat/chat_room.dart';
import 'package:ryze/shared/component/navigate.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              children: const [
                Text(
                  'Recent Chats',
                ),
                Spacer(),
                Icon(
                  Icons.search,
                  color: Colors.blue,
                )
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: getRecentChatMessage(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Object?>> chatItems =
                      snapshot.data!.docs;
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: chatItems.length,
                      itemBuilder: (context, int index) {
                        final recentChat = chatItems[index];
                        return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(getUserFromListUser(recentChat['users']))
                                .get(),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                dynamic userItems = snap.data!.data();
                                return Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  userItems['profilePhotoUrl']),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            navigateTo(context,
                                                ChatRoom(userData: userItems));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.6,
                                                child: Text(
                                                  userItems['name'].toString(),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:const TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              if (recentChat[
                                                          'lastMessageMediaUrl']
                                                      .isNotEmpty ||
                                                  recentChat[
                                                          'lastMessageVoiceUrl']
                                                      .isNotEmpty)
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                              if (recentChat[
                                                      'lastMessageMediaUrl']
                                                  .isNotEmpty)
                                                Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.photo,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text('photo'),
                                                  ],
                                                ),
                                              if (recentChat[
                                                      'lastMessageVoiceUrl']
                                                  .isNotEmpty)
                                                Row(
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .keyboard_voice_outlined,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text('voice'),
                                                  ],
                                                ),
                                              if (recentChat[
                                                      'lastMessageMediaUrl']
                                                  .isEmpty)
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  child: Text(
                                                    recentChat['lastMessage']
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const CircleAvatar(
                                              radius: 8,
                                              backgroundColor: Colors.blueGrey,
                                              child: Text(
                                                '1',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(TimeAgoExtention
                                                .displayTimeAgoFromTimestamp(
                                                    recentChat[
                                                            'lastMessageSendTime']
                                                        .toDate()
                                                        .toString(),
                                                    true))
                                          ],
                                        ),
                                      ],
                                    ));
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            });
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })
        ],
      ),
    );
  }
}
