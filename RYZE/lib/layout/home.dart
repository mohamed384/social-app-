import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ryze/activity_users.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/layout/cubit/states.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/friends.dart';
import 'package:ryze/screens/posts/home_posts.dart';
import 'package:ryze/screens/profile/profile.dart';

import 'package:scroll_bottom_navigation_bar/scroll_bottom_navigation_bar.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
   ScrollController controller= ScrollController();
   late List<Widget> homeScreens;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      return await getMeDetailsFromFirebase(context);
    });

    homeScreens = <Widget>[
      HomePosts(controller:controller),
      const Friends(),
      const ActivityUsers(),
      ProfileScreen(userItem: meInfo[0],isMyProfile: true),
    ];
    super.initState();
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
          return HomeCubit.get(context).isLoaded
              ? const Center(child: CircularProgressIndicator())
              : Scaffold(
                  body: ValueListenableBuilder<int>(
                        valueListenable:
                           controller.bottomNavigationBar.tabNotifier,
                        builder: (context, tabIndex, child) {
                          return homeScreens.elementAt(tabIndex);
                        }),

                  bottomNavigationBar: ScrollBottomNavigationBar(
                    controller: controller,
                    items: [
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.person_add), label: 'Follow'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.notifications),
                          label: 'Notifications'),
                      BottomNavigationBarItem(
                          icon: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  alignment: FractionalOffset.center,
                                  image: CachedNetworkImageProvider(
                                      meInfo[0]['profilePhotoUrl'].toString()),
                                )),
                          ),
                          label: 'Profile'),
                    ],
                  ),
                );
        });
  }



}
