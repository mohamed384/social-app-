import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/shared/component/choose_image.dart';
import 'package:ryze/shared/component/comment_record_click.dart';
import 'package:ryze/shared/component/message_record_click.dart';
import 'package:ryze/shared/component/text_form.dart';
import 'package:ryze/shared/constants/constants.dart';

class BottomTextF extends StatelessWidget {
  final GestureTapCallback onSendTap;
  final CommentCubit cubit;
  final TextEditingController textController;
  final FocusNode focusNode;
  final dynamic postItems;
  final bool isComment;
  final String email;

  const BottomTextF(
      {Key? key,
      required this.onSendTap,
      required this.cubit,
      required this.textController,
      required this.focusNode,
      this.postItems,
      required this.isComment,
      this.email = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cubit.isEditComment)
              Container(
                height: MediaQuery.of(context).size.height * 0.055,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    topLeft: Radius.circular(15.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/edit.png',
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width / 12,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "Edit Comment",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.purple,
                          size: MediaQuery.of(context).size.width / 16),
                      onPressed: () {
                        cubit.changeIsEditComment(false);
                        textController.text = '';
                      },
                    ),
                  ],
                ),
              ),
            if (cubit.imagesPath.isNotEmpty)
              Container(
                color: Colors.grey.shade700,
                height: MediaQuery.of(context).size.height * 0.09,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cubit.imagesPath.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.height * 0.09,
                          height: MediaQuery.of(context).size.height * 0.09,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                alignment: FractionalOffset.center,
                                image: FileImage(
                                    File(cubit.imagesPath[index].path)),
                              )),
                        ),
                        InkWell(
                            onTap: () {
                              cubit.removeOneImagesPath(index);
                              imagesPaths.removeAt(index);
                            },
                            child: Container(
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  color: Colors.grey.shade300,
                                ))),
                      ],
                    );
                  },
                ),
              ),
            Container(
              color:Get.isDarkMode?null: cubit.isRecording
                  ? Colors.white.withOpacity(0)
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  cubit.isRecording
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (!cubit.isEditComment)
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Image.asset(
                                    'assets/images/plus.png',
                                    width:
                                        MediaQuery.of(context).size.width / 17,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                onTap: () async {
                                  cubit.changeIsEditComment(false);
                                  await showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return Center(
                                            child: ChoosePhotoFrom(
                                                context: context,
                                                onTabCamera: () async {
                                                  Navigator.pop(ctx);
                                                  CommentCubit.get(context)
                                                      .changeImagesPath(
                                                          await getImage(
                                                              source:
                                                                  ImageSource
                                                                      .camera,
                                                              ));
                                                },
                                                onTabGallary: () async {
                                                  Navigator.pop(ctx);
                                                  CommentCubit.get(context)
                                                      .changeImagesPath(
                                                          await getImageMulti());
                                                }));
                                      });
                                },
                              ),
                            Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 45),
                                width: MediaQuery.of(context).size.width / 1.21,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:Get.isDarkMode?Colors.grey.shade700: HexColor('#f2f0f2'),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextForm(
                                  focusNode: focusNode,
                                  controller: textController,
                                  maxLines: null,
                                  keyType: TextInputType.multiline,
                                  isBorder: false,
                                  borderRadius: 10,
                                  onFocusBorder: 10,
                                  onChange: (value) {
                                    cubit.changeTextFieldComment(value);
                                  },
                                  hintText: 'type something...',
                                )),
                          ],
                        ),
                  (cubit.textFieldComment.trim() == '' &&
                          cubit.imagesPath.isEmpty)
                      ? isComment
                          ? CommentRecordClick(
                              focusNode: focusNode,
                              cubit: cubit,
                              postId: postItems['postId'].toString(),
                            )
                          : MessageRecordClick(
                              focusNode: focusNode,
                              cubit: cubit,
                    email: email,
                            )
                      : cubit.isLoadNewComment
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width / 15,
                              child: CircularProgressIndicator(
                                color: HexColor('#8C8198'),
                                strokeWidth: 3,
                              ))
                          : InkWell(
                              onTap: onSendTap,
                              child: Image.asset(
                                  'assets/images/send_gradiant.png',
                                  fit: BoxFit.fill,
                                  width:
                                      MediaQuery.of(context).size.width / 12),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
