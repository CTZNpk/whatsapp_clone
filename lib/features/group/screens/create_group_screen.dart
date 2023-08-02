import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/group/controller/group_controller.dart';
import 'package:whatsapp_clone/features/group/widgets/select_contacts_group.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  static const String routeName = '/create-group';
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  File? image;
  final TextEditingController groupNameController = TextEditingController();

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void createGroup() {
    if (groupNameController.text.trim().isNotEmpty && image != null) {
      ref.read(groupControllerProvider).createGroup(
            context,
            groupNameController.text.trim(),
            image!,
            ref.read(selectedGroupContacts),
          );
      ref.read(selectedGroupContacts.notifier).update((state) => []);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Center(
        child: Column(
          children: [
            const VerticalSpacing(10),
            _ShowImageAndIcon(image: image, selectImage: selectImage),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: groupNameController,
                decoration: const InputDecoration(hintText: 'Enter Group Name'),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Select Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SelectContactsGroup(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createGroup,
        backgroundColor: Theme.of(context).tabBarTheme.labelColor,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ShowImageAndIcon extends StatelessWidget {
  final File? image;
  final VoidCallback selectImage;
  const _ShowImageAndIcon({
    required this.image,
    required this.selectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ShowImageOrDefault(image: image),
        Positioned(
          bottom: -10,
          left: 80,
          child: IconButton(
            onPressed: selectImage,
            icon: const Icon(Icons.add_a_photo),
          ),
        ),
      ],
    );
  }
}

class _ShowImageOrDefault extends StatelessWidget {
  final File? image;
  const _ShowImageOrDefault({required this.image});

  @override
  Widget build(BuildContext context) {
    return image == null
        ? const _DefaultAvatar()
        : _AvatarFromImage(image: image);
  }
}

class _AvatarFromImage extends StatelessWidget {
  const _AvatarFromImage({
    required this.image,
  });

  final File? image;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: FileImage(
        image!,
      ),
      radius: 64,
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundImage: NetworkImage(
        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
      ),
      radius: 64,
    );
  }
}
