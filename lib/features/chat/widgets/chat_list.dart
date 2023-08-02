import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';
import 'package:whatsapp_clone/share/enums/message_enum.dart';
import 'package:whatsapp_clone/share/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/share/widgets/loader.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const ChatList(
      {super.key, required this.recieverUserId, required this.isGroupChat});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref
        .read(messageReplyProvider.notifier)
        .update((state) => MessageReply(message, isMe, messageEnum));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.isGroupChat
            ? ref
                .read(chatControllerProvider)
                .groupChatStream(widget.recieverUserId)
            : ref
                .read(chatControllerProvider)
                .chatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback(
            (_) {
              messageController
                  .jumpTo(messageController.position.maxScrollExtent);
            },
          );
          return ListView.builder(
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final messageData = snapshot.data![index];
              var timeSent = DateFormat.Hm().format(messageData.timeSent);
              if (!messageData.isSeen &&
                  messageData.recieverId ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                    context, widget.recieverUserId, messageData.messageId);
              }
              return _MessageCard(
                message: messageData.text,
                date: timeSent,
                myMessage: messageData.senderId ==
                    FirebaseAuth.instance.currentUser!.uid,
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                userName: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                isSeen: messageData.isSeen,
                onSwipe: onSwipe,
              );
            },
          );
        });
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final bool myMessage;
  final bool isSeen;
  final Function onSwipe;
  final String repliedText;
  final String userName;
  final MessageEnum repliedMessageType;

  const _MessageCard({
    required this.message,
    required this.date,
    required this.myMessage,
    required this.type,
    required this.onSwipe,
    required this.repliedText,
    required this.userName,
    required this.repliedMessageType,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    final myTheme = Theme.of(context);
    return _MessageAlignAndConstraints(
      onSwipe: onSwipe,
      myMessage: myMessage,
      message: message,
      userName: userName,
      messageType: type,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: myMessage
            ? myTheme.colorScheme.primaryContainer
            : myTheme.colorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: _MessageCardStack(
          message: message,
          date: date,
          myMessage: myMessage,
          type: type,
          isReplying: isReplying,
          userName: userName,
          repliedMessageType: repliedMessageType,
          repliedText: repliedText,
          isSeen: isSeen,
        ),
      ),
    );
  }
}

class _MessageAlignAndConstraints extends StatelessWidget {
  final bool myMessage;
  final Widget child;
  final Function onSwipe;
  final String message;
  final String userName;
  final MessageEnum messageType;

  const _MessageAlignAndConstraints({
    required this.myMessage,
    required this.child,
    required this.onSwipe,
    required this.message,
    required this.userName,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      onLeftSwipe:
          myMessage ? () => onSwipe(message, myMessage, messageType) : () {},
      onRightSwipe:
          myMessage ? () {} : () => onSwipe(message, myMessage, messageType),
      child: Align(
        alignment: myMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MessageCardStack extends StatelessWidget {
  final String message;
  final String date;
  final bool myMessage;
  final MessageEnum type;
  final bool isReplying;
  final bool isSeen;
  final String userName;
  final String repliedText;
  final MessageEnum repliedMessageType;
  const _MessageCardStack(
      {required this.message,
      required this.date,
      required this.myMessage,
      required this.type,
      required this.isReplying,
      required this.userName,
      required this.repliedMessageType,
      required this.repliedText,
      required this.isSeen});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Column(
      children: [
        if (isReplying)
          Container(
            padding: type == MessageEnum.image
                ? const EdgeInsets.all(5.0)
                : type == MessageEnum.video
                    ? const EdgeInsets.all(5.0)
                    : const EdgeInsets.only(
                        top: 4,
                        left: 5,
                        right: 40,
                      ),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: myTheme.scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(
                  5,
                ),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
            ),
            child: Column(
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const VerticalSpacing(3),
                DisplayTextImageGIF(
                    message: repliedText, type: repliedMessageType),
                const VerticalSpacing(3),
              ],
            ),
          ),
        Stack(
          children: [
            _Message(
              message: message,
              type: type,
            ),
            _Time(
              date: date,
              myMessage: myMessage,
              isSeen: isSeen,
            ),
          ],
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String message;
  final MessageEnum type;
  const _Message({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: type == MessageEnum.image
          ? const EdgeInsets.all(5.0)
          : type == MessageEnum.video
              ? const EdgeInsets.all(5.0)
              : const EdgeInsets.only(
                  left: 10,
                  right: 50,
                  top: 5,
                  bottom: 20,
                ),
      child: DisplayTextImageGIF(message: message, type: type),
    );
  }
}

class _Time extends StatelessWidget {
  final String date;
  final bool myMessage;
  final bool isSeen;

  const _Time(
      {required this.date, required this.myMessage, required this.isSeen});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Positioned(
      bottom: 4,
      right: 5,
      child: Row(
        children: [
          Text(
            date,
            style: myTheme.textTheme.labelSmall,
          ),
          const SizedBox(
            width: 2,
          ),
          myMessage
              ? Icon(Icons.done_all,
                  size: 20, color: isSeen ? Colors.blue : Colors.grey)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
