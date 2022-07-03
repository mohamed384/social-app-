import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/layout/cubit/states.dart';
import 'package:ryze/models/firebase.dart';
import 'package:ryze/models/timeAgo_display.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/chat/home_chat.dart';
import 'package:ryze/screens/posts/add_posts.dart';
import 'package:ryze/screens/comment/comments.dart';
import 'package:ryze/screens/posts/edit_post.dart';
import 'package:ryze/screens/profile/profile.dart';
import 'package:ryze/screens/search_screen.dart';
import 'package:ryze/screens/show_story.dart';
import 'package:ryze/shared/component/bottom_dialog.dart';
import 'package:ryze/shared/component/like_Animation.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/component/post_carousel.dart';
import 'package:ryze/screens/story/my_story.dart';
import 'package:ryze/shared/component/toast.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:intl/intl.dart' as numberformatted;

class HomePosts extends StatefulWidget {
  final ScrollController controller;

  const HomePosts({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomePosts> createState() => _HomePostsState();
}

class _HomePostsState extends State<HomePosts> {
  late HomeCubit cubit;

  @override
  void initState() {
    // TODO: implement initState
    cubit = HomeCubit.get(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cubit.getFollowers(user!.uid);
      return await cubit.getTimeline();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(listener: (context, state) {
      if (state is FirebasePostsErrorState) {
        showToast(
          text: state.error,
          state: ToastStates.error,
        );
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: ScrollAppBar(
          automaticallyImplyLeading: false,
          controller: widget.controller,
          // Note the controller here
          title: const Text("Ryze"),
          elevation: 0.8,
          actions: [
            IconButton(
              onPressed: () {
                navigateTo(context, const AddNewPost());
              },
              icon: const Icon(Icons.add_box_outlined),

            ),
            IconButton(
              onPressed: () {
                navigateTo(context, const Search());
              },
              icon: const Icon(Icons.search),

            ),
            IconButton(
              onPressed: () {
                navigateTo(context, const HomeChat());
              },
              icon: const Icon(Icons.message),
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            RefreshIndicator(
              onRefresh: () {
                cubit.forRefresh();
                return Future.delayed(const Duration(seconds: 1), () {});
              },
              child: SingleChildScrollView(
                controller: widget.controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StoryHome(cubit: cubit),
                    Divider(
                      thickness: 8,
                      color: Colors.grey.withOpacity(.3),
                    ),
                    Posts(
                      cubit: cubit,
                      postItem: cubit.timelinePosts,
                    ),
                  ],
                ),
              ),
            ),
            cubit.isSentimentPostAnim
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3.2,
                        ),
                        cubit.isSentimentPost
                            ? Image.asset(
                                'assets/images/good-review.png',
                                width: 200,
                              )
                            : Image.asset(
                                'assets/images/bad-review.png',
                                width: 200,
                              ),
                        Text(
                          cubit.isSentimentPost
                              ? 'post is positive '
                              : 'post is negative',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: cubit.isSentimentPost
                                  ? Colors.green.shade200
                                  : HexColor('#fb254a')),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    });
  }
}

class StoryHome extends StatelessWidget {
  final HomeCubit cubit;


  const StoryHome({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235.0,
      child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('userStories')
              .orderBy('time', descending: true)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<Object?>> items = snapshot.data!.docs;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        navigateTo(
                            context,
                            ShowStory(
                              storyItems: items.isEmpty ? null : items[0],
                              userItem: meInfo[0],
                            ));
                      },
                      child: Story(
                          storyItems: items.isEmpty ? null : items[0],
                          userInfo: meInfo[0]),
                    ),
                    ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, int position) {
                          return InkWell(
                              onTap: () {
                                navigateTo(
                                    context,
                                    ShowStory(
                                      storyItems:
                                          items.isEmpty ? null : items[0],
                                      userItem: null,
                                    ));
                              },
                              child: items[position]['uid'] != meInfo[0]['uid']
                                  ? Story(
                                      storyItems: items[position],
                                      userInfo: null)
                                  : const SizedBox());
                        }),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}

class Posts extends StatelessWidget {
  final HomeCubit cubit;
  final dynamic postItem;

  const Posts({Key? key, required this.cubit, required this.postItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: postItem.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              InkWell(
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      postItem[index]
                                      ['profilePhotoUrl']),
                                  radius: 22,
                                ),
                                onTap: () {
                                  navigateTo(
                                      context,
                                      FutureBuilder(
                                          future:
                                          getUsersDetailsFromFirebase(
                                              context,
                                              postItem[index]
                                              ['uid']),
                                          builder: (context, snap) {
                                            if (snap.hasData) {
                                              return ProfileScreen(
                                                userItem: userInfo[0],
                                                isMyProfile: false,
                                              );
                                            } else {
                                              return const Center(
                                                  child:
                                                  CircularProgressIndicator());
                                            }
                                          }));
                                },
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            postItem[index]['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                          onTap: () {
                                            navigateTo(
                                                context,
                                                FutureBuilder(
                                                    future:
                                                    getUsersDetailsFromFirebase(
                                                        context,
                                                        postItem[
                                                        index]
                                                        [
                                                        'uid']),
                                                    builder: (context,
                                                        snap) {
                                                      if (snap
                                                          .hasData) {
                                                        return ProfileScreen(
                                                          userItem:
                                                          userInfo[
                                                          0],
                                                          isMyProfile:
                                                          false,
                                                        );
                                                      } else {
                                                        return const Center(
                                                            child:
                                                            CircularProgressIndicator());
                                                      }
                                                    }));
                                          },
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              TimeAgoExtention
                                                  .displayTimeAgoFromTimestamp(
                                                  postItem[index]
                                                  ['time']
                                                      .toDate()
                                                      .toString(),
                                                  false),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                 ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            if (postItem[index]
                                            ['isUpdated'])
                                              InkWell(
                                                onTap: () {
                                                  cubit
                                                      .changeIsEditAnim(
                                                      true);
                                                },
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 15,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    AnimatedOpacity(
                                      opacity: cubit.isEditAnim ? 1 : 0,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: LikeAnimation(
                                        child: Container(
                                          padding:
                                          const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                5),
                                          ),
                                          child: Text(
                                            'Edited on ' +
                                                TimeAgoExtention
                                                    .displayTimeAgoFromTimestamp(
                                                    postItem[index][
                                                    'editTime']
                                                        .toDate()
                                                        .toString(),
                                                    false),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                ),
                                          ),
                                        ),
                                        isAnimating: cubit.isEditAnim,
                                        animTime: 2000,
                                        onEnd: () {
                                          cubit.changeIsEditAnim(false);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 25,
                          ),
                          onPressed: () {
                            dialogBottomSheet(
                                context: context,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      children: [
                                        if (postItem[index]['text'] !=
                                            '')
                                          ListTile(
                                            dense: true,
                                            title: const Text(
                                              "check the post mode",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: const Icon(
                                                Icons.ac_unit),
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .pop();
                                              await sentimentPost(
                                                  postItem[index]
                                                  ['text'],
                                                  cubit,
                                                  context);
                                              cubit
                                                  .changeIsSentimentPostAnim(
                                                  true);
                                              await Future.delayed(
                                                  const Duration(
                                                      seconds: 2), () {
                                                cubit
                                                    .changeIsSentimentPostAnim(
                                                    false);
                                              });
                                              //cubit.isSentimentPost? Image.asset('assets/images/good-review.png',width: 22,):Image.asset('assets/images/bad-review.png',width: 22,);
                                            },
                                          ),
                                        if (postItem[index]['uid'] ==
                                            meInfo[0]['uid'])
                                          ListTile(
                                            dense: true,
                                            title: const Text(
                                              "Edit",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: const Icon(
                                                Icons.edit_outlined),
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .pop();
                                              navigateTo(
                                                  context,
                                                  EditPost(
                                                    postItem: postItem,
                                                    postIndex: index,
                                                  ));
                                            },
                                          ),
                                        if (postItem[index]['uid'] ==
                                            meInfo[0]['uid'])
                                          ListTile(
                                            dense: true,
                                            title: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            leading: const Icon(
                                                Icons.delete_outline),
                                            onTap: () async {
                                              Navigator.of(context)
                                                  .pop();

                                              AuthCubit.get(context)
                                                  .changeTextField('');
                                              await FirebaseFirestore
                                                  .instance
                                                  .collection(
                                                  'userPosts')
                                                  .doc(postItem[index]
                                              ['postId'])
                                                  .delete()
                                                  .then((value) {

                                                showToast(
                                                    text:
                                                    'delete successful',
                                                    state: ToastStates
                                                        .success);
                                              }).catchError((error) {
                                                showToast(
                                                    text:
                                                    'failed try again',
                                                    state: ToastStates
                                                        .error);
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
                                                    horizontalTitleGap:
                                                    1,
                                                    title: const Text(
                                                      "identity hate",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    leading:
                                                    Image.asset(
                                                      'assets/images/hate.png',
                                                      height: 22,
                                                      width: 22,
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(
                                                          context)
                                                          .pop();

                                                      isToxicComment(
                                                          postItem[
                                                          index]
                                                          ['text'],
                                                          'identity_hate',
                                                          meInfo[0][
                                                          'uid']
                                                              .toString(),
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],isPost: true);
                                                    },
                                                  ),
                                                  ListTile(
                                                    dense: true,
                                                    horizontalTitleGap:
                                                    1,
                                                    title: const Text(
                                                      "insult",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    leading:
                                                    Image.asset(
                                                      'assets/images/insult.png',
                                                      height: 22,
                                                      width: 22,
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(
                                                          context)
                                                          .pop();

                                                      isToxicComment(
                                                          postItem[
                                                          index]
                                                          ['text'],
                                                          'insult',
                                                          meInfo[0][
                                                          'uid']
                                                              .toString(),
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],isPost: true);
                                                    },
                                                  ),
                                                  ListTile(
                                                    dense: true,
                                                    horizontalTitleGap:
                                                    1,
                                                    title: const Text(
                                                      "obscene",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    leading:
                                                    Image.asset(
                                                      'assets/images/obscene.png',
                                                      height: 22,
                                                      width: 22,
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(
                                                          context)
                                                          .pop();
                                                      isToxicComment(
                                                          postItem[
                                                          index]
                                                          ['text'],
                                                          'obscene',
                                                          meInfo[0][
                                                          'uid']
                                                              .toString(),
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],isPost: true);
                                                    },
                                                  ),
                                                  ListTile(
                                                    dense: true,
                                                    horizontalTitleGap:
                                                    1,
                                                    title: const Text(
                                                      "threat",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    leading:
                                                    Image.asset(
                                                      'assets/images/threat.png',
                                                      height: 22,
                                                      width: 22,
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(
                                                          context)
                                                          .pop();
                                                      isToxicComment(
                                                          postItem[
                                                          index]
                                                          ['text'],
                                                          'threat',
                                                          meInfo[0][
                                                          'uid']
                                                              .toString(),
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],
                                                          postItem[
                                                          index]
                                                          [
                                                          'postId'],isPost: true);
                                                    },
                                                  ),
                                                ]);
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ]);
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    postItem[index]['text'] != null
                        ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            postItem[index]['text'],
                            style: const TextStyle(
                                fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
                        : const SizedBox(),
                    postItem[index]['mediaUrl'].isNotEmpty
                        ? PostCarousel(
                      listImage: postItem[index]['mediaUrl'],
                      postId: postItem[index]['postId'],
                      onDoubleTap: () async {
                        await addToActivityFeed(
                            type: 'like',
                            uid: postItem[index]['uid'],
                            postId: postItem[index]['postId'],
                            postText: postItem[index]['text'],
                            profilePhoto: meInfo[0]
                            ['profilePhotoUrl']
                                .toString(),
                            name: meInfo[0]['name'].toString(),
                            mediaUrl: postItem[index]
                            ['mediaUrl']);
                      },
                    )
                        : const SizedBox(),
                    const SizedBox(
                      height: 10,
                    ),
                    LikeCommentShare(
                      postItems: postItem[index],
                    )

                  ],
                ),
              ),
              Divider(
                thickness: 8,
                height: 0,
                color: Colors.grey.withOpacity(.3),
              ),
            ],
          );
        });
  }
}

