import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ryze/shared/constants/constants.dart';

class CircleEditPhoto extends StatelessWidget {
  final List imagePath;

  const CircleEditPhoto({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleImage(
          width: 80.0,
          height: 80.0,
          image: imagePath.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        alignment: FractionalOffset.center,
                        image: FileImage(File(imagePath[0].path)),
                      )),
                )
              : Image.asset('assets/images/user.png'),
          paddingImage: 0,
        ),
        const Icon(
          Icons.camera_alt,
          color: iconColor,
        ),
      ],
    );
  }
}

class CircleImage extends StatelessWidget {
  final double width, height, paddingImage, borderRadius;
  final Widget image;
  final bool isShadow, isBorder;

  const CircleImage({
    Key? key,
    required this.width,
    required this.height,
    required this.image,
    required this.paddingImage,
    this.isShadow = true,
    this.isBorder = true,
    this.borderRadius = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Get.isDarkMode?Theme.of(context).scaffoldBackgroundColor: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: isBorder
              ? Border.all(
                  color: kPrimaryColor,
                  width: 1.5,
                )
              : null,
          boxShadow: isShadow
              ? [
                  BoxShadow(
                    color: Get.isDarkMode
                        ? Colors.black.withOpacity(0)
                        : Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: const Offset(0, 25),
                  ),
                ]
              : null),
      child: Padding(
        padding: EdgeInsets.all(paddingImage),
        child: image,
      ),
    );
  }
}
