import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/layout/cubit/states.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/chat/chat_room.dart';
import 'package:ryze/screens/posts/home_posts.dart';
import 'package:ryze/screens/profile/edit_prfile.dart';
import 'package:ryze/screens/settings.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:intl/intl.dart' as numberformatted;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {Key? key, this.isMyProfile = false, required this.userItem})
      : super(key: key);
  final bool isMyProfile;
  final dynamic userItem;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController controller = ScrollController();
  late final HomeCubit cubit;

  @override
  void initState() {
    cubit = HomeCubit.get(context);
    super.initState();
    cubit.getIsFollow(widget.userItem['uid']);
    cubit.getProfilePosts(widget.userItem['uid']);
    cubit.getFollowing(widget.userItem['uid']);
    cubit.getFollowers(widget.userItem['uid']);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: ScrollAppBar(
              controller: controller, // Note the controller here
              title: const Text("Ryze"),
              elevation: 0.8,
              actions: [
                IconButton(
                  onPressed: () {
                    navigateTo(context, const SettingsPage());
                  },
                  icon: const Icon(Icons.settings),
                  color:Get.isDarkMode?Colors.white: Colors.grey,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                          radius: 48,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            widget.userItem['profilePhotoUrl']
                                                .toString(),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          widget.userItem['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Color(0xff035AA6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            MaterialButton(
                                              onPressed: () async {
                                                if (widget.userItem['uid'] !=
                                                    meInfo[0]['uid']) {
                                                  if (cubit.isFollowBtn) {
                                                    cubit.changeIsFollowBtn(
                                                        false);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('followers')
                                                        .doc(user!.uid)
                                                        .collection(
                                                            "userFollowers")
                                                        .doc(widget
                                                            .userItem['uid'])
                                                        .delete();
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('following')
                                                        .doc(widget
                                                            .userItem['uid'])
                                                        .collection(
                                                            "userFollowing")
                                                        .doc(user!.uid)
                                                        .delete();
                                                    await removeFromActivityUser(
                                                        uid: widget
                                                            .userItem['uid']);
                                                  } else {
                                                    cubit.changeIsFollowBtn(
                                                        true);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('followers')
                                                        .doc(user!.uid)
                                                        .collection(
                                                            "userFollowers")
                                                        .doc((widget
                                                            .userItem['uid']))
                                                        .set({});
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('following')
                                                        .doc(widget
                                                            .userItem['uid'])
                                                        .collection(
                                                            "userFollowing")
                                                        .doc(user!.uid)
                                                        .set({});
                                                    await addToActivityFeed(
                                                        type: 'follow',
                                                        uid: widget
                                                            .userItem['uid'],
                                                        postId: '',
                                                        postText: '',
                                                        profilePhoto: meInfo[0][
                                                                'profilePhotoUrl']
                                                            .toString(),
                                                        name: meInfo[0]['name']
                                                            .toString(),
                                                        mediaUrl: []);
                                                  }
                                                }
                                                if (widget.userItem['uid'] ==
                                                    meInfo[0]['uid']) {
                                                  navigateTo(context, const EditProfilePage());
                                                }

                                              },
                                              color: const Color(0xff035AA6),
                                              minWidth: 180,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                widget.userItem['uid'] ==
                                                        meInfo[0]['uid']
                                                    ? 'Edit Profile'
                                                    : cubit.isFollowBtn
                                                        ? 'unFollow'
                                                        : 'Follow',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                if (!widget.isMyProfile) {
                                                  navigateTo(
                                                      context,
                                                      ChatRoom(
                                                          userData:
                                                              widget.userItem));
                                                }
                                              },
                                              color: Colors.grey[300],
                                              minWidth: 10,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(widget.isMyProfile
                                                  ? Icons.more_horiz
                                                  : Icons.messenger_outline),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        numberformatted.NumberFormat.compact()
                                            .format(
                                                cubit.profilePostFuture.length),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Color(0xff035AA6),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      const Text(
                                        'Posts',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        numberformatted.NumberFormat.compact()
                                            .format(cubit.followersList.length),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Color(0xff035AA6),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      const Text(
                                        'Followers',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        numberformatted.NumberFormat.compact()
                                            .format(cubit.followingList.length),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Color(0xff035AA6),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      const Text(
                                        'Following',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(
                              thickness: 8,
                              height: 0,
                              color: Colors.grey.withOpacity(.3),
                            ),
                            SingleChildScrollView(
                              controller: controller,
                              child: Posts(
                                cubit: cubit,
                                postItem: cubit.profilePostFuture,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
