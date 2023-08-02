import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/share/widgets/loader.dart';

class VideoPlayerItem extends StatefulWidget {
  const VideoPlayerItem({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  bool isPlay = false;
  late CachedVideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController.value.isInitialized? AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
               CachedVideoPlayer(videoPlayerController),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              onPressed: () {
                isPlay
                    ? videoPlayerController.pause()
                    : videoPlayerController.play();
                setState(() {
                  isPlay = !isPlay;
                });
              },
              icon: Icon(
                isPlay ? Icons.pause_circle : Icons.play_circle,
              ),
            ),
          ),
        ],
      ),
    ): const Loader();
  }
}
