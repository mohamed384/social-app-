import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:ryze/screens/posts/home_posts.dart';
import 'package:ryze/screens/profile/profile.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/component/post_carousel.dart';
import 'package:ryze/shared/component/text_form.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController controller = TextEditingController();
  late AuthCubit cubit;

  @override
  void initState() {
    cubit = AuthCubit.get(context);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    cubit.textFieldSearch = ''; // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            title: TextForm(
              hintText: 'search here',
              isBorder: false,
              onChange: (value) {
                cubit.changeTextFieldSearch(value);
              },
              controller: controller,
            ),
            titleSpacing: 0.0,
            actions: [
              IconButton(onPressed: () {
                cubit.changeTextFieldSearch('');
                controller.text='';
              }, icon: const Icon(Icons.close))
            ],
          ),
          body: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    onTap: (index) {
                      cubit.changeTabSearchIndex(index);
                    },
                    indicator:
                    CircleTabIndicator(color:const Color(0xff035AA6), radius: 4),
                    indicatorSize: TabBarIndicatorSize.label,
                    unselectedLabelColor:Get.isDarkMode?Colors.white: Colors.grey,
                    labelColor:const Color(0xff035AA6),
                    tabs: [
                      Tab(
                        text: 'Persons'.tr,
                      ),
                      Tab(
                        text: 'Posts'.tr,
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream:FirebaseFirestore.instance
                                .collection('users')
                                .where("nameSearch", arrayContains: cubit.textFieldSearch)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData){
                                List<QueryDocumentSnapshot<Object?>> searchItemsPerson =
                                    snapshot.data!.docs;
                                return ListView.builder(
                                  itemCount: searchItemsPerson.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot data =
                                    searchItemsPerson[index];
                                    return InkWell(
                                      child: Card(
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: CircleAvatar(
                                                radius: 28,
                                                backgroundImage: NetworkImage(
                                                    data['profilePhotoUrl']
                                                        .toString()),
                                              ),
                                            ),
                                            Text(
                                              data['name'],
                                              style: const TextStyle(
                                                fontSize: 24,
                                                color: Color(0xff035AA6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        navigateTo(
                                            context,
                                            ProfileScreen(
                                              userItem: data,
                                              isMyProfile: false,
                                            ));

                                      },
                                    );
                                  },
                                );
                              }else {
                                return const Center(child: CircularProgressIndicator());
                              }

                            }
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream:FirebaseFirestore.instance
                                .collection('userPosts')
                                .where("postTextSearch", arrayContains: cubit.textFieldSearch)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData){
                                List<QueryDocumentSnapshot<Object?>> searchItemsPosts =
                                    snapshot.data!.docs;
                                return ListView.builder(
                                  itemCount: searchItemsPosts.length,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot data =
                                    searchItemsPosts[index];
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
                                                    child: InkWell(
                                                      child: Row(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage: NetworkImage(
                                                                data
                                                                ['profilePhotoUrl']),
                                                            radius: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                               data
                                                                ['name'],
                                                                maxLines: 1,
                                                                overflow: TextOverflow.fade,
                                                                softWrap: false,
                                                                style: const TextStyle(
                                                                    fontSize: 18,
                                                                    color: Colors.black,
                                                                    fontWeight:
                                                                    FontWeight.bold),
                                                              ),
                                                              const SizedBox(
                                                                height: 3,
                                                              ),

                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      onTap: ()async{
                                                       await HomeCubit.get(context).getPosts(data['uid']);
                                                        navigateTo(
                                                            context,
                                                            ProfileScreen(
                                                              userItem: data[index],
                                                              isMyProfile: false,

                                                            ));
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                             data['text'] != null
                                                  ? Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                     data['text'],
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              )
                                                  : const SizedBox(),
                                             data['mediaUrl'].isNotEmpty
                                                  ? PostCarousel(
                                                listImage:data
                                                ['mediaUrl'],
                                                postId: data.id,
                                              )
                                                  : const SizedBox(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              LikeCommentShare(
                                                postItems: searchItemsPosts[index],
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
                                  },
                                );
                              }else {
                                return const Center(child: CircularProgressIndicator());
                              }

                            }
                        ),
                      ],
                    ),
                  ),

                ],
              )),
        );
      },
    );
  }
}




class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}


