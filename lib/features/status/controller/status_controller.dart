import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/status/services/status_service.dart';
import 'package:whatsapp_clone/share/model/status_model.dart';

final statusControllerProvider = Provider((ref) {
  final statusService = ref.read(statusServiceProvider);
  return StatusController(statusService: statusService, ref: ref);
});

class StatusController {
  final StatusService statusService;
  final ProviderRef ref;

  StatusController({
    required this.statusService,
    required this.ref,
  });

  Future addStatus(File file, BuildContext context) async {
    ref.watch(userDataAuthProvider).whenData((value) async {
      await statusService.uploadStatus(
          username: value!.name,
          profilePic: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusImage: file,
          context: context);
    });
  }

  Future<List<Status>> getStatus (BuildContext context) async{
    List<Status> statuses = await statusService.getStatus(context);
    return statuses;
  }
}
