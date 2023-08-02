import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/status/controller/status_controller.dart';
import 'package:whatsapp_clone/features/status/screens/status_screen.dart';
import 'package:whatsapp_clone/share/model/status_model.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class StatusContactsScreen extends ConsumerWidget {
  const StatusContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return FutureBuilder<List<Status>>(
      future: ref.read(statusControllerProvider).getStatus(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var statusData = snapshot.data![index];
            return Column(
              children: [
                InkWell(
                  onTap:(){
                    Navigator.pushNamed(context, StatusScreen.routeName, arguments: statusData);
                  },
                  child: ListTile(
                    title: _TileName(title: statusData.username),
                    leading: _LeadingImage(image: statusData.profilepic),
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
      },
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
