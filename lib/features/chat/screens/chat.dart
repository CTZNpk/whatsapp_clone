import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/share/services/shared_firebase_storage_services.dart';
import 'package:whatsapp_clone/features/chat/widgets/chat_list.dart';
import 'package:whatsapp_clone/share/model/user_model.dart';
import 'package:whatsapp_clone/features/chat/widgets/message_bar.dart';

class ChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final String profilePic;
  final bool isGroupChat;

  const ChatScreen({
    super.key,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.isGroupChat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return Scaffold(
      appBar: _ChatAppBar(
        profilePic: profilePic,
        uid: uid,
        name: name,
        myTheme: myTheme,
        ref: ref,
        isGroupChat: isGroupChat,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              isGroupChat: isGroupChat,
              recieverUserId: uid,
            ),
          ),
          MessageBar(
            isGroupChat:isGroupChat,
            recieverUserId: uid,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.ref,
    required this.profilePic,
    required this.uid,
    required this.name,
    required this.myTheme,
    required this.isGroupChat,
  });
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final String profilePic;
  final String uid;
  final String name;
  final ThemeData myTheme;
  final WidgetRef ref;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.white,
      leading: _PopButtonWithProfilePic(profilePic: profilePic),
      title: _NameAndOnlineStatus(
          ref: ref, uid: uid, name: name, myTheme: myTheme, isGroupChat: isGroupChat,),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }
}

class _PopButtonWithProfilePic extends StatelessWidget {
  const _PopButtonWithProfilePic({
    required this.profilePic,
  });

  final String profilePic;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned(
          right: 17,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_sharp),
          ),
        ),
        Positioned(
          left: 21,
          top: 6,
          child: CircleAvatar(
            backgroundImage: NetworkImage(profilePic),
            radius: 18,
          ),
        ),
      ],
    );
  }
}

class _NameAndOnlineStatus extends StatelessWidget {
  const _NameAndOnlineStatus({
    required this.ref,
    required this.uid,
    required this.name,
    required this.myTheme,
    required this.isGroupChat,
  });

  final WidgetRef ref;
  final String uid;
  final String name;
  final ThemeData myTheme;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 50,
      child: isGroupChat
          ? Center(
            child: Text(
                name,
                style: myTheme.textTheme.labelLarge,
              ),
          )
          : StreamBuilder<UserModel>(
              stream: ref
                  .read(sharedFirebaseStorageServiceProvider)
                  .userDatabyId(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                return Center(
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: myTheme.textTheme.labelLarge,
                      ),
                      Text(
                        snapshot.data!.isOnline ? 'online' : 'offline',
                        style: myTheme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
