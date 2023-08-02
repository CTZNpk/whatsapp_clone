import 'dart:io';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    image = pickedImage != null ? File(pickedImage.path) : null;
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return image;
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    video = pickedVideo != null ? File(pickedVideo.path) : null;
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return video;
}

pickGif(BuildContext context) async {
  GiphyGif? gif;
  try {
    gif = await Giphy.getGif(
      context: context,
      apiKey: 'YKOjwMVlH14Q42mJpaj5A00KgXhrbJD4',
    );
  } catch (e) {
    showSnackBar(context: context, content: e.toString());
  }
  return gif;
}
