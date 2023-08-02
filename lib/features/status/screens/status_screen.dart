import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:whatsapp_clone/share/model/status_model.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class StatusScreen extends StatefulWidget {
  static const String routeName = '/status-screen';
  final Status status;
  const StatusScreen({super.key, required this.status});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyitems = [];

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyitems.add(StoryItem.pageImage(
        url: widget.status.photoUrl[i],
        controller: controller,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: storyitems.isEmpty
          ? const LoadingScreen()
          : StoryView(
              storyItems: storyitems,
              controller: controller,
              onComplete: () => Navigator.pop(context),
              onVerticalSwipeComplete: (direction){
                if(direction == Direction.down){
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
