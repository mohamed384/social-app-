import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:ryze/screens/story/add_story_screen.dart';
import 'package:ryze/shared/component/choose_image.dart';
import 'package:ryze/shared/component/circle_edit_photo.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';

class Story extends StatefulWidget {
  final Map? userInfo;
  final dynamic storyItems;

  const Story({Key? key, required this.storyItems, required this.userInfo})
      : super(key: key);

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  late AuthCubit cubit;

  @override
  void initState() {
    cubit = AuthCubit.get(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.userInfo == null) {
        return await getUsersDetailsFromFirebase(
            context, widget.storyItems['uid']);
      }
      if (widget.storyItems == null) {
        userInfo[0] = meInfo[0];
      }
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    cubit.imagesPath.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
          child: SizedBox(
            width: 120.0, //story container width
            height: 230.0, //story container height
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  widget.storyItems == null
                                      ? meInfo[0]['profilePhotoUrl']
                                      : widget.storyItems['mediaUrl'][0]),
                              fit: BoxFit.cover,
                              colorFilter: widget.storyItems == null
                                  ? const ColorFilter.mode(
                                      Colors.black45, BlendMode.hardLight)
                                  : null),
                          borderRadius: BorderRadius.circular(10.0)),
                      width: 120.0, //story image width
                      height: 160.0,
                      //story image height
                    ),
                  ],
                ),
                Padding(
                  child: PhysicalModel(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.transparent,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: widget.storyItems == null
                          ? null
                          : BoxDecoration(
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      widget.userInfo == null
                                          ? userInfo[0]['profilePhotoUrl']
                                          : widget
                                              .userInfo!['profilePhotoUrl']),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                  width: 3.0,
                                  color: widget.storyItems['storySeen']
                                          .contains(meInfo[0]['uid'])
                                      ? Colors.grey
                                      : const Color(0xFF2845E7)),
                            ),
                      child: widget.storyItems == null
                          ? CircleImage(
                              width: 10,
                              height: 10,
                              image: InkWell(
                                  onTap: () async {
                                    imagesPaths.clear();
                                    await showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return Center(
                                              child: ChoosePhotoFrom(
                                                  context: context,
                                                  onTabCamera: () async {
                                                    Navigator.pop(ctx);
                                                    cubit.changeImagesPath(
                                                        await getImage(
                                                      source:
                                                          ImageSource.camera,
                                                    ));
                                                    navigateTo(
                                                        context,
                                                        AddStoryScreen(
                                                          cubit: cubit,
                                                        ));
                                                  },
                                                  onTabGallary: () async {
                                                    Navigator.pop(ctx);
                                                    cubit.changeImagesPath(
                                                        await getImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    ));
                                                    navigateTo(
                                                        context,
                                                        AddStoryScreen(
                                                          cubit: cubit,
                                                        ));
                                                  }));
                                        });

                                    // await  cubit.uploadToFirebase(isStory: true,postId:widget.items[widget.position]['storyId']);
                                  },
                                  child: const Icon(
                                    Icons.add_box,
                                  )),
                              paddingImage: 0,
                              borderRadius: 10.0,
                              isShadow: false,
                              isBorder: false,
                            )
                          : null,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(5.0, 85.0, 5.0, 0.0),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 160.0, 5.0, 0.0),
                  child: widget.storyItems == null
                      ? const Text('Create Story',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))
                      : Text(
                          widget.storyItems['name'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
