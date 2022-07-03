import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:uuid/uuid.dart';

class AddStoryScreen extends StatelessWidget {
  const AddStoryScreen(
      {Key? key,
      required this.cubit})
      : super(key: key);


  final AuthCubit cubit;

  @override
  Widget build(BuildContext context) {
    List mediaUrlStory = [];
    String storyId = const Uuid().v4();

    return  BlocConsumer<AuthCubit, AuthStates>(listener: (_, state) {
      if (state is UploadToFirebaseSuccessState) {
        cubit.createNewStory(storyId: storyId, mediaUrl: mediaUrlStory, text: 'text',name: meInfo[0]['name'],profilePhotoUrl:meInfo[0]['profilePhotoUrl'] );
      }

    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.crop_rotate,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.title,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 27,
                ),
                onPressed: () {}),
          ],
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: Image.file(
                  File(cubit.imagesPath[0].path),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: TextFormField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    maxLines: 6,
                    minLines: 1,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add Caption....",
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                        ),
                        suffixIcon: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.tealAccent[700],
                            child: IconButton(
                              onPressed: () async {
                                mediaUrlStory = await cubit.uploadToFirebase(
                                    isStory: true,
                                    postId: storyId);
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 27,
                              ),
                            ))),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
