import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/layout/cubit/states.dart';
import 'package:ryze/screens/comment/comments.dart';
import 'package:ryze/screens/posts/home_posts.dart';

class NotificationPosts extends StatelessWidget {
  const NotificationPosts({Key? key, required this.postId}) : super(key: key);

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('userPosts')
                          .doc(postId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Posts(
                              cubit: HomeCubit.get(context),
                              postItem: [snapshot.data!.data()]);
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),

                ],
              ),
            ),
          );
        });
  }
}
