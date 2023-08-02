import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/screens/chat.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: ref.read(chatControllerProvider).chatGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var groupData = snapshot.data![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ChatScreen.routeName,
                                arguments: {
                                  'name': groupData.name,
                                  'uid': groupData.groupId,
                                  'profilePic': groupData.groupPic,
                                  'isGroupChat': true,
                                },
                              );
                            },
                            child: ListTile(
                              title: _TileName(title: groupData.name),
                              subtitle:
                                  _TileMessage(message: groupData.lastmessage),
                              leading: _LeadingImage(image: groupData.groupPic),
                              trailing: _TrailingTime(
                                time:
                                    DateFormat.Hm().format(groupData.timeSent),
                              ),
                            ),
                          ),
                          Divider(
                            color: myTheme.dividerColor,
                            indent: 85,
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            StreamBuilder(
              stream: ref.read(chatControllerProvider).chatContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingScreen();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ChatScreen.routeName,
                                arguments: {
                                  'name': chatContactData.name,
                                  'uid': chatContactData.contactId,
                                  'profilePic': chatContactData.profilePic,
                                  'isGroupChat': false,
                                },
                              );
                            },
                            child: ListTile(
                              title: _TileName(title: chatContactData.name),
                              subtitle: _TileMessage(
                                  message: chatContactData.lastMessage),
                              leading: _LeadingImage(
                                  image: chatContactData.profilePic),
                              trailing: _TrailingTime(
                                time: DateFormat.Hm()
                                    .format(chatContactData.timeSent),
                              ),
                            ),
                          ),
                          Divider(
                            color: myTheme.dividerColor,
                            indent: 85,
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TileName extends StatelessWidget {
  final String title;
  const _TileName({required this.title});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Text(
      title,
      style: myTheme.textTheme.labelLarge,
    );
  }
}

class _TileMessage extends StatelessWidget {
  final String message;
  const _TileMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: 6.0,
      ),
      child: Row(
        children: [
          _ContactListIcon(message: message),
          Text(
            message.length > 30 ? '${message.substring(0, 30)}.....' : message,
            style: myTheme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _ContactListIcon extends StatelessWidget {
  final String message;
  const _ContactListIcon({required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message) {
      case 'Photo':
        return const _ContactListIconPadding(icon: Icons.photo);
      case 'Video':
        return const _ContactListIconPadding(icon: Icons.videocam);
      case 'Audio':
        return const _ContactListIconPadding(icon: Icons.audio_file);
      case 'GIF':
        return const _ContactListIconPadding(icon: Icons.gif);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ContactListIconPadding extends StatelessWidget {
  final IconData icon;
  const _ContactListIconPadding({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 4.0,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 15,
      ),
    );
  }
}

class _LeadingImage extends StatelessWidget {
  final String image;
  const _LeadingImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(
        image,
      ),
    );
  }
}

class _TrailingTime extends StatelessWidget {
  final String time;
  const _TrailingTime({required this.time});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Text(
      time,
      style: myTheme.textTheme.labelSmall,
    );
  }
}
