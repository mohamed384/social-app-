import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/timeAgo_display.dart';
import 'package:ryze/screens/not_post.dart';
import 'package:ryze/screens/posts/home_posts.dart';
import 'package:ryze/screens/profile/profile.dart';
import 'package:ryze/shared/component/bottom_dialog.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';

class ActivityUsers extends StatefulWidget {
  const ActivityUsers({Key? key}) : super(key: key);

  @override
  _ActivityUsersState createState() => _ActivityUsersState();
}

class _ActivityUsersState extends State<ActivityUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(seconds: 1), () {
            setState(() {});
          });
        },
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('activity')
              .doc(user!.uid)
              .collection('activityItems')
              .orderBy('time', descending: true)
              .limit(50)
              .get(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              var itemsActivityUsers = snapshot.data!.docs;
              if (itemsActivityUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'no_notification'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        'assets/images/comment.png',
                        height: 150,
                        width: 150,
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: itemsActivityUsers.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          if(itemsActivityUsers[index]['type']=='follow'){
                            navigateTo(context, ProfileScreen(userItem: itemsActivityUsers[index]));
                          }else{
                            navigateTo(
                                context, NotificationPosts(postId: itemsActivityUsers[index]
                            ['postId']));
                          }

                        },
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      itemsActivityUsers[index]
                                          ['profilePhotoUrl']),
                                  radius:
                                      MediaQuery.of(context).size.width * 0.09,
                                ),
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.03,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(
                                      itemsActivityUsers[index]['type'] ==
                                                  'like' ||
                                              itemsActivityUsers[index]
                                                      ['type'] ==
                                                  'likeComment'
                                          ? 'assets/images/heart_fill.png'
                                          : 'assets/images/comment.png'),
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    textScaleFactor: 1.2,
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: itemsActivityUsers[index]
                                                    ['name'] +
                                                '  ',
                                            style: const TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (itemsActivityUsers[index]
                                                  ['type'] ==
                                              'like')
                                            TextSpan(
                                              text: 'like your post: '
                                                  '${itemsActivityUsers[index]['postText']}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          if (itemsActivityUsers[index]
                                                  ['type'] ==
                                              'comment')
                                            TextSpan(
                                              text: 'comment_on_post'.tr +
                                                  '${itemsActivityUsers[index]['comment']}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          if (itemsActivityUsers[index]
                                                  ['type'] ==
                                              'replyComment')
                                            TextSpan(
                                              text: 'reply_to_comment'.tr +
                                                  '${itemsActivityUsers[index]['comment']}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          if (itemsActivityUsers[index]
                                                  ['type'] ==
                                              'likeComment')
                                            TextSpan(
                                              text: 'react_to_comment'.tr +
                                                  '${itemsActivityUsers[index]['postText']}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          if (itemsActivityUsers[index]
                                                  ['type'] ==
                                              'follow')
                                            TextSpan(
                                              text: 'start_follow_you'.tr,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    TimeAgoExtention
                                        .displayTimeAgoFromTimestamp(
                                            itemsActivityUsers[index]['time']
                                                .toDate()
                                                .toString(),
                                            false),
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.more_horiz),
                                      onPressed: () {
                                        dialogBottomSheet(
                                          context: context,
                                          children: [
                                            ListTile(
                                              dense: true,
                                              title: Text(
                                                  'delete_notification'.tr),
                                              leading: const Icon(Icons.delete),
                                              onTap: () async {
                                                await removeFromActivityUser(
                                                    uid: user!.uid,
                                                    userID: itemsActivityUsers[
                                                        index]['uid']);
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