class LikeCommentShare extends StatelessWidget {
  final dynamic postItems;

  const LikeCommentShare({Key? key, required this.postItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userPosts')
            .doc(postItems['postId'])
            .collection('comments')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var commentItems = snapshot.data!.docs;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 20,
                      child: postItems['likes'].length != 0
                          ? Text(
                              numberformatted.NumberFormat.compact()
                                  .format(postItems['likes'].length),
                              style: const TextStyle(
                                  fontSize: 12,),
                            )
                          : const Text(''),
                    ),
                    SizedBox(
                      width: 20,
                      child: commentItems.isNotEmpty
                          ? Text(
                              numberformatted.NumberFormat.compact()
                                  .format(commentItems.length),
                              style: const TextStyle(
                                  fontSize: 12,),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  height: 5,
                  color: Colors.grey.withOpacity(.3),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child: Image.asset(
                        postItems['likes'].containsKey(user!.uid)
                            ? 'assets/images/heart_fill.png'
                            : 'assets/images/heart_outline.png',
                        height: 20,
                        width: 20,
                      ),
                      onTap: () async {
                        if (postItems['likes'].containsKey(user!.uid)) {
                          await FirebaseFirestore.instance
                              .collection("userPosts")
                              .doc(postItems['postId'])
                              .set({
                            'likes': {user!.uid: FieldValue.delete()}
                          }, SetOptions(merge: true));
                          await removeFromActivityUser(uid: postItems['uid']);
                        } else {
                          await FirebaseFirestore.instance
                              .collection("userPosts")
                              .doc(postItems['postId'])
                              .set(
                            {
                              'likes': {user!.uid: 'like'}
                            },
                            SetOptions(merge: true),
                          );
                          await addToActivityFeed(
                              type: 'like',
                              uid: postItems['uid'],
                              postId: postItems['postId'],
                              postText: postItems['text'],
                              profilePhoto:
                                  meInfo[0]['profilePhotoUrl'].toString(),
                              name: meInfo[0]['name'].toString(),
                              mediaUrl: postItems['mediaUrl']);
                        }
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        showGeneralDialog(
                            barrierLabel: "Comments",
                            barrierDismissible: false,
                            barrierColor: Colors.black.withOpacity(0.5),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            context: context,
                            pageBuilder: (context, anim1, anim2) {
                              return CommentsPage(
                                postItems: postItems,
                                commentItems: commentItems,
                              );
                            },
                            transitionBuilder: (context, anim1, anim2, child) {
                              return SlideTransition(
                                position: Tween(
                                        begin: const Offset(0, 1),
                                        end: const Offset(0, 0))
                                    .animate(anim1),
                                child: child,
                              );
                            });
                      },
                      icon: Image.asset(
                        'assets/images/comment.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ],
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
