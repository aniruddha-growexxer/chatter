import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  final List<StoryItem> storyItems;
  const StoryScreen({Key? key, required this.storyItems}) : super(key: key);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("More"),
      ),
      body: widget.storyItems.isEmpty
          ? Container(
              child: Text("Something went wrong"),
            )
          : StoryView(
              storyItems: widget.storyItems,
              onStoryShow: (s) {
                if (kDebugMode) {
                  log("Showing a story");
                }
              },
              onComplete: () {
                if (kDebugMode) {
                  log("Completed a cycle");
                }
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                log(direction.toString());
                switch (direction) {
                  case Direction.up:
                    log("user swiped up");
                    break;
                  case Direction.down:
                    if (direction!.index > 100) {
                      Navigator.pop(context);
                    }
                    break;
                  default:
                    break;
                }
                // if(direction==Direction.up){
                //   log("user swiped up");
                // }else if(direction==Direction.left){
                //   storyController.next();
                // }else if(direction==Direction.right){
                //   storyController.previous();
                // }
              },
              progressPosition: ProgressPosition.top,
              repeat: false,
              controller: storyController,
            ),
    );
  }
}
