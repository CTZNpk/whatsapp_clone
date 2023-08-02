import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';
import 'package:whatsapp_clone/share/widgets/error.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class SelectContactScreen extends ConsumerStatefulWidget {
  static const routeName = '/select-contact';
  const SelectContactScreen({super.key});

  @override
  ConsumerState<SelectContactScreen> createState() =>
      _SelectContactScreenState();
}

class _SelectContactScreenState extends ConsumerState<SelectContactScreen> {
  bool showLoadingScreen = false;
  bool rePrintContacts = false;

  void selectContact(
      WidgetRef ref, ContactModel selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  void reloadPage() {
    return ref.refresh(getContactProvider);
  }

  void toggleLoadingScreen() {
    setState(() {
      showLoadingScreen = !showLoadingScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoadingScreen
        ? const LoadingScreen()
        : Scaffold(
            appBar: _AppBarContactScreen(
              reloadPage: reloadPage,
              toggleLoadingScreen: toggleLoadingScreen,
            ),
            body: ref.watch(getContactProvider).when(
                  data: (contactList) => _ContactTilesBuilder(
                    contactList: contactList,
                    selectContact: selectContact,
                  ),
                  error: (error, trace) => ErrorScreen(error: error.toString()),
                  loading: () => const LoadingScreen(),
                ),
          );
  }
}

class _AppBarContactScreen extends StatelessWidget
    implements PreferredSizeWidget {
  const _AppBarContactScreen(
      {required this.reloadPage, required this.toggleLoadingScreen});

  final Function reloadPage;
  final Function toggleLoadingScreen;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 30);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Select contact'),
      bottom: _SyncContactButton(
        reloadPage: reloadPage,
        toggleLoadingScreen: toggleLoadingScreen,
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert,
          ),
        ),
      ],
    );
  }
}

class _SyncContactButton extends ConsumerWidget implements PreferredSizeWidget {
  const _SyncContactButton(
      {required this.reloadPage, required this.toggleLoadingScreen});

  final Function reloadPage;
  final Function toggleLoadingScreen;
  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return Container(
      height: 30,
      color: myTheme.colorScheme.onSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Tap to sync contacts'),
          OutlinedButton(
            onPressed: () async {
              toggleLoadingScreen();
              await ref.read(selectContactControllerProvider).syncContacts();
              reloadPage();
              toggleLoadingScreen();
            },
            style: ButtonStyle(
              textStyle:
                  MaterialStatePropertyAll(myTheme.textTheme.labelMedium),
            ),
            child: const Row(
              children: [
                Text('sync'),
                Icon(Icons.sync),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ContactTilesBuilder extends ConsumerWidget {
  final List<ContactModel> contactList;
  final Function selectContact;
  const _ContactTilesBuilder(
      {required this.contactList, required this.selectContact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTheme = Theme.of(context);
    return ListView.builder(
      itemCount: contactList.length,
      itemBuilder: (context, index) {
        final contact = contactList[index];
        return InkWell(
          onTap: () => selectContact(ref, contact, context),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: ListTile(
              title: Text(
                contact.name,
                style: myTheme.textTheme.labelLarge,
              ),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(contact.profilePic),
                radius: 30,
              ),
            ),
          ),
        );
      },
    );
  }
}
