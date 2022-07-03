import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/component/post_carousel.dart';
import 'package:ryze/shared/constants/constants.dart';

class EditPost extends StatefulWidget {
  final dynamic postItem;
  final int postIndex;

  const EditPost({
    Key? key,
    required this.postItem,
    required this.postIndex,
  }) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  TextEditingController postTextController = TextEditingController();
  final indicatorController = CarouselController();

  late List mediaUrl;
  late AuthCubit cubit;

  @override
  void initState() {
    cubit = AuthCubit.get(context);
    postTextController.text = widget.postItem[widget.postIndex]['text'];
    cubit.changeImagesPath(widget.postItem[widget.postIndex]['mediaUrl']);
    super.initState();
  }

  @override
  void dispose() {
    postTextController.dispose();
    cubit.imagesPath.clear();
    imagesPaths.clear();
    cubit.changeTextField('');
    cubit.index = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(listener: (_, state) {
      if (state is UploadToFirebaseSuccessState) {
        cubit.updatePost(
            postId: widget.postItem[widget.postIndex].id,
            mediaUrl: mediaUrl,
            text: postTextController.text);
      }
      if (state is UpdatePostSuccessState) {
        HomeCubit.get(context).forRefresh();
        cubit.imagesPath.clear();
        imagesPaths.clear();
        cubit.changeTextField('');
        navigatePop(context);
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('edit_post'.tr),
          actions: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: cubit.isUploadedPost
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: Icon(Icons.check,
                            size: 30,
                            color: cubit.textFieldPost.isEmpty
                                ? Colors.grey
                                : Colors.blue),
                        onPressed: () async {
                          if (cubit.imagesPath.isNotEmpty) {
                            mediaUrl = await cubit.uploadToFirebase(
                                postId: widget.postItem[widget.postIndex].id);
                          }
                          if (cubit.textFieldPost != '' &&
                              cubit.imagesPath.isEmpty) {
                            cubit.updatePost(
                                mediaUrl: [],
                                text: postTextController.text,
                                postId: widget.postItem[widget.postIndex].id);
                          }
                        }))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height / 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            meInfo[0]['profilePhotoUrl'].toString()),
                        radius: 25.0,
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meInfo[0]['name'].toString(),
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'public'.tr,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: postTextController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    cubit.changeTextField(value);
                  },
                ),
                if (cubit.imagesPath.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        PostCarousel(
                          listImage: cubit.imagesPath,
                          isCubit: true,
                        ),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey,
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white,
                                size: MediaQuery.of(context).size.width / 16),
                          ),
                          onPressed: () {
                            if (cubit.imagesPath[cubit.index].runtimeType !=
                                XFile) {
                              cubit.deletePostImage(
                                  postId: widget.postItem[widget.postIndex].id,
                                  url: cubit.imagesPath[cubit.index]);
                            }
                            cubit.removeOneImagesPath();
                            if (cubit.index != 0) {
                              cubit.index--;
                            }

                            cubit.changeTextField('value');
                          },
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
        bottomSheet: SizedBox(
          height: MediaQuery.of(context).size.height / 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () async {
                    imagesPaths.clear();
                    cubit.addImagesPath(
                        await getImageMulti(imageQuality: 100, maxWidth: null));
                    if (cubit.imagesPath.isNotEmpty) {
                      cubit.changeTextField('value');
                    }
                  },
                  icon: const Icon(Icons.insert_photo)),
              IconButton(
                  onPressed: () async {
                    imagesPaths.clear();

                    cubit.addImagesPath(await getImage(
                        source: ImageSource.camera,
                        imageQuality: 100,
                        maxWidth: null));
                    if (cubit.imagesPath.isNotEmpty) {
                      cubit.changeTextField('value');
                    }
                  },
                  icon: const Icon(Icons.camera_alt)),
            ],
          ),
        ),
      );
    });
  }
}
