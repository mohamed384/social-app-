import 'package:flutter/material.dart';
import 'package:story/story_page_view/story_page_view.dart';

class ShowStory extends StatefulWidget {
  const ShowStory({Key? key, required this.storyItems, required this.userItem,}) : super(key: key);
  final dynamic storyItems;
  final dynamic userItem;
  @override
  _ShowStoryState createState() => _ShowStoryState();
}

class _ShowStoryState extends State<ShowStory> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;

  @override
  void initState() {
    super.initState();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryPageView(
        itemBuilder: (context, pageIndex, storyIndex) {

          return Stack(
            children: [
              Positioned.fill(
                child: Container(color: Colors.black),
              ),
              Positioned.fill(
                child: Image.network(
                widget.storyItems['mediaUrl'][0],
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 44, left: 8),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.userItem['profilePhotoUrl']),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.userItem['name'],
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        gestureItemBuilder: (context, pageIndex, storyIndex) {
          return Stack(children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ]);
        },
        indicatorAnimationController: indicatorAnimationController,
        initialStoryIndex: (pageIndex) {
          return 0;
        },
        pageLength: widget.storyItems['mediaUrl'].length,
        storyLength: (int pageIndex) {
          return widget.storyItems['mediaUrl'].length;
        },
        onPageLimitReached: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
