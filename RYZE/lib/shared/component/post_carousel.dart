import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/shared/component/like_Animation.dart';
import 'package:ryze/shared/constants/constants.dart';

class PostCarousel extends StatefulWidget {
  final List listImage;
  final bool isCubit;
  final double photoHeight;
  final String postId;
  final Function? onDoubleTap;

  const PostCarousel({Key? key,
    required this.listImage,
    this.photoHeight = 400,
    this.isCubit = false,
    this.postId = '', this.onDoubleTap})
      : super(key: key);

  @override
  State<PostCarousel> createState() => _PostCarouselState();
}

class _PostCarouselState extends State<PostCarousel> {
  late int index2;

  bool isAnimated = false;
@override
  void initState() {
   index2 = 0;
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                items: [
                  for (var i in widget.listImage)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: i.runtimeType != XFile
                            ? CachedNetworkImage(
                          imageUrl: i,
                          fit: BoxFit.fill,
                        )
                            : Image.file(File(i.path), fit: BoxFit.fill))
                ],
                options: CarouselOptions(
                    height: widget.photoHeight,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    viewportFraction: 1.0,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        index2 = index;
                        if (widget.isCubit) {
                          AuthCubit
                              .get(context)
                              .index = index;
                        }
                      });
                    }),
              ),
              AnimatedOpacity(
                opacity: isAnimated ? 1 : 0,
                duration: const Duration(
                  milliseconds: 400,
                ),
                child: LikeAnimation(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 100,
                  ),
                  isAnimating: isAnimated,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  onEnd: () {
                    setState(() {
                      isAnimated = false;
                    });
                  },
                ),
              ),
            ],
          ),
          highlightColor:Colors.transparent,
          onDoubleTap: widget.postId == ''
              ? null
              : () async {
            setState(() {
              isAnimated = !isAnimated;
            });
            if (isAnimated) {
              await FirebaseFirestore.instance

                  .collection("userPosts")
                  .doc(widget.postId)
                  .set(
                {
                  'likes': {user!.uid: 'like'}
                },
                SetOptions(merge: true),
              );
            }
             widget.onDoubleTap;
          },
        ),
        if (widget.listImage.length != 1)
          DotsIndicator(
            dotsCount:
            widget.listImage.length > 10 ? 10 : widget.listImage.length,
            position: widget.isCubit
                ? AuthCubit
                .get(context)
                .index
                .toDouble()
                : index2.toDouble(),
            decorator: const DotsDecorator(
              activeColor: Colors.blue,
              spacing: EdgeInsets.all(3),
            ),
          )
      ],
    );
  }
}
