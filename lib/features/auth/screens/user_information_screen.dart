import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/share/spacing.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() =>
      _UserInformationScreenState();
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen>
{ final TextEditingController nameController = TextEditingController();
  File? image;
  bool loading = false;

  void toggleLoadingScreen() {
    setState(() {
      loading = !loading;
    });
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      toggleLoadingScreen();
      ref.read(authControllerProvider).saveUserDataToFirebase(
            context,
            name,
            image,
          );
    } else {
      showSnackBar(context: context, content: 'Provide User Name');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return loading
        ? const LoadingScreen()
        : Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const VerticalSpacing(30),
                    _ShowImageAndIcon(image: image,selectImage: selectImage,),
                    Row(
                      children: [
                        Container(
                          width: size.width * 0.85,
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                hintText: 'Enter your name'),
                          ),
                        ),
                        IconButton(
                          onPressed: storeUserData,
                          icon: const Icon(Icons.done),
                        ),
                      ],
                    )
                  ],
                ),
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
