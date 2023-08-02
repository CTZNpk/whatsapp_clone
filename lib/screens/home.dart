import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_clone/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/features/status/screens/status_contacts_screen.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';
import 'widgets/contacts_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabBarController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    tabBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _MobileAppBar(
          tabBarController: tabBarController,
        ),
        body: TabBarView(
          controller: tabBarController,
          children: const [
            ContactsList(),
            StatusContactsScreen(),
            Text('Calls'),
          ],
        ),
        floatingActionButton: _MyFloatingActionButton(
          tabBarController: tabBarController,
        ),
      ),
    );
  }
}

class _MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabBarController;
  const _MobileAppBar({required this.tabBarController});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'WhatsApp',
      ),
      centerTitle: false,
      actions: [
        _ActionIconButton(icon: Icons.search, onPressed: () {}),
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.grey,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Create Group'),
              onTap: () {
                Future(
                  () =>
                      Navigator.pushNamed(context, CreateGroupScreen.routeName),
                );
              },
            ),
          ],
        ),
      ],
      bottom: _MobileTabBar(
        tabBarController: tabBarController,
        tabs: const [
          Tab(
            text: 'CHAT',
          ),
          Tab(
            text: 'STATUS',
          ),
          Tab(
            text: 'CALLS',
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Function onPressed;
  const _ActionIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return IconButton(
      icon: Icon(icon),
      onPressed: () => onPressed(),
      color: myTheme.appBarTheme.foregroundColor,
    );
  }
}

class _MobileTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController tabBarController;
  const _MobileTabBar({
    required this.tabs,
    required this.tabBarController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return TabBar(
      controller: tabBarController,
      indicatorColor: myTheme.tabBarTheme.indicatorColor,
      indicatorWeight: 4,
      labelColor: myTheme.tabBarTheme.labelColor,
      unselectedLabelColor: myTheme.tabBarTheme.unselectedLabelColor,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: tabs,
    );
  }
}

class _MyFloatingActionButton extends StatelessWidget {
  final TabController tabBarController;
  const _MyFloatingActionButton({
    required this.tabBarController,
  });

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () async {
        if (tabBarController.index == 0) {
          Navigator.pushNamed(context, SelectContactScreen.routeName);
        } else {
          File? pickedImage = await pickImageFromGallery(context);
          if (pickedImage != null && context.mounted) {
            Navigator.pushNamed(context, ConfirmStatusScreen.routeName,
                arguments: pickedImage);
          }
        }
      },
      backgroundColor: myTheme.floatingActionButtonTheme.backgroundColor,
      foregroundColor: myTheme.floatingActionButtonTheme.foregroundColor,
      child: const Icon(Icons.comment),
    );
  }
}
