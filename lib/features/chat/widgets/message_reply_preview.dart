import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';
import 'package:whatsapp_clone/share/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/share/spacing.dart';

class MessageReplyPreview extends ConsumerWidget {
  const MessageReplyPreview({super.key});

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe ? 'Me' : 'Opposite',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                child: const Icon(
                  Icons.close,
                  size: 16,
                ),
                onTap: () => cancelReply(ref),
              ),
            ],
          ),
          const VerticalSpacing(8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: DisplayTextImageGIF(
              message: messageReply.message,
              type: messageReply.messageEnum,
            ),
          ),
        ],
      ),
    );
  }
}
