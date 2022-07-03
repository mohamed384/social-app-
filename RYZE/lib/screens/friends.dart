import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';

import 'package:ryze/screens/profile/profile.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
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
          ),
          body: Column(
            children: [
              FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('following')
                      .doc(user!.uid)
                      .collection('userFollowing')
                      .limit(50)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List suggest = [];
                      List<QueryDocumentSnapshot<Object?>> followingItems =
                          snapshot.data!.docs;
                      for (var element in followingItems) {
                        suggest.add(element.id);
                      }
                      return FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('followers')
                              .doc((suggest..shuffle())[0])
                              .collection('userFollowers')
                              .where('uid', isNotEqualTo: user!.uid)
                              .limit(50)
                              .get(),
                          builder: (context, snapshot2) {
                            if (snapshot2.hasData) {
                              List<QueryDocumentSnapshot<Object?>>
                                  userFollowItems = snapshot2.data!.docs;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: userFollowItems.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userFollowItems[index].id)
                                          .get(),
                                      builder: (context, snapshot3) {
                                        if (snapshot3.hasData) {
                                          DocumentSnapshot<Object?>?
                                              userInfoItems = snapshot3.data;
                                          return InkWell(
                                            child: Card(
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: CircleAvatar(
                                                      radius: 28,
                                                      backgroundImage: NetworkImage(
                                                          userInfoItems![
                                                                  'profilePhotoUrl']
                                                              .toString()),
                                                    ),
                                                  ),
                                                  Text(
                                                    userInfoItems['name'],
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      color: Color(0xff035AA6),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              navigateTo(
                                                  context,
                                                  ProfileScreen(
                                                    userItem: userInfoItems,
                                                    isMyProfile: false,
                                                  ));
                                            },
                                          );
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      });
                                },
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          });
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}
