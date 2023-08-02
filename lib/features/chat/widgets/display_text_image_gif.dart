import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/chat/widgets/video_player_item.dart';
import 'package:whatsapp_clone/share/enums/message_enum.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;

  const DisplayTextImageGIF({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    bool isPlaying = false;
    final AudioPlayer audioPlayer = AudioPlayer();
    return type == MessageEnum.text
        ? Text(
            message,
            style: myTheme.textTheme.labelMedium,
          )
        : type == MessageEnum.video
            ? VideoPlayerItem(videoUrl: message)
            : type == MessageEnum.audio
                ? StatefulBuilder(builder: (context, setState) {
                    return IconButton(
                      constraints: const BoxConstraints(minWidth: 100),
                      onPressed: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play(UrlSource(message));
                        }
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                      icon: Icon(
                          isPlaying ? Icons.pause_circle : Icons.play_circle),
                    );
                  })
                : CachedNetworkImage(
                    imageUrl: message,
                  );
  }
}
